#' Return supplement document
#'
#' @description
#' Return supplement document in base64 encoded format based on a supplement_id
#'
#' @param supplementID supplement_id integer value from bill object
#'
#' @param file Optional file path to write the decoded document to. When supplied, the base64 doc is decoded and saved to disk
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Supplement document with metadata and base64 encoded document, or the file path invisibly when `file` is supplied
#'
#' @examples
#' \dontrun{
#' getSupplement(supplementID = 1234567)
#' getSupplement(supplementID = 1234567, file = "supplement.pdf")
#' }
#'
#' @export
getSupplement <- function(supplementID = NULL, file = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getSupplement",
    id = supplementID,
    legiKey = legiKey
  )

  message(paste0(response$supplement$bill_number, " - ", response$supplement$type_desc))
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$supplement$doc), file)
    message(paste0("Document saved to ", file))
    return(invisible(file))
  }
  return(response$supplement)
}
