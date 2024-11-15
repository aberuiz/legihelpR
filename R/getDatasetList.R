#' Return list of available datasets
#'
#' @description
#' Return a list of available datasets, available to filter by state and year
#'
#' @param state US state 2 character abbreviation
#'
#' @param year 4 year digit
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns available datasets for download
#'
#' @export
getDatasetList <- function(state = NULL, year = NULL, legiKey = NULL){
  op <- "getDatasetList"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey,"\nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"))
  }

  if (!is.null(year)){
    if(nchar(year) !=4){
      warning("year should be 4 digits")
    }
  }

  tryCatch({
    req <- httr2::request("https://api.legiscan.com") |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
        state = state,
        state = year,
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

    return(dplyr::bind_rows(response$datasetlist))
  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
