#' Return record on Person
#'
#' @description
#' Return an individual record with basic information
#'
#' @param PeopleID integer value from legiscan
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @export
getPerson <- function(PeopleID = NULL, legiKey = NULL){
  op <- "getPerson"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  req <- httr2::request("https://api.legiscan.com") |>
    httr2::req_url_query(
      key = legiKey,
      op = op,
      id = PeopleID
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  print(req$person$name)
  return(dplyr::bind_rows(req$person))

  tryCatch({
    req <- httr2::request("https://api.legiscan.com") |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
        id = PeopleID
      ) |>
      httr2::req_perform()

    response <- httr2::resp_body_json(req)

    if (!is.null(response$status)) {
      if (response$status != "OK") {
        stop(sprintf("API returned error: %s", response$alert))
      }
    }

    return(dplyr::bind_rows(req$person))

  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
