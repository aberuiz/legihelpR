test_that("stallTimeout defaults to 60 seconds and rounds up to whole seconds", {
  withr::local_options(legihelpR.stall_timeout = NULL)
  expect_equal(stallTimeout(), 60)
  withr::local_options(legihelpR.stall_timeout = 5)
  expect_equal(stallTimeout(), 5)
  withr::local_options(legihelpR.stall_timeout = 0)
  expect_equal(stallTimeout(), 0)
  # curl would truncate 0.5 to 0, which means no limit at all.
  withr::local_options(legihelpR.stall_timeout = 0.5)
  expect_equal(stallTimeout(), 1)
  withr::local_options(legihelpR.stall_timeout = 1e300)
  expect_equal(stallTimeout(), .Machine$integer.max)
})

test_that("an invalid legihelpR.stall_timeout errors before any request", {
  for (bad in list(-1, "60", NA_real_, NA, Inf, c(1, 2), numeric(), TRUE)) {
    withr::local_options(legihelpR.stall_timeout = bad)
    expect_error(
      stallTimeout(),
      "`legihelpR.stall_timeout` option must be a non-negative number of seconds",
      fixed = TRUE
    )
    without_internet(
      expect_error(
        legiRequest(op = "getBill", id = 1, legiKey = fakeKey),
        "legihelpR.stall_timeout",
        fixed = TRUE
      )
    )
  }
})

# Options of the request legiRequest would send.
sentOptions <- function() {
  sent <- NULL
  httr2::local_mocked_responses(function(req) {
    sent <<- req$options
    httr2::response(
      200,
      headers = list("content-type" = "application/json"),
      body = charToRaw('{"status":"OK"}')
    )
  })
  legiRequest(op = "getBill", id = 1, legiKey = fakeKey)
  sent
}

test_that("requests carry the stall limit and no total time limit", {
  withr::local_options(legihelpR.stall_timeout = NULL)
  options <- sentOptions()
  expect_equal(options$low_speed_limit, 1)
  expect_equal(options$low_speed_time, 60)
  expect_null(options$timeout)
  expect_null(options$timeout_ms)
})

test_that("0 explicitly turns off curl's own stall limit", {
  withr::local_options(legihelpR.stall_timeout = 0)
  expect_equal(sentOptions()$low_speed_time, 0)
})

test_that("a stalled read is retried and ends as legihelpR_network_error", {
  silent <- local_silent_server()
  local_mocked_bindings(legiApiUrl = function() silent$url)
  withr::local_options(legihelpR.stall_timeout = 1)

  started <- Sys.time()
  cnd <- tryCatch(legiRequest(op = "getBill", id = 1, legiKey = fakeKey), error = function(e) e)
  elapsed <- as.numeric(difftime(Sys.time(), started, units = "secs"))

  expect_s3_class(cnd, c("legihelpR_network_error", "legihelpR_error"))
  expect_match(conditionMessage(cnd), "Operation too slow")
  expect_no_match(conditionMessage(cnd), fakeKey, fixed = TRUE)
  expect_no_match(conditionMessage(cnd), "may or may not")
  expect_equal(count_connections(silent$server), 3L)
  # 3 one-second stalls plus at most 2 + 4 seconds of backoff.
  expect_gte(elapsed, 3)
  expect_lt(elapsed, 30)
})

test_that("a stalled setMonitor is not retried and says the outcome is unknown", {
  silent <- local_silent_server()
  local_mocked_bindings(legiApiUrl = function() silent$url)
  withr::local_options(legihelpR.stall_timeout = 1)

  cnd <- tryCatch(
    setMonitor(billIDs = 1, action = "monitor", legiKey = fakeKey),
    error = function(e) e
  )

  expect_s3_class(cnd, c("legihelpR_network_error", "legihelpR_error"))
  expect_equal(cnd$op, "setMonitor")
  expect_match(conditionMessage(cnd), "Operation too slow")
  expect_match(conditionMessage(cnd), "may or may not have been applied")
  expect_no_match(conditionMessage(cnd), "Could not reach")
  expect_no_match(conditionMessage(cnd), fakeKey, fixed = TRUE)
  expect_equal(count_connections(silent$server), 1L)
})
