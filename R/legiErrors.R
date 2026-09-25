#' Errors raised by legihelpR API functions
#'
#' @description
#' Every API function stops with a classed condition when a request fails, so
#' callers can tell failures that are worth trying again later from ones that
#' will fail again unchanged. All of them inherit from \code{legihelpR_error}
#' and can be caught with \code{tryCatch()}.
#'
#' Temporary failures are retried automatically, up to 3 attempts per request,
#' before an error is raised: HTTP 429 and 503 responses, API messages that
#' plainly report rate limiting, and, for read-only functions, HTTP 502 and
#' 504 responses and network failures. Waits honor LegiScan's
#' \code{Retry-After} header and otherwise back off exponentially. When the
#' server asks for a longer wait than the \code{legihelpR.max_retry_wait}
#' option allows (60 seconds by default), legihelpR stops instead of waiting;
#' the requested wait is in the error's \code{retry_after} field. Other
#' failures stop immediately.
#'
#' \code{setMonitor()} changes the monitor list of the account, so it is only
#' retried after responses that say the request was not handled (HTTP 429 and
#' 503, or a rate limit message). After a network failure or gateway error the
#' change may or may not have been applied; check \code{getMonitorList()}
#' before repeating it.
#'
#' LegiScan does not publish its error messages, so classes that depend on
#' the message are matched conservatively. Unrecognized API errors keep the
#' generic \code{legihelpR_api_error} class.
#'
#' @section Condition classes:
#' \describe{
#'   \item{\code{legihelpR_rate_limited}}{Too many requests. Temporary: wait
#'   and try again, or increase \code{options(legihelpR.request_interval)}.}
#'   \item{\code{legihelpR_unavailable}}{HTTP 502, 503 or 504. Temporary.}
#'   \item{\code{legihelpR_network_error}}{LegiScan could not be reached.
#'   Usually temporary.}
#'   \item{\code{legihelpR_quota_exceeded}}{The key's query allowance is used
#'   up. Retrying will not help until it resets.}
#'   \item{\code{legihelpR_invalid_key}}{LegiScan does not recognize the API
#'   key.}
#'   \item{\code{legihelpR_access_denied}}{The account is not allowed to make
#'   the request, for example a disabled key, missing subscription, or HTTP
#'   401 or 403.}
#'   \item{\code{legihelpR_invalid_request}}{LegiScan rejected the request
#'   parameters, for example an unknown id or stale dataset access key.}
#'   \item{\code{legihelpR_invalid_response}}{The response could not be read,
#'   for example a web page instead of JSON, or a download that is not a ZIP
#'   archive.}
#'   \item{\code{legihelpR_api_error}}{Added to every error LegiScan reported
#'   with \code{status = "ERROR"}, and the only class for unrecognized ones.}
#'   \item{\code{legihelpR_http_error}}{Added to every error from an HTTP 4xx
#'   or 5xx response.}
#' }
#'
#' @section Condition fields:
#' \describe{
#'   \item{\code{op}}{LegiScan operation, e.g. \code{"getBill"}.}
#'   \item{\code{http_status}}{HTTP status code, or \code{NA}.}
#'   \item{\code{api_message}}{LegiScan's alert message, or \code{NA}.}
#'   \item{\code{retry_after}}{Seconds LegiScan asked to wait, or \code{NA}.}
#' }
#' API and dataset access keys are removed from messages and fields, and
#' conditions do not carry the request.
#'
#' @examples
#' \dontrun{
#' bill <- tryCatch(
#'   getBill(billID = 1234),
#'   legihelpR_rate_limited = function(e) {
#'     Sys.sleep(max(e$retry_after, 60, na.rm = TRUE))
#'     getBill(billID = 1234)
#'   },
#'   legihelpR_quota_exceeded = function(e) stop("Out of queries this month")
#' )
#' }
#'
#' @name legihelpR-errors
NULL

# Operations that change account state. They are not retried when the request
# may already have been applied.
stateChangingOps <- "setMonitor"

#' Decide whether a response is worth another attempt
#'
#' @description
#' Used as the `is_transient` callback of `httr2::req_retry()`. The HTTP status
#' decides retries; message text only ever adds a retry for an HTTP 200 API
#' error that plainly reports rate limiting. A message can never cancel a
#' retry for a retryable status, since wording such as "limit exceeded" is too
#' ambiguous to tell a per-second limit from an exhausted allowance.
#'
#' @param resp An httr2 response.
#'
#' @param changesState Whether the request changes account state.
#'
#' @returns \code{TRUE} to retry the request.
#'
#' @noRd
isTransientResponse <- function(resp, changesState = FALSE){
  status <- httr2::resp_status(resp)
  # Gateway errors and network failures may come after the request was
  # applied, so only reads retry them.
  retryStatuses <- if (changesState) c(429, 503) else c(429, 502, 503, 504)
  transient <- status %in% retryStatuses ||
    (status < 300 && identical(apiErrorCategory(readApiAlert(resp)$message), "rate_limited"))
  # A wait beyond the limit (e.g. until an allowance resets) is reported
  # rather than slept through.
  transient && !retryWaitTooLong(retryAfterSeconds(resp))
}

#' Seconds a response asks the client to wait
#'
#' @param resp An httr2 response.
#'
#' @returns Seconds from the \code{Retry-After} header, or \code{NA}.
#'
#' @noRd
retryAfterSeconds <- function(resp){
  after <- tryCatch(
    suppressWarnings(httr2::resp_retry_after(resp)),
    error = function(e) NA_real_
  )
  if (length(after) != 1L || !is.numeric(after) || !is.finite(after)) NA_real_ else max(after, 0)
}

#' Check a server-requested wait against `legihelpR.max_retry_wait`
#'
#' @param after Seconds requested, or \code{NA}.
#'
#' @returns \code{TRUE} when the wait is longer than legihelpR will sleep.
#'
#' @noRd
retryWaitTooLong <- function(after){
  !is.na(after) && after > maxRetryWait()
}

maxRetryWait <- function(){
  maxWait <- getOption("legihelpR.max_retry_wait", 60)
  validMaxWait <- is.numeric(maxWait) &&
    length(maxWait) == 1L &&
    !is.na(maxWait) &&
    maxWait >= 0
  if (!validMaxWait){
    stop(
      "`legihelpR.max_retry_wait` option must be a non-negative number of seconds",
      call. = FALSE
    )
  }
  maxWait
}

#' Read the alert from a LegiScan error body
#'
#' @description
#' Error bodies are small, so large bodies such as dataset downloads are not
#' parsed.
#'
#' @param resp An httr2 response.
#'
#' @returns A list with \code{message} and \code{contact}, or \code{NULL}.
#'
#' @noRd
readApiAlert <- function(resp){
  if (!httr2::resp_has_body(resp) ||
      !isTRUE(grepl("json", httr2::resp_content_type(resp), ignore.case = TRUE)) ||
      length(httr2::resp_body_raw(resp)) > 65536L){
    return(NULL)
  }
  body <- tryCatch(httr2::resp_body_json(resp), error = function(e) NULL)
  if (!is.list(body) || identical(body$status, "OK")) return(NULL)
  alertFromBody(body)
}

alertFromBody <- function(body){
  alert <- if (is.list(body)) body$alert else NULL
  if (!is.list(alert)) return(NULL)
  message <- alert$message
  if (!rlang::is_string(message) || is.na(message) || !nzchar(message)) message <- NULL
  contact <- if (is.list(alert$contact)) alert$contact$email else NULL
  if (!rlang::is_string(contact) || is.na(contact)) contact <- NULL
  list(message = message, contact = contact)
}

#' Classify a LegiScan alert message
#'
#' @description
#' Confirmed messages include "Invalid API key", "Invalid API key format",
#' "Invalid bill id", and "Full-text query too long, 1025 bytes of 1024
#' limit". Others are matched on unambiguous wording only. Categories are
#' checked in order, so account problems win over request and rate problems.
#'
#' @param message Alert message, or \code{NULL}.
#'
#' @returns A category name, or \code{NA} when unrecognized.
#'
#' @noRd
apiErrorCategory <- function(message){
  if (!rlang::is_string(message) || is.na(message)) return(NA_character_)
  patterns <- c(
    invalid_key = "\\binvalid api key\\b|\\bunknown api key\\b|\\bapi key (is )?(invalid|unknown|not recognized)\\b",
    # Needs allowance wording: "rate limit exceeded" alone may be per second,
    # and "query too long ... 1024 limit" is a parameter error.
    quota_exceeded = "\\bquota\\b|\\bmonthly\\b|\\bper month\\b|\\ballowance\\b|\\bquery limit\\b",
    access_denied = "\\b(disabled|suspended|revoked|banned|forbidden|access denied|not authori[sz]ed|unauthori[sz]ed|not permitted|permission|subscription)\\b",
    invalid_request = "^\\W*(invalid|unknown|missing|unrecognized|bad)\\b|\\btoo long\\b|\\bnot found\\b|\\brequired\\b",
    rate_limited = "\\brate.?limit|\\btoo many (requests|queries)\\b|\\bper second\\b|\\bslow down\\b|\\bthrottl"
  )
  for (category in names(patterns)){
    if (grepl(patterns[[category]], message, ignore.case = TRUE, perl = TRUE)) return(category)
  }
  NA_character_
}

httpErrorCategory <- function(status){
  if (status == 429) return("rate_limited")
  if (status %in% c(502, 503, 504)) return("unavailable")
  if (status %in% c(401, 403)) return("access_denied")
  if (status %in% c(400, 414, 422)) return("invalid_request")
  NA_character_
}

#' Remove API and dataset access keys from text
#'
#' @description
#' LegiScan can echo the request URL in alert messages, e.g. "Invalid API key
#' format -- <ip> -- /?key=...&op=...".
#'
#' @param text Text to clean.
#'
#' @param secrets Key values to remove wherever they appear.
#'
#' @returns The text with keys replaced by \code{<redacted>}.
#'
#' @noRd
redactSecrets <- function(text, secrets = NULL){
  if (!rlang::is_string(text) || is.na(text)) return(text)
  for (secret in secrets){
    # Very short values would redact unrelated text.
    if (rlang::is_string(secret) && !is.na(secret) && nchar(secret) >= 8L){
      text <- gsub(secret, "<redacted>", text, fixed = TRUE)
    }
  }
  gsub("((?:access_)?key=)[^&#\\s]+", "\\1<redacted>", text, ignore.case = TRUE, perl = TRUE)
}

#' Stop with a classed legihelpR error
#'
#' @description
#' Built with base \code{stop()} rather than \code{rlang::abort()}: rlang prints
#' a backtrace in non-interactive sessions, and it would show a key passed
#' literally as an argument.
#'
#' @noRd
stopLegi <- function(category, message, op, httpStatus = NA_integer_,
                     apiMessage = NULL, apiError = FALSE,
                     retryAfter = NA_real_, hints = NULL){
  classes <- unique(c(
    paste0("legihelpR_", category),
    if (apiError) "legihelpR_api_error",
    if (!is.na(httpStatus) && httpStatus >= 400) "legihelpR_http_error",
    "legihelpR_error", "error", "condition"
  ))
  cnd <- structure(
    class = classes,
    list(
      message = paste(c(message, hints), collapse = "\n"),
      call = NULL,
      op = op,
      http_status = as.integer(httpStatus),
      api_message = if (is.null(apiMessage)) NA_character_ else apiMessage,
      retry_after = retryAfter
    )
  )
  stop(cnd)
}

errorHints <- function(category, op, contact = NULL){
  hint <- switch(
    category,
    invalid_key = "Check the key passed as `legiKey` or stored with `setlegiKey()`. Repeating the request will not help.",
    quota_exceeded = "The API key's query allowance appears to be used up; requests will keep failing until it resets. Repeating the request will not help.",
    access_denied = "The account for this API key is not allowed to make this request. Check the account status and subscription at legiscan.com.",
    invalid_request = if (op %in% c("getDataset", "getDatasetRaw")){
      "Repeating the same request will fail again. If `accessKey` came from an older `getDatasetList()` result, request a fresh one."
    } else {
      "Repeating the same request will fail again."
    },
    rate_limited = "Wait before trying again, or increase `options(legihelpR.request_interval)`.",
    unavailable = "LegiScan appears to be temporarily unavailable. Try again later.",
    network_error = "Check the network connection and try again.",
    NULL
  )
  if (op %in% stateChangingOps && category %in% c("network_error", "unavailable", "http_error")){
    hint <- c(hint, "The change may or may not have been applied. Check `getMonitorList()` before repeating it.")
  }
  if (!is.null(contact) && category %in% c("invalid_key", "quota_exceeded", "access_denied")){
    hint <- c(hint, paste0("LegiScan API support: ", contact))
  }
  hint
}

#' Stop for a status ERROR body
#'
#' @param body Parsed response body.
#'
#' @param op LegiScan operation.
#'
#' @param secrets Key values to redact.
#'
#' @noRd
stopApiError <- function(body, op, secrets){
  alert <- alertFromBody(body)
  apiMessage <- redactSecrets(alert$message, secrets)
  shown <- apiMessage
  if (is.null(shown)){
    shown <- paste0("status ", paste(body$status, collapse = ", "))
  }
  category <- apiErrorCategory(apiMessage)
  if (is.na(category)) category <- "api_error"
  stopLegi(
    category,
    sprintf("API returned error: %s", shown),
    op = op,
    apiMessage = apiMessage,
    apiError = TRUE,
    hints = errorHints(category, op, alert$contact)
  )
}

#' Stop for an HTTP error response
#'
#' @description
#' The HTTP status wins except when the body names an account problem (bad
#' key, used-up allowance, restricted account), which retrying cannot fix.
#'
#' @param resp An httr2 response with a 4xx or 5xx status.
#'
#' @noRd
stopHttpError <- function(resp, op, secrets){
  status <- httr2::resp_status(resp)
  alert <- readApiAlert(resp)
  apiMessage <- redactSecrets(alert$message, secrets)
  bodyCategory <- apiErrorCategory(apiMessage)
  category <- if (bodyCategory %in% c("invalid_key", "quota_exceeded", "access_denied")){
    bodyCategory
  } else {
    httpErrorCategory(status)
  }
  if (is.na(category)) category <- if (is.na(bodyCategory)) "http_error" else bodyCategory

  retryAfter <- retryAfterSeconds(resp)
  hints <- errorHints(category, op, alert$contact)
  if (retryWaitTooLong(retryAfter)){
    hints <- c(
      sprintf(
        "LegiScan asked to wait %s before retrying, longer than the `legihelpR.max_retry_wait` option (%s seconds), so legihelpR stopped instead of waiting.",
        formatWait(retryAfter), format(maxRetryWait())
      ),
      hints
    )
  }
  desc <- httr2::resp_status_desc(resp)
  stopLegi(
    category,
    paste0(
      "LegiScan returned HTTP ", status,
      if (!is.na(desc)) paste0(" ", desc),
      if (!is.null(apiMessage)) paste0(": ", apiMessage)
    ),
    op = op,
    httpStatus = status,
    apiMessage = apiMessage,
    apiError = !is.null(alert),
    retryAfter = retryAfter,
    hints = hints
  )
}

stopNetworkError <- function(cnd, op, secrets){
  detail <- if (inherits(cnd$parent, "condition")) conditionMessage(cnd$parent) else conditionMessage(cnd)
  stopLegi(
    "network_error",
    paste0("Could not reach LegiScan: ", redactSecrets(detail, secrets)),
    op = op,
    hints = errorHints("network_error", op)
  )
}

formatWait <- function(seconds){
  if (seconds < 120) return(sprintf("%g seconds", round(seconds)))
  if (seconds < 7200) return(sprintf("%g minutes", round(seconds / 60)))
  sprintf("%g hours", round(seconds / 3600, 1))
}
