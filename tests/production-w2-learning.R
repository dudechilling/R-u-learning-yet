# L5 independent W2 teaching / assessment checks, synthetic and local.
# Do not treat exercise-check success as independent learning evidence.
src <- Sys.getenv("RU_L2_ASSESSMENT_SOURCE",unset="")
if(nzchar(src)) { source(src,local=FALSE) } else {
  suppressPackageStartupMessages(library(rulearn))
}
learn_source <- Sys.getenv("RU_L2_LEARNING_SOURCE",unset="")
if(nzchar(learn_source)) source(learn_source,local=FALSE)
if(!nzchar(src)) .ru_learning_checker <- getFromNamespace(".ru_learning_checker","rulearn")
if(!nzchar(learn_source)) ru_learn <- getFromNamespace("ru_learn","rulearn")
self <- grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)
stopifnot(length(self)==1L)
fixture <- file.path(dirname(normalizePath(sub("^--file=", "", self),mustWork=TRUE)),
                     "fixtures", "w2-learning-expected.R")
source(fixture,local=TRUE)
ru_w2_learning_oracle_selftest()
expected <- ru_w2_learning_expectations()
failed <- 0L
check <- function(name,actual,pass) {
  ok <- isTRUE(pass)
  cat("L5_W2_LEARN ",name," ",if(ok)"PASS" else "FAIL"," ",actual,"\n",sep="")
  if(!ok)failed <<- failed+1L
}
empty <- new.env(parent=emptyenv())
sample_scores <- new.env(parent=emptyenv())
sample_scores$scores <- c(6,8,10)
reply <- function(label,code,value=NULL,e=sample_scores,stage="check") {
 .ru_learning_checker(label,code,envir_result=e,last_value=value,
                      stage=stage,engine="r")
}
# Distinct correct alternatives with equivalent computations.
for(code in c("mean(scores)","base::mean(scores)",
              "sum(scores)/length(scores)")) {
 out <- reply("ru-f02-average",code,8)
 check(paste0("mean_alt_",gsub("[^a-z0-9]","",code)),
       paste(out$type,out$correct),
       identical(out$correct,TRUE) && identical(out$type,"success") &&
         grepl("Guided practice only",out$message,fixed=TRUE))
}
for(code in c("sum(is.na(x))","length(which(is.na(x)))")) {
 out <- reply("ru-f03-index",code,1)
 check("missingness_alt",paste(out$type,out$correct),isTRUE(out$correct))
}
for(code in c("scores <- c(6,8,10)","scores = c(6,8,10)")) {
 out <- reply("ru-f02-assignment",code,NULL)
 check("assignment_alt",paste(out$type,out$correct),isTRUE(out$correct))
}
for(code in c("8","median(scores)","17","", "scores == c(6,8,10)")) {
 out <- reply("ru-f02-average",code,8)
 check(paste0("reject_incorrect_",nchar(code)),paste(out$type,out$correct),
       identical(out$correct,FALSE))
}
out<-reply("ru-f03-index","sum(x == NA)",NA_integer_)
check("reject_na_comparison",paste(out$type,out$correct),
      identical(out$correct,FALSE))
out<-reply("ru-f02-average","mean(scores",NULL,stage="error_check")
check("r_error_is_explained_not_credited",paste(out$type,out$correct),
      identical(out$correct,FALSE) &&
      grepl("could not evaluate",out$message,fixed=TRUE))
# Check progress independence and malformed lesson selection.
cat_in_fn <- function(f,expr,expected="ru_invalid_argument") {
 err<-tryCatch({force(expr);NULL},error=identity)
 check(f,if(inherits(err,"error"))paste(class(err),collapse="/")else"No error",
   inherits(err,expected))
}
selection <- ru_learn()
check("no_argument_lesson_selector",selection$status,
      identical(selection$status,"SELECTOR") &&
      identical(selection$opened,FALSE) &&
      identical(selection$progress_claim,"NONE") &&
      nrow(selection$lessons)==3L &&
      identical(selection$lessons$id,expected$required_lesson_ids))
cat_in_fn("invalid_path",ru_learn(path="../escape"))
cat_in_fn("unknown_lesson",ru_learn(lesson="ru.learning.foundation.99"))
cat_in_fn("invalid_resume",ru_learn(resume=NA))
# The installed package tutorial launch is a separate UI gate; without install,
# no successful opening may be claimed.
if(failed) {
 cat("L5_W2_LEARNING_INDEPENDENT_CHANGES_REQUIRED ",failed,"\n",sep="")
 quit(save="no",status=1L)
}
cat("L5_W2_LEARNING_INDEPENDENT_SYNTHETIC_CHECKS_PASS_NOT_HUMAN_COMPETENCE\n")