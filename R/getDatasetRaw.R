#' Download dataset archive as a ZIP file
#'
#' @description
#' Download a specific dataset as a binary ZIP archive written directly to disk,
#' containing all bills, votes, and people data for the specified session
#'
#' @param sessionID session_id integer value (use session_id from getDatasetList)
#'
#' @param accessKey access_key string value (use access_key from getDatasetList)
#'
#' @param file File path to write the ZIP archive to. Defaults to legiscan_dataset_<sessionID>.zip in the working directory
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @param format File format of the ZIP contents, either "json" or "csv"
#' (case-insensitive)
#'
#' @returns The path of the downloaded ZIP archive as a character string,
#' returned invisibly. The archive is written to disk.
#'
#' @examples
#' \dontrun{
#' getDatasetRaw(sessionID = 1234, accessKey = "abc123def456")
#' getDatasetRaw(sessionID = 1234, accessKey = "abc123def456", format = "csv")
#' }
#'
#' @export
getDatasetRaw <- function(sessionID = NULL, accessKey = NULL, file = NULL, legiKey = NULL, format = "json"){

  if (is.null(sessionID) || is.null(accessKey)){
    stop("Specify both a sessionID and accessKey from `getDatasetList` to download a dataset")
  }
  format <- normalizeDatasetFormat(format)

  response <- legiRequest(
    op = "getDatasetRaw",
    id = sessionID,
    access_key = accessKey,
    format = format,
    legiKey = legiKey,
    raw = TRUE
  )

  if (is.null(file)){
    file <- paste0("legiscan_dataset_", sessionID, ".zip")
  }
  writeBin(response, file)
  message(paste0("Dataset saved to ", file))
  return(invisible(file))
}
