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
#' \dontrun{
#' getSponsoredList(peopleID = 5997)
#' }
#'
#' @export
getSponsoredList <- function(peopleID = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getSponsoredList",
    id = peopleID,
    legiKey = legiKey
  )

  cat(
    paste0(
      "Individual: ", response$sponsoredbills$sponsor$name, '\n',
      "District: ", response$sponsoredbills$sponsor$district, '\n',
      "First Active: ", utils::tail(dplyr::bind_rows(response$sponsoredbills$sessions),n=1)$session_title, '\n',
      "Last Active: ", utils::head(dplyr::bind_rows(response$sponsoredbills$sessions), n=1)$session_title, '\n'
    )
  )
  return(dplyr::bind_rows(response$sponsoredbills$bills))
}
