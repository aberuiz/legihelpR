#' People from specified session
#'
#' @description
#' Return a dataframe of people from the specified session
#'
#' @param sessionID Session ID. Can be found with `getSessions`
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A data frame (tibble) of people active in the session, excluding
#' session metadata. Columns come from the API response. An empty people list
#' returns zero rows and zero columns.
#'
#' @examples
#' \dontrun{
#' getSessionPeople(sessionID = 2160)
#' }
#'
#' @export
getSessionPeople <- function(sessionID = NULL, legiKey = NULL){

  requireArg(sessionID, "sessionID")

  response <- legiRequest(
    op = "getSessionPeople",
    id = sessionID,
    legiKey = legiKey
  )

  message(response$sessionpeople$session$session_name)
  return(dplyr::bind_rows(response$sessionpeople$people))
}
