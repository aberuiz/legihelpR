#' Return record on Person
#'
#' @description
#' Return an individual record with basic information
#'
#' @param peopleID integer value from legiscan
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A data frame (tibble) containing the individual record. Columns
#' come from the API response.
#'
#' @examples
#' \dontrun{
#' getPerson(peopleID = 5997)
#' }
#'
#' @export
getPerson <- function(peopleID = NULL, legiKey = NULL){

  validateId(peopleID, "peopleID")

  response <- legiRequest(
    op = "getPerson",
    id = peopleID,
    legiKey = legiKey
  )

  message(response$person$name)
  return(dplyr::bind_rows(response$person))
}
