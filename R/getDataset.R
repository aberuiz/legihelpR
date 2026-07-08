#' Download dataset archive
#'
#' @description
#' Return a base64 encoded ZIP archive of a specific dataset based on session_id and access_key
#'
#' @param sessionID session_id integer value (use session_id from getDatasetList)
#'
#' @param accessKey access_key string value (use access_key from getDatasetList)
#'
#' @param file Optional file path to write the decoded ZIP archive to. When supplied, the base64 zip is decoded and saved to disk
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Dataset archive with metadata and base64 encoded ZIP file, or the file path invisibly when `file` is supplied
#'
#' @examples
#' \dontrun{
#' getDataset(sessionID = 1234, accessKey = "abc123def456")
#' getDataset(sessionID = 1234, accessKey = "abc123def456", file = "dataset.zip")
#' }
#'
#' @export
getDataset <- function(sessionID = NULL, accessKey = NULL, file = NULL, legiKey = NULL){

  # LegiScan's getDataset operation requires BOTH the session_id and the
  # access_key (the two are issued together by getDatasetList). Guard with `||`
  # so a call missing either one fails locally with a clear message rather than
  # firing a malformed request. Mirrors the check in getDatasetRaw().
  if (is.null(sessionID) || is.null(accessKey)){
    stop("Specify both a sessionID and accessKey from `getDatasetList` to download a dataset")
  }

  response <- legiRequest(
    op = "getDataset",
    id = sessionID,
    access_key = accessKey,
    legiKey = legiKey
  )

  message(paste0("Dataset: ", response$dataset$session_name, " (", response$dataset$state_name, ")"))
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$dataset$zip), file)
    message(paste0("Dataset saved to ", file))
    return(invisible(file))
  }
  return(response$dataset)
}
