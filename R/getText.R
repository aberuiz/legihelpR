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
#' @returns A list containing bill text document metadata and a base64 encoded
#' \code{doc} field. When \code{file} is supplied, the decoded content is written to disk
#' and \code{file} is returned invisibly instead of the list.
#'
#' @examples
#' \dontrun{
#' getText(textID = 1234567)
#' getText(textID = 1234567, file = "bill_text.html")
#' }
#'
#' @export
getText <- function(textID = NULL, file = NULL, legiKey = NULL){

  requireArg(textID, "textID")

  response <- legiRequest(
    op = "getBillText",
    id = textID,
    legiKey = legiKey
  )

  message("Bill text ", response$text$doc_id, " - ", response$text$type)
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$text$doc), file)
    message(paste0("Document saved to ", file))
    return(invisible(file))
  }
  return(response$text)
}
