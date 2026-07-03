#' Return amendment document
#'
#' @description
#' Return amendment document in base64 encoded format based on an amendment_id
#'
#' @param amendmentID amendment_id integer value from bill object
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Amendment document with metadata and base64 encoded document
#'
#' @examples
#' \dontrun{
#' getAmendment(amendmentID = 1234567)
#' }
#'
#' @export
getAmendment <- function(amendmentID = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getAmendment",
    id = amendmentID,
    legiKey = legiKey
  )

  print(paste0(response$amendment$bill_number, " - ", response$amendment$title))
  return(response$amendment)
}
