# Explicit local home; the attach hook uses the same entry point.
# Only static files under the session temporary directory reach the Viewer.
.ru_home_display <- function(path) rstudioapi::viewer(path)

ru_home <- function(open=TRUE) {
  if(!is.logical(open) || length(open)!=1L || is.na(open))
    stop("open must be TRUE or FALSE.",call.=FALSE)
  folder <- .ru_viewer_prepare()
  path <- file.path(folder,"home.html")
  if(!file.exists(path)) stop("The local home page was not created.",call.=FALSE)
  if(open) {
    if(interactive() && .ru_rstudio_ready("viewer")) {
      .ru_home_display(path)
    } else {
      message("Local home prepared. Use help(package='rulearn') or ru_text('mean') outside RStudio.")
    }
  }
  invisible(path)
}

.ru_home_code <- function(id,code) {
  paste0("<section aria-label='Runnable R example'><div class='code-toolbar'>",
    "<span>Copy, inspect, then run in R</span><button class='copy' type='button' ",
    "data-target='",id,"' aria-label='Copy this R example'>Copy</button></div>",
    "<pre class='r-code' tabindex='0' aria-label='Scrollable R code'><code id='",id,"'>",
    .ru_html_escape(code),"</code></pre><p class='copy-status' aria-live='polite'></p></section>")
}

.ru_pathways <- function() {
  path <- system.file("extdata","pathways.csv",package="rulearn")
  if(!nzchar(path)) stop("The installed learning path catalogue is missing.",call.=FALSE)
  x <- utils::read.csv(path,stringsAsFactors=FALSE,na.strings=character())
  if(!all(c("pathway","step","id","prerequisite") %in% names(x)) ||
     anyDuplicated(paste(x$pathway,x$step)) || any(!.ru_safe_id(x$id)))
    stop("The learning path catalogue is invalid.",call.=FALSE)
  x
}

.ru_write_paths <- function(folder) {
  x <- .ru_pathways()
  coverage <- .ru_coverage()
  parts <- vapply(unique(x$pathway),function(group) {
    rows <- x[x$pathway==group,,drop=FALSE]
    rows <- rows[order(rows$step),,drop=FALSE]
    items <- vapply(seq_len(nrow(rows)),function(i) {
      row <- rows[i,]
      lesson <- .ru_lesson_read(row$id)
      matched <- match(row$id,coverage$reference_id)
      title <- if(!is.null(lesson)) lesson$title
               else if(!is.na(matched)) coverage$canonical_question[matched]
               else gsub("_"," ",row$id,fixed=TRUE)
      ready <- !is.null(lesson) && identical(lesson$meta$status,"VERIFIED") &&
        file.exists(file.path(folder,paste0(row$id,".html")))
      status <- if(ready) "VERIFIED" else if(!is.na(matched) &&
        coverage$content_status[matched] %in% c("AUTHORED","NEEDS_REVIEW")) "IN_REVIEW" else "PLANNED"
      label <- .ru_html_escape(title)
      if(ready) label <- paste0("<a href='",row$id,".html'>",label,"</a>")
      paste0("<li>",label," <small>",status,"</small>",
        if(!ready) "<p>Not yet an accepted compact workflow.</p>" else "",
        if(nzchar(row$prerequisite)) paste0("<p class='path-prerequisite'>Prerequisite: ",
          .ru_html_escape(gsub("_"," ",row$prerequisite,fixed=TRUE)),".</p>") else "","</li>")
    },character(1L))
    paste0("<section><h2>",.ru_html_escape(group),"</h2><ol class='path-list'>",
           paste(items,collapse=""),"</ol></section>")
  },character(1L))
  intro <- paste0("<h1>Learning paths</h1><p>Follow the prerequisites, not a course timetable. ",
    "VERIFIED describes the recorded method checks, not universal validity or complete release approval. ",
    "IN_REVIEW and PLANNED items are not verified lessons.</p>",
    "<p>Mixed models, complex surveys, spatial dependence and advanced time-series inference ",
    "are UNSUPPORTED unless the catalogue supplies a separately verified workflow.</p>")
  writeLines(.ru_shell("Learning paths",paste0(intro,paste(parts,collapse=""))),
             file.path(folder,"paths.html"),useBytes=TRUE)
}

