library(rulearn)
root <- system.file(package="rulearn")
files <- c(list.files(file.path(root,"lessons"),pattern="[.]md$",full.names=TRUE),
           file.path(root,"extdata","coverage.csv"))
stopifnot(length(files)==85L,all(file.exists(files)))
txt <- paste(unlist(lapply(files,readLines,warn=FALSE)),collapse="\n")
# Restricted exact terms belong in an operator-controlled file outside Git.
# CI still checks generic filesystem disclosure and network-free assets.
private_file <- Sys.getenv("RULEARN_PRIVATE_TERMS_FILE", unset="")
private_signals <- c("/home/", "/mnt/", "file:///", "C:\\Users\\")
if(nzchar(private_file)) {
  stopifnot(file.exists(private_file))
  private_signals <- unique(c(private_signals,readLines(private_file,warn=FALSE)))
  private_signals <- private_signals[nzchar(private_signals)]
} else message("Restricted term list not supplied: generic path checks only.")
hits <- vapply(private_signals,function(x)
  grepl(tolower(x),tolower(txt),fixed=TRUE),logical(1))
if(any(hits)) stop("Restricted marker found; inspect the private audit report.")
js <- paste(readLines(file.path(root,"www","reference.js"),warn=FALSE),collapse="\n")
css <- paste(readLines(file.path(root,"www","reference.css"),warn=FALSE),collapse="\n")
shell <- paste(deparse(getFromNamespace(".ru_shell","rulearn")),collapse="\n")
stopifnot(!grepl("fetch(",js,fixed=TRUE),
          !grepl("XMLHttpRequest",js,fixed=TRUE),
          !grepl("@import",css,fixed=TRUE),
          !grepl("https://",css,fixed=TRUE),
          grepl("connect-src 'none'",shell,fixed=TRUE),
          grepl("default-src 'none'",shell,fixed=TRUE))
cat("Configured source-marker and offline Viewer static audit: PASS\n")