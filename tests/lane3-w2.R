# RU L3 W2: exact-source AN-01 regression suite; no external data or uploads.
# Run from an installed source build or set RU_L3_SOURCE for an external smoke.
source_file <- Sys.getenv("RU_L3_SOURCE", unset = "")
if (nzchar(source_file)) {
  source(source_file, local = FALSE)
} else {
  suppressPackageStartupMessages(library(rulearn))
  ns <- asNamespace("rulearn")
  for (name in c("ru_analyze_plan","ru_analyze_code","ru_analyze_execute",
                 "ru_analyze_export",".ru_an_authorize_export",
                 ".ru_an_verify",".ru_an_hash"))
    assign(name, get(name,envir=ns), envir=.GlobalEnv)
}
required <- c("ru_analyze_plan","ru_analyze_code","ru_analyze_execute",
              "ru_analyze_export")
stopifnot(all(vapply(required,exists,logical(1L),mode="function")))
mark <- function(id, expr) {
  force(expr)
  cat("L3 PASS: ",id,"\n",sep="")
}
sp <- function(operation="summary.only",missingness="complete_case_with_consent",
               approval=TRUE, hist=NULL, outcome="reading") {
  attest <- if (is.null(approval)) list() else
    list(missingness_exclusion_consent=list(value=approval,source="user",
          revision=1L,captured_at="2026-10-22T21:10:00-07:00"))
  params <- if (is.null(hist)) list(report_nonfinite=TRUE) else hist
  list(schema_version="1.1-draft.v2",
       method_id="describe.numeric",operation=operation,parameters=params,
       objective="describe",estimand="empirical_sample_distribution",
       outcome=outcome,predictors=NULL,grouping=NULL,unit_id=NULL,
       dependence="unknown",design="descriptive",sampling="not_applicable",
       missingness_policy=missingness,inference_target="sample_only",
       confidence_level=NULL,user_attestations=attest)
}
status <- function(spec,data,expected,reason,context=NULL) {
  p<-ru_analyze_plan(spec,data,source_context=context)
  stopifnot(identical(p$status,expected),identical(p$reason,reason))
  invisible(p)
}
guided_csv <- paste0("row_key,site_group,reading\n",
   "G001,North,13\nG002,North,\nG003,South,18\nG004,South,20\n")
stopifnot(length(charToRaw(guided_csv))==81L,
  digest::digest(charToRaw(guided_csv),serialize=FALSE,algo="sha256")==
    "3166dcb4137ce10342f5bed98004c71e28e3aace1a0c088c7fa7c33da8f3834a")
guided <- utils::read.csv(text=guided_csv,stringsAsFactors=FALSE,
  na.strings=c("","NA"),colClasses=c("character","character","numeric"))
stopifnot(nrow(guided)==4L,identical(names(guided),
  c("row_key","site_group","reading")),
  identical(typeof(guided[["reading"]]),"double"),
  identical(guided[["reading"]],c(13,NA_real_,18,20)))
