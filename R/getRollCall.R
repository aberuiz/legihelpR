#' Voting information for provided Roll Call
#'
#' @description
#' Return vote detail summary for provided Roll Call and a nested list of individual votes
#'
#' @param RollCall Roll Call ID integer
#'
#' @param legiKey 32 character string provided by legiscan
#'
#' @returns Summary of Vote and nested list of individual votes by people id
#'
#' @examples
#' getRollCall(RollCall = 1361957)
#'
#' @export
getRollCall <- function(RollCall = NULL, legiKey = NULL){
  op <- "getRollcall"

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
        id = RollCall,
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

    print(response$roll_call$desc)
    return(response)
  }, error = function(e) {
    stop(sprintf("Error in API request: %s", e$message))
  })
}
