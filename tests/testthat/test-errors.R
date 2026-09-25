jsonResponse <- function(body, status = 200L, headers = list()) {
  httr2::response(
    status_code = status,
    headers = c(list(`Content-Type` = "application/json"), headers),
    body = charToRaw(body)
  )
}

apiError <- function(message, status = 200L, headers = list()) {
  jsonResponse(
    sprintf('{"status":"ERROR","alert":{"message":"%s"}}', message),
    status = status,
    headers = headers
  )
}

# Returns the condition legiRequest raises for a mocked response.
requestError <- function(resp, op = "getBill", ...) {
  httr2::local_mocked_responses(list(resp))
  tryCatch(
    legiRequest(op = op, id = 1, ..., legiKey = fakeKey),
    error = function(e) e
  )
}

test_that("API messages are classified conservatively", {
  # Messages confirmed from the live API.
  expect_equal(apiErrorCategory("Invalid API key"), "invalid_key")
  expect_equal(
    apiErrorCategory("Invalid API key format -- 127.0.0.1 -- /?key=short&op=getSessionList"),
    "invalid_key"
  )
  expect_equal(apiErrorCategory("Invalid bill id"), "invalid_request")
  # Mentions "query" and "limit" but is a parameter error, not an allowance.
  expect_equal(
    apiErrorCategory("Full-text query too long, 1025 bytes of 1024 limit"),
    "invalid_request"
  )

  expect_equal(apiErrorCategory("Monthly query limit exceeded"), "quota_exceeded")
  expect_equal(apiErrorCategory("Rate limit exceeded: 30000 queries per month"), "quota_exceeded")
  expect_equal(apiErrorCategory("Rate limit exceeded"), "rate_limited")
  expect_equal(apiErrorCategory("Too many requests, slow down"), "rate_limited")
  expect_equal(apiErrorCategory("API key disabled"), "access_denied")
  # A dataset access key is a request parameter, not the API key.
  expect_equal(apiErrorCategory("Invalid access key"), "invalid_request")
  expect_equal(apiErrorCategory("Something went wrong"), NA_character_)
  expect_equal(apiErrorCategory(NULL), NA_character_)
  expect_equal(apiErrorCategory(NA_character_), NA_character_)
})

test_that("retryable HTTP statuses are retried whatever the body says", {
  expect_true(isTransientResponse(httr2::response(429)))
  expect_true(isTransientResponse(httr2::response(503)))
  expect_true(isTransientResponse(httr2::response(429, headers = list(`Retry-After` = "2"))))
  # Allowance wording must not cancel a retry the status asks for.
  expect_true(isTransientResponse(apiError("Monthly query limit exceeded", status = 429)))
  expect_true(isTransientResponse(apiError("Invalid API key", status = 503)))
})

test_that("gateway errors are retried for reads but not state changes", {
  for (status in c(502, 504)) {
    expect_true(isTransientResponse(httr2::response(status)))
    expect_false(isTransientResponse(httr2::response(status), changesState = TRUE))
  }
  expect_true(isTransientResponse(httr2::response(429), changesState = TRUE))
  expect_true(isTransientResponse(httr2::response(503), changesState = TRUE))
})

test_that("permanent failures are not retried", {
  for (status in c(400, 401, 403, 404, 500)) {
    expect_false(isTransientResponse(httr2::response(status)))
  }
  expect_false(isTransientResponse(apiError("Invalid bill id")))
  expect_false(isTransientResponse(apiError("Invalid API key")))
  expect_false(isTransientResponse(apiError("Monthly query limit exceeded")))
  expect_false(isTransientResponse(apiError("Something went wrong")))
  expect_false(isTransientResponse(jsonResponse('{"status":"OK"}')))
  expect_false(isTransientResponse(
    httr2::response(200, headers = list(`Content-Type` = "application/zip"), body = charToRaw("PK"))
  ))
})

test_that("an API rate limit message on HTTP 200 is retried", {
  expect_true(isTransientResponse(apiError("Rate limit exceeded")))
  expect_true(isTransientResponse(apiError("Rate limit exceeded"), changesState = TRUE))
})

