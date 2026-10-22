# Student-first offline tutorial integration and numerical regression.
# These checks do not replace an actual Windows RStudio keyboard/clipboard test.
library(rulearn)
home_path <- ru_home(open=FALSE)
folder <- dirname(home_path)
target <- file.path(folder,"tutorials.html")
stopifnot(file.exists(target))
read <- function(path) paste(readLines(path,warn=FALSE,encoding="UTF-8"),collapse="\n")
home <- read(home_path)
tutorial <- read(target)

# A new learner can reach a real tutorial rather than a command-only paragraph.
stopifnot(grepl("Open the guided tutorials",home,fixed=TRUE),
          grepl("href='tutorials.html'",home,fixed=TRUE),
          grepl("New to RU? Try an example first.",home,fixed=TRUE),
          grepl("href='tutorials.html'",read(file.path(folder,"using.html")),fixed=TRUE),
          grepl("href='tutorials.html'",read(file.path(folder,"start.html")),fixed=TRUE),
          !grepl("Redistribution clearance is pending",home,fixed=TRUE))

# Every relative tutorial link resolves; anchor fragments point to real IDs.
refs <- regmatches(tutorial,gregexpr("href='[^']+'",tutorial,perl=TRUE))[[1L]]
refs <- sub("^href='","",sub("'$","",refs))
stopifnot(length(refs)>=6L)
for(ref in refs) {
  stopifnot(!grepl("://",ref,fixed=TRUE))
  bits <- strsplit(ref,"#",fixed=TRUE)[[1L]]
  file <- if(nzchar(bits[1L])) file.path(folder,bits[1L]) else target
  stopifnot(file.exists(file))
  if(length(bits)>1L && nzchar(bits[2L])) {
    text <- read(file)
    stopifnot(grepl(paste0("id='",bits[2L],"'"),text,fixed=TRUE))
  }
}

code_from_page <- function(id) {
  pat <- paste0("(?s)<code id='",id,"'>(.*?)</code>")
  found <- regmatches(tutorial,regexec(pat,tutorial,perl=TRUE))[[1L]]
  stopifnot(length(found)==2L,nzchar(found[2L]))
  text <- found[2L]
  text <- gsub("&lt;","<",text,fixed=TRUE)
  text <- gsub("&gt;",">",text,fixed=TRUE)
  text <- gsub("&quot;",'"',text,fixed=TRUE)
  text <- gsub("&#39;","'",text,fixed=TRUE)
  gsub("&amp;","&",text,fixed=TRUE)
}

# The exact R displayed in the two Copy boxes must be valid and reproducible.
hist_code <- code_from_page("tutorial-histogram-code")
ci_code <- code_from_page("tutorial-confidence-code")
for(id in c("tutorial-histogram-code","tutorial-confidence-code"))
  stopifnot(grepl(paste0("data-target='",id,"'"),tutorial,fixed=TRUE))
stopifnot(length(gregexpr("class='copy'",tutorial,fixed=TRUE)[[1L]])==2L,
          length(gregexpr("class='copy-status'",tutorial,fixed=TRUE)[[1L]])==2L)
grDevices::pdf(tempfile(fileext=".pdf"))
hist_env <- new.env(parent=.GlobalEnv)
eval(parse(text=hist_code),envir=hist_env)
grDevices::dev.off()
stopifnot(inherits(hist_env$histogram,"histogram"),
          length(hist_env$durations)==nrow(datasets::faithful),
          sum(hist_env$histogram$counts)==nrow(datasets::faithful))

ci_env <- new.env(parent=.GlobalEnv)
eval(parse(text=ci_code),envir=ci_env)
expected <- mean(ci_env$values) + c(-1,1) *
  stats::qt(0.95,length(ci_env$values)-1) *
  stats::sd(ci_env$values)/sqrt(length(ci_env$values))
stopifnot(isTRUE(all.equal(as.numeric(ci_env$interval),expected,tolerance=1e-12)),
          identical(attr(ci_env$interval,"conf.level"),0.90),
          isTRUE(all.equal(as.numeric(round(ci_env$interval,2)),c(4.77,11.23))))
cat("Student tutorials PASS: offline navigation, links, two copy controls, histogram and numerical t interval.\n")
