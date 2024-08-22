#' Return a specific bill
#'
#' @description
#' Return a specific bill based on a legiscan bill_id
#'
#' @param billID bill_id integer value
#'
#' @examples
#' getBill(billID = 1633853)
#'
#' @export
getBill <- function(billID = NULL, legiKey = NULL, op = "getBill"){
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
      id = billID,
      .multi = "explode"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  print(
    paste0(req$bill$bill_number, " from ", req$bill$state, " ", req$bill$session$session_name)
  )
  return(req$bill)
}
