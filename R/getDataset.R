#' Download dataset archive
#'
#' @description
#' Return a base64 encoded ZIP archive of a specific dataset based on session_id and access_key
#'
#' @param sessionID session_id integer value (use session_id from getDatasetList)
#'
#' @param accessKey access_key string value (use access_key from getDatasetList)
#'
#' @param file Optional file path to write the decoded ZIP archive to. When supplied, the base64 zip is decoded and saved to disk. The destination folder must already exist
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @param format File format of the ZIP contents, either "json" or "csv"
#' (case-insensitive)
#'
#' @returns A list containing dataset archive metadata and a base64 encoded
#' \code{zip} field. When \code{file} is supplied, the decoded content is written to disk
#' and \code{file} is returned invisibly instead of the list.
#'
#' @examples
#' \dontrun{
#' getDataset(sessionID = 1234, accessKey = "abc123def456")
#' getDataset(sessionID = 1234, accessKey = "abc123def456", format = "csv", file = "dataset.zip")
#' }
#'
#' @export
getDataset <- function(sessionID = NULL, accessKey = NULL, file = NULL, legiKey = NULL, format = "json"){

  # Session ID and access key are issued together by getDatasetList.
  if (is.null(sessionID) || is.null(accessKey)){
    stop("Specify both a sessionID and accessKey from `getDatasetList` to download a dataset")
  }
  validateId(sessionID, "sessionID")
  validateAccessKey(accessKey)
  format <- normalizeDatasetFormat(format)
  if (!is.null(file)){
    validateOutputFile(file)
  }

  response <- legiRequest(
    op = "getDataset",
    id = sessionID,
    access_key = accessKey,
    format = format,
    legiKey = legiKey
  )

  datasetLabel <- response$dataset$session_name
  if (rlang::is_string(response$dataset$state_name) &&
      !is.na(response$dataset$state_name) &&
      nzchar(response$dataset$state_name)){
    datasetLabel <- paste0(datasetLabel, " (", response$dataset$state_name, ")")
  }
  message("Dataset: ", datasetLabel)
  if (!is.null(file)){
    writeBin(openssl::base64_decode(response$dataset$zip), file)
    message(paste0("Dataset saved to ", file))
    return(invisible(file))
  }
  return(response$dataset)
}