test_that("waits longer than legihelpR.max_retry_wait are not slept through", {
  long <- httr2::response(429, headers = list(`Retry-After` = "7200"))
  expect_false(isTransientResponse(long))
  withr::local_options(legihelpR.max_retry_wait = Inf)
  expect_true(isTransientResponse(long))
  withr::local_options(legihelpR.max_retry_wait = 10)
  expect_false(isTransientResponse(httr2::response(503, headers = list(`Retry-After` = "11"))))
  expect_true(isTransientResponse(httr2::response(503, headers = list(`Retry-After` = "10"))))
  # Unparseable headers fall back to backoff rather than stopping.
  expect_true(isTransientResponse(httr2::response(429, headers = list(`Retry-After` = "soon"))))
})

test_that("an invalid legihelpR.max_retry_wait errors", {
  withr::local_options(legihelpR.max_retry_wait = -1)
  expect_error(maxRetryWait(), "max_retry_wait")
  withr::local_options(legihelpR.max_retry_wait = "60")
  expect_error(maxRetryWait(), "max_retry_wait")
})

test_that("API errors get classes, fields, and hints", {
  cnd <- requestError(jsonResponse(
    '{"status":"ERROR","alert":{"message":"Invalid API key","contact":{"email":"api@legiscan.com"}}}'
  ))
  expect_s3_class(cnd, c("legihelpR_invalid_key", "legihelpR_api_error", "legihelpR_error"))
  expect_false(inherits(cnd, "legihelpR_http_error"))
  expect_match(conditionMessage(cnd), "API returned error: Invalid API key")
  expect_match(conditionMessage(cnd), "setlegiKey")
  expect_match(conditionMessage(cnd), "api@legiscan.com")
  expect_equal(cnd$op, "getBill")
  expect_equal(cnd$api_message, "Invalid API key")
  expect_equal(cnd$http_status, NA_integer_)
  expect_null(conditionCall(cnd))

  expect_s3_class(requestError(apiError("Invalid bill id")), "legihelpR_invalid_request")
  expect_s3_class(requestError(apiError("Monthly query limit exceeded")), "legihelpR_quota_exceeded")
  expect_s3_class(requestError(apiError("API key suspended")), "legihelpR_access_denied")
  # Exhausted retries on a rate limit message still say so.
  expect_s3_class(requestError(apiError("Rate limit exceeded")), "legihelpR_rate_limited")

  cnd <- requestError(apiError("Something went wrong"))
  expect_equal(class(cnd)[1:2], c("legihelpR_api_error", "legihelpR_error"))
  expect_match(conditionMessage(cnd), "API returned error: Something went wrong")

  cnd <- requestError(jsonResponse('{"status":"ERROR"}'))
  expect_s3_class(cnd, "legihelpR_api_error")
  expect_match(conditionMessage(cnd), "API returned error: status ERROR")
  expect_equal(cnd$api_message, NA_character_)
})

test_that("HTTP errors are classified by status", {
  cnd <- requestError(httr2::response(429, headers = list(`Retry-After` = "7200")))
  expect_s3_class(cnd, c("legihelpR_rate_limited", "legihelpR_http_error", "legihelpR_error"))
  expect_equal(cnd$http_status, 429L)
  expect_equal(cnd$retry_after, 7200)
  expect_match(conditionMessage(cnd), "HTTP 429 Too Many Requests")
  expect_match(conditionMessage(cnd), "2 hours.*max_retry_wait")

  cnd <- requestError(httr2::response(429))
  expect_equal(cnd$retry_after, NA_real_)
  expect_no_match(conditionMessage(cnd), "max_retry_wait")

  expect_s3_class(requestError(httr2::response(403)), "legihelpR_access_denied")
  expect_s3_class(requestError(httr2::response(401)), "legihelpR_access_denied")
  expect_s3_class(requestError(httr2::response(503)), "legihelpR_unavailable")
  expect_s3_class(requestError(httr2::response(504)), "legihelpR_unavailable")
  expect_s3_class(requestError(httr2::response(400)), "legihelpR_invalid_request")
  cnd <- requestError(httr2::response(500))
  expect_equal(class(cnd)[1:3], c("legihelpR_http_error", "legihelpR_error", "error"))
})

