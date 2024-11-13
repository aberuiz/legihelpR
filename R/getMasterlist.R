#' Return legiscan Master List
#'
#' @description
#' Returns a legiscan Master List for a specified session or the most recent regular session if only state is provided
#'
#' @param session Session id integer value. Can be found with `getSessions`
#'
#' @param state US state abbreviation
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Master List in dataframe format
#'
#' @examples
#' getMasterList(session = 2108)
#' getMasterList(state = "TX")
#'
#' @export
getMasterList <- function(session = NULL, state = NULL, legiKey = NULL){
  op <- "getMasterList"

  if (is.null(legiKey)){
    legiKey <- getlegiKey()
  }
  if (nchar(legiKey)!=32){
    warning(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
    return(paste0("Invalid API Key: ",legiKey," Register <https://legiscan.com/user/register> Store with `setlegiKey`"))
  }

  if (is.null(session)){
    if (is.null(state)){
      #errorCondition("Specify a Session or a State to return a Master List")
      stop("Specify a Session or a State to return a Master List")
    }
  }

  tryCatch({
    req <- httr2::request(
      "https://api.legiscan.com"
    ) |>
      httr2::req_url_query(
        key = legiKey,
        op = op,
        state = state,
        id = session,
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

    print(response$masterlist$session$session_name)
    return(dplyr::bind_rows(response$masterlist[-1]))

  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
