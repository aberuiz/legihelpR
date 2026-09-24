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

# The API measures queries in UTF-8 bytes (confirmed live: "Full-text query
# too long, 1025 bytes of 1024 limit"). The legiscan.com search box is stricter.
maxQueryBytes <- 1024L

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
  # LegiScan rejects long queries; never truncate, since that changes the search.
  queryBytes <- nchar(enc2utf8(query), type = "bytes")
  if (queryBytes > maxQueryBytes){
    stop(
      sprintf(
        "`query` is %d bytes (UTF-8); LegiScan allows at most %d. Accented and other non-ASCII characters count as 2-4 bytes each",
        queryBytes, maxQueryBytes
      ),
      call. = FALSE
    )
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

#' Coerce a whole-number argument
#'
#' @param x A single number or string of digits.
#'
#' @returns The value as a double, or \code{NA} when it is not a single finite
#' whole number.
#'
#' @noRd
asWholeNumber <- function(x){
  if (length(x) != 1L) return(NA_real_)
  if (is.character(x)){
    if (is.na(x) || !grepl("^[0-9]+$", x)) return(NA_real_)
    x <- as.numeric(x)
  }
  if (!is.numeric(x) || is.na(x) || !is.finite(x) || x != floor(x)) return(NA_real_)
  as.numeric(x)
}

#' Check candidate LegiScan identifiers
#'
#' @param x Vector of identifiers, numeric or strings of digits.
#'
#' @returns Logical vector, TRUE for each positive whole number.
#'
#' @noRd
isValidId <- function(x){
  if (!is.numeric(x) && !is.character(x)) return(rep(FALSE, length(x)))
  vapply(x, function(v){
    v <- asWholeNumber(v)
    !is.na(v) && v >= 1
  }, logical(1), USE.NAMES = FALSE)
}

#' Validate a single LegiScan identifier
#'
#' @description
#' Guard clause for endpoints that take a single mandatory identifier (bill_id,
#' people_id, text_id, ...). LegiScan answers a missing or malformed id with a
#' generic error after a full network round-trip; checking locally fails fast
#' with a message that names the offending argument and spares the caller's
#' monthly quota.
#'
#' @param value The identifier, a whole number or string of digits.
#'
#' @param name The argument name, used verbatim in the error message.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateId <- function(value, name){
  if (is.null(value)){
    stop(sprintf("`%s` is required", name), call. = FALSE)
  }
  if (length(value) != 1L || !isValidId(value)){
    stop(sprintf("`%s` must be a single positive whole number", name), call. = FALSE)
  }
  invisible(NULL)
}

#' Validate a vector of LegiScan identifiers
#'
#' @param values Identifiers, whole numbers or strings of digits.
#'
#' @param name The argument name, used verbatim in the error message.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateIds <- function(values, name){
  if (is.null(values) || length(values) == 0L || anyNA(values)){
    stop(sprintf("Specify one or more %s to operate on", name), call. = FALSE)
  }
  if (!all(isValidId(values))){
    stop(sprintf("`%s` must contain only positive whole numbers", name), call. = FALSE)
  }
  invisible(NULL)
}

legiStates <- c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
  "DC", "US"
)

#' Normalize and validate a state abbreviation
#'
#' @param state Two letter state abbreviation, \code{DC}, or \code{US} for Congress.
#'
#' @param allowAll Whether \code{ALL} (nationwide search) is accepted.
#'
#' @returns The uppercase abbreviation.
#'
#' @noRd
normalizeState <- function(state, allowAll = FALSE){
  valid <- c(legiStates, if (allowAll) "ALL")
  if (rlang::is_string(state) && !is.na(state)){
    state <- toupper(trimws(state))
    if (state %in% valid) return(state)
  }
  stop(
    sprintf(
      "`state` must be a US state abbreviation, 'DC', or 'US'%s",
      if (allowAll) ", or 'ALL'" else ""
    ),
    call. = FALSE
  )
}

#' Validate a search year selector
#'
#' @param year 1=All, 2=Current, 3=Recent, 4=Prior, or an exact year.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateSearchYear <- function(year){
  value <- asWholeNumber(year)
  maxYear <- as.numeric(format(Sys.Date(), "%Y")) + 1
  if (is.na(value) || !(value %in% 1:4 || (value >= 1900 && value <= maxYear))){
    stop(
      "`year` must be 1 (all), 2 (current), 3 (recent), 4 (prior), or an exact year from 1900",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' Validate a dataset list year
#'
#' @param year Four digit year.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateDatasetYear <- function(year){
  value <- asWholeNumber(year)
  if (is.na(value) || value < 1000 || value > 9999){
    stop("`year` must be a 4 digit year", call. = FALSE)
  }
  invisible(NULL)
}

#' Normalize and validate a monitor list record filter
#'
#' @param record "current", "archived", or an exact year from 2010.
#'
#' @returns The record filter, lowercased when it is a keyword.
#'
#' @noRd
normalizeRecord <- function(record){
  if (rlang::is_string(record) && !is.na(record) &&
      tolower(record) %in% c("current", "archived")){
    return(tolower(record))
  }
  value <- asWholeNumber(record)
  if (is.na(value) || value < 2010){
    stop("`record` must be 'current', 'archived', or a year from 2010", call. = FALSE)
  }
  record
}

#' Validate a dataset access key
#'
#' @param accessKey access_key string from getDatasetList.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateAccessKey <- function(accessKey){
  if (!rlang::is_string(accessKey) || is.na(accessKey) || !nzchar(trimws(accessKey))){
    stop("`accessKey` must be a non-empty string from `getDatasetList`", call. = FALSE)
  }
  invisible(NULL)
}

#' Validate a destination file path
#'
#' @description
#' Checked before downloading so an unwritable path does not waste a request.
#'
#' @param file Destination file path.
#'
#' @returns Invisibly \code{NULL}.
#'
#' @noRd
validateOutputFile <- function(file){
  if (!rlang::is_string(file) || is.na(file) || !nzchar(file)){
    stop("`file` must be a non-empty file path", call. = FALSE)
  }
  if (dir.exists(file)){
    stop(sprintf("`file` is a directory: %s", file), call. = FALSE)
  }
  if (!dir.exists(dirname(path.expand(file)))){
    stop(sprintf("Directory for `file` does not exist: %s", dirname(file)), call. = FALSE)
  }
  invisible(NULL)
}
