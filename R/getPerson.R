#' Return record on Person
#'
#' @description
#' Return an individual record with basic information
#'
#' @param PeopleID integer value from legiscan
#'
#' @export
getPerson <- function(PeopleID = NULL, op = "getPerson", legiKey = NULL){
  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  req <- httr2::request("https://api.legiscan.com") |>
    httr2::req_url_query(
      key = legiKey,
      op = op,
      id = PeopleID
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  return(dplyr::bind_rows(req$person))
}
