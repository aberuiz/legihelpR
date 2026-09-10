#' Return legiscan Master List
#'
#' @description
#' Returns a legiscan Master List for a specified session or the most recent regular session if only state is provided
#'
#' @param sessionID Session id integer value. Can be found with `getSessions`
#'
#' @param state US state abbreviation. Ignored when `sessionID` is supplied
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A data frame (tibble) of bills, excluding session metadata.
#' Columns come from the API response. An empty bill list returns zero rows
#' and zero columns.
#'
#' @examples
#' \dontrun{
#' getMasterList(sessionID = 2108)
#' getMasterList(state = "TX")
#' }
#'
#' @export
getMasterList <- function(sessionID = NULL, state = NULL, legiKey = NULL){

  if (is.null(sessionID) && is.null(state)){
    stop("Specify a Session or a State to return a Master List")
  }

  response <- legiRequest(
    op = "getMasterList",
    state = if (is.null(sessionID)) state else NULL,
    id = sessionID,
    legiKey = legiKey
  )

  # Remove session metadata by name so response order does not matter.
  masterlist <- response$masterlist
  if (!is.null(masterlist$session)){
    message(masterlist$session$session_name)
    masterlist$session <- NULL
  }
  return(dplyr::bind_rows(masterlist))
}
