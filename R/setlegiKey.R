#' Set a legiscan api key
#'
#' @description
#' Every request requires a legiscan api key to be set in order to complete a request.
#'
#' @param APIkey 32 character string given to you by legiscan.com
#'
#' @param install Store the key in your .Renviron file for use across sessions
#'
#' @param overwrite Overwrite a previously installed key in your .Renviron file
#'
#' @return Your legiscan API key is set for data requests
#'
#' @export
setlegiKey <- function(APIkey, install = FALSE, overwrite = FALSE){

  if (!rlang::is_string(APIkey)){
    stop("'APIkey` must be a string.")
  }
  if (nchar(APIkey)!=32){
    stop(paste0("'Invalid API Key: ",APIkey," Register @ <https://legiscan.com/user/register>'"))
  }

  if (install) {
    home <- Sys.getenv("HOME")
    renv <- file.path(home, ".Renviron")
    if(!file.exists(renv)){
      file.create(renv)
    }
    else{
      if(isTRUE(overwrite)){
        # Back up only when overwriting, i.e. when we are about to rewrite the
        # file to strip the old key. The non-overwrite path merely appends and
        # leaves the original intact, so backing up there would needlessly
        # clobber any existing .Renviron_backup with no benefit.
        message("Your original .Renviron will be backed up in R HOME directory.")
        file.copy(renv, file.path(home, ".Renviron_backup"), overwrite = TRUE)
        oldenv <- readLines(renv)
        newenv <- oldenv[!grepl("legiKey", oldenv)]
        writeLines(newenv, renv)
      }
      else{
        tv <- readLines(renv)
        if(any(grepl("legiKey",tv))){
          stop("legiKey has previously been set. Overwrite it with the argument 'overwrite=TRUE'", call.=FALSE)
        }
      }
    }

    newKey <- paste0("legiKey='", APIkey, "'")
    # Append API key to .Renviron file
    write(newKey, renv, sep = "\n", append = TRUE)
    message('Your legiscan API key has been stored in your .Renviron and can be accessed by Sys.getenv("legiKey"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
    return(invisible(APIkey))
  } else {
    message("To install your legiscan API key for future sessions, run this function with `install = TRUE`.")
    Sys.setenv(legiKey = APIkey)
  }

}
