# Local static Viewer navigation. All generated files live in an R tempdir.
.ru_viewer_dir <- function() file.path(tempdir(),"rulearn-reference")

# The canonical scoped topic ledger is shipped without private course links.
.ru_coverage <- function() {
  file <- system.file("extdata","coverage.csv",package="rulearn")
  if(!nzchar(file))stop("The installed topic coverage index is missing.",call.=FALSE)
  utils::read.csv(file,stringsAsFactors=FALSE,fileEncoding="UTF-8",
                  na.strings=character())
}
.ru_write_catalog <- function(folder) {
  topics <- .ru_coverage()
  sections <- vapply(unique(topics$domain),function(domain) {
    data <- topics[topics$domain==domain,,drop=FALSE]
    items <- vapply(seq_len(nrow(data)),function(i) {
      row <- data[i,]
      reference <- row$reference_id
      available <- identical(row$content_status,"VERIFIED") &&
                   .ru_safe_id(reference) &&
                   file.exists(file.path(folder,paste0(reference,".html")))
      title <- .ru_html_escape(row$canonical_question)
      label <- .ru_html_escape(row$content_status)
      if(available) paste0("<li><a href='",reference,".html'>",
                            title,"</a><small> &middot; ",label,"</small></li>")
      else paste0("<li>",title,"<small> &middot; ",label,
                  " (compact page pending)</small></li>")
    },character(1L))
    paste0("<details class='catalog-group'><summary>",.ru_html_escape(domain),
           " &middot; ",nrow(data)," topics</summary><ul>",
           paste(items,collapse=""),"</ul></details>")
  },character(1L))
  counts <- table(factor(topics$content_status,
              levels=c("VERIFIED","NEEDS_REVIEW","DISCOVERED")))
  intro <- paste0("<h1>Topic coverage</h1>",
    "<p>",nrow(topics)," scoped topics. ",
    as.integer(counts["VERIFIED"])," compact lessons verified in automated R tests; ",
    as.integer(counts["NEEDS_REVIEW"])," need revision and ",
    as.integer(counts["DISCOVERED"])," await fuller source review.</p>",
    "<p>Incomplete topics are indexed for planning, not represented as finished teaching material.</p>")
  writeLines(.ru_shell("Topic coverage",paste0(intro,paste(sections,collapse=""))),
             file.path(folder,"catalog.html"),useBytes=TRUE)
}
.ru_viewer_prepare <- function(hits=NULL,query="") {
  folder <- .ru_viewer_dir()
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  dir.create(file.path(folder,"figures"),recursive=TRUE,showWarnings=FALSE)
  assets <- system.file("www",package="rulearn")
  if(!nzchar(assets)) stop("Installed offline Viewer assets missing.",call.=FALSE)
  for(file in c("reference.css","reference.js")) {
    if(!file.copy(file.path(assets,file),file.path(folder,file),overwrite=TRUE))
      stop("Could not stage Viewer asset: ",file,call.=FALSE)
  }
  figs <- list.files(file.path(assets,"figures"),pattern="[.]svg$",full.names=TRUE)
  if(length(figs))
    if(!all(file.copy(figs,file.path(folder,"figures"),overwrite=TRUE)))
      stop("Could not stage illustration assets.",call.=FALSE)

  catalog <- .ru_catalog()
  catalog <- catalog[!duplicated(catalog$id),,drop=FALSE]
  for(i in seq_len(nrow(catalog))) {
    item <- catalog[i,]
    if(!.ru_safe_id(item$id))stop("Unsafe reference ID.",call.=FALSE)
    lesson <- .ru_lesson_read(item$id)
    body <- if(!is.null(lesson)) .ru_page_html(lesson)
            else .ru_short_fallback(item)
    writeLines(.ru_shell(item$title,body),
               file.path(folder,paste0(item$id,".html")),useBytes=TRUE)
  }
  .ru_write_results(hits,query,folder,catalog)
  .ru_write_catalog(folder)
  folder
}
.ru_write_results <- function(hits,query,folder,catalog) {
  if(is.null(hits)) hits <- catalog
  # Distinct IDs can have multiple content types; one link per real article.
  hits <- hits[!duplicated(hits$id),,drop=FALSE]
  if(!nrow(hits)) {
    text <- paste0("<section class='immediate'><h1>No matching local reference</h1>",
                   "<p>No reviewed topic matched <strong>",
                   .ru_html_escape(query),"</strong>.</p>",
                   "<p>Try a more specific method or open the topic catalogue. ",
                   "Do not use an unrelated statistical procedure.</p></section>")
  } else {
    items <- vapply(seq_len(nrow(hits)),function(i) {
      item <- hits[i,]
      lesson <- .ru_lesson_read(item$id)
      label <- if(is.null(lesson)) "Existing guide - not yet compact"
               else "Compact native-R reference"
      paste0("<li><a href='",item$id,".html'>",
             "<span class='result-title'>",.ru_html_escape(item$title),"</span>",
             "<span class='result-type'>",.ru_html_escape(label),"</span></a></li>")
    },character(1L))
    text <- paste0("<h1>",if(nzchar(query)) "Search results" else "Reference topics",
                   "</h1><p>",
                   if(nzchar(query))paste0("Matching topics for <strong>",
                     .ru_html_escape(query),"</strong>. Choose the method ",
                     "that fits your data and question.")
                   else "Browse the local reference collection.",
                   "</p><ol class='results'>",paste(items,collapse=""),
                   "</ol>")
  }
  writeLines(.ru_shell(if(nrow(hits)) "Search results" else "No match",text),
             file.path(folder,"results.html"),useBytes=TRUE)
}

