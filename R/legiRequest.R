#' Perform a legiscan API request
#'
#' @description
#' Internal helper for all API functions. Validates the API key, performs the
#' request against api.legiscan.com, and checks the API status of the response.
#'
#' @param op legiscan API operation name
#'
#' @param ... Query parameters for the operation (e.g. id, state, query)
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @param raw Return the raw response body instead of parsed JSON.
#' Used by `getDatasetRaw` which returns a binary ZIP stream.
#'
#' @returns Parsed JSON response as a list, or a raw vector when raw = TRUE
#'
#' @noRd
legiRequest <- function(op, ..., legiKey = NULL, raw = FALSE){

  # Callers validate operation-specific arguments.

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  validateApiKey(legiKey)

  req <- httr2::request("https://api.legiscan.com")
  req <- httr2::req_url_query(
    req,
    key = legiKey,
    op = op,
    ...,
    .multi = "explode"
  )
  req <- httr2::req_user_agent(req, "legihelpR (https://github.com/aberuiz/legihelpR)")
  # httr2's req_throttle() only paces the first attempt, so retries reserve
  # their send time from the same pacer as every other request.
  req <- httr2::req_retry(
    req,
    max_tries = 3,
    after = function(resp){
      after <- httr2::resp_retry_after(resp)
      if (is.na(after)) NA else reserveRequestSlot(after)
    },
    backoff = function(tries){
      reserveRequestSlot(round(min(stats::runif(1, 1, 2^tries), 60), 1))
    }
  )
  Sys.sleep(reserveRequestSlot())
  req <- httr2::req_perform(req)

  # Raw downloads can still return JSON errors.
  if (raw && !grepl("json", httr2::resp_content_type(req), ignore.case = TRUE)){
    return(httr2::resp_body_raw(req))
  }

  response <- httr2::resp_body_json(req)

  if (!is.list(response) || is.null(response$status)){
    stop("API returned an invalid response without a status.", call. = FALSE)
  }
  if (!identical(response$status, "OK")){
    alert <- if (is.list(response$alert)) response$alert$message else NULL
    if (!rlang::is_string(alert) || is.na(alert) || !nzchar(alert)){
      alert <- paste0("status ", paste(response$status, collapse = ", "))
    }
    stop(sprintf("API returned error: %s", alert), call. = FALSE)
  }

  return(response)
}

pacer <- new.env(parent = emptyenv())
pacer$lastRequest <- -Inf

#' Reserve the next LegiScan request slot
#'
#' @description
#' LegiScan limits the API to about 2 requests per second over a sliding
#' window. Every attempt, including retries and pagination, reserves a send
#' time at least `getOption("legihelpR.request_interval", 0.6)` seconds after
#' the previous one. The pacer is shared within one R process only; parallel
#' workers or separate sessions using the same key each keep their own.
#'
#' @param delay Minimum seconds to wait before sending, e.g. from a retry
#' backoff or `Retry-After` header.
#'
#' @returns Seconds to wait before sending the request.
#'
#' @noRd
reserveRequestSlot <- function(delay = 0){
  interval <- getOption("legihelpR.request_interval", 0.6)
  validInterval <- is.numeric(interval) &&
    length(interval) == 1L &&
    !is.na(interval) &&
    is.finite(interval) &&
    interval >= 0
  if (!validInterval){
    stop(
      "`legihelpR.request_interval` option must be a non-negative number of seconds",
      call. = FALSE
    )
  }

  now <- as.numeric(Sys.time())
  sendAt <- max(now + delay, pacer$lastRequest + interval)
  pacer$lastRequest <- sendAt
  sendAt - now
}

#' Validate a LegiScan API key
#'
#' @description
#' Shared validation for keys supplied directly to API functions or through
#' `setlegiKey()`. Invalid keys are deliberately not echoed in errors because
#' condition logs are often collected by CI and monitoring systems.
#'
#' @param key API key to validate.
#'
#' @returns Invisibly \code{NULL}; called for its side effect of erroring on invalid
#' input.
#'
#' @noRd
validateApiKey <- function(key){
  if (!rlang::is_string(key) || is.na(key) || nchar(key) != 32L){
    stop(
      paste0(
        "Invalid API Key: expected a non-missing 32-character string.\n",
        "Register <https://legiscan.com/user/register>\n",
        "Store with `setlegiKey`"
      ),
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' Validate search pagination inputs
#'
#' @param query Search query string.
#' @param page First result page to fetch.
#' @param maxPages Maximum number of pages to fetch.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateSearchArgs <- function(query, page, maxPages){
  if (!rlang::is_string(query) || is.na(query) || !nzchar(trimws(query))){
    stop("`query` must be a non-empty string", call. = FALSE)
  }

  validPage <- length(page) == 1L &&
    is.numeric(page) &&
    !is.na(page) &&
    is.finite(page) &&
    page >= 1 &&
    page == floor(page)
  if (!validPage){
    stop("`page` must be a positive whole number", call. = FALSE)
  }

  validMaxPages <- length(maxPages) == 1L &&
    is.numeric(maxPages) &&
    !is.na(maxPages) &&
    maxPages >= 1 &&
    ((is.finite(maxPages) && maxPages == floor(maxPages)) ||
      is.infinite(maxPages))
  if (!validMaxPages){
    stop("`maxPages` must be a positive whole number or `Inf`", call. = FALSE)
  }

  invisible(NULL)
}

#' Normalize and validate a dataset format
#'
#' @param format Dataset archive format.
#'
#' @returns The normalized lowercase format.
#'
#' @noRd
normalizeDatasetFormat <- function(format){
  if (!rlang::is_string(format) || is.na(format)){
    stop("`format` must be either 'json' or 'csv'", call. = FALSE)
  }
  format <- tolower(format)
  if (!format %in% c("json", "csv")){
    stop("`format` must be either 'json' or 'csv'", call. = FALSE)
  }
  format
}

#' Require that a mandatory argument was supplied
#'
#' @description
#' Guard clause for endpoints that take a single mandatory identifier (bill_id,
#' people_id, text_id, ...). LegiScan answers a missing id with a generic error
#' after a full network round-trip; checking locally fails fast with a message
#' that names the offending argument and spares the caller's monthly quota.
#'
#' @param value The argument value to check.
#'
#' @param name The argument name, used verbatim in the error message.
#'
#' @returns Invisibly \code{NULL}; called for its side effect of erroring on \code{NULL}.
#'
#' @noRd
requireArg <- function(value, name){
  if (is.null(value)){
    stop(sprintf("`%s` is required", name), call. = FALSE)
  }
  invisible(NULL)
}