.ru_write_home <- function(folder) {
  docs <- system.file("help-pages",package="rulearn")
  pages <- c(start="Start here",using="Use the local library",notices="License and notices",
             accessibility="Accessibility and help")
  for(id in names(pages)) {
    source <- file.path(docs,paste0(id,".html"))
    if(!file.exists(source)) stop("Installed help page missing: ",id,call.=FALSE)
    writeLines(.ru_shell(pages[[id]],paste(readLines(source,warn=FALSE,encoding="UTF-8"),collapse="\n")),
               file.path(folder,paste0(id,".html")),useBytes=TRUE)
  }
  licenses <- system.file("licensing",package="rulearn")
  local_licenses <- file.path(folder,"licensing")
  dir.create(local_licenses,showWarnings=FALSE)
  notice_files <- c("MIT.txt","CC-BY-4.0-NOTICE.txt","scope.csv")
  if(!nzchar(licenses) || !all(file.exists(file.path(licenses,notice_files))) ||
     !all(file.copy(file.path(licenses,notice_files),local_licenses,overwrite=TRUE)))
    stop("Installed local licence notices could not be prepared.",call.=FALSE)
  .ru_write_paths(folder)
  idx <- .ru_lesson_index()
  ready <- idx[idx$status=="VERIFIED",,drop=FALSE]
  links <- vapply(seq_len(nrow(ready)),function(i) paste0("<li><a href='",ready$id[i],
    ".html'>",.ru_html_escape(ready$title[i]),"</a></li>"),character(1L))
  writeLines(.ru_shell("Browse verified methods",paste0("<h1>Browse verified methods</h1>",
    "<p>These compact references have recorded software/editorial checks. Their assumptions still matter. ",
    "Rights, platform and release acceptance are separate gates.</p><ul class='method-list'>",
    paste(links,collapse=""),"</ul>")),file.path(folder,"methods.html"),useBytes=TRUE)
  body <- paste0("<p class='eyebrow'>Offline statistical learning</p><h1>R-u-learning-yet</h1>",
    "<p class='home-lead'>Ask a question. Find a suitable method. Inspect and edit ordinary R code.</p>",
    "<p>For new learners and analysts. Applied and research coverage is listed honestly in the learning paths. ",
    "A reference does not choose your sampling assumptions or prove a causal claim.</p>",
    "<nav class='home-nav' aria-label='Start and browse'>",
    "<a href='start.html'>Start here</a><a href='#ask'>Ask a statistics question</a>",
    "<a href='paths.html'>Learning paths</a><a href='methods.html'>Browse verified methods</a>",
    "<a href='using.html#tutorials'>Tutorials</a><a href='start.html#examples'>R examples</a>",
    "<a href='catalog.html'>Reference and coverage</a><a href='notices.html'>License and notices</a>",
    "<a href='accessibility.html'>Help</a></nav>",
    "<section id='ask'><h2>Ask a statistics question</h2>",
    "<p>Copy this command into RStudio's Console. Search runs in R, not in this static page. ",
    "The query stays on your computer. The library may return no match rather than an incompatible method.</p></section>",
    .ru_home_code("home-search",'ru_find("How do I create a histogram?")'),
    "<section><h2>Read, check, then run</h2><p>Open the result. Check the conditions. ",
    "Copy its native R example into a script. Edit the named inputs. Interpret the output and its limits. ",
    "The Copy button does not execute code.</p></section>",
    "<section><h2>What is installed?</h2><p>",nrow(idx)," compact lesson files. ",
    "Use <a href='catalog.html'>Reference and coverage</a> for per-method status, ",
    "including unfinished topics. A catalogue entry is not a claim that a method is available.</p></section>",
    "<section><h2>Offline by default</h2><p>Local navigation, examples and code copying need no account or remote service. ",
    "Source citations are optional online links. <a href='notices.html'>Redistribution clearance is pending.</a></p></section>",
    "<section><h2>Control automatic opening</h2><p>Set the following option before attaching the package. ",
    "You can still call <code>ru_home()</code> to reopen this page.</p></section>",
    .ru_home_code("home-optout","options(rulearn.auto_home = FALSE)\nlibrary(rulearn)"))
  writeLines(.ru_shell("Home",body),file.path(folder,"home.html"),useBytes=TRUE)
}
