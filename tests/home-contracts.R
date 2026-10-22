# Exact installed home/attach contracts. Mocked IDE conditions are unit tests,
# not evidence of an actual interactive RStudio run.
stopifnot(!interactive())
home_file <- file.path(tempdir(),"rulearn-reference","home.html")
stopifnot(!file.exists(home_file))
startup <- capture.output(suppressPackageStartupMessages(library(rulearn)))
stopifnot(length(startup)==0L,!file.exists(home_file))
attach_home <- getFromNamespace(".ru_attach_home","rulearn")
stopifnot(!".onAttach" %in% getNamespaceExports("rulearn"))

# Interactivity and opt-out must short-circuit before any IDE probe.
for(inter in c(FALSE,TRUE)) for(enabled in c(FALSE,TRUE)) for(available in c(FALSE,TRUE)) {
  opened <- 0L; probed <- 0L; messages <- character()
  got <- attach_home(is_interactive=inter,enabled=enabled,
    ready=function() {probed <<- probed+1L;available},
    open=function() {opened <<- opened+1L},
    notify=function(x) messages <<- c(messages,x))
  expected <- inter && enabled && available
  stopifnot(identical(got,expected),opened==as.integer(expected),
            probed==as.integer(inter&&enabled),length(messages)==0L)
}
# Suppressing startup messages must not disable the UI event.
opened <- 0L
suppressPackageStartupMessages(attach_home(TRUE,TRUE,ready=function()TRUE,
  open=function() opened <<- opened+1L))
stopifnot(opened==1L)
# Each actual attach event calls once; no independent timer or repeated hook.
attach_home(TRUE,TRUE,ready=function()TRUE,open=function()opened <<- opened+1L)
stopifnot(opened==2L)
messages <- character()
stopifnot(identical(attach_home(TRUE,TRUE,ready=function()TRUE,
  open=function()stop("controlled Viewer failure"),
  notify=function(x)messages <<- c(messages,x)),FALSE),length(messages)==1L,
  grepl("controlled Viewer failure",messages,fixed=TRUE),
  grepl("ru_home()",messages,fixed=TRUE))
stopifnot(nrow(ru_find("How do I create a histogram?"))>0L)
# The documented option is evaluated before attach.
old <- options(rulearn.auto_home=FALSE)
stopifnot(identical(attach_home(TRUE,ready=function()stop("must not probe")),FALSE))
options(old)
stopifnot(grepl("child_ok = FALSE",paste(deparse(getFromNamespace(".ru_rstudio_ready","rulearn")),collapse=" "),fixed=TRUE))

view <- withVisible(ru_home(open=FALSE))
stopifnot(!view$visible,file.exists(view$value),identical(view$value,home_file),
          startsWith(normalizePath(view$value,winslash="/"),normalizePath(tempdir(),winslash="/")))
again <- withVisible(ru_home(open=FALSE))
stopifnot(identical(again$value,view$value),!again$visible)
folder <- dirname(view$value)
expected <- c("home.html","start.html","using.html","tutorials.html","paths.html","methods.html",
              "notices.html","accessibility.html","catalog.html","results.html")
stopifnot(all(file.exists(file.path(folder,expected))))
read <- function(p) paste(readLines(p,warn=FALSE,encoding="UTF-8"),collapse="\n")
home <- read(view$value)
for(label in c("Start here","Ask a statistics question","Learning paths",
  "Browse verified methods","Tutorials","R examples","Reference and coverage",
  "License and notices","Help")) stopifnot(grepl(label,home,fixed=TRUE))
stopifnot(grepl("rulearn.auto_home",home,fixed=TRUE),
          grepl("Read source licences and notices",home,fixed=TRUE),
          grepl("href='tutorials.html'",home,fixed=TRUE))
# All relative href/src targets and in-file anchors on generated documentation exist.
for(name in expected) {
  html <- read(file.path(folder,name))
  refs <- regmatches(html,gregexpr("(?:href|src)='[^']+'",html,perl=TRUE))[[1L]]
  refs <- sub("^[^=]+='","",sub("'$","",refs))
  for(ref in refs) {
    if(grepl("^https://",ref)) next
    bits <- strsplit(ref,"#",fixed=TRUE)[[1L]]
    target <- if(!nzchar(bits[1L])) file.path(folder,name) else file.path(folder,bits[1L])
    stopifnot(file.exists(target))
    if(length(bits)>1L && nzchar(bits[2L]))
      stopifnot(grepl(paste0("id='",bits[2L],"'"),read(target),fixed=TRUE))
  }
}
paths <- getFromNamespace(".ru_pathways","rulearn")()
stopifnot(setequal(unique(paths$pathway),c("Beginner","Core","Applied","Research")),
          !anyDuplicated(paste(paths$pathway,paths$step)),
          all(paths$prerequisite[paths$prerequisite!=""] %in% paths$id))
stopifnot(grepl("PLANNED",read(file.path(folder,"paths.html")),fixed=TRUE),
          grepl("UNSUPPORTED",read(file.path(folder,"paths.html")),fixed=TRUE))
# Prerequisites form an acyclic ordered graph; all active path cards exist.
for(i in seq_len(nrow(paths))) {
  pre <- paths$prerequisite[i]
  if(nzchar(pre)) stopifnot(match(pre,paths$id)<i)
  stopifnot(!is.null(getFromNamespace(".ru_lesson_read","rulearn")(paths$id[i])))
}
# HTML is escaped; the renderer must never execute a learner's question.
evil <- "<script>alert('not code')</script> & \"test\""
getFromNamespace(".ru_viewer_prepare","rulearn")(hits=ru_find(evil),query=evil)
rendered <- read(file.path(folder,"results.html"))
stopifnot(!grepl("<script>alert",rendered,fixed=TRUE),
          grepl("&lt;script&gt;",rendered,fixed=TRUE),
          grepl("connect-src 'none'",rendered,fixed=TRUE))
# Input validation and a real noninteractive fallback, not an IDE mock.
for(x in list(NA,1,"yes",logical(),c(TRUE,FALSE)))
  stopifnot(inherits(try(ru_home(open=x),silent=TRUE),"try-error"))
messages <- character()
fallback <- withCallingHandlers(ru_home(),message=function(m) {
  messages <<- c(messages,conditionMessage(m)); invokeRestart("muffleMessage")
})
stopifnot(identical(fallback,home_file),length(messages)==1L,
          grepl("outside RStudio",messages,fixed=TRUE))
cat("Home contracts PASS: 8 attach conditions; failure, opt-out, quiet attach, local links, paths, escaping and fallback. Real IDE acceptance remains unverified.\n")