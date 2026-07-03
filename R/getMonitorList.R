#' Return associated monitor list
#'
#' @description
#' Return items from the monitor list from the account associated with the legiKey provided
#'
#' @param record Record filter: "current" or "archived", or an exact year >= 2010
#'
#' @param legiKey 32 character API key from legiscan
#'
#' @returns Monitored bills in dataframe format
#'
#' @examples
#' \dontrun{
#' getMonitorList()
#' getMonitorList(record = "archived")
#' }
#'
#' @export
getMonitorList <- function(record = "current", legiKey = NULL){

  response <- legiRequest(
    op = "getMonitorList",
    record = record,
    legiKey = legiKey
  )

  return(dplyr::bind_rows(response$monitorlist))
}
