# Offline assignment-first pages in RStudio Viewer.
# One Markdown source per compact lesson, no web service.

.ru_lesson_root <- function() system.file("lessons",package="rulearn")

.ru_lesson_read <- function(id) {
  if(!grepl("^[a-z][a-z0-9_]*$",id)) return(NULL)
  file <- file.path(.ru_lesson_root(),paste0(id,".md"))
  if(!file.exists(file)) return(NULL)
  lines <- readLines(file,warn=FALSE,encoding="UTF-8")
  if(length(lines)<15L || lines[1L]!="---")
    stop("Invalid lesson source: ",id,call.=FALSE)
  term <- which(lines[-1L]=="---")
  if(!length(term)) stop("Unterminated lesson metadata: ",id,call.=FALSE)
  end <- term[1L]+1L
  meta <- list()
  for(line in lines[seq.int(2L,end-1L)]) {
    pos <- regexpr(":",line,fixed=TRUE)[1L]
    if(pos>1L)
      meta[[substr(line,1L,pos-1L)]] <- trimws(substr(line,pos+1L,nchar(line)))
  }
  required <- c("id","type","domain","aliases","related",
                "visual","alt","caption","sources","status")
  if(!all(required %in% names(meta)) || !identical(meta$id,id))
    stop("Incomplete lesson metadata: ",id,call.=FALSE)
  sections <- list(); section <- ""; title <- ""
  if(end<length(lines))
    for(line in lines[seq.int(end+1L,length(lines))]) {
      if(startsWith(line,"# ")) title <- substring(line,3L)
      else if(startsWith(line,"## ")) {
        section <- tolower(trimws(substring(line,4L)))
        if(!section %in% names(sections)) sections[[section]] <- character()
      } else if(nzchar(section)) sections[[section]] <- c(sections[[section]],line)
    }
  mandatory <- c("immediate answer","what to check",
                 "interpret your results","learn more")
  if(!all(mandatory %in% names(sections)) || !nzchar(title))
    stop("Required lesson sections missing: ",id,call.=FALSE)
  # Conceptual exam study need not invent code.
  code <- ""
  rows <- list()
  if("use this in r" %in% names(sections)) {
    chunk <- sections[["use this in r"]]
    start <- grep("^```r[[:space:]]*$",chunk)
    stop <- which(chunk=="```")
    if(length(start)!=1L || length(stop)!=1L || stop<=start+1L)
      stop("Expected exactly one native R block: ",id,call.=FALSE)
    code <- paste(chunk[seq.int(start+1L,stop-1L)],collapse="\n")
    if(!nzchar(trimws(code)))stop("Empty code block: ",id,call.=FALSE)
    if(!"what to edit" %in% names(sections))
      stop("R example must explain editable elements: ",id,call.=FALSE)
    table <- sections[["what to edit"]]
    table <- table[grepl("^\\|",table)]
    if(length(table)<3L) stop("Edit table missing: ",id,call.=FALSE)
    table <- table[-c(1L,2L)]
    rows <- lapply(table,function(line) {
      line <- sub("^\\|","",sub("\\|$","",line))
      v <- trimws(strsplit(line,"|",fixed=TRUE)[[1L]])
      if(length(v)!=3L) stop("Invalid edit row: ",id,call.=FALSE)
      v
    })
  } else if("what to edit" %in% names(sections)) {
    stop("Concept-only lesson must omit code-edit table: ",id,call.=FALSE)
  }
  if(!nzchar(code) && !"exam answer pattern" %in% names(sections))
    stop("Concept-only lesson needs exam answer pattern: ",id,call.=FALSE)
  list(id=id,title=title,meta=meta,sections=sections,
       code=code,edit=rows,source=file)
}

