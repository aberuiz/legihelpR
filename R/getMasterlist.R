#' Return legiscan Master List
#'
#' @description
#' Returns a legiscan Master List for a specified session or the most recent regular session if only state is provided
#'
#' @param sessionID Session id integer value. Can be found with `getSessions`
#'
#' @param state US state abbreviation
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Master List in dataframe format
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
    state = state,
    id = sessionID,
    legiKey = legiKey
  )

  message(response$masterlist$session$session_name)
  return(dplyr::bind_rows(response$masterlist[-1]))
}
