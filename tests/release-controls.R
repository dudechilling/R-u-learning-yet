# Check truthful scoped licensing and local notice navigation, not legal clearance.
library(rulearn)
root <- system.file("licensing",package="rulearn")
stopifnot(nzchar(root),all(file.exists(file.path(root,c("MIT.txt","CC-BY-4.0-NOTICE.txt","scope.csv")))))
scope <- utils::read.csv(file.path(root,"scope.csv"),stringsAsFactors=FALSE)
stopifnot(nrow(scope)>=250L,!anyDuplicated(scope$source_path),
          all(nzchar(scope$source_path)),all(nzchar(scope$license)),
          !any(grepl("(^/|(^|/)\\.\\.(/|$)|[A-Za-z]:)",scope$source_path,perl=TRUE)),
          all(scope$license %in% c("MIT","CC-BY-4.0; code examples MIT")))
mit <- paste(readLines(file.path(root,"MIT.txt"),warn=FALSE),collapse="\n")
cc <- paste(readLines(file.path(root,"CC-BY-4.0-NOTICE.txt"),warn=FALSE),collapse="\n")
stopifnot(grepl("Permission is hereby granted",mit,fixed=TRUE),
          grepl("THE SOFTWARE IS PROVIDED",mit,fixed=TRUE),
          !grepl("<YEAR>",mit,fixed=TRUE),!grepl("<COPYRIGHT HOLDER>",mit,fixed=TRUE),
          grepl("https://creativecommons.org/licenses/by/4.0/legalcode.en",cc,fixed=TRUE),
          grepl("No grant is made",cc,fixed=TRUE))
folder <- dirname(ru_home(open=FALSE))
for(file in c("MIT.txt","CC-BY-4.0-NOTICE.txt","scope.csv"))
  stopifnot(identical(readBin(file.path(root,file),"raw",n=file.info(file.path(root,file))$size),
                     readBin(file.path(folder,"licensing",file),"raw",n=file.info(file.path(folder,"licensing",file))$size)))
page <- paste(readLines(file.path(folder,"notices.html"),warn=FALSE),collapse="\n")
stopifnot(grepl("Original RU source and educational material",page,fixed=TRUE),
          grepl("separate rights",page,fixed=TRUE),
          grepl("licensing/MIT.txt",page,fixed=TRUE),
          grepl("licensing/scope.csv",page,fixed=TRUE))
cat("Source licence and notice consistency PASS; no guarantee of zero copyright risk.\n")