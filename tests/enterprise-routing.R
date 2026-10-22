# Frozen independently specified positive and exclusion cases. No answer tuning.
library(rulearn)
fixture <- file.path("fixtures","enterprise-method-cases.csv")
if(!file.exists(fixture)) {
  file_arg <- grep("^--file=",commandArgs(),value=TRUE)
  if(length(file_arg)==1L) fixture <- file.path(dirname(sub("^--file=","",file_arg)),
                                              "fixtures","enterprise-method-cases.csv")
}
stopifnot(file.exists(fixture))
cases <- utils::read.csv(fixture,stringsAsFactors=FALSE,na.strings=character())
stopifnot(nrow(cases)==140L,!anyDuplicated(cases$case_id),!anyDuplicated(cases$query),
          length(unique(cases$family))==10L,all(table(cases$family,cases$kind)==7L))
observed <- vapply(cases$query,function(query) {
  hit <- ru_find(query,n=1L)
  if(nrow(hit)) hit$id[1L] else "NO_MATCH"
},character(1L))
cases$observed <- unname(observed)
cases$status <- ifelse(cases$observed==cases$expected,"PASS","FAIL")
out <- Sys.getenv("RULEARN_QA_ROUTE_RESULTS","")
if(nzchar(out)) utils::write.csv(cases,out,row.names=FALSE)
if(any(cases$status!="PASS")) {
  print(cases[cases$status!="PASS",c("case_id","query","expected","observed")],row.names=FALSE)
  stop(sum(cases$status!="PASS")," frozen route expectations failed.",call.=FALSE)
}
# An independently frozen second pass covers alternate estimators and operations.
adversarial <- utils::read.csv(file.path(dirname(fixture),"enterprise-adversarial.csv"),stringsAsFactors=FALSE)
stopifnot(nrow(adversarial)==40L,!anyDuplicated(adversarial$query))
adversarial$observed <- vapply(adversarial$query,function(q) {
  h<-ru_find(q,n=1L);if(nrow(h)) h$id[1L] else "NO_MATCH"
},character(1L))
if(any(adversarial$observed!=adversarial$expected)) {
 print(adversarial[adversarial$observed!=adversarial$expected,]);stop("Additional estimator exclusions failed.")
}

# Keep ordinary APIs, input rejection and explicit text behavior compatible.
stopifnot(nrow(ru_find(NA_character_))==0L,nrow(ru_find(character()))==0L,
          nrow(ru_find(list("glm")))==0L,nrow(ru_find(""))==0L)
for(id in unique(cases$family)) stopifnot(identical(ru_find(id,n=1L)$id,id))
cat("Enterprise frozen routes PASS: 180/180 (140 primary + 40 independent exclusions); ten families, 7 positive and 7 negative/adversarial each.\n")