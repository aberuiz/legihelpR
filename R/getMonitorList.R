#' Return monitored list
#'
#' @description
#' Return items from the monitored list from the account associated with legiKey provided
#'
#' @param legiKey 32 character API key from legiscan
#'
#' @export
getMonitorList <- function(legiKey = NULL, op = "getMonitorList"){
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
      .multi = "explode"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  return(dplyr::bind_rows(req$monitorlist))
}
