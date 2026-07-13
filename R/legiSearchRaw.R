#' Return raw search results from legiscan's database
#'
#' @description
#' Return search results from legiscan's full text engine with simplified details,
#' 2000 results at a time. Returns relevance, bill_id, and change_hash only,
#' appropriate for automated keyword monitoring. Check legiscan.com for specific search syntax for more details.
#'
#' @param query Enter your search text. Your query may use grammatically correct spacing. Use legiscan's search syntax for more powerful results.
#'
#' @param state Search the entire nation by default with 'ALL' or specify state using letter abbreviations
#'
#' @param year Should be an integer. 1=All, 2=Current, 3=Recent, 4=Prior, >1900=Exact Year
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
#' @returns Search results with relevance, bill_id, and change_hash in dataframe format.
#' When the search matches nothing, a zero-row dataframe with the same columns
#' is returned with a warning
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

  all_data <- list()
  pagesFetched <- 0

  while (TRUE) {
    response <- legiRequest(
      op = "getSearchRaw",
      state = state,
      query = query,
      year = year,
      id = sessionID,
      page = page,
      legiKey = legiKey
    )
    pagesFetched <- pagesFetched + 1

    results <- response$searchresult$results
    if (is.null(results) || length(results) == 0) {
      break
    }

    all_data <- dplyr::bind_rows(all_data, dplyr::bind_rows(results))

    # Guard against a missing summary so we never loop forever or error on a
    # zero-length comparison. Mirrors the check in legiSearch().
    page_total <- response$searchresult$summary$page_total
    if (is.null(page_total) || page >= page_total) {
      break
    }

    # maxPages caps API queries spent, so count pages fetched rather than
    # comparing against the page number, which overshoots when `page` > 1.
    if (pagesFetched >= maxPages) {
      message(page_total, " pages of results exist; stopped at page ", page, ". Raise `maxPages` to fetch them.")
      break
    }

    page <- page + 1
  }
  if (length(all_data) == 0) {
    warning("No results found. Reference <https://legiscan.com/fulltext-search> for help with search syntax.")
    # Return a zero-row frame with the documented getSearchRaw columns instead
    # of NULL, so downstream code (nrow, column selection, bind_rows) handles
    # an empty result without special-casing.
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
