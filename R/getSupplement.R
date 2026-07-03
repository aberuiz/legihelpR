#' Return supplement document
#'
#' @description
#' Return supplement document in base64 encoded format based on a supplement_id
#'
#' @param supplementID supplement_id integer value from bill object
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Supplement document with metadata and base64 encoded document
#'
#' @examples
#' \dontrun{
#' getSupplement(supplementID = 1234567)
#' }
#'
#' @export
getSupplement <- function(supplementID = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getSupplement",
    id = supplementID,
    legiKey = legiKey
  )

  print(paste0(response$supplement$bill_number, " - ", response$supplement$type_desc))
  return(response$supplement)
}
