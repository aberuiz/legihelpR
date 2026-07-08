#' Return record on Person
#'
#' @description
#' Return an individual record with basic information
#'
#' @param peopleID integer value from legiscan
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Individual record in dataframe format
#'
#' @examples
#' \dontrun{
#' getPerson(peopleID = 5997)
#' }
#'
#' @export
getPerson <- function(peopleID = NULL, legiKey = NULL){

  requireArg(peopleID, "peopleID")

  response <- legiRequest(
    op = "getPerson",
    id = peopleID,
    legiKey = legiKey
  )

  message(response$person$name)
  return(dplyr::bind_rows(response$person))
}
