#' Return supplement document
#'
#' @description
#' Return supplement document in base64 encoded format based on a supplement_id
#'
#' @param supplementID supplement_id integer value from bill object
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Supplement document with metadata and base64 encoded document
#'
#' @examples
#' getSupplement(supplementID = 1234567)
#'
#' @export
getSupplement <- function(supplementID = NULL, legiKey = NULL){
  op <- "getSupplement"

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
        id = supplementID,
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

    print(paste0(response$supplement$bill_number, " - ", response$supplement$type_desc))
    return(response$supplement)

  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
