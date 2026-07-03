#' Return legiscan Master List for change detection
#'
#' @description
#' Returns a Master List of bill_id and change_hash values for a specified session
#' or the most recent regular session if only state is provided. Optimized for
#' detecting which bills have changed and need updating via `getBill`.
#'
#' @param session Session id integer value. Can be found with `getSessions`
#'
#' @param state US state abbreviation
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Master List of bill_id and change_hash in dataframe format
#'
#' @examples
#' \dontrun{
#' getMasterListRaw(session = 2108)
#' getMasterListRaw(state = "TX")
#' }
#'
#' @export
getMasterListRaw <- function(session = NULL, state = NULL, legiKey = NULL){

  if (is.null(session) && is.null(state)){
    stop("Specify a Session or a State to return a Master List")
  }

  response <- legiRequest(
    op = "getMasterListRaw",
    state = state,
    id = session,
    legiKey = legiKey
  )

  masterlist <- response$masterlist
  if (!is.null(masterlist$session)){
    print(masterlist$session$session_name)
    masterlist$session <- NULL
  }
  return(dplyr::bind_rows(masterlist))
}