.ru_is_clear_match <- function(query,hits) {
  if(nrow(hits)==1L) return(TRUE)
  if(!nrow(hits))return(FALSE)
  first <- hits$id[1L]
  lesson <- .ru_lesson_read(first)
  if(is.null(lesson)) return(FALSE)
  q <- tolower(trimws(query))
  if(q==first || grepl(first,q,fixed=TRUE))return(TRUE)
  alias <- trimws(strsplit(tolower(lesson$meta$aliases),";",fixed=TRUE)[[1L]])
  alias <- alias[nchar(alias)>=4L]
  # Explicit subject phrase in the question, excluding the generic word data.
  if(any(vapply(alias,function(a)grepl(a,q,fixed=TRUE),logical(1L))))
    return(TRUE)
  query_terms <- .ru_words(query)
  title_terms <- .ru_words(lesson$title)
  length(intersect(query_terms,title_terms))>=2L &&
    !any(c("statistics","data","variable","variables") %in%
           setdiff(query_terms,title_terms))
}

.ru_viewer_show <- function(hits=NULL,query="",force_page=NULL) {
  if(!.ru_rstudio_ready("viewer")) return(invisible(NULL))
  folder <- .ru_viewer_prepare(hits=hits,query=query)
  target <- "results.html"
  if(!is.null(force_page) && .ru_safe_id(force_page) &&
     file.exists(file.path(folder,paste0(force_page,".html"))))
    target <- paste0(force_page,".html")
  else if(!is.null(hits) && .ru_is_clear_match(query,hits))
    target <- paste0(hits$id[1L],".html")
  path <- file.path(folder,target)
  rstudioapi::viewer(path)
  invisible(path)
}

# Explicit text mode for ordinary R terminals, not a routine side effect of search.
ru_text <- function(query) {
  if(!is.character(query) || length(query)!=1L || is.na(query))
    stop("Provide one reference question or ID.",call.=FALSE)
  hits <- .ru_search_results(query,n=3L)
  if(!nrow(hits)) {
    cat("No local reference found.\n")
    return(invisible(hits))
  }
  item <- hits[1L,]
  lesson <- .ru_lesson_read(item$id)
  if(!is.null(lesson)) {
    cat(lesson$title,"\n\n",
        paste(trimws(lesson$sections[["immediate answer"]]),collapse=" "),
        "\n\nR code:\n",lesson$code,"\n",sep="")
  } else {
    cat(item$title,"\n",
        "Older reference. Inspect its native help or R script with ru_edit('",
        item$id,"').\n",sep="")
  }
  invisible(hits)
}