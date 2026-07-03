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
#' @param session Limit search to specific session with a session_id
#'
#' @param page Default is set to return Page 1. `legiSearch` will paginate and include results.
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
legiSearch <- function(query = NULL, state = "ALL", year = 2, session = NULL, page = 1, legiKey = NULL){

  all_data <- list()

  while (TRUE) {
    response <- legiRequest(
      op = "getSearch",
      state = state,
      query = query,
      year = year,
      id = session,
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

    if (nrow(df) < 50) {
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
