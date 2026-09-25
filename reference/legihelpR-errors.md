# Errors raised by legihelpR API functions

Every API function stops with a classed condition when a request fails,
so callers can tell failures that are worth trying again later from ones
that will fail again unchanged. All of them inherit from
`legihelpR_error` and can be caught with
[`tryCatch()`](https://rdrr.io/r/base/conditions.html).

Temporary failures are retried automatically, up to 3 attempts per
request, before an error is raised: HTTP 429 and 503 responses, API
messages that plainly report rate limiting, and, for read-only
functions, HTTP 502 and 504 responses and network failures. Waits honor
LegiScan's `Retry-After` header and otherwise back off exponentially.
When the server asks for a longer wait than the
`legihelpR.max_retry_wait` option allows (60 seconds by default),
legihelpR stops instead of waiting; the requested wait is in the error's
`retry_after` field. Other failures stop immediately.

[`setMonitor()`](https://aberuiz.github.io/legihelpR/reference/setMonitor.md)
changes the monitor list of the account, so it is only retried after
responses that say the request was not handled (HTTP 429 and 503, or a
rate limit message). After a network failure or gateway error the change
may or may not have been applied; check
[`getMonitorList()`](https://aberuiz.github.io/legihelpR/reference/getMonitorList.md)
before repeating it.

LegiScan does not publish its error messages, so classes that depend on
the message are matched conservatively. Unrecognized API errors keep the
generic `legihelpR_api_error` class.

## Condition classes

- `legihelpR_rate_limited`:

  Too many requests. Temporary: wait and try again, or increase
  `options(legihelpR.request_interval)`.

- `legihelpR_unavailable`:

  HTTP 502, 503 or 504. Temporary.

- `legihelpR_network_error`:

  LegiScan could not be reached. Usually temporary.

- `legihelpR_quota_exceeded`:

  The key's query allowance is used up. Retrying will not help until it
  resets.

- `legihelpR_invalid_key`:

  LegiScan does not recognize the API key.

- `legihelpR_access_denied`:

  The account is not allowed to make the request, for example a disabled
  key, missing subscription, or HTTP 401 or 403.

- `legihelpR_invalid_request`:

  LegiScan rejected the request parameters, for example an unknown id or
  stale dataset access key.

- `legihelpR_invalid_response`:

  The response could not be read, for example a web page instead of
  JSON, or a download that is not a ZIP archive.

- `legihelpR_api_error`:

  Added to every error LegiScan reported with `status = "ERROR"`, and
  the only class for unrecognized ones.

- `legihelpR_http_error`:

  Added to every error from an HTTP 4xx or 5xx response.

## Condition fields

- `op`:

  LegiScan operation, e.g. `"getBill"`.

- `http_status`:

  HTTP status code, or `NA`.

- `api_message`:

  LegiScan's alert message, or `NA`.

- `retry_after`:

  Seconds LegiScan asked to wait, or `NA`.

API and dataset access keys are removed from messages and fields, and
conditions do not carry the request.

## Examples

``` r
if (FALSE) { # \dontrun{
bill <- tryCatch(
  getBill(billID = 1234),
  legihelpR_rate_limited = function(e) {
    Sys.sleep(max(e$retry_after, 60, na.rm = TRUE))
    getBill(billID = 1234)
  },
  legihelpR_quota_exceeded = function(e) stop("Out of queries this month")
)
} # }
```
