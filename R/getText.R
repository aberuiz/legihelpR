#' Return bill text document
#'
#' @description
#' Return bill text document in base64 encoded format based on a text_id
#'
#' @param textID text_id integer value from bill object
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Bill text document with metadata and base64 encoded document
#'
#' @examples
#' \dontrun{
#' getText(textID = 1234567)
#' }
#'
#' @export
getText <- function(textID = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getBillText",
    id = textID,
    legiKey = legiKey
  )

  print(paste0(response$text$bill_number, " - ", response$text$type_desc))
  return(response$text)
}
