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
#' @returns A data frame (tibble) of available datasets and their download
#' metadata. Columns come from the API response. An empty dataset list returns
#' zero rows and zero columns.
#'
#' @examples
#' \dontrun{
#' getDatasetList(state = "TX", year = 2023)
#' }
#'
#' @export
getDatasetList <- function(state = NULL, year = NULL, legiKey = NULL){

  if (!is.null(year)){
    yearText <- as.character(year)
    if(length(yearText) != 1L || is.na(yearText) || !grepl("^[[:digit:]]{4}$", yearText)){
      warning("year should be 4 digits", call. = FALSE)
    }
  }

  response <- legiRequest(
    op = "getDatasetList",
    state = state,
    year = year,
    legiKey = legiKey
  )

  return(dplyr::bind_rows(response$datasetlist))
}
