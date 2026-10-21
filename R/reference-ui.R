# Display installed references with native R Help and RStudio's existing panes.
.ru_rstudio_ready <- function(feature="previewRd") {
  requireNamespace("rstudioapi",quietly=TRUE) &&
    isTRUE(tryCatch(rstudioapi::isAvailable(),error=function(e) FALSE)) &&
    isTRUE(tryCatch(rstudioapi::hasFun(feature),error=function(e) FALSE))
}

.ru_console_rd <- function(rd) {
  text <- paste(utils::capture.output(tools::Rd2txt(rd)),collapse="\n")
  # Rd2txt creates printer-style underline/bold via a character then
  # backspace. Remove these controls for an ordinary Console display.
  gsub(paste0(".",intToUtf8(8L)),"",text,perl=TRUE)
}

.ru_help_page <- function(topic,package="rulearn") {
  page <- do.call(utils::help,list(topic=topic,package=package))
  if(!length(page))
    stop("No installed help article for ",topic,call.=FALSE)
  # Native R help dispatches to RStudio's Help pane when running in
  # the IDE, and to R's usual pager/terminal otherwise.
  print(page)
  invisible(page)
}

# Escape characters with special meaning in the Rd documentation syntax.
.ru_rd_escape <- function(text) {
  text <- gsub("\\","\\\\",text,fixed=TRUE)
  text <- gsub("{","\\{",text,fixed=TRUE)
  text <- gsub("}","\\}",text,fixed=TRUE)
  text <- gsub("%","\\%",text,fixed=TRUE)
  text
}

# Small presentation adapter: installed Quarto source -> temporary native Rd.
# This does not duplicate the authoritative text or add a rendering dependency.
.ru_rd_inline <- function(line) {
  pattern <- "(`[^`]+`|\\*\\*[^*]+\\*\\*|\\[[^]]+\\]\\([^)]*\\))"
  spans <- gregexpr(pattern,line,perl=TRUE)[[1L]]
  if(length(spans)==1L && spans[1L]==-1L) {
    if(grepl("^[-*] ",line)) line <- paste0("  ",substring(line,3L))
    return(.ru_rd_escape(line))
  }
  lens <- attr(spans,"match.length")
  result <- character()
  last <- 1L
  for(i in seq_along(spans)) {
    from <- spans[i]
    if(from>last) result <- c(result,.ru_rd_escape(substr(line,last,from-1L)))
    token <- substr(line,from,from+lens[i]-1L)
    if(startsWith(token,"`")) {
      result <- c(result,paste0("\\code{",
                               .ru_rd_escape(substr(token,2L,nchar(token)-1L)),"}"))
    } else if(startsWith(token,"**")) {
      result <- c(result,paste0("\\strong{",
                               .ru_rd_escape(substr(token,3L,nchar(token)-2L)),"}"))
    } else {
      m <- regmatches(token,regexec("^\\[([^]]+)\\]\\(([^)]+)\\)$",token))[[1L]]
      if(length(m)==3L && grepl("^https?://",m[3L]))
        result <- c(result,paste0("\\href{",.ru_rd_escape(m[3L]),
                                 "}{",.ru_rd_escape(m[2L]),"}"))
      else if(length(m)==3L)
        result <- c(result,.ru_rd_escape(m[2L]))
      else
        result <- c(result,.ru_rd_escape(token))
    }
    last <- from+lens[i]
  }
  if(last<=nchar(line))
    result <- c(result,.ru_rd_escape(substr(line,last,nchar(line))))
  paste0(result,collapse="")
}

