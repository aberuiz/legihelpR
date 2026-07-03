#' Return legislative session ids
#'
#' @description
#' Return a dataframe for all session ids of specified state in legiscan's database
#'
#' @param state US State abbreviation
#'
#' @param legiKey 32 character string provided by legiscan.com
#'
#' @returns A dataframe of all state legislative session ids
#'
#' @examples
#' \dontrun{
#' getSessions(state = "MA")
#' }
#'
#' @export
getSessions <- function(state = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getSessionList",
    state = state,
    legiKey = legiKey
  )

  return(dplyr::bind_rows(response$sessions))
}
