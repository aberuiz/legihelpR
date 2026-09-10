#' Return legiscan Master List for change detection
#'
#' @description
#' Returns a Master List of bill_id and change_hash values for a specified session
#' or the most recent regular session if only state is provided. Optimized for
#' detecting which bills have changed and need updating via `getBill`.
#'
#' @param sessionID Session id integer value. Can be found with `getSessions`
#'
#' @param state US state abbreviation. Ignored when `sessionID` is supplied
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A data frame (tibble) of bill IDs and change hashes, excluding
#' session metadata. Nonempty results retain the API columns. An empty bill
#' list returns zero rows with integer \code{bill_id} and character
#' \code{number} and \code{change_hash} columns. Use \code{nrow()} to test
#' whether there are any bills.
#'
#' @examples
#' \dontrun{
#' getMasterListRaw(sessionID = 2108)
#' getMasterListRaw(state = "TX")
#' }
#'
#' @export
getMasterListRaw <- function(sessionID = NULL, state = NULL, legiKey = NULL){

  if (is.null(sessionID) && is.null(state)){
    stop("Specify a Session or a State to return a Master List")
  }

  response <- legiRequest(
    op = "getMasterListRaw",
    state = if (is.null(sessionID)) state else NULL,
    id = sessionID,
    legiKey = legiKey
  )

  masterlist <- response$masterlist
  if (!is.null(masterlist$session)){
    message(masterlist$session$session_name)
    masterlist$session <- NULL
  }
  if (length(masterlist) == 0L){
    return(dplyr::tibble(
      bill_id = integer(),
      number = character(),
      change_hash = character()
    ))
  }
  return(dplyr::bind_rows(masterlist))
}
