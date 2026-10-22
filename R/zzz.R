# Attachment is the only automatic UI event. Namespace loading stays silent.
# The narrow callback boundary protects package usability if home display fails.
.ru_attach_home <- function(is_interactive=interactive(),
                            enabled=getOption("rulearn.auto_home",TRUE),
                            ready=function() .ru_rstudio_ready("viewer"),
                            open=function() ru_home(),
                            notify=packageStartupMessage) {
  if(!isTRUE(is_interactive) || !isTRUE(enabled)) return(invisible(FALSE))
  tryCatch({
    if(!isTRUE(ready())) return(invisible(FALSE))
    open()
    invisible(TRUE)
  },error=function(e) {
    notify(paste0("rulearn home could not open: ",conditionMessage(e),
                  ". Use ru_home() or help(package='rulearn')."))
    invisible(FALSE)
  })
}
.onAttach <- function(libname,pkgname) .ru_attach_home()