.ru_quarto_guide_to_rd <- function(id) {
  path <- system.file("guides",paste0(id,".qmd"),package="rulearn")
  script <- system.file("examples",paste0(id,".R"),package="rulearn")
  if(!nzchar(path)) stop("Installed guide missing for ",id,call.=FALSE)
  lines <- readLines(path,warn=FALSE,encoding="UTF-8")
  title <- id
  if(length(lines)>=3L && identical(lines[1L],"---")) {
    front_end <- which(lines[-1L]=="---")[1L]+1L
    if(!is.na(front_end)) {
      header <- lines[seq.int(2L,front_end-1L)]
      title_line <- grep("^title:",header,value=TRUE)
      if(length(title_line)) {
        title <- trimws(sub("^title:\\s*","",title_line[1L]))
        title <- sub('^"(.*)"$',"\\1",title)
      }
      lines <- if(front_end<length(lines))lines[-seq_len(front_end)] else character()
    }
  }
  native <- if(nzchar(script)) readLines(script,warn=FALSE,encoding="UTF-8") else character()
  quick_at <- grep("^## ---- quick-",native)
  worked_at <- grep("^## ---- worked-",native)
  section_source <- function(kind) {
    if(length(quick_at)!=1L || length(worked_at)!=1L ||
       worked_at<=quick_at) stop("Invalid canonical labels for ",id,call.=FALSE)
    if(kind=="quick") native[seq.int(quick_at+1L,worked_at-1L)]
    else native[seq.int(worked_at+1L,length(native))]
  }
  uses_wrapper <- any(grepl("ru_apply\\(",lines,perl=TRUE))
  intro <- if(uses_wrapper)
    paste0("Older compatibility guide: examples using ru_apply() run a ",
           "rulearn wrapper, not ordinary R functions. Use native R help ",
           "for underlying commands. Preserve appropriate study assumptions.")
  else
    paste0("This walkthrough teaches ordinary R code. Get a Source-editor ",
           "copy with ru_edit('",id,"',mode='quick') when available, ",
           "or mode='full' for the annotated version.")
  rd <- c(paste0("\\name{rulearn-guide-",id,"}"),
          paste0("\\alias{rulearn-guide-",id,"}"),
          paste0("\\title{",.ru_rd_escape(title),"}"),
          paste0("\\description{",.ru_rd_escape(intro),"}"))
  current <- FALSE
  i <- 1L
  while(i<=length(lines)) {
    line <- lines[i]
    if(grepl("^#{1,4} ",line)) {
      if(current) rd <- c(rd,"}")
      rd <- c(rd,paste0("\\section{",.ru_rd_escape(sub("^#{1,4} +","",line)),"}{"))
      current <- TRUE
      if(grepl("^## Complete walkthrough",line))
        rd <- c(rd,"Optional detailed instructions follow. Use the short answer above if it is sufficient.")
      i <- i+1L
      next
    }
    if(grepl("^```",line)) {
      after <- which(lines=="```" & seq_along(lines)>i)
      if(!length(after)) stop("Unterminated code block for ",id,call.=FALSE)
      until <- after[1L]
      code <- if(until==i+1L) character() else lines[seq.int(i+1L,until-1L)]
      if(grepl("^```\\{r",line)) {
        if(grepl("setup-quick|setup-worked",line)) code <- character()
        else if(grepl("quick-",line) && length(quick_at)==1L)
          code <- section_source("quick")
        else if(grepl("worked-",line) && length(worked_at)==1L)
          code <- section_source("worked")
        code <- code[!grepl("^\\s*#\\|",code)]
        code <- code[!grepl("^\\s*knitr::read_chunk\\(",code)]
      }
      if(length(code) && any(nzchar(trimws(code)))) {
        if(!current) {
          rd <- c(rd,"\\section{R code}{")
          current <- TRUE
        }
        rd <- c(rd,"\\preformatted{",.ru_rd_escape(paste(code,collapse="\n")),"}")
      }
      i <- until+1L
      next
    }
    if(grepl("^\\[[^]]+\\]\\(\\.\\./examples/",line))
      line <- paste0("Get an editable script: `ru_edit('",id,"')`.")
    if(nzchar(trimws(line))) {
      if(!current) {rd <- c(rd,"\\section{Explanation}{"); current <- TRUE}
      rd <- c(rd,.ru_rd_inline(line))
    } else if(current) rd <- c(rd,"")
    i <- i+1L
  }
  if(current) rd <- c(rd,"}")
  rd <- c(rd,paste0("\\seealso{\\code{ru_edit('",id,
                    "', mode='full')}, \\code{ru_find('",id,"')}}"))
  rdpath <- file.path(tempdir(),paste0("rulearn-guide-",id,".Rd"))
  writeLines(rd,rdpath,useBytes=TRUE)
  tools::parse_Rd(rdpath)
  rdpath
}

.ru_show_guide <- function(id) {
  page <- .ru_quarto_guide_to_rd(id)
  if(.ru_rstudio_ready("previewRd")) {
    tryCatch(rstudioapi::previewRd(page),error=function(e) {
      warning("RStudio Help preview did not open: ",conditionMessage(e),
              ". Showing the readable Console version.",call.=FALSE)
      cat(.ru_console_rd(tools::parse_Rd(page)),"\n",sep="")
    })
  } else {
    cat(.ru_console_rd(tools::parse_Rd(page)),"\n",sep="")
  }
  invisible(page)
}