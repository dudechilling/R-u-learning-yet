# Read the one canonical Quarto guide bundled with the installed package.
ru_guide <- function(query) {
  item <- .ru_pick(query)
  if (is.null(item)) return(invisible(NULL))
  path <- system.file("guides",paste0(item$id,".qmd"),package="rulearn")
  if (!nzchar(path))
    stop("The installed guide is missing for ",item$id,call.=FALSE)
  lines <- readLines(path,warn=FALSE,encoding="UTF-8")
  if (length(lines)>=3L && lines[1L]=="---") {
    second <- which(lines[-1L]=="---")
    if (length(second)) lines <- lines[-seq_len(second[1L]+1L)]
  }
  # The Quarto page executes this exact script using read_chunk().
  # Expand it in the Console as well, rather than maintaining two code copies.
  begin <- grep("^```[{]r setup-worked-",lines)
  if (length(begin)==1L) {
    close <- which(lines=="```" & seq_along(lines)>begin)
    start_code <- grep("^```[{]r worked-",lines)
    start_code <- start_code[start_code>begin]
    if (length(close)>=2L && length(start_code)==1L &&
        close[1L]<start_code[1L] && close[2L]>start_code[1L]) {
      script <- system.file("examples",paste0(item$id,".R"),
                            package="rulearn")
      if (!nzchar(script))
        stop("The example script is missing for ",item$id,call.=FALSE)
      native <- readLines(script,warn=FALSE,encoding="UTF-8")
      # The script can contain a separate short quick example. Expand only
      # the detailed section at this point; the short section is added below.
      worked <- grep("^## ---- worked-",native)
      if (length(worked)!=1L || worked>=length(native))
        stop("Missing canonical worked R code for ",item$id,call.=FALSE)
      native <- native[seq.int(worked+1L,length(native))]
      before <- if(begin>1L) lines[seq_len(begin-1L)] else character()
      after <- if(close[2L]<length(lines))
        lines[seq.int(close[2L]+1L,length(lines))] else character()
      lines <- c(before,"```r",native,"```",after)
    } else {
      stop("The guide contains an invalid external-code reference for ",
           item$id,call.=FALSE)
    }
  }
  # Expand the optional quick example from the SAME installed script.
  # Quarto extracts both chunks using knitr::read_chunk(); the Console
  # displays the exact R lines instead of showing empty Quarto fences.
  quick_setup <- grep("^```[{]r setup-quick-",lines)
  if(length(quick_setup)==1L) {
    file <- system.file("examples",paste0(item$id,".R"),package="rulearn")
    if (!nzchar(file))
      stop("Quick-example source missing for ",item$id,call.=FALSE)
    full <- readLines(file,warn=FALSE,encoding="UTF-8")
    quick_at <- grep("^## ---- quick-",full)
    worked_at <- grep("^## ---- worked-",full)
    if(length(quick_at)!=1L || length(worked_at)!=1L ||
       worked_at<=quick_at+1L)
      stop("Invalid quick-example sections for ",item$id,call.=FALSE)
    quick <- full[seq.int(quick_at+1L,worked_at-1L)]
    close_setup <- which(lines=="```" & seq_along(lines)>quick_setup)[1L]
    if (is.na(close_setup))
      stop("Invalid Quarto setup for ",item$id,call.=FALSE)
    lines <- lines[-seq.int(quick_setup,close_setup)]
    q <- grep("^```[{]r quick-",lines)
    if(length(q)!=1L)
      stop("Missing quick-example display for ",item$id,call.=FALSE)
    qend <- which(lines=="```" & seq_along(lines)>q)[1L]
    if(is.na(qend))
      stop("Unterminated quick-example display for ",item$id,call.=FALSE)
    before <- if(q>1L) lines[seq_len(q-1L)] else character()
    after <- if(qend<length(lines))
      lines[seq.int(qend+1L,length(lines))] else character()
    lines <- c(before,"```r",quick,"```",after)
  }
  cat(paste(lines,collapse="\n"),"\n",sep="")
  invisible(path)
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
  if (isTRUE(open)) utils::file.edit(dest)
  invisible(normalizePath(dest))
}
