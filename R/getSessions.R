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
#' getSessions(state = "MA")
#'
#' @export
getSessions <- function(state = "TX", legiKey = NULL, op = "getSessionlist"){
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
      state = state,
      .multi = "explode"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  return(dplyr::bind_rows(req$sessions))
}
