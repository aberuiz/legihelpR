#' Voting information for provided Roll Call
#'
#' @description
#' Return vote detail summary for provided Roll Call and a nested list of individual votes
#'
#' @param RollCall Roll Call ID integer
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Summary of Vote and nested list of individual votes by people id
#'
#' @examples
#' \dontrun{
#' getRollCall(RollCall = 1361957)
#' }
#'
#' @export
getRollCall <- function(RollCall = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getRollcall",
    id = RollCall,
    legiKey = legiKey
  )

  message(response$roll_call$desc)
  return(response$roll_call)
}
