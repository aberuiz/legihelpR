test_that("setlegiKey does not treat comments or similar names as existing keys", {
  home <- withr::local_tempdir()
  withr::local_envvar(HOME = home)
  renv <- file.path(home, ".Renviron")
  original <- c(
    "# legiKey='commented-out'",
    "my_legiKey_backup='keep-me'"
  )
  writeLines(original, renv)

  expect_message(
    setlegiKey(fakeKey, install = TRUE),
    "has been stored"
  )
  lines <- readLines(renv, warn = FALSE)
  expect_contains(lines, original)
  expect_equal(sum(grepl("^legiKey=", lines)), 1)
})

test_that("setlegiKey overwrite preserves lookalike entries and creates a backup", {
  home <- withr::local_tempdir()
  withr::local_envvar(HOME = home)
  renv <- file.path(home, ".Renviron")
  oldKey <- paste(rep("A", 32), collapse = "")
  original <- c(
    "# legiKey='commented-out'",
    "my_legiKey_backup='keep-me'",
    paste0("  legiKey = '", oldKey, "'")
  )
  writeLines(original, renv)

  expect_message(
    expect_message(
      setlegiKey(fakeKey, install = TRUE, overwrite = TRUE),
      "will be backed up"
    ),
    "has been stored"
  )

  expect_equal(
    readLines(file.path(home, ".Renviron_backup"), warn = FALSE),
    original
  )
  lines <- readLines(renv, warn = FALSE)
  expect_contains(lines, original[1:2])
  expect_false(any(grepl(oldKey, lines, fixed = TRUE)))
  expect_equal(sum(grepl("^[[:space:]]*legiKey[[:space:]]*=", lines)), 1)
})

test_that("invalid API key errors do not echo supplied values", {
  invalidKey <- paste(rep("S", 31), collapse = "")
  error <- tryCatch(setlegiKey(invalidKey), error = identity)

  expect_s3_class(error, "error")
  expect_match(conditionMessage(error), "Invalid API Key")
  expect_false(grepl(invalidKey, conditionMessage(error), fixed = TRUE))
  expect_error(setlegiKey(c(fakeKey, fakeKey)), "Invalid API Key")
})

test_that("setlegiKey fails safely when HOME is unavailable", {
  withr::local_envvar(HOME = "")
  expect_error(
    setlegiKey(fakeKey, install = TRUE),
    "HOME is not set"
  )
})

test_that("installing a key preserves an unterminated Renviron entry", {
  testHome <- withr::local_tempdir()
  withr::local_envvar(c(HOME = testHome, legiKey = NA, LEGIHELP_TEST = NA))
  renv <- file.path(testHome, ".Renviron")

  for (lastLine in c("LEGIHELP_TEST=preserved", "# trailing comment")){
    writeChar(lastLine, renv, eos = NULL)
    suppressMessages(setlegiKey(fakeKey, install = TRUE))
    lines <- readLines(renv, warn = FALSE)
    expect_identical(lines, c(lastLine, paste0("legiKey='", fakeKey, "'")))
    readRenviron(renv)
    expect_identical(Sys.getenv("legiKey"), fakeKey)
  }
  expect_identical(Sys.getenv("LEGIHELP_TEST"), "preserved")
})
