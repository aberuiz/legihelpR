#' Return associated monitor list for change detection
#'
#' @description
#' Return bill_id and change_hash values from the monitor list of the account
#' associated with the legiKey provided. Optimized for detecting which bills
#' have changed and need updating via `getBill`.
#'
#' @param record Record filter: "current" or "archived", or an exact year >= 2010
#'
#' @param legiKey 32 character API key from legiscan
#'
#' @returns Monitored bills with bill_id and change_hash in dataframe format
#'
#' @examples
#' \dontrun{
#' getMonitorListRaw()
#' getMonitorListRaw(record = "archived")
#' }
#'
#' @export
getMonitorListRaw <- function(record = "current", legiKey = NULL){

  response <- legiRequest(
    op = "getMonitorListRaw",
    record = record,
    legiKey = legiKey
  )

  return(dplyr::bind_rows(response$monitorlist))
}
