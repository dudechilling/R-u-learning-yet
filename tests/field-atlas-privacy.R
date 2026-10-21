library(rulearn)
root <- system.file(package="rulearn")
files <- c(list.files(file.path(root,"lessons"),pattern="[.]md$",full.names=TRUE),
           file.path(root,"extdata","coverage.csv"))
stopifnot(length(files)==62L,all(file.exists(files)))
txt <- paste(unlist(lapply(files,readLines,warn=FALSE)),collapse="\n")
private_signals <- c(paste0("/", "mnt", "/", "current-", "semester"),paste0("/", "home", "/", "earl"),paste0("S:",intToUtf8(92L)),
  paste0("ST", "AT", " ", "1200"),paste0("GE", "OG", " ", "2700"),"Fall 2026","tru.ca",
  "Sean Hellingman","David Hill","Alfred Core")
hits <- private_signals[vapply(private_signals,function(x)
  grepl(tolower(x),tolower(txt),fixed=TRUE),logical(1))]
if(length(hits)) stop("Public package includes private source marker: ",paste(hits,collapse=","))
js <- paste(readLines(file.path(root,"www","reference.js"),warn=FALSE),collapse="\n")
css <- paste(readLines(file.path(root,"www","reference.css"),warn=FALSE),collapse="\n")
shell <- paste(deparse(getFromNamespace(".ru_shell","rulearn")),collapse="\n")
stopifnot(!grepl("fetch(",js,fixed=TRUE),
          !grepl("XMLHttpRequest",js,fixed=TRUE),
          !grepl("@import",css,fixed=TRUE),
          !grepl("https://",css,fixed=TRUE),
          grepl("connect-src 'none'",shell,fixed=TRUE),
          grepl("default-src 'none'",shell,fixed=TRUE))
cat("Private source-marker and offline Viewer static audit: PASS\n")