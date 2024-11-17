#' Return associated monitor list
#'
#' @description
#' Return items from the monitor list from the account associated with the legiKey provided
#'
#' @param legiKey 32 character API key from legiscan
#'
#' @export
getMonitorList <- function(legiKey = NULL){
  op <- "getMonitorList"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  tryCatch({
    req <- httr2::request("https://api.legiscan.com") |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
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

    return(dplyr::bind_rows(response$monitorlist))

  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
