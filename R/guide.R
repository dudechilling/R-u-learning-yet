# Show one installed guide as a readable native Rd topic.
# The existing Quarto and R files remain the one canonical source.
ru_guide <- function(query) {
  item <- .ru_pick(query)
  if(is.null(item)) return(invisible(NULL))
  .ru_show_guide(item$id)
}

# Copy an editable ordinary R script. Revised guides keep an immediate
# answer and a detailed example in one canonical source file, but the
# student's edited copy contains only the requested part by default.
ru_edit <- function(query, dir=getwd(), open=interactive(),
                    mode=c("full","quick","both")) {
  mode <- match.arg(mode)
  source <- .ru_example(query)
  if (is.null(source)) return(invisible(NULL))
  if (!dir.exists(dir)) stop("The requested directory does not exist.")
  original <- readLines(source,warn=FALSE,encoding="UTF-8")
  quick <- grep("^## ---- quick-",original)
  worked <- grep("^## ---- worked-",original)
  has_sections <- length(quick)==1L && length(worked)==1L &&
                  quick<worked
  if (mode=="quick" && !has_sections)
    stop("This guide has no independently runnable quick example. ",
         "Use mode='full' instead.",call.=FALSE)
  suffix <- if (mode=="full") "" else paste0("-",mode)
  dest <- file.path(dir,paste0("ru-",tools::file_path_sans_ext(
    basename(source)),suffix,".R"))
  if (file.exists(dest))
    stop("Refusing to overwrite ",dest,
         ". Move or rename the existing file before retrying.",call.=FALSE)

  if (has_sections && mode!="both") {
    lines <- if (mode=="quick")
      original[seq.int(quick+1L,worked-1L)]
    else
      original[seq.int(worked+1L,length(original))]
    if (!length(lines) || !any(nzchar(trimws(lines))))
      stop("The requested R example contains no executable code.",call.=FALSE)
    writeLines(lines,dest,useBytes=TRUE)
  } else {
    if (!file.copy(source,dest,overwrite=FALSE))
      stop("Could not copy the example to ",dest,call.=FALSE)
  }
  message("Editable copy: ",normalizePath(dest))
  if(isTRUE(open)) {
    if(.ru_rstudio_ready("navigateToFile")) {
      tryCatch(rstudioapi::navigateToFile(dest),error=function(e) {
        warning("RStudio Source editor did not open: ",conditionMessage(e),
                call.=FALSE)
        utils::file.edit(dest)
      })
    } else {
      utils::file.edit(dest)
    }
  }
  invisible(normalizePath(dest))
}
