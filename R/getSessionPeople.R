#' People from specified session
#'
#' @description
#' Return a dataframe of people from the specified session
#'
#' @param session Session ID. Can be found with `getSessions`
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @examples
#' getSessionPeople(session = 2003)
#'
#' @export
getSessionPeople <- function(session = NULL, legiKey = NULL){
  op = "getSessionPeople"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  req <- httr2::request(
    "https://api.legiscan.com"
  ) |>
    httr2::req_url_query(
      key = legiKey,
      op = op,
      id = session,
      .multi = "explode"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  print(req$sessionpeople$session$session_name)
  return(dplyr::bind_rows(req$sessionpeople$people))
}
