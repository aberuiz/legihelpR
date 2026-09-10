#' Return raw search results from legiscan's database
#'
#' @description
#' Return search results from legiscan's full text engine with simplified details,
#' 2000 results at a time. Returns relevance, bill_id, and change_hash only,
#' appropriate for automated keyword monitoring. Check legiscan.com for specific search syntax for more details.
#'
#' @param query Enter your search text. Your query may use grammatically correct spacing. Use legiscan's search syntax for more powerful results.
#'
#' @param state Search the entire nation by default with 'ALL' or specify state
#' using letter abbreviations. Ignored when `sessionID` is supplied
#'
#' @param year Should be an integer. 1=All, 2=Current, 3=Recent, 4=Prior,
#' >1900=Exact Year. Ignored when `sessionID` is supplied
#'
#' @param sessionID Limit search to specific session with a session_id
#'
#' @param page Default is set to return Page 1. `legiSearchRaw` will paginate and include results.
#'
#' @param maxPages Maximum number of pages to fetch. Each page is one API query
#' against your monthly quota. Use `Inf` to fetch every page.
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A data frame (tibble) of search results combined across fetched
#' pages, with \code{relevance}, \code{bill_id}, and \code{change_hash}. When no results are
#' found, a warning is issued and a zero-row tibble with these columns is returned.
#'
#' @examples
#' \dontrun{
#' legiSearchRaw(
#'   query = "intro:month AND wage theft",
#'   state = "TX"
#' )
#' }
#'
#' @export
legiSearchRaw <- function(query = NULL, state = "ALL", year = 2, sessionID = NULL, page = 1, maxPages = 10, legiKey = NULL){

  validateSearchArgs(query, page, maxPages)

  all_data <- list()
  pagesFetched <- 0
  requestState <- if (is.null(sessionID)) state else NULL
  requestYear <- if (is.null(sessionID)) year else NULL

  while (TRUE) {
    response <- legiRequest(
      op = "getSearchRaw",
      state = requestState,
      query = query,
      year = requestYear,
      id = sessionID,
      page = page,
      legiKey = legiKey
    )
    pagesFetched <- pagesFetched + 1

    results <- response$searchresult$results
    if (is.null(results) || length(results) == 0) {
      break
    }

    all_data[[length(all_data) + 1L]] <- dplyr::bind_rows(results)

    # Stop at the final page or when the API omits pagination metadata.
    page_total <- response$searchresult$summary$page_total
    if (is.null(page_total) || page >= page_total) {
      break
    }

    # Count fetched pages independently of the starting page number.
    if (pagesFetched >= maxPages) {
      message(page_total, " pages of results exist; stopped at page ", page, ". Raise `maxPages` to fetch them.")
      break
    }

    page <- page + 1
  }
  all_data <- dplyr::bind_rows(all_data)
  if (length(all_data) == 0) {
    warning("No results found. Reference <https://legiscan.com/fulltext-search> for help with search syntax.")
    # Preserve columns for downstream operations on empty results.
    return(dplyr::tibble(
      relevance = integer(),
      bill_id = integer(),
      change_hash = character()
    ))
  } else {
    message(paste0(nrow(all_data), " Results Found"))
    return(all_data)
  }
}
