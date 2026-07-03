#' Download dataset archive
#'
#' @description
#' Return a base64 encoded ZIP archive of a specific dataset based on session_id and access_key
#'
#' @param sessionID session_id integer value (use session_id from getDatasetList)
#'
#' @param accessKey access_key string value (use access_key from getDatasetList)
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Dataset archive with metadata and base64 encoded ZIP file
#'
#' @examples
#' \dontrun{
#' getDataset(sessionID = 1234, accessKey = "abc123def456")
#' }
#'
#' @export
getDataset <- function(sessionID = NULL, accessKey = NULL, legiKey = NULL){

  if (is.null(sessionID) && is.null(accessKey)){
    stop("Specify either a sessionID or accessKey to download a dataset")
  }

  response <- legiRequest(
    op = "getDataset",
    id = sessionID,
    access_key = accessKey,
    legiKey = legiKey
  )

  print(paste0("Dataset: ", response$dataset$session_name, " (", response$dataset$state_name, ")"))
  return(response$dataset)
}
