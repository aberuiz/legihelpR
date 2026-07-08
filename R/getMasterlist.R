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

  # The masterlist object holds a `session` block alongside the numbered bill
  # entries. Remove it by name rather than by position (`[-1]`): a positional
  # drop silently discards the wrong element if LegiScan ever reorders the
  # object. Matches the approach in getMasterListRaw().
  masterlist <- response$masterlist
  message(masterlist$session$session_name)
  masterlist$session <- NULL
  return(dplyr::bind_rows(masterlist))
}
