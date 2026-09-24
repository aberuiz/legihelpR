#' Return supplement document
#'
#' @description
#' Return supplement document in base64 encoded format based on a supplement_id
#'
#' @param supplementID supplement_id integer value from bill object
#'
#' @param file Optional file path to write the decoded document to. When supplied, the base64 doc is decoded and saved to disk. The destination folder must already exist
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns A list containing supplement document metadata and a base64 encoded
#' \code{doc} field. When \code{file} is supplied, the decoded content is written to disk
#' and \code{file} is returned invisibly instead of the list.
#'
#' @examples
#' \dontrun{
#' getSupplement(supplementID = 1234567)
#' getSupplement(supplementID = 1234567, file = "supplement.pdf")
#' }
#'
#' @export
getSupplement <- function(supplementID = NULL, file = NULL, legiKey = NULL){

  validateId(supplementID, "supplementID")
  if (!is.null(file)){
    validateOutputFile(file)
  }

  response <- legiRequest(
    op = "getSupplement",
    id = supplementID,
    legiKey = legiKey
  )

  message("Supplement ", response$supplement$supplement_id, " - ", response$supplement$title)
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$supplement$doc), file)
    message(paste0("Document saved to ", file))
    return(invisible(file))
  }
  return(response$supplement)
}
