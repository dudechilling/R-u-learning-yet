# The same exact-source package gate used by each supported CI runner.
# All build output stays outside the source tree. No warning suppression.
source_dir <- normalizePath(Sys.getenv("GITHUB_WORKSPACE",getwd()),winslash="/",mustWork=TRUE)
stopifnot(file.exists(file.path(source_dir,"DESCRIPTION")))
meta <- read.dcf(file.path(source_dir,"DESCRIPTION"))
stopifnot(meta[1,"Package"]=="rulearn")
output <- Sys.getenv("RULEARN_CI_OUTPUT",tempfile("rulearn-ci-"))
dir.create(output,recursive=TRUE,showWarnings=FALSE)
output <- normalizePath(output,winslash="/",mustWork=TRUE)
old <- getwd()
setwd(output)
R <- file.path(R.home("bin"),if(.Platform$OS.type=="windows")"R.exe" else "R")
Rscript <- file.path(R.home("bin"),if(.Platform$OS.type=="windows")"Rscript.exe" else "Rscript")
run_checked <- function(command,args,log) {
  code <- system2(command,args=args,stdout=log,stderr=log)
  if(!identical(as.integer(code),0L)) {
    cat(readLines(log,warn=FALSE),sep="\n")
    stop("Command failed; inspect ",log,call.=FALSE)
  }
}
tryCatch({
  run_checked(R,c("CMD","build",shQuote(source_dir)),"build.log")
  archive <- paste0("rulearn_",meta[1,"Version"],".tar.gz")
  stopifnot(file.exists(archive))
  run_checked(R,c("CMD","check","--no-manual",shQuote(archive)),"check.log")
  stopifnot(any(grepl("^Status: OK",readLines("check.log",warn=FALSE))))
  fresh <- file.path(output,"fresh-library")
  dir.create(fresh)
  # Exercise the documented R installation route, not only R CMD INSTALL.
  utils::install.packages(archive,repos=NULL,type="source",lib=fresh)
  stopifnot(as.character(utils::packageVersion("rulearn",lib.loc=fresh))==meta[1,"Version"])
  previous <- Sys.getenv("R_LIBS")
  Sys.setenv(R_LIBS=paste(c(fresh,previous[nzchar(previous)]),collapse=.Platform$path.sep))
  tests <- sort(list.files(file.path(source_dir,"tests"),pattern="[.]R$",full.names=TRUE))
  stopifnot(length(tests)>=20L)
  for(test in tests) run_checked(Rscript,c("--vanilla",shQuote(test)),paste0(basename(test),".log"))
  writeLines(capture.output(sessionInfo()),"sessionInfo.txt")
  cat("Exact source build/check and fresh-library regressions PASS:",length(tests),"scripts.\n")
  cat("Evidence directory:",output,"\n")
},finally=setwd(old))