source_record <- function(data=guided) {
  binds <- Map(function(name,col,role) list(
      original_name=name,storage_type=typeof(col),analytic_role=role,
      measurement_unit=if (role=="outcome") list(
         declared_code="degree_Celsius",canonical_code="degree_Celsius",
         unit_vocab_version="ru-units-v1",
         declaration_evidence="L2 authored instructional source card v1") else NULL),
      names(data),unname(data),c("record_key","grouping_category","outcome"))
  raw_local <- digest::digest(list(codec="ru.r-serialize-v3.local.v1",data=data),
                algo="sha256",serialize=TRUE,serializeVersion=3L)
  list(schema_version="ru.source_context.v1",
       source=list(kind="authored_installed_csv",
         source_id="ru.learning.foundation.03.sites-intro-v1",
         content_version="ru-learning-foundation-v1",
         source_file_sha256=
           "3166dcb4137ce10342f5bed98004c71e28e3aace1a0c088c7fa7c33da8f3834a",
         source_provenance=list(author="RU L2",
           declaration_sha256="6c71ff1a11957b104f2dafb6db7ade1c8b85bc167c10f0db06cc25477845b967",
           verification_state="SOURCE_BYTES_CHECKED",installed=FALSE)),
       parse=list(format="csv",encoding="UTF-8",has_header=TRUE,
                  delimiter=",",na_strings=c("","NA"),
                  column_classes=c("character","character","numeric"),
                  parser_contract="ru-guided-csv-v1"),
       bindings=binds,
       snapshot=list(encoder_id="ru.r-serialize-v3.local.v1",
         sha256=raw_local,row_count=nrow(data),
         column_count=ncol(data),column_order=names(data),
         row_names_kind="automatic",
         missingness_by_column=vapply(data,function(col) sum(is.na(col)),
                                      integer(1L)),
         data_revision=1L),
       identity_contract=list(source_context_version="ru.source_context.v1",
         method_dictionary_version="1.1-draft.v2",
         identity_codec_id="ru.r-serialize-v3.local.v1",
         source_context_binding="CURRENT_DATA_REQUIRED"),
       review=list(editorial="NOT_REVIEWED",statistical="NOT_REVIEWED",
                   instructional="NOT_REVIEWED",accessibility="NOT_REVIEWED",
                   rights="NOT_CLEARED",release="NOT_REVIEWED"))
}
ctx <- source_record()
mark("G2 imported CSV bytes / typed roles", {
  stopifnot(identical(guided$reading,c(13,NA_real_,18,20)))
})
p <- ru_analyze_plan(sp(),guided,source_context=ctx)
mark("G2 planned mean 17 conditional on consent", {
  stopifnot(p$status=="READY",p$checked$n_raw==4,
    p$checked$n_observed==3,p$checked$n_missing==1L,
    identical(p$measurement_unit,"degree_Celsius"),
    !("reading" %in% names(p)),!identical(p$binding$data_sha256,
                                         p$binding$source_sha256),
    !is.null(p$plan_id),nchar(p$plan_id)==64L)
})
no_na <- guided
no_na$reading <- c(13,16,18,20)
mark("no missing values / report and fail policies", {
  status(sp(missingness="report",approval=NULL),no_na,"READY",
         "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN")
  status(sp(missingness="fail",approval=NULL),no_na,"READY",
         "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN")
})
mark("missingness semantics and consent", {
  status(sp(missingness="report",approval=NULL),guided,"NEEDS_INPUT",
         "MISSINGNESS_TREATMENT_REQUIRED")
  status(sp(missingness="fail",approval=NULL),guided,"INVALID",
         "MISSINGNESS_POLICY_VIOLATION")
  status(sp(approval=NULL),guided,"NEEDS_INPUT","EXCLUSION_CONSENT_REQUIRED")
  status(sp(approval=FALSE),guided,"UNSUPPORTED","CONSENT_DENIED")
  status(sp(approval=TRUE),guided,"READY","ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN")
})
mark("clustered descriptive sample has no inferential independence gate", {
  clustered <- sp()
  clustered$dependence <- "clustered"
  status(clustered,guided,"READY","ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN")
})
mark("source-unit provenance / role integrity", {
  bad<-source_record()
  bad$bindings[[3]]$measurement_unit$canonical_code<-"degree_Fahrenheit"
  status(sp(),guided,"INVALID","UNIT_METADATA_CONFLICT",bad)
  bad<-source_record()
  bad$bindings[[3]]$analytic_role<-"other"
  status(sp(),guided,"INVALID","SOURCE_OUTCOME_ROLE_CONFLICT",bad)
  bad<-source_record()
  bad$bindings[[3]]$storage_type<-"integer"
  status(sp(),guided,"INVALID","SOURCE_COLUMN_BINDING_MISMATCH",bad)
  plain<-ru_analyze_plan(sp(),guided)
  stopifnot(plain$status=="READY",is.null(plain$measurement_unit))
  bad<-source_record();bad$snapshot$data_revision<-0L
  status(sp(),guided,"INVALID","SOURCE_CONTEXT_SCHEMA_MISMATCH",bad)
  bad<-source_record()
  bad$source$kind<-c("authored_installed_csv","constructed_in_memory")
  status(sp(),guided,"INVALID","SOURCE_CONTEXT_SCHEMA_INVALID",bad)
})
mark("source_context nested metadata rejects embedded raw research rows", {
  bad <- source_record()
  bad$parse$extra_raw_data <- guided
  status(sp(), guided, "INVALID", "SOURCE_CONTEXT_SCHEMA_INVALID", bad)
  bad <- source_record()
  bad$source$source_provenance$author <- guided
  status(sp(), guided, "INVALID", "SOURCE_CONTEXT_SCHEMA_INVALID", bad)
  bad <- source_record()
  bad$review$editorial <- list(raw_data=guided)
  status(sp(), guided, "INVALID", "SOURCE_CONTEXT_SCHEMA_INVALID", bad)
  bad <- source_record()
  bad$bindings[[1]]$measurement_unit <-
    list(declared_code="degree_Celsius",canonical_code="degree_Celsius",
         unit_vocab_version="ru-units-v1",
         declaration_evidence="declared",raw_rows=guided)
  status(sp(), guided, "INVALID", "SOURCE_CONTEXT_SCHEMA_INVALID", bad)
  stopifnot(is.null(p$source_metadata$parse$extra_raw_data),
            is.null(p$source_metadata$source$source_provenance$raw_rows))
})
mark("constructed in-memory source cannot carry CSV parse metadata", {
  bad <- source_record()
  bad$source$kind <- "constructed_in_memory"
  bad$source$source_file_sha256 <- NULL
  status(sp(),guided,"INVALID","SOURCE_CONTEXT_SCHEMA_INVALID",bad)
})
mark("unsupported data types and frame identity", {
  bad<-guided;bad$site_group<-factor(bad$site_group)
  status(sp(),bad,"UNSUPPORTED","UNSUPPORTED_COLUMN_TYPE")
  bad<-guided;bad$reading<-as.Date("2026-10-24")+seq_len(nrow(bad))
  status(sp(),bad,"UNSUPPORTED","UNSUPPORTED_COLUMN_TYPE")
  bad<-guided;row.names(bad)<-c("a","b","c","d")
  status(sp(),bad,"UNSUPPORTED","EXPLICIT_ROW_NAMES_UNSUPPORTED")
  bad<-guided;names(bad)[1]<-"réc"
  status(sp(),bad,"UNSUPPORTED","NON_ASCII_IDENTITY_UNSUPPORTED")
  bad<-guided;bad$reading<-as.character(bad$reading)
  status(sp(),bad,"INVALID","NUMERIC_OUTCOME_REQUIRED")
})
mark("nonfinite outcome and malformed spec", {
  bad<-guided;bad$reading[1]<-Inf
  status(sp(),bad,"UNSUPPORTED","NONFINITE_NUMERIC_OUTCOME_UNSUPPORTED")
  bad<-guided;bad$reading[1]<-NaN
  status(sp(),bad,"UNSUPPORTED","NONFINITE_NUMERIC_OUTCOME_UNSUPPORTED")
  status(sp(),NULL,"NEEDS_INPUT","CURRENT_DATA_REQUIRED")
  s<-sp();s$method_id<-"estimate.mean"
  status(s,guided,"UNSUPPORTED","METHOD_NOT_IMPLEMENTED")
  s<-sp();s$method_id<-"imaginary.method"
  status(s,guided,"INVALID","UNKNOWN_METHOD_ID")
  s<-sp();s$confidence_level<-.95
  status(s,guided,"INVALID","DESCRIPTIVE_SPEC_CONTRADICTION")
  s<-sp();s$dependence<-c("unknown","clustered")
  status(s,guided,"INVALID","MALFORMED_SPEC")
})
mark("deterministic identity / revision and timestamps", {
  again<-ru_analyze_plan(sp(),guided,ctx)
  stopifnot(identical(p$plan_id,again$plan_id),
            identical(p$seal,again$seal))
  stamped<-sp();stamped$user_attestations$missingness_exclusion_consent$captured_at<-
    "2026-10-23T01:00:00-07:00"
  p2<-ru_analyze_plan(stamped,guided,ctx)
  stopifnot(identical(p$plan_id,p2$plan_id),identical(p$seal,p2$seal))
  changed<-sp();changed$user_attestations$missingness_exclusion_consent$revision<-2L
  stopifnot(!identical(ru_analyze_plan(changed,guided,ctx)$plan_id,p$plan_id))
  newer<-source_record();newer$snapshot$data_revision<-2L
  stopifnot(!identical(ru_analyze_plan(sp(),guided,newer)$plan_id,p$plan_id))
})
preview <- ru_analyze_code(p)
mark("ordinary code preview, not executed", {
  stopifnot(preview$status=="PREVIEW_ONLY",preview$reason=="NOT_EXECUTED",
            is.character(preview$code),length(preview$code)==1L,
            grepl('data\\[\\["reading"\\]\\]',preview$code),
            grepl("# RU inspectable preview: NOT_EXECUTED",preview$code,fixed=TRUE),
            !grepl("c(13, NA",preview$code,fixed=TRUE))
  e<-new.env(parent=baseenv())
  e$data<-guided
  math<-eval(parse(text=preview$code),envir=e)
  x<-c(13,18,20)
  independent_mean<-sum(x)/length(x)
  independent_sd<-sqrt(sum((x-independent_mean)^2)/(length(x)-1))
  stopifnot(identical(math$mean,independent_mean),
    isTRUE(all.equal(math$sd,independent_sd)),
    math$n_observed==3L,math$n_missing==1L)
})
mark("literal-safe adversarial column identity", {
  hostile <- 'reading"]];stop("COLUMN_INJECTION");data[["reading'
  d <- data.frame(value=c(3,4,5),check.names=FALSE)
  names(d) <- hostile
  s <- sp(missingness="report",approval=NULL,outcome=hostile)
  ph <- ru_analyze_plan(s,d)
  stopifnot(ph$status=="READY")
  show <- ru_analyze_code(ph)
  check <- new.env(parent=baseenv());check$data <- d
  out <- eval(parse(text=show$code),envir=check)
  stopifnot(out$mean==4,grepl("COLUMN_INJECTION",show$code,fixed=TRUE))
})
mark("confirmation, actual execution and result seal", {
  bundle<-list(data=guided,source_context=ctx)
  cancelled<-ru_analyze_execute(p,bundle,confirm=FALSE)
  stopifnot(cancelled$status=="CANCELLED")
  executed<-ru_analyze_execute(p,bundle,confirm=TRUE)
  stopifnot(executed$status=="SUCCEEDED",
    executed$reason=="DESCRIPTIVE_RESULT_ONLY",executed$value$mean==17,
    executed$value$n_missing==1L,executed$measurement_unit=="degree_Celsius",
    nchar(executed$result_sha256)==64L,
    identical(ru_analyze_execute(p,guided,confirm=TRUE)$status,
              "REVALIDATION_REQUIRED"))
})
bundle<-list(data=guided,source_context=ctx)
result<-ru_analyze_execute(p,bundle,confirm=TRUE)
mark("stale/current data and configuration refuse execution", {
  changed<-guided;changed$reading[4]<-21
  stopifnot(ru_analyze_execute(p,list(data=changed,source_context=ctx),
      confirm=TRUE)$status=="REVALIDATION_REQUIRED")
  changed<-guided;changed$site_group[2]<-"Other"
  stopifnot(ru_analyze_execute(p,list(data=changed,source_context=ctx),
      confirm=TRUE)$status=="REVALIDATION_REQUIRED")
  changed<-guided[c("site_group","row_key","reading")]
  stopifnot(ru_analyze_execute(p,list(data=changed,source_context=ctx),
      confirm=TRUE)$status=="REVALIDATION_REQUIRED")
  newer<-source_record();newer$snapshot$data_revision<-2L
  stopifnot(ru_analyze_execute(p,list(data=guided,source_context=newer),
      confirm=TRUE)$status=="REVALIDATION_REQUIRED")
  newunit<-source_record()
  newunit$bindings[[3]]$measurement_unit$declared_code<-"degree_Fahrenheit"
  newunit$bindings[[3]]$measurement_unit$canonical_code<-"degree_Fahrenheit"
  stopifnot(ru_analyze_execute(p,list(data=guided,source_context=newunit),
      confirm=TRUE)$status=="REVALIDATION_REQUIRED")
  damaged<-p
  damaged$spec$user_attestations$missingness_exclusion_consent$revision<-2L
  stopifnot(ru_analyze_execute(damaged,bundle,confirm=TRUE)$status=="FAILED")
})
mark("histogram closure, bin counts and code", {
  d<-data.frame(reading=c(5,10,17,21,23,26))
  opts<-list(report_nonfinite=TRUE,breaks=c(0,10,20,30),
    histogram_scale="count",density_curve="none",
    interval_closure="left_closed_right_open",include_lowest=TRUE)
  ph<-ru_analyze_plan(sp("summary.histogram",missingness="report",
                         approval=NULL,hist=opts),d)
  stopifnot(ph$status=="READY",grepl("right = FALSE",
    ru_analyze_code(ph)$code,fixed=TRUE))
  rh<-ru_analyze_execute(ph,d,confirm=TRUE)
  stopifnot(rh$status=="SUCCEEDED",
    identical(as.integer(rh$value$histogram$counts),c(1L,2L,3L)),
    rh$value$histogram$closure=="left_closed_right_open")
  opts$interval_closure<-"right_closed_left_open"
  pr<-ru_analyze_plan(sp("summary.histogram",missingness="report",
                         approval=NULL,hist=opts),d)
  rr<-ru_analyze_execute(pr,d,confirm=TRUE)
  stopifnot(rr$status=="SUCCEEDED",
    identical(as.integer(rr$value$histogram$counts),c(2L,1L,3L)),
    !identical(pr$plan_id,ph$plan_id))
  opts$histogram_scale <- c("count","density")
  status(sp("summary.histogram",missingness="report",approval=NULL,
            hist=opts),d,"INVALID","INVALID_HISTOGRAM_PARAMETERS")
  opts$histogram_scale <- "count"
  opts$breaks<-c(0,5,20,30)
  status(sp("summary.histogram",missingness="report",
            approval=NULL,hist=opts),d,"NEEDS_INPUT",
         "UNEQUAL_WIDTH_REQUIRES_DENSITY")
})
mark("zero imputation creates a distinct computation", {
  d<-guided;d$reading[2]<-0
  op<-ru_analyze_plan(sp(),d)
  out<-ru_analyze_execute(op,d,confirm=TRUE)
  stopifnot(out$status=="SUCCEEDED",out$value$mean==12.75,
            !identical(op$plan_id,p$plan_id))
})
mark("result-bound export requires fresh consent and current source", {
  destdir<-tempfile("ru-l3-w2-export-")
  dir.create(destdir,recursive=FALSE)
  target<-file.path(destdir,"result.txt")
  token<-.ru_an_authorize_export(target,p,result,consent=TRUE)
  stopifnot(ru_analyze_export(p,result,token,data=NULL)$status=="REFUSED")
  # Any attempt consumes its one-shot permission, including a refused attempt.
  stopifnot(ru_analyze_export(p,result,token,data=bundle)$status=="REFUSED")
  token<-.ru_an_authorize_export(target,p,result,consent=TRUE)
  written<-ru_analyze_export(p,result,token,data=bundle)
  stopifnot(written$status=="EXPORTED",file.exists(target),
    grepl("Mean: 17",paste(readLines(target,warn=FALSE),collapse="\\n"),
          fixed=TRUE))
  stopifnot(ru_analyze_export(p,result,token,data=bundle)$status=="REFUSED")
  again<-.ru_an_authorize_export(target,p,result,consent=TRUE)
  stopifnot(ru_analyze_export(p,result,again,data=bundle)$status=="REFUSED")
  stopifnot(identical(readLines(target,warn=FALSE),
                      readLines(written$path,warn=FALSE)))
  bad<-result;bad$value$mean<-19
  outdest<-file.path(destdir,"bad.txt")
  tk<-.ru_an_authorize_export(outdest,p,bad,consent=TRUE)
  stopifnot(ru_analyze_export(p,bad,tk,data=bundle)$status=="REFUSED",
            !file.exists(outdest))
  tk<-.ru_an_authorize_export(outdest,p,result,consent=TRUE)
  changed<-guided;changed$reading[4]<-21
  stopifnot(ru_analyze_export(p,result,tk,data=list(data=changed,source_context=ctx))$status=="REFUSED",
            !file.exists(outdest))
  stopifnot(ru_analyze_export(p,result,tk,data=bundle)$status=="REFUSED")
  tk<-.ru_an_authorize_export(outdest,p,result,consent=TRUE)
  stopifnot(ru_analyze_export(p,result,tk,include_data=TRUE,data=bundle)$status=="REFUSED",
            !file.exists(outdest))
  tk<-.ru_an_authorize_export(outdest,p,consent=TRUE)
  code_only<-ru_analyze_export(p,result=NULL,path=tk)
  stopifnot(code_only$status=="EXPORTED",
            grepl("NOT_EXECUTED",readLines(outdest,warn=FALSE)[1],fixed=TRUE),
            any(grepl("stop('RU code-only export has no verified",
                readLines(outdest,warn=FALSE),fixed=TRUE)))
  unlink(destdir,recursive=TRUE)
})
mark("one-shot export token consumed even after invalid plan/argument", {
  outdir <- tempfile("ru-l3-token-refusal-")
  dir.create(outdir)
  one <- file.path(outdir,"tampered-plan.txt")
  tok <- .ru_an_authorize_export(one,p,result,consent=TRUE)
  altered_plan <- p
  altered_plan$checked$n_raw <- 999L
  denied <- ru_analyze_export(altered_plan,result,tok,data=bundle)
  stopifnot(denied$status=="REFUSED",
            denied$reason=="PLAN_NOT_READY_OR_MODIFIED")
  retry <- ru_analyze_export(p,result,tok,data=bundle)
  stopifnot(retry$status=="REFUSED",
            retry$reason=="FRESH_EXPORT_CONSENT_REQUIRED",
            !file.exists(one))
  two <- file.path(outdir,"malformed-flag.txt")
  tok <- .ru_an_authorize_export(two,p,result,consent=TRUE)
  denied <- ru_analyze_export(p,result,tok,include_data=NA,data=bundle)
  stopifnot(denied$status=="REFUSED",
            denied$reason=="INCLUDE_DATA_ARGUMENT_INVALID")
  retry <- ru_analyze_export(p,result,tok,data=bundle)
  stopifnot(retry$status=="REFUSED",
            retry$reason=="FRESH_EXPORT_CONSENT_REQUIRED",
            !file.exists(two))
  unlink(outdir,recursive=TRUE)
})
cat("RU L3 W2 AN-01 full independent suite PASS\n")