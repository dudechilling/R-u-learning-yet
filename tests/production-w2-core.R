# L5 W2-R1 synthetic independent accept-or-reject suite for AN-01.
# Versioned expectations from frozen G1 and L5 oracle; not derived from L3 tests.
# A mismatch is reported as actual status and reason and exits 1.
source_file <- Sys.getenv("RU_L3_SOURCE",unset="")
if (nzchar(source_file)) { source(source_file,local=FALSE) } else {
  suppressPackageStartupMessages(library(rulearn))
}
self <- grep("^--file=", commandArgs(trailingOnly=FALSE), value=TRUE)
stopifnot(length(self)==1L)
fixture <- file.path(dirname(normalizePath(sub("^--file=", "", self),mustWork=TRUE)),
                     "fixtures", "w2-independent-oracle.R")
source(fixture,local=TRUE)
oracle <- ru_w2_independent_oracle()
ru_w2_oracle_selftest()
d <- oracle$guided
baseline <- serialize(d,NULL,version=3L)
sc <- function(policy="complete_case_with_consent",approval=TRUE,
               dependence="unknown",outcome="reading") {
  consent <- if(is.null(approval)) list() else list(
    missingness_exclusion_consent=list(value=approval,source="user",revision=1L,
                                       captured_at="2026-10-24T08:00:00-07:00"))
  list(schema_version="1.1-draft.v2",method_id="describe.numeric",
       operation="summary.only",parameters=list(report_nonfinite=TRUE),
       objective="describe",estimand="empirical_sample_distribution",
       outcome=outcome,predictors=NULL,grouping=NULL,unit_id=NULL,
       dependence=dependence,design="descriptive",sampling="not_applicable",
       missingness_policy=policy,inference_target="sample_only",
       confidence_level=NULL,user_attestations=consent)
}
failed <- 0L
compare <- function(name,p,expected_status,expected_reason) {
  actual_status <- if(is.list(p) && !is.null(p$status)) p$status else "<NO_STATUS>"
  actual_reason <- if(is.list(p) && !is.null(p$reason)) p$reason else "<NO_REASON>"
  ok <- identical(actual_status,expected_status) &&
        identical(actual_reason,expected_reason)
  cat("L5_AN01 ",name," EXPECTED ",expected_status,"/",expected_reason,
      " ACTUAL ",actual_status,"/",actual_reason,
      " ",if(ok)"PASS" else "FAIL","\n",sep="")
  if(!ok) failed <<- failed+1L
  invisible(ok)
}
c <- oracle$policy_cases
for(name in names(c)) {
  case <- c[[name]]
  p <- tryCatch(ru_analyze_plan(sc(policy=case$missingness_policy,
    approval=if(is.na(case$consent))NULL else case$consent,
    dependence=if(!is.null(case$dependence))case$dependence else "unknown"),d),
    error=function(e) list(status="<ERROR>",reason=conditionMessage(e)))
  compare(name,p,case$status,case$reason)
}
ready <- ru_analyze_plan(sc(),d)
if (identical(ready$status,"READY")) {
  same <- ru_analyze_plan(sc(),d)
  ok <- identical(ready$plan_id,same$plan_id) &&
        identical(ready$seal,same$seal)
  cat("L5_AN01 DETERMINISM ",if(ok)"PASS" else "FAIL","\n",sep="")
  if(!ok) failed<-failed+1L
  preview <- ru_analyze_code(ready)
  ok <- identical(preview$status,"PREVIEW_ONLY") &&
    identical(preview$reason,"NOT_EXECUTED") &&
    is.character(preview$code) &&
    grepl("NOT_EXECUTED",preview$code,fixed=TRUE)
  cat("L5_AN01 INSPECTABLE_NOT_EXECUTED_PREVIEW ",if(ok)"PASS" else "FAIL","\n",sep="")
  if(!ok) failed<-failed+1L
  no <- ru_analyze_execute(ready,d,confirm=FALSE)
  ok <- identical(no$status,"CANCELLED")
  cat("L5_AN01 UNCONFIRMED_RUN_CANCELLED ",if(ok)"PASS" else "FAIL","\n",sep="")
  if(!ok) failed<-failed+1L
  run <- ru_analyze_execute(ready,d,confirm=TRUE)
  expected <- oracle$expected_numeric
  ok <- identical(run$status,"SUCCEEDED") &&
    isTRUE(all.equal(run$value$mean,expected$mean)) &&
    isTRUE(all.equal(run$value$median,expected$median)) &&
    isTRUE(all.equal(run$value$sd,expected$sample_sd)) &&
    identical(as.integer(run$value$n_observed),expected$n_observed) &&
    identical(as.integer(run$value$n_missing),expected$n_missing)
  cat("L5_AN01 NUMERIC_EXECUTION ",if(ok)"PASS" else "FAIL",
      " ACTUAL_MEAN ",if(!is.null(run$value$mean))run$value$mean else NA_real_,"\n",sep="")
  if(!ok) failed<-failed+1L
  edited <- d;edited$reading[4L] <- 21
  stale <- ru_analyze_execute(ready,edited,confirm=TRUE)
  compare("changed_reading_revokes_run",stale,"REVALIDATION_REQUIRED",
          "CURRENT_DATA_OR_CONFIGURATION_CHANGED")
  relabel <- d;relabel$site_group[1L]<-"Other"
  stale <- ru_analyze_execute(ready,relabel,confirm=TRUE)
  compare("changed_site_revokes_run",stale,"REVALIDATION_REQUIRED",
          "CURRENT_DATA_OR_CONFIGURATION_CHANGED")
  reordered <- d[c(2L,1L,3L,4L),,drop=FALSE]
  stale <- ru_analyze_execute(ready,reordered,confirm=TRUE)
  compare("row_reordering_revokes_run",stale,"REVALIDATION_REQUIRED",
          "CURRENT_EXPLICIT_ROW_NAMES_UNSUPPORTED")
  # ru.export.refusal.v2 / SUP-RU-W2-R3-EXPORT-PRECEDENCE-30 rev30.
  # Historical 13d8636c expected current-data reasons for UNAUTHORIZED raw
  # string paths. That exact old source/log stays immutable. Current acceptance
  # tests both sides of the authorization boundary without weakening it.
  target <- file.path(tempdir(),"ru-l5-w2-result-observed.txt")
  if (file.exists(target)) stop("Unsafe occupied QA export destination")
  refused <- ru_analyze_export(ready,run,path=target,data=NULL)
  compare("raw_path_hides_missing_data",refused,"REFUSED",
          "FRESH_EXPORT_CONSENT_REQUIRED")
  refused <- ru_analyze_export(ready,run,path=target,data=edited)
  compare("raw_path_hides_stale_data",refused,"REFUSED",
          "FRESH_EXPORT_CONSENT_REQUIRED")
  auth <- if (exists(".ru_an_authorize_export",inherits=TRUE))
    get(".ru_an_authorize_export",inherits=TRUE) else
    getFromNamespace(".ru_an_authorize_export","rulearn")
  scoped <- auth(target,ready,run,consent=TRUE)
  refused <- ru_analyze_export(ready,run,path=scoped,data=NULL)
  compare("authorized_path_requires_current_data",refused,"REFUSED",
          "CURRENT_DATA_REQUIRED")
  refused <- ru_analyze_export(ready,run,path=scoped,data=d)
  compare("missing_data_refusal_consumes_authorization",refused,"REFUSED",
          "FRESH_EXPORT_CONSENT_REQUIRED")
  scoped <- auth(target,ready,run,consent=TRUE)
  refused <- ru_analyze_export(ready,run,path=scoped,data=edited)
  compare("authorized_path_revalidates_stale_data",refused,"REFUSED",
          "REVALIDATION_REQUIRED")
  refused <- ru_analyze_export(ready,run,path=scoped,data=d)
  compare("stale_data_refusal_consumes_authorization",refused,"REFUSED",
          "FRESH_EXPORT_CONSENT_REQUIRED")
  ok <- !file.exists(target)
  cat("L5_AN01 REFUSALS_DID_NOT_WRITE ",if(ok)"PASS" else "FAIL","\n",sep="")
  if(!ok)failed<-failed+1L
  raw <- serialize(d,NULL,version=3L)
  ok <- identical(raw,baseline) &&
        !("data" %in% names(ready)) &&
        !("raw_rows" %in% names(ready)) &&
        !("observations" %in% names(ready))
  cat("L5_AN01 NO_DATA_MUTATION_OR_ROWS_IN_PLAN ",if(ok)"PASS" else "FAIL","\n",sep="")
  if(!ok) failed<-failed+1L
}
if (failed) {
 cat("L5_W2_AN01_INDEPENDENT_CHANGES_REQUIRED ",failed,
     " independent status/reason/behavior mismatches\n",sep="")
 quit(save="no",status=1L)
}
cat("L5_W2_AN01_INDEPENDENT_ALL_EXPECTATIONS_PASS\n")