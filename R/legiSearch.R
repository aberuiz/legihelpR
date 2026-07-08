#' Return search results from legiscan's database
#'
#' @description
#' Return search results from legiscan's database. Check legiscan.com for specific search syntax for more details.
#'
#' @param query Enter your search text. Your query may use grammatically correct spacing. Use legiscan's search syntax for more powerful results.
#'
#' @param state Search the entire nation by default with 'ALL' or specify state using letter abbreviations
#'
#' @param year Should be an integer. 1=All, 2=Current, 3=Recent, 4=Prior, >1900=Exact Year
#'
#' @param sessionID Limit search to specific session with a session_id
#'
#' @param page Default is set to return Page 1. `legiSearch` will paginate and include results.
#'
#' @param maxPages Maximum number of pages to fetch. Each page is one API query
#' against your monthly quota. Use `Inf` to fetch every page.
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Search results in dataframe format
#'
#' @examples
#' \dontrun{
#' legiSearch(
#'   query = "action:yesterday AND 'workers compensation'",
#'   state = "TX"
#' )
#'
#' legiSearch(
#'   query = "intro:month AND wage theft"
#' )
#' }
#'
#' @export
legiSearch <- function(query = NULL, state = "ALL", year = 2, sessionID = NULL, page = 1, maxPages = 10, legiKey = NULL){

  all_data <- list()

  while (TRUE) {
    response <- legiRequest(
      op = "getSearch",
      state = state,
      query = query,
      year = year,
      id = sessionID,
      page = page,
      legiKey = legiKey
    )

    if (is.null(response$searchresult) || length(response$searchresult) == 0) {
      break
    }

    df <- dplyr::bind_rows(response$searchresult[-1])

    if (nrow(df) == 0) {
      break
    }

    all_data <- dplyr::bind_rows(all_data, df)

    # `summary$page_total` is the authoritative page count. Prefer it over the
    # old "final page has < 50 rows" heuristic, which fired one extra empty
    # request whenever the result count was an exact multiple of the 50-row
    # page size. Guard against a missing summary so we never loop forever.
    page_total <- response$searchresult$summary$page_total
    if (is.null(page_total) || page >= page_total) {
      break
    }

    if (page >= maxPages) {
      message("Stopped at page ", page, "; more results exist. Raise `maxPages` to fetch them.")
      break
    }

    page <- page + 1
  }
  if (length(all_data) == 0) {
    warning("No results found. Reference <https://legiscan.com/fulltext-search> for help with search syntax.")
    return(NULL)
  } else {
    message(paste0(nrow(all_data), " Results Found"))
    return(all_data)
  }
}
