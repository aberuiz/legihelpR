#' Return search results from legiscan's database
#'
#' @description
#' Return up to 2,000 results at a time from legiscan's database
#'
#' @param query Enter your text
#'
#' @param state Search the entire nation by default with 'ALL' or specify state using letter abbreviations
#'
#' @param year Should be an integer. 1=All, 2=Current, 3=Recent, 4=Prior, >1900=Exact Year
#'
#' @param session Limit search to specific session with a session_id
#'
#' @param page Default is set to return Page 1. Up to 2,000 results per page
#' @export
legiSearch <- function(query = NULL, state = "ALL", year = 2, session = NULL, page = 1, legiKey = NULL, op = "getSearch"){
  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  all_data <- list()

  while (TRUE) {
    req <- httr2::request("https://api.legiscan.com") |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
        state = state,
        query = query,
        year = year,
        id = session,
        page = page,
        .multi = "explode"
      ) |>
      httr2::req_perform() |>
      httr2::resp_body_json()
    df <- dplyr::bind_rows(req$searchresult[-1])

    if (nrow(df) < 50){
      return(df)
    }
    all_data <- dplyr::bind_rows(all_data, df)
    page <- page + 1
  }
  if (length(all_data == 0)){
    warning("No results found. Check legiscan.com for search syntax help.")
  } else {
    print(paste0(length(all_data), " Results Found"))
    return(all_data)
  }
  # req <- httr2::request("https://api.legiscan.com") |>
  #   httr2::req_url_query(
  #     key = legiKey,
  #     op = op,
  #     state = state,
  #     query = query,
  #     year = year,
  #     id = session,
  #     page = page,
  #     .multi = "explode"
  #   ) |>
  #   httr2::req_perform() |>
  #   httr2::resp_body_json()

#  print(paste0(req$searchresult$summary$count, " Results found from "))
#  return(dplyr::bind_rows(req$searchresult[-1]))# |>
#    select(c(relvance, state, bill_number, bill_id, title, url, text_url, last_action_date, last_action))
}
