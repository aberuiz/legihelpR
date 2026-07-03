#' People from specified session
#'
#' @description
#' Return a dataframe of people from the specified session
#'
#' @param session Session ID. Can be found with `getSessions`
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns People active in the specified session in dataframe format
#'
#' @examples
#' \dontrun{
#' getSessionPeople(session = 2160)
#' }
#'
#' @export
getSessionPeople <- function(session = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getSessionPeople",
    id = session,
    legiKey = legiKey
  )

  message(response$sessionpeople$session$session_name)
  return(dplyr::bind_rows(response$sessionpeople$people))
}
