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
#' @returns A data frame (tibble) of monitored bill IDs and change hashes.
#' Nonempty results retain the API columns. An empty monitor list returns zero
#' rows with integer \code{bill_id}, \code{stance}, and \code{status} columns
#' and character \code{state}, \code{number}, and \code{change_hash} columns.
#' Use \code{nrow()} to test whether there are any bills.
#'
#' @examples
#' \dontrun{
#' getMonitorListRaw()
#' getMonitorListRaw(record = "archived")
#' }
#'
#' @export
getMonitorListRaw <- function(record = "current", legiKey = NULL){

  record <- normalizeRecord(record)

  response <- legiRequest(
    op = "getMonitorListRaw",
    record = record,
    legiKey = legiKey
  )

  if (length(response$monitorlist) == 0L){
    return(dplyr::tibble(
      bill_id = integer(),
      state = character(),
      number = character(),
      stance = integer(),
      change_hash = character(),
      status = integer()
    ))
  }
  return(dplyr::bind_rows(response$monitorlist))
}
