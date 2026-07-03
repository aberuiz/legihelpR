#' Add or remove bills from the monitor list
#'
#' @description
#' Interact with GAITS to add or remove bills from the monitor list of the
#' account associated with the legiKey provided, or set a stance on monitored bills
#'
#' @param billIDs One or more bill_id integer values to operate on
#'
#' @param action Action to take on the bill list: "monitor", "remove", or "set"
#'
#' @param stance Position on the bill: "watch", "support", or "oppose"
#'
#' @param legiKey 32 character API key from legiscan
#'
#' @returns Status of each bill_id and the action taken in dataframe format
#'
#' @examples
#' \dontrun{
#' setMonitor(billIDs = c(150334, 141690), action = "monitor")
#' setMonitor(billIDs = 1533377, action = "set", stance = "support")
#' }
#'
#' @export
setMonitor <- function(billIDs = NULL, action = NULL, stance = "watch", legiKey = NULL){

  if (is.null(billIDs)){
    stop("Specify one or more billIDs to operate on")
  }
  if (is.null(action) || !action %in% c("monitor", "remove", "set")){
    stop("action must be one of 'monitor', 'remove', or 'set'")
  }
  if (!stance %in% c("watch", "support", "oppose")){
    stop("stance must be one of 'watch', 'support', or 'oppose'")
  }

  response <- legiRequest(
    op = "setMonitor",
    list = paste(billIDs, collapse = ","),
    action = action,
    stance = stance,
    legiKey = legiKey
  )

  return(
    data.frame(
      bill_id = names(response$`return`),
      result = unlist(response$`return`),
      row.names = NULL
    )
  )
}
