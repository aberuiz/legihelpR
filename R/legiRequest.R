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

  # legiRequest cannot enforce required parameters itself: which ones matter is
  # per-operation (some need an id, others a state, query, etc.). The callers
  # own that check via requireArg() below.

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (is.null(legiKey) || nchar(legiKey)!=32){
    stop(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"), call. = FALSE)
  }

  req <- httr2::request("https://api.legiscan.com") |>
    httr2::req_url_query(
      key = legiKey,
      op = op,
      ...,
      .multi = "explode"
    ) |>
    httr2::req_user_agent("legihelpR (https://github.com/aberuiz/legihelpR)") |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_throttle(capacity = 30, fill_time_s = 60) |>
    httr2::req_perform()

  # error responses come back as JSON even for raw operations
  if (raw && !grepl("json", httr2::resp_content_type(req))){
    return(httr2::resp_body_raw(req))
  }

  response <- httr2::resp_body_json(req)

  if (!is.null(response$status) && response$status != "OK"){
    stop(sprintf("API returned error: %s", response$alert$message), call. = FALSE)
  }

  return(response)
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
#' @returns Invisibly `NULL`; called for its side effect of erroring on `NULL`.
#'
#' @noRd
requireArg <- function(value, name){
  if (is.null(value)){
    stop(sprintf("`%s` is required", name), call. = FALSE)
  }
  invisible(NULL)
}
