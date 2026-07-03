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
#' @examples
#' \dontrun{
#' getDatasetList(state = "TX", year = 2023)
#' }
#'
#' @export
getDatasetList <- function(state = NULL, year = NULL, legiKey = NULL){

  if (!is.null(year)){
    if(nchar(year) !=4){
      warning("year should be 4 digits")
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
