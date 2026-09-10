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
#' @returns A list containing amendment document metadata and a base64 encoded
#' \code{doc} field. When \code{file} is supplied, the decoded content is written to disk
#' and \code{file} is returned invisibly instead of the list.
#'
#' @examples
#' \dontrun{
#' getAmendment(amendmentID = 1234567)
#' getAmendment(amendmentID = 1234567, file = "amendment.pdf")
#' }
#'
#' @export
getAmendment <- function(amendmentID = NULL, file = NULL, legiKey = NULL){

  requireArg(amendmentID, "amendmentID")

  response <- legiRequest(
    op = "getAmendment",
    id = amendmentID,
    legiKey = legiKey
  )

  message("Amendment ", response$amendment$amendment_id, " - ", response$amendment$title)
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$amendment$doc), file)
    message(paste0("Document saved to ", file))
    return(invisible(file))
  }
  return(response$amendment)
}
