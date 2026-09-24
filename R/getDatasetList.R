#' Return list of available datasets
#'
#' @description
#' Return a list of available datasets, available to filter by state and year
#'
#' @param state US state abbreviation, 'DC', or 'US' for Congress (case-insensitive)
#'
#' @param year 4 digit year
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

  if (!is.null(state)){
    state <- normalizeState(state)
  }
  if (!is.null(year)){
    validateDatasetYear(year)
  }

  response <- legiRequest(
    op = "getDatasetList",
    state = state,
    year = year,
    legiKey = legiKey
  )

  return(dplyr::bind_rows(response$datasetlist))
}
