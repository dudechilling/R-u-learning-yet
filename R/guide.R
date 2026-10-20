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
      before <- if(begin>1L) lines[seq_len(begin-1L)] else character()
      after <- if(close[2L]<length(lines))
        lines[seq.int(close[2L]+1L,length(lines))] else character()
      lines <- c(before,"```r",native,"```",after)
    } else {
      stop("The guide contains an invalid external-code reference for ",
           item$id,call.=FALSE)
    }
  }
  cat(paste(lines,collapse="\n"),"\n",sep="")
  invisible(path)
}

# Copy a self-contained .R script into the user's project to edit in RStudio.
ru_edit <- function(query, dir=getwd(), open=interactive()) {
  source <- .ru_example(query)
  if (is.null(source)) return(invisible(NULL))
  if (!dir.exists(dir)) stop("The requested directory does not exist.")
  dest <- file.path(dir,paste0("ru-",basename(source)))
  if (file.exists(dest))
    stop("Refusing to overwrite ",dest,
         ". Move or rename the existing file before retrying.",call.=FALSE)
  if (!file.copy(source,dest,overwrite=FALSE))
    stop("Could not copy the example to ",dest,call.=FALSE)
  message("Editable copy: ",normalizePath(dest))
  if (isTRUE(open)) utils::file.edit(dest)
  invisible(normalizePath(dest))
}