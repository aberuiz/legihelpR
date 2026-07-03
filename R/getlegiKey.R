#' Return legiscan API key
#'
#' @description
#' Returns the legiscan API Key set in the environment
#'
#' @export
getlegiKey <- function(){
  legiKey <- Sys.getenv("legiKey")
  if (!nzchar(legiKey)){
    return(NULL)
  }
  return(legiKey)
}
