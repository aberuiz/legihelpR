#' Return legiscan API key
#'
#' @description
#' Returns the legiscan API Key set in the environment
#'
#' @returns The API key as a character string, or \code{NULL} when the environment
#' variable is unset or empty.
#'
#' @export
getlegiKey <- function(){
  legiKey <- Sys.getenv("legiKey")
  if (!nzchar(legiKey)){
    return(NULL)
  }
  return(legiKey)
}
