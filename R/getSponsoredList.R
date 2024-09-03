#' Return df of bills an individual has sponsored
#'
#' @description
#' Returns a dataframe of bills that an indiviual legislator has sponsored, as specified using their people_id
#'
#' @param peopleID People id integer value
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Bills sponsored by a specified individual
#'
#' @examples
#' getSponsoredList(peopleID = 5997)
#'
#' @export
getSponsoredList <- function(peopleID = NULL, legiKey = NULL){
  op <- "getSponsoredList"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  req <- httr2::request(
    "https://api.legiscan.com"
  ) |>
    httr2::req_url_query(
      key = legiKey,
      op = op,
      id = peopleID,
      .multi = "explode"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  cat(
    paste0(
      "Individual: ", req$sponsoredbills$sponsor$name, '\n',
      "District: ", req$sponsoredbills$sponsor$district, '\n',
      "First Active: ", tail(dplyr::bind_rows(req$sponsoredbills$sessions),n=1)$session_title, '\n',
      "Last Active: ", head(dplyr::bind_rows(req$sponsoredbills$sessions), n=1)$session_title, '\n'
    )
  )
  return(dplyr::bind_rows(req$sponsoredbills$bills))
}
