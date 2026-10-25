# RU W2-R2 Analyze consumer real-server tests. No browser, network or raw data export.
engine <- Sys.getenv("RU_L3_SOURCE",unset="")
consumer <- Sys.getenv("RU_L3_CONSUMER_SOURCE",unset="")
if (nzchar(engine) && nzchar(consumer)) {
  source(engine,local=FALSE); source(consumer,local=FALSE)
} else {
  suppressPackageStartupMessages(library(rulearn))
  ns <- asNamespace("rulearn")
  for (n in c("ru_analyze","ru_analyze_plan","ru_analyze_code",
              "ru_analyze_execute","ru_analyze_export",
              ".ru_an_authorize_export",".ru_an_consumer_prepare",
              ".ru_an_consumer_dependency_status",
              ".ru_an_consumer_default",".ru_an_consumer_data",
              ".ru_an_consumer_result_text"))
    assign(n,get(n,envir=ns),envir=.GlobalEnv)
}
mark <- function(label,expr) {force(expr); cat("L3 W2-R2 PASS: ",label,"\n",sep="")}
fixture <- data.frame(site=c("North","North","South","South"),
                      reading=c(13,NA_real_,18,20),
                      stringsAsFactors=FALSE)
ctx_fixture <- function(data=fixture) {
  types <- vapply(data,typeof,character(1L))
  bindings <- lapply(seq_along(data),function(i) list(
    original_name=names(data)[i],storage_type=unname(types[i]),
    analytic_role=if(names(data)[i]=="reading")"outcome" else
      "grouping_category",
    measurement_unit=if(names(data)[i]=="reading")
      list(declared_code="degree_Celsius",canonical_code="degree_Celsius",
           unit_vocab_version="ru-units-v1",
           declaration_evidence="explicit synthetic teaching record") else NULL))
  list(schema_version="ru.source_context.v1",
    source=list(kind="constructed_in_memory",
      source_id="ru.testing.l3.w2r2.sites",content_version="ru-w2r2-synthetic-1",
      source_file_sha256=NULL,
      source_provenance=list(author="L3 independent synthetic fixture",
        declaration_sha256=strrep("a",64),
        verification_state="DECLARED_ONLY",installed=FALSE)),
    parse=NULL,bindings=bindings,
    snapshot=list(encoder_id="ru.r-serialize-v3.local.v1",
      sha256=digest::digest(list(codec="ru.r-serialize-v3.local.v1",
                                data=data),algo="sha256",
                            serialize=TRUE,serializeVersion=3L),
      row_count=nrow(data),column_count=ncol(data),
      column_order=names(data),row_names_kind="automatic",
      missingness_by_column=vapply(data,function(v) sum(is.na(v)),integer(1L)),
      data_revision=1L),
    identity_contract=list(source_context_version="ru.source_context.v1",
      method_dictionary_version="1.1-draft.v2",
      identity_codec_id="ru.r-serialize-v3.local.v1",
      source_context_binding="CURRENT_DATA_REQUIRED"),
    review=list(editorial="NOT_REVIEWED",statistical="NOT_REVIEWED",
      instructional="NOT_REVIEWED",accessibility="NOT_REVIEWED",
      rights="NOT_CLEARED",release="NOT_REVIEWED"))
}
context <- ctx_fixture()
bundle <- list(data=fixture,source_context=context)
mark("app construction / no automatic Shiny run or computation",{
  app <- ru_analyze(bundle)
  stopifnot(inherits(app,"shiny.appobj"),is.function(app$serverFuncSource()))
  stopifnot(identical(names(formals(ru_analyze)),c("data","spec")))
})
mark("direct planner translator four eligibility states",{
  f <- function(policy="report",consent="undecided",d=bundle,question="summary",
                outcome="reading",data_choice="provided",spec=NULL)
    .ru_an_consumer_prepare(d,spec,data_choice=data_choice,
      question=question,outcome=outcome,
      missingness_policy=policy,consent=consent)
  stopifnot(f()$status=="NEEDS_INPUT",
    f()$reason=="MISSINGNESS_TREATMENT_REQUIRED",
    f("fail")$status=="INVALID",
    f("fail")$reason=="MISSINGNESS_POLICY_VIOLATION",
    f("complete_case_with_consent")$reason=="EXCLUSION_CONSENT_REQUIRED",
    f("complete_case_with_consent","deny")$status=="UNSUPPORTED",
    f("complete_case_with_consent","deny")$reason=="CONSENT_DENIED",
    f("complete_case_with_consent","grant")$status=="READY",
    f("complete_case_with_consent","grant")$reason==
      "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN",
    f(data_choice="")$reason=="DATA_SELECTION_REQUIRED",
    f(question="")$reason=="QUESTION_SELECTION_REQUIRED",
    f(outcome="")$reason=="OUTCOME_REQUIRED",
    f(d=NULL)$status=="NEEDS_INPUT")
  wrong <- .ru_an_consumer_default()
  wrong$method_id <- "estimate.mean"
  stopifnot(f(spec=wrong)$status=="UNSUPPORTED",
    f(spec=wrong)$reason=="METHOD_NOT_IMPLEMENTED")
  wrong <- .ru_an_consumer_default()
  wrong$method_id <- "not.real"
  stopifnot(f(spec=wrong)$status=="INVALID",
    f(spec=wrong)$reason=="UNKNOWN_METHOD_ID")
  unsupported <- fixture
  unsupported$reading <- as.character(unsupported$reading)
  stopifnot(f(d=unsupported,policy="report")$status=="INVALID",
    f(d=unsupported,policy="report")$reason=="NUMERIC_OUTCOME_REQUIRED")
  stopifnot(.ru_an_consumer_prepare(bundle,data_choice="provided",
    question="histogram",outcome="reading",missingness_policy=
      "complete_case_with_consent",consent="grant")$reason==
      "HISTOGRAM_BREAKS_REQUIRED")
})
mark("missing-dependency path reports UNAVAILABLE",{
  original <- environment(.ru_an_consumer_dependency_status)
  wrapper <- .ru_an_consumer_dependency_status
  local_env <- new.env(parent=original)
  local_env$requireNamespace <- function(package,quietly=TRUE)
    !identical(package,"bslib")
  environment(wrapper) <- local_env
  unavailable <- wrapper()
  stopifnot(identical(unavailable$status,"UNAVAILABLE"),
            identical(unavailable$reason,"ANALYZE_DEPENDENCIES_MISSING"),
            identical(unavailable$missing_dependencies,"bslib"),
            grepl("No packages were installed",unavailable$detail,fixed=TRUE))
})
mark("actual Shiny server choice/consent/preview/run/export lifecycle",{
  destdir <- tempfile("ru-w2r2-")
  dir.create(destdir)
  result_path <- file.path(destdir,"sample-result.txt")
  preview_path <- file.path(destdir,"guarded-preview.R")
  existing_path <- file.path(destdir,"existing.txt")
  writeLines("DO-NOT-OVERWRITE",existing_path)
  shiny::testServer(app$serverFuncSource(),{
    stopifnot(is.null(current_plan()),is.null(code_preview()),
              is.null(execution_result()),is.null(export_receipt()))
    stopifnot(grepl("NOT_EXECUTED",output$result_info,fixed=TRUE))
    session$setInputs(data_choice="provided",question_choice="summary",
      outcome_choice="reading",missing_choice="report",
      consent_choice="undecided",export_kind="result",
      run_confirm=FALSE,export_consent=FALSE)
    stopifnot(is.null(current_plan()),is.null(execution_result()))
    session$setInputs(plan_btn=1)
    stopifnot(current_plan()$status=="NEEDS_INPUT",
      current_plan()$reason=="MISSINGNESS_TREATMENT_REQUIRED")
    session$setInputs(preview_btn=1)
    stopifnot(code_preview()$status=="UNAVAILABLE")
    session$setInputs(run_btn=1)
    stopifnot(execution_result()$status=="FAILED",
      execution_result()$reason=="PLAN_NOT_READY")
    session$setInputs(missing_choice="complete_case_with_consent",
                      consent_choice="undecided")
    stopifnot(is.null(current_plan()),is.null(execution_result()))
    session$setInputs(plan_btn=2)
    stopifnot(current_plan()$status=="NEEDS_INPUT",
              current_plan()$reason=="EXCLUSION_CONSENT_REQUIRED")
    session$setInputs(consent_choice="deny")
    session$setInputs(plan_btn=3)
    stopifnot(current_plan()$status=="UNSUPPORTED",
              current_plan()$reason=="CONSENT_DENIED")
    session$setInputs(consent_choice="grant")
    session$setInputs(plan_btn=4)
    plan <- current_plan()
    stopifnot(plan$status=="READY",
      plan$reason=="ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN",
      plan$checked$n_missing==1L,
      identical(plan$measurement_unit,"degree_Celsius"),
      is.null(plan$data),is.null(execution_result()))
    stopifnot(grepl("READY",output$plan_info,fixed=TRUE))
    session$setInputs(preview_btn=2)
    stopifnot(code_preview()$status=="PREVIEW_ONLY",
       code_preview()$reason=="NOT_EXECUTED",
       is.null(execution_result()),
       grepl('data[["reading"]]',output$code_info,fixed=TRUE))
    session$setInputs(run_btn=2,run_confirm=FALSE)
    stopifnot(execution_result()$status=="CANCELLED",
              execution_result()$reason=="RUN_NOT_CONFIRMED")
    session$setInputs(run_confirm=TRUE)
    stopifnot(execution_result()$status=="CANCELLED")
    session$setInputs(run_btn=3)
    stopifnot(execution_result()$status=="SUCCEEDED",
      execution_result()$value$mean==17,
      execution_result()$value$n_observed==3L,
      execution_result()$measurement_unit=="degree_Celsius",
      grepl("Observed mean: 17",output$result_info,fixed=TRUE))
    # No implicit export; destination and consent must both be explicit.
    session$setInputs(export_path=result_path,export_consent=FALSE,
                      export_btn=1)
    stopifnot(export_receipt()$status=="REFUSED",
              export_receipt()$reason=="EXPLICIT_EXPORT_CONSENT_REQUIRED",
              !file.exists(result_path))
    session$setInputs(export_consent=TRUE,export_btn=2)
    stopifnot(export_receipt()$status=="EXPORTED",
              file.exists(result_path),
              grepl("Mean: 17",paste(readLines(result_path),collapse=" "),
                    fixed=TRUE))
    session$setInputs(export_btn=3)
    stopifnot(export_receipt()$status=="REFUSED",
              export_receipt()$reason=="FRESH_DESTINATION_CONSENT_REQUIRED",
              !identical(readLines(result_path),"DO-NOT-OVERWRITE"))
    session$setInputs(export_path=existing_path)
    session$setInputs(export_consent=FALSE)
    session$setInputs(export_consent=TRUE)
    session$setInputs(export_btn=4)
    stopifnot(export_receipt()$status=="REFUSED",
              identical(readLines(existing_path),"DO-NOT-OVERWRITE"))
    # Proven consumer defect: checking consent for A and changing to B must
    # not create B until the user explicitly consents again.
    changed_path <- file.path(destdir,"unconsented-change.txt")
    session$setInputs(export_path=result_path)
    session$setInputs(export_consent=FALSE)
    session$setInputs(export_consent=TRUE)
    session$setInputs(export_path=changed_path)
    session$setInputs(export_btn=5)
    stopifnot(export_receipt()$status=="REFUSED",
              export_receipt()$reason=="FRESH_DESTINATION_CONSENT_REQUIRED",
              !file.exists(changed_path))
    session$setInputs(export_kind="code",export_path=preview_path)
    session$setInputs(export_consent=FALSE)
    session$setInputs(export_consent=TRUE)
    session$setInputs(export_btn=6)
    stopifnot(export_receipt()$status=="EXPORTED",
              file.exists(preview_path),
              grepl("NOT_EXECUTED",readLines(preview_path)[1],fixed=TRUE),
              any(grepl("stop('RU code-only export",
                  readLines(preview_path),fixed=TRUE)))
    # Method-change invalidates even a previously succeeded run.
    session$setInputs(outcome_choice="site")
    stopifnot(is.null(current_plan()),is.null(execution_result()),
              is.null(code_preview()))
    session$setInputs(plan_btn=5)
    stopifnot(current_plan()$status=="INVALID",
              current_plan()$reason=="NUMERIC_OUTCOME_REQUIRED")
  })
  unlink(destdir,recursive=TRUE)
})
mark("actual Shiny server complete-case histogram remains preview-only until run",{
  histogram_app <- ru_analyze(bundle)
  shiny::testServer(histogram_app$serverFuncSource(),{
    session$setInputs(data_choice="provided",question_choice="histogram",
      outcome_choice="reading",missing_choice="complete_case_with_consent",
      consent_choice="grant",histogram_breaks="0,10,20,30",
      histogram_scale="count",interval_closure="left_closed_right_open",
      include_lowest=TRUE)
    session$setInputs(plan_btn=1)
    stopifnot(current_plan()$status=="READY",
              current_plan()$spec$operation=="summary.histogram",
              is.null(execution_result()))
    session$setInputs(preview_btn=1)
    stopifnot(code_preview()$status=="PREVIEW_ONLY",
              is.null(execution_result()))
    session$setInputs(run_confirm=TRUE,run_btn=1)
    stopifnot(execution_result()$status=="SUCCEEDED",
      identical(as.integer(execution_result()$value$histogram$counts),
                c(0L,2L,1L)))
    session$setInputs(histogram_breaks="")
    stopifnot(is.null(current_plan()),is.null(execution_result()))
    session$setInputs(plan_btn=2)
    stopifnot(current_plan()$status=="NEEDS_INPUT",
              current_plan()$reason=="HISTOGRAM_BREAKS_REQUIRED")
  })
})
mark("no attached data renders as explicit NEEDS_INPUT, never computes",{
  no_data <- ru_analyze()
  stopifnot(inherits(no_data,"shiny.appobj"))
  shiny::testServer(no_data$serverFuncSource(),{
    session$setInputs(data_choice="none",question_choice="summary",
      outcome_choice="reading")
    session$setInputs(plan_btn=1)
    stopifnot(current_plan()$status=="NEEDS_INPUT",
      current_plan()$reason=="DATA_SELECTION_REQUIRED",
      is.null(execution_result()))
  })
})
mark("authorized-token replay proves export current-data precedence",{
  p <- .ru_an_consumer_prepare(bundle,data_choice="provided",
    question="summary",outcome="reading",
    missingness_policy="complete_case_with_consent",consent="grant")
  stopifnot(p$status=="READY")
  good <- ru_analyze_execute(p,bundle,confirm=TRUE)
  stopifnot(good$status=="SUCCEEDED",good$value$mean==17)
  dest <- tempfile("ru-l3-w2r2-stale-")
  # Consent absent: security gate precedes data diagnostics by design.
  no_consent <- ru_analyze_export(p,good,path=dest,data=NULL)
  stopifnot(no_consent$status=="REFUSED",
            no_consent$reason=="FRESH_EXPORT_CONSENT_REQUIRED")
  tok <- .ru_an_authorize_export(dest,p,good,consent=TRUE)
  no_data <- ru_analyze_export(p,good,path=tok,data=NULL)
  stopifnot(no_data$status=="REFUSED",
            no_data$reason=="CURRENT_DATA_REQUIRED",!file.exists(dest))
  stopifnot(ru_analyze_export(p,good,path=tok,data=bundle)$reason==
              "FRESH_EXPORT_CONSENT_REQUIRED")
  altered <- bundle
  altered$data$reading[4] <- 21
  tok <- .ru_an_authorize_export(dest,p,good,consent=TRUE)
  changed <- ru_analyze_export(p,good,path=tok,data=altered)
  stopifnot(changed$status=="REFUSED",
            changed$reason=="REVALIDATION_REQUIRED",!file.exists(dest))
  stopifnot(ru_analyze_export(p,good,path=tok,data=bundle)$reason==
              "FRESH_EXPORT_CONSENT_REQUIRED")
  altered <- bundle
  altered$source_context$snapshot$data_revision <- 2L
  tok <- .ru_an_authorize_export(dest,p,good,consent=TRUE)
  stopifnot(ru_analyze_export(p,good,path=tok,data=altered)$reason==
              "REVALIDATION_REQUIRED",!file.exists(dest))
  altered <- bundle
  altered$source_context$bindings[[2]]$measurement_unit$canonical_code <-
    "degree_Fahrenheit"
  tok <- .ru_an_authorize_export(dest,p,good,consent=TRUE)
  stopifnot(ru_analyze_export(p,good,path=tok,data=altered)$reason==
              "REVALIDATION_REQUIRED",!file.exists(dest))
  tok <- .ru_an_authorize_export(dest,p,good,consent=TRUE)
  success <- ru_analyze_export(p,good,path=tok,data=bundle)
  stopifnot(success$status=="EXPORTED",file.exists(dest))
  unlink(dest)
})
cat("RU W2-R2 numeric Analyze consumer full server suite PASS\n")