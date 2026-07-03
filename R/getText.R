#' Return bill text document
#'
#' @description
#' Return bill text document in base64 encoded format based on a text_id
#'
#' @param textID text_id integer value from bill object
#'
#' @param file Optional file path to write the decoded document to. When supplied, the base64 doc is decoded and saved to disk
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Bill text document with metadata and base64 encoded document, or the file path invisibly when `file` is supplied
#'
#' @examples
#' \dontrun{
#' getText(textID = 1234567)
#' getText(textID = 1234567, file = "bill_text.html")
#' }
#'
#' @export
getText <- function(textID = NULL, file = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getBillText",
    id = textID,
    legiKey = legiKey
  )

  message(paste0(response$text$bill_number, " - ", response$text$type_desc))
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$text$doc), file)
    message(paste0("Document saved to ", file))
    return(invisible(file))
  }
  return(response$text)
}