test_that("HTTP error bodies refine the class only for account problems", {
  cnd <- requestError(apiError("Monthly query limit exceeded", status = 429))
  expect_s3_class(cnd, c("legihelpR_quota_exceeded", "legihelpR_api_error", "legihelpR_http_error"))
  expect_match(conditionMessage(cnd), "HTTP 429 Too Many Requests: Monthly query limit exceeded")

  expect_s3_class(requestError(apiError("Invalid API key", status = 403)), "legihelpR_invalid_key")
  # The status wins over a request-level message.
  expect_s3_class(requestError(apiError("Invalid bill id", status = 503)), "legihelpR_unavailable")
  expect_s3_class(requestError(apiError("Invalid bill id", status = 404)), "legihelpR_invalid_request")
})

test_that("network failures are classified", {
  failure <- function(req) {
    rlang::error_cnd(
      class = c("httr2_failure", "httr2_error"),
      message = "Failed to perform HTTP request.",
      parent = simpleError("Could not resolve host: api.legiscan.com")
    )
  }
  httr2::local_mocked_responses(failure)
  cnd <- tryCatch(legiRequest(op = "getBill", id = 1, legiKey = fakeKey), error = function(e) e)
  expect_s3_class(cnd, c("legihelpR_network_error", "legihelpR_error"))
  expect_match(conditionMessage(cnd), "Could not resolve host")
  expect_no_match(conditionMessage(cnd), "getMonitorList")

  cnd <- tryCatch(
    legiRequest(op = "setMonitor", list = "1", action = "monitor", legiKey = fakeKey),
    error = function(e) e
  )
  expect_match(conditionMessage(cnd), "may or may not have been applied")
})

test_that("keys never appear in errors", {
  accessKey <- "0123456789abcdef0123456789abcdef"
  echoed <- sprintf(
    "Invalid API key format -- 127.0.0.1 -- /?key=%s&op=getDataset&access_key=%s",
    fakeKey, accessKey
  )
  cnds <- list(
    requestError(apiError(echoed), op = "getDataset", access_key = accessKey),
    requestError(apiError(echoed, status = 403), op = "getDataset", access_key = accessKey),
    # Keys that are not in a key= parameter are removed by value.
    requestError(apiError(paste("Bad", accessKey)), op = "getDataset", access_key = accessKey)
  )
  for (cnd in cnds) {
    text <- paste(c(conditionMessage(cnd), capture.output(str(unclass(cnd)))), collapse = "\n")
    expect_no_match(text, fakeKey, fixed = TRUE)
    expect_no_match(text, accessKey, fixed = TRUE)
    expect_match(cnd$api_message, "<redacted>", fixed = TRUE)
  }
  expect_match(conditionMessage(cnds[[3]]), "getDatasetList")
  expect_equal(redactSecrets("key=abc&op=x&access_key=def"), "key=<redacted>&op=x&access_key=<redacted>")
  expect_equal(redactSecrets("keyboard monkey"), "keyboard monkey")
})

test_that("unreadable responses are invalid_response errors", {
  html <- httr2::response(200, headers = list(`Content-Type` = "text/html"), body = charToRaw("<html>Down</html>"))
  cnd <- requestError(html)
  expect_s3_class(cnd, c("legihelpR_invalid_response", "legihelpR_error"))
  expect_match(conditionMessage(cnd), "not valid JSON")

  expect_s3_class(requestError(jsonResponse('{"bill":{}}')), "legihelpR_invalid_response")
  cnd <- requestError(jsonResponse("[1]"))
  expect_s3_class(cnd, "legihelpR_invalid_response")
  expect_match(conditionMessage(cnd), "without a status")
})

test_that("raw downloads must be ZIP archives", {
  zip <- httr2::response(
    200,
    headers = list(`Content-Type` = "application/zip"),
    body = as.raw(c(0x50, 0x4b, 0x03, 0x04))
  )
  httr2::local_mocked_responses(list(zip))
  expect_equal(legiRequest(op = "getDatasetRaw", legiKey = fakeKey, raw = TRUE), zip$body)

  html <- httr2::response(200, headers = list(`Content-Type` = "text/html"), body = charToRaw("<html></html>"))
  cnd <- requestError(html, op = "getDatasetRaw", raw = TRUE)
  expect_s3_class(cnd, "legihelpR_invalid_response")
  expect_match(conditionMessage(cnd), "text/html instead of a ZIP archive")

  # JSON errors from a raw download are classified like any other.
  expect_s3_class(
    requestError(apiError("Invalid access key"), op = "getDatasetRaw", raw = TRUE),
    "legihelpR_invalid_request"
  )
})
