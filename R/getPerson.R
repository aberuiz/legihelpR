#' Return record on Person
#'
#' @description
#' Return an individual record with basic information
#'
#' @param peopleID integer value from legiscan
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A one-row data frame (tibble) containing the individual record.
#' Columns come from the API response. Nested fields such as \code{bio} are
#' kept as list columns, e.g. \code{person$bio[[1]]$social$email}.
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

  # bind_rows spreads nested fields (bio) across rows, so add them as list
  # columns to keep one row per person
  person <- response$person
  nested <- vapply(person, is.list, logical(1))
  df <- dplyr::bind_rows(person[!nested])
  df[names(person)[nested]] <- lapply(person[nested], list)
  return(df)
}
