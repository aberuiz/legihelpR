# Local validators catch predictable mistakes before a request spends quota.
# Endpoint checks run under without_internet so any request would fail loudly.

test_that("search queries are limited to 1024 UTF-8 bytes, never truncated", {
  # Limits confirmed live against the API: 1024 bytes pass, 1025 fail.
  expect_silent(validateSearchArgs(strrep("a", 1024), 1, 1))
  expect_silent(validateSearchArgs(strrep("\u00f1", 512), 1, 1))
  expect_error(
    validateSearchArgs(strrep("a", 1025), 1, 1),
    "`query` is 1025 bytes (UTF-8); LegiScan allows at most 1024",
    fixed = TRUE
  )
  # Each "\u00f1" is 2 bytes, so 513 of them exceed the limit.
  expect_error(
    validateSearchArgs(strrep("\u00f1", 513), 1, 1),
    "`query` is 1026 bytes",
    fixed = TRUE
  )
})

test_that("validateId accepts positive whole numbers and digit strings", {
  expect_silent(validateId(1633853, "billID"))
  expect_silent(validateId(1633853L, "billID"))
  expect_silent(validateId("1633853", "billID"))
  expect_error(validateId(NULL, "billID"), "`billID` is required")
  bad <- list(NA, NA_real_, Inf, 1.5, 0, -1, "12a", "", "0", "-3", "12.5",
              c(1, 2), numeric(), TRUE)
  for (value in bad) {
    expect_error(
      validateId(value, "billID"),
      "`billID` must be a single positive whole number"
    )
  }
})

test_that("validateIds checks every element", {
  expect_silent(validateIds(c(150334, 141690), "billIDs"))
  expect_silent(validateIds(c("150334", "141690"), "billIDs"))
  expect_error(validateIds(NULL, "billIDs"), "Specify one or more billIDs")
  expect_error(validateIds(c(1, NA), "billIDs"), "Specify one or more billIDs")
  expect_error(
    validateIds(c(1, 2.5), "billIDs"),
    "`billIDs` must contain only positive whole numbers"
  )
  expect_error(
    validateIds(c("1", "abc"), "billIDs"),
    "`billIDs` must contain only positive whole numbers"
  )
})

test_that("normalizeState uppercases valid codes and rejects others", {
  expect_equal(normalizeState("tx"), "TX")
  expect_equal(normalizeState("US"), "US")
  expect_equal(normalizeState("dc"), "DC")
  expect_equal(normalizeState("all", allowAll = TRUE), "ALL")
  expect_error(normalizeState("ALL"), "`state` must be")
  expect_error(normalizeState("ZZ"), "`state` must be")
  expect_error(normalizeState("Texas"), "`state` must be")
  expect_error(normalizeState(NA_character_), "`state` must be")
  expect_error(normalizeState(c("TX", "CA")), "`state` must be")
})

test_that("year selectors follow LegiScan's documented values", {
  for (year in list(1, 2, 3, 4, 1900, 2024, "2024")) {
    expect_silent(validateSearchYear(year))
  }
  for (year in list(0, 5, 1899, 2.5, NA, "abc", c(2, 3), 9999)) {
    expect_error(validateSearchYear(year), "`year` must be")
  }

  expect_silent(validateDatasetYear(2023))
  expect_silent(validateDatasetYear("2023"))
  for (year in list(23, 20233, "20x3", NA, 2023.5)) {
    expect_error(validateDatasetYear(year), "`year` must be a 4 digit year")
  }
})

test_that("normalizeRecord accepts keywords and years from 2010", {
  expect_equal(normalizeRecord("current"), "current")
  expect_equal(normalizeRecord("ARCHIVED"), "archived")
  expect_equal(normalizeRecord(2010), 2010)
  expect_error(normalizeRecord(2009), "`record` must be")
  expect_error(normalizeRecord("old"), "`record` must be")
  expect_error(normalizeRecord(NA), "`record` must be")
})

test_that("validateAccessKey rejects missing and blank keys", {
  expect_silent(validateAccessKey("abc123"))
  for (key in list("", "   ", NA_character_, 123, c("a", "b"))) {
    expect_error(validateAccessKey(key), "`accessKey` must be a non-empty string")
  }
})

test_that("validateOutputFile requires a writable destination", {
  dir <- withr::local_tempdir()
  expect_silent(validateOutputFile(file.path(dir, "out.zip")))
  expect_error(validateOutputFile(dir), "`file` is a directory")
  expect_error(
    validateOutputFile(file.path(dir, "missing", "out.zip")),
    "Directory for `file` does not exist"
  )
  expect_error(validateOutputFile(""), "`file` must be a non-empty file path")
  expect_error(validateOutputFile(NA_character_), "`file` must be a non-empty file path")
})

test_that("endpoints reject invalid inputs before any request", {
  missingDir <- file.path(withr::local_tempdir(), "missing", "x.zip")
  without_internet({
    expect_error(legiSearch(strrep("a", 1025), legiKey = fakeKey), "1025 bytes")
    expect_error(legiSearchRaw(strrep("a", 1025), legiKey = fakeKey), "1025 bytes")
    expect_error(legiSearch("tax", state = "ZZ", legiKey = fakeKey), "`state` must be")
    expect_error(legiSearchRaw("tax", year = 5, legiKey = fakeKey), "`year` must be")
    expect_error(legiSearch("tax", sessionID = "abc", legiKey = fakeKey), "`sessionID` must be")
    expect_error(getBill("abc", legiKey = fakeKey), "`billID` must be")
    expect_error(getPerson(-1, legiKey = fakeKey), "`peopleID` must be")
    expect_error(getRollCall(1.5, legiKey = fakeKey), "`rollCallID` must be")
    expect_error(getText(1, file = missingDir, legiKey = fakeKey), "Directory for `file`")
    expect_error(getAmendment(1, file = missingDir, legiKey = fakeKey), "Directory for `file`")
    expect_error(getSupplement(1, file = missingDir, legiKey = fakeKey), "Directory for `file`")
    expect_error(getMasterList(state = "Texas", legiKey = fakeKey), "`state` must be")
    expect_error(getMasterListRaw(sessionID = 0, legiKey = fakeKey), "`sessionID` must be")
    expect_error(getSessions(state = "ZZ", legiKey = fakeKey), "`state` must be")
    expect_error(getDatasetList(year = 23, legiKey = fakeKey), "4 digit year")
    expect_error(getDataset(1, "  ", legiKey = fakeKey), "`accessKey` must be")
    expect_error(getDataset(1, "abc", file = missingDir, legiKey = fakeKey), "Directory for `file`")
    expect_error(getDatasetRaw(1, "abc", file = missingDir, legiKey = fakeKey), "Directory for `file`")
    expect_error(setMonitor(c(1, 2.5), action = "monitor", legiKey = fakeKey), "`billIDs` must contain")
    expect_error(getMonitorList(record = 2009, legiKey = fakeKey), "`record` must be")
    expect_error(getMonitorListRaw(record = "old", legiKey = fakeKey), "`record` must be")
  })
})

test_that("session-scoped searches skip state and year validation", {
  requestArgs <- NULL
  local_mocked_bindings(
    legiRequest = function(...) {
      requestArgs <<- list(...)
      list(status = "OK", searchresult = list())
    }
  )
  expect_warning(
    legiSearch("tax", state = "ZZ", year = 99, sessionID = 2108, legiKey = fakeKey),
    "No results found"
  )
  expect_null(requestArgs$state)
  expect_equal(requestArgs$id, 2108)
})
