#' Set a legiscan api key
#'
#'  @description
#'  Every request requires a legiscan api key to be set in order to complete a request.
#'
#' @param APIkey 32 character string given to you by legiscan.com
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
    if(file.exists(renv)){
      # Backup original .Renviron
      file.copy(renv, file.path(home, ".Renviron_backup"))
    }
    if(!file.exists(renv)){
      file.create(renv)
    }
    else{
      if(isTRUE(overwrite)){
        message("Your original .Renviron will be backed up in R HOME directory.")
        oldenv = read.table(renv, stringsAsFactors = FALSE)
        newenv <- oldenv[-grep("legiKey", oldenv),]
        write.table(newenv, renv, quote = FALSE, sep = "\n",
                    col.names = FALSE, row.names = FALSE)
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
    message('Your legiscan API key has been stored in your .Renviron and can be accessed by Sys.getenv("beaKey"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
    return(legiKey)
  } else {
    message("To install your legiscan API key for future sessions, run this function with `install = TRUE`.")
    Sys.setenv(legiKey = APIkey)
  }

}
