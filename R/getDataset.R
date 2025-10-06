#' Download dataset archive
#'
#' @description
#' Return a base64 encoded ZIP archive of a specific dataset based on session_id or access_key
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
#' getDataset(sessionID = 1234)
#' getDataset(accessKey = "abc123def456")
#'
#' @export
getDataset <- function(sessionID = NULL, accessKey = NULL, legiKey = NULL){
  op <- "getDataset"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"))
  }

  if (is.null(sessionID) && is.null(accessKey)){
    stop("Specify either a sessionID or accessKey to download a dataset")
  }

  tryCatch({
    req <- httr2::request("https://api.legiscan.com") |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
        id = sessionID,
        access_key = accessKey,
        .multi = "explode"
      ) |>
      httr2::req_perform()

    status <- httr2::resp_status(req)
    if (status != 200) {
      stop(sprintf("API request failed with status code: %d", status))
    }

    response <- httr2::resp_body_json(req)

    if (!is.null(response$status)) {
      if (response$status != "OK") {
        stop(sprintf("API returned error: %s", response$alert))
      }
    }

    print(paste0("Dataset: ", response$dataset$session_name, " (", response$dataset$state_name, ")"))
    return(response$dataset)

  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
