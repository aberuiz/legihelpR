# These use the reserved .invalid domain, so even a broken guard reaches nothing.
test_that("with_mock_dir refuses to record when the directory is missing", {
  expect_error(
    with_mock_dir("no-such-fixtures", stop("expression was evaluated")),
    "refusing to record"
  )
  expect_false(dir.exists(test_path("no-such-fixtures")))
})

test_that("a missing mock stops without reaching the network", {
  fixtures <- list.files(test_path("fixtures"))
  with_mock_dir("fixtures", {
    expect_error(
      httr2::req_perform(httr2::request("https://legihelpr-test.invalid/no-mock")),
      class = "httptest2_request"
    )
  })
  expect_identical(list.files(test_path("fixtures")), fixtures)
})

test_that("an unmocked request goes to the closed local proxy", {
  expect_error(
    httr2::req_perform(httr2::request("https://legihelpr-test.invalid/")),
    class = "httr2_failure"
  )
  cnd <- tryCatch(
    httr2::req_perform(httr2::request("https://legihelpr-test.invalid/")),
    error = function(e) e
  )
  expect_match(conditionMessage(cnd$parent), "127.0.0.1", fixed = TRUE)
})

test_that("the real API key is not available to tests", {
  expect_identical(Sys.getenv("legiKey"), "")
})