.ru_lesson_index <- function() {
  folder <- .ru_lesson_root()
  blank <- data.frame(id=character(),type=character(),title=character(),
                      keywords=character(),status=character(),
                      stringsAsFactors=FALSE)
  if(!nzchar(folder)) return(blank)
  paths <- sort(list.files(folder,pattern="^[a-z0-9_]+[.]md$",full.names=FALSE))
  if(!length(paths)) return(blank)
  do.call(rbind,lapply(paths,function(x) {
    item <- .ru_lesson_read(tools::file_path_sans_ext(x))
    data.frame(id=item$id,type=item$meta$type,title=item$title,
               keywords=paste(item$meta$aliases,item$meta$domain),
               status=item$meta$status,stringsAsFactors=FALSE)
  }))
}
.ru_html_escape <- function(x) {
  x <- gsub("&","&amp;",x,fixed=TRUE)
  x <- gsub("<","&lt;",x,fixed=TRUE)
  x <- gsub(">","&gt;",x,fixed=TRUE)
  x <- gsub('"',"&quot;",x,fixed=TRUE)
  gsub("'","&#39;",x,fixed=TRUE)
}
.ru_inline <- function(text) {
  pieces <- strsplit(.ru_html_escape(text),intToUtf8(96L),fixed=TRUE)[[1L]]
  if(length(pieces)==1L) return(pieces)
  paste0(vapply(seq_along(pieces),function(i)
    if(i%%2L==0L) paste0("<code>",pieces[i],"</code>") else pieces[i],
    character(1L)),collapse="")
}
.ru_rich_paragraphs <- function(lines) {
  lines <- trimws(lines);lines <- lines[nzchar(lines)]
  if(!length(lines)) return("")
  paste0(vapply(lines,function(line) {
    if(grepl("^- ",line))
      paste0("<p class='check-line'><span aria-hidden='true'>&bull; </span>",
             .ru_inline(sub("^- ","",line)),"</p>")
    else paste0("<p>",.ru_inline(line),"</p>")
  },character(1L)),collapse="\n")
}
.ru_safe_id <- function(id) grepl("^[a-z][a-z0-9_]*$",id)
.ru_related <- function(item) {
  ids <- trimws(strsplit(item$meta$related,";",fixed=TRUE)[[1L]])
  ids <- ids[nzchar(ids)]
  if(!length(ids))return("")
  labels <- vapply(ids,function(id) {
    if(!.ru_safe_id(id))return("")
    page <- .ru_lesson_read(id)
    if(is.null(page))return("")
    paste0("<a href='",id,".html'>",.ru_html_escape(page$title),"</a>")
  },character(1L))
  labels <- labels[nzchar(labels)]
  if(!length(labels))return("")
  paste0("<nav class='related' aria-label='Related topics'><h3>Related topics</h3>",
         paste(labels,collapse=" "),"</nav>")
}
.ru_table <- function(item) {
  labels <- c("Element","Controls","Replace with")
  rows <- vapply(item$edit,function(row) paste0(
    "<tr>",paste0("<td data-label='",labels,"'>",
                   vapply(row,.ru_inline,character(1L)),"</td>",collapse=""),
    "</tr>"),character(1L))
  paste0("<table class='edit'><thead><tr>",
         paste0("<th>",labels,"</th>",collapse=""),
         "</tr></thead><tbody>",paste(rows,collapse=""),"</tbody></table>")
}
.ru_visual <- function(item) {
  visual <- item$meta$visual
  if(!nzchar(visual))return("")
  if(!grepl("^[a-z0-9-]+[.]svg$",visual))
    stop("Invalid visual filename: ",item$id,call.=FALSE)
  paste0("<figure><img src='figures/",visual,"' width='480' alt='",
         .ru_html_escape(item$meta$alt),"'/>",
         "<figcaption>",.ru_inline(item$meta$caption),"</figcaption>",
         "<p class='visual-open'><a href='figures/",visual,
         "' target='_blank' rel='noopener noreferrer' aria-label='Open full-size illustration: ",
         .ru_html_escape(item$meta$alt),"'>",
         "Open full-size illustration (local)</a></p></figure>")
}
.ru_source_links <- function(item) {
  links <- trimws(strsplit(item$meta$sources,";",fixed=TRUE)[[1L]])
  links <- links[grepl("^https://[a-zA-Z0-9./?=&_-]+$",links)]
  if(!length(links))return("")
  paste0("<p class='sources'><strong>Sources:</strong> ",
         paste(vapply(links,function(link)paste0("<a href='",
             .ru_html_escape(link),"' rel='noopener noreferrer'>",
             .ru_html_escape(sub("^https://","",link)),"</a>"),character(1L)),
               collapse=" &middot; "),"</p>")
}
.ru_page_html <- function(item) {
  paste0("<article class='lesson' data-lesson='",item$id,"'>",
    "<p class='eyebrow'>",.ru_html_escape(item$meta$domain),"</p>",
    "<h1>",.ru_html_escape(item$title),"</h1>",
    if(!identical(item$meta$status,"VERIFIED"))
      "<p class='review-status'>Authored draft: source and editorial verification pending.</p>"
    else "",
    "<section class='immediate' aria-label='Immediate answer'><h2>Quick answer</h2>",
    .ru_rich_paragraphs(item$sections[["immediate answer"]]),"</section>",
    if("exam answer pattern" %in% names(item$sections))
      paste0("<section><h2>Answer pattern for study</h2>",
        .ru_rich_paragraphs(item$sections[["exam answer pattern"]]),"</section>")
    else "",
    if(nzchar(item$code))
      paste0("<section aria-label='Native R example'><h2>Use this in R</h2>",
        "<div class='code-toolbar'><span>Ordinary R &middot; editable</span>",
        "<button class='copy' data-target='code-",item$id,"' type='button' ",
        "aria-label='Copy this R code to the clipboard'>Copy</button></div>",
        "<pre class='r-code' tabindex='0' aria-label='Scrollable R code'><code id='code-",item$id,"'>",
        .ru_html_escape(item$code),"</code></pre>",
        "<p class='copy-status' aria-live='polite'></p></section>",
        "<section><h2>What to edit</h2>",.ru_table(item),"</section>")
    else "",
    "<section><h2>What to check</h2>",
    .ru_rich_paragraphs(item$sections[["what to check"]]),"</section>",
    "<section><h2>Interpret your results</h2>",
    .ru_rich_paragraphs(item$sections[["interpret your results"]]),"</section>",
    .ru_visual(item),
    "<details><summary>Learn more</summary><div class='details-body'>",
    .ru_rich_paragraphs(item$sections[["learn more"]]),
    .ru_source_links(item),"</div></details>",
    .ru_related(item),"</article>")
}
.ru_short_fallback <- function(item) {
  legacy <- identical(item$type,"walkthrough")
  if(legacy) {
    warn <- "This older walkthrough has not passed the compact native-R review. Its example may use ru_apply(), a compatibility wrapper."
    nextstep <- paste0("Use ru_edit('",item$id,"', mode='full') for the original editable script. Inspect native R help before applying it.")
  } else {
    warn <- "This topic has a native R Help article, but its compact Viewer lesson is not yet independently reviewed."
    nextstep <- paste0("Use help('",item$topic,"', package='rulearn') for the full offline reference.")
  }
  paste0("<article class='lesson'><p class='eyebrow'>",.ru_html_escape(item$type),
         " &middot; Further review needed</p><h1>",.ru_html_escape(item$title),"</h1>",
         "<section class='immediate'><h2>Current reference status</h2><p>",
         .ru_html_escape(warn),"</p><p>",.ru_html_escape(nextstep),
         "</p></section><p><a href='results.html'>Browse related topics</a></p></article>")
}
.ru_shell <- function(title,body) {
  paste0("<!doctype html>\n<html lang='en'><head><meta charset='UTF-8'>",
         "<meta name='viewport' content='width=device-width, initial-scale=1'>",
         "<meta http-equiv='Content-Security-Policy' ",
         "content=\"default-src 'none'; img-src 'self' data:; style-src 'self'; ",
         "script-src 'self'; connect-src 'none'; form-action 'none'; object-src 'none'; base-uri 'none'\">",
         "<title>",.ru_html_escape(title)," &mdash; R-u-learning-yet</title>",
         "<link href='field-atlas.css' rel='stylesheet'>",
         "<link href='reference.css' rel='stylesheet'></head>",
         "<body><main class='page'><header class='site-head'><a href='results.html'>",
         "<strong>R-u-learning-yet</strong></a><span>Offline RStudio reference</span></header>",
         body,"<footer>Running R code does not verify sampling or model assumptions.</footer></main>",
         "<script defer src='reference.js'></script></body></html>")
}