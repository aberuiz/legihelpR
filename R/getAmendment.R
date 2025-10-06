#' Return amendment document
#'
#' @description
#' Return amendment document in base64 encoded format based on an amendment_id
#'
#' @param amendmentID amendment_id integer value from bill object
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Amendment document with metadata and base64 encoded document
#'
#' @examples
#' getAmendment(amendmentID = 1234567)
#'
#' @export
getAmendment <- function(amendmentID = NULL, legiKey = NULL){
  op <- "getAmendment"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"))
  }

  tryCatch({
    req <- httr2::request("https://api.legiscan.com") |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
        id = amendmentID,
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

    print(paste0(response$amendment$bill_number, " - ", response$amendment$title))
    return(response$amendment)

  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
