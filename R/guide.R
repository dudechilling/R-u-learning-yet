# Show one installed guide as a readable native Rd topic.
# The existing Quarto and R files remain the one canonical source.
ru_guide <- function(query) {
  hits <- .ru_search_results(query,n=3L,type="walkthrough")
  if(!nrow(hits)) return(invisible(NULL))
  first <- hits[1L,,drop=FALSE]
  if(.ru_rstudio_ready("viewer"))
    .ru_viewer_show(first,query,force_page=first$id)
  invisible(system.file("guides",paste0(first$id,".qmd"),package="rulearn"))
}

# Copy an editable ordinary R script. Revised guides keep an immediate
# answer and a detailed example in one canonical source file, but the
# student's edited copy contains only the requested part by default.
ru_edit <- function(query, dir=getwd(), open=interactive(),
                    mode=c("full","quick","both")) {
  mode <- match.arg(mode)
  if(!is.character(query) || length(query)!=1L || is.na(query))
    stop("Provide one reference topic or question.",call.=FALSE)
  hits <- .ru_search_results(query,n=1L)
  if(!nrow(hits)) return(invisible(NULL))
  id <- hits$id[1L]
  lesson <- .ru_lesson_read(id)
  # Use the exact installed script for an original worked guide. Do not
  # invoke the legacy fuzzy picker for a new compact lesson: it could
  # print an unrelated match or copy the wrong statistical operation.
  source <- system.file("examples",paste0(id,".R"),package="rulearn")
  if(!dir.exists(dir))stop("The requested directory does not exist.",call.=FALSE)
  if(!nzchar(source)) {
    if(is.null(lesson) || !nzchar(lesson$code)) return(invisible(NULL))
    dest <- file.path(dir,paste0("ru-",lesson$id,".R"))
    if(file.exists(dest))stop("Refusing to overwrite ",dest,call.=FALSE)
    writeLines(lesson$code,dest,useBytes=TRUE)
    if(isTRUE(open)) {
      if(.ru_rstudio_ready("navigateToFile"))
        tryCatch(rstudioapi::navigateToFile(dest),error=function(e)
          utils::file.edit(dest))
      else utils::file.edit(dest)
    }
    return(invisible(normalizePath(dest)))
  }
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
