#' Return df of bills an individual has sponsored
#'
#' @description
#' Returns a dataframe of bills that an indiviual legislator has sponsored, as specified using their people_id
#'
#' @param peopleID People id integer value
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A data frame (tibble) of sponsored bills, excluding sponsor and
#' session metadata. Columns come from the API response. An empty bill list
#' returns zero rows and zero columns.
#'
#' @examples
#' \dontrun{
#' getSponsoredList(peopleID = 5997)
#' }
#'
#' @export
getSponsoredList <- function(peopleID = NULL, legiKey = NULL){

  requireArg(peopleID, "peopleID")

  response <- legiRequest(
    op = "getSponsoredList",
    id = peopleID,
    legiKey = legiKey
  )

  sessions <- dplyr::bind_rows(response$sponsoredbills$sessions)
  if ("session_title" %in% names(sessions)){
    sessionNames <- sessions$session_title
  } else if ("session_name" %in% names(sessions)){
    sessionNames <- sessions$session_name
  } else {
    sessionNames <- character()
  }
  firstActive <- if (length(sessionNames)) utils::tail(sessionNames, n = 1) else "Unknown"
  lastActive <- if (length(sessionNames)) utils::head(sessionNames, n = 1) else "Unknown"

  message(
    paste0(
      "Individual: ", response$sponsoredbills$sponsor$name, '\n',
      "District: ", response$sponsoredbills$sponsor$district, '\n',
      "First Active: ", firstActive, '\n',
      "Last Active: ", lastActive
    )
  )
  return(dplyr::bind_rows(response$sponsoredbills$bills))
}
