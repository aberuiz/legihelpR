#' Return a specific bill
#'
#' @description
#' Return a specific bill based on a legiscan bill_id
#'
#' @param billID bill_id integer value
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Bill detail information including sponsors, history, texts, and roll calls
#'
#' @examples
#' \dontrun{
#' getBill(billID = 1633853)
#' }
#'
#' @export
getBill <- function(billID = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getBill",
    id = billID,
    legiKey = legiKey
  )

  message(
    paste0(response$bill$bill_number, " from ", response$bill$state, " ", response$bill$session$session_name)
  )
  return(response$bill)
}
