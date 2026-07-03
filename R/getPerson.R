#' Return record on Person
#'
#' @description
#' Return an individual record with basic information
#'
#' @param PeopleID integer value from legiscan
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Individual record in dataframe format
#'
#' @examples
#' \dontrun{
#' getPerson(PeopleID = 5997)
#' }
#'
#' @export
getPerson <- function(PeopleID = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getPerson",
    id = PeopleID,
    legiKey = legiKey
  )

  message(response$person$name)
  return(dplyr::bind_rows(response$person))
}
