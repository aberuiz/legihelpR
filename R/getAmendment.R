#' Return amendment document
#'
#' @description
#' Return amendment document in base64 encoded format based on an amendment_id
#'
#' @param amendmentID amendment_id integer value from bill object
#'
#' @param file Optional file path to write the decoded document to. When supplied, the base64 doc is decoded and saved to disk
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Amendment document with metadata and base64 encoded document, or the file path invisibly when `file` is supplied
#'
#' @examples
#' \dontrun{
#' getAmendment(amendmentID = 1234567)
#' getAmendment(amendmentID = 1234567, file = "amendment.pdf")
#' }
#'
#' @export
getAmendment <- function(amendmentID = NULL, file = NULL, legiKey = NULL){

  response <- legiRequest(
    op = "getAmendment",
    id = amendmentID,
    legiKey = legiKey
  )

  message(paste0(response$amendment$bill_number, " - ", response$amendment$title))
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$amendment$doc), file)
    message(paste0("Document saved to ", file))
    return(invisible(file))
  }
  return(response$amendment)
}
