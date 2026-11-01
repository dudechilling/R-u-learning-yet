# Open an installed walkthrough in the Viewer or return its Quarto path.
# The guide explains the method; its paired R script supplies runnable code.
ru_guide <- function(query) {
  # W5 guides are presentation only. Resolve exactly as public ru_find()
  # does; never let a method-name substring outrank the data/design roles.
  resolved <- .ru_w5_method_resolve(query,n=1L)
  if (resolved$status %in% c("AMBIGUOUS","UNSUPPORTED","NO_MATCH"))
    return(invisible(NULL))
  if (identical(resolved$status,"METHOD")) {
    guide <- .ru_w5_method_guide(query,method_id=resolved$method_id)
    if (!is.null(guide)) {
      render <- get0(".ru_w5_method_render",mode="function",inherits=TRUE)
      if (!is.null(render) && .ru_rstudio_ready("viewer"))
        tryCatch(render(guide,open=TRUE),error=function(e) NULL)
      return(invisible(guide))
    }
    # Six IDs have no new W5 teaching guide. Offer only their actual
    # installed legacy guide, if present, never a different method.
    id <- resolved$method_id
    path <- system.file("guides",paste0(id,".qmd"),package="rulearn")
    if (!nzchar(path)) return(invisible(NULL))
    if (.ru_rstudio_ready("viewer")) {
      first <- .ru_catalog()
      first <- first[first$id==id & first$type=="walkthrough",,drop=FALSE]
      if (nrow(first)) .ru_viewer_show(first[1L,,drop=FALSE],query,
                                     force_page=id)
    }
    return(invisible(path))
  }
  # A legacy reference is eligible only when the SAME first-ranked public
  # ru_find() hit has a real installed guide. Never perform a second fuzzy
  # walkthrough search that silently changes the method identity.
  hits <- resolved$hits
  if (!nrow(hits)) return(invisible(NULL))
  first <- hits[1L,,drop=FALSE]
  if (!identical(first$type[[1L]],"walkthrough"))
    return(invisible(NULL))
  path <- system.file("guides",paste0(first$id[[1L]],".qmd"),
                      package="rulearn")
  if (!nzchar(path)) return(invisible(NULL))
  if (.ru_rstudio_ready("viewer"))
    .ru_viewer_show(first,query,force_page=first$id[[1L]])
  invisible(path)
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
