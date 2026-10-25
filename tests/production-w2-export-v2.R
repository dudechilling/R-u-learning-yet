# L5 production W2 contract: ru.export.refusal.v2
# Authorized by SUP-RU-W2-R3-EXPORT-PRECEDENCE-30 revision 30.
# This NEW regression does not replace or retroactively pass the original
# immutable L5 13d8636c core fixture (and its W2-R2 failing evidence).
# Test permission-first and authorized data-specific refusals separately.
engine <- Sys.getenv("RU_L3_SOURCE", unset = "")
consumer <- Sys.getenv("RU_L3_CONSUMER_SOURCE", unset = "")
if (nzchar(engine)) {
  stopifnot(file.exists(engine), nzchar(consumer), file.exists(consumer))
  source(engine, local = FALSE)
  source(consumer, local = FALSE)
  authorize <- .ru_an_authorize_export
} else {
  suppressPackageStartupMessages(library(rulearn))
  authorize <- getFromNamespace(".ru_an_authorize_export", "rulearn")
}
stopifnot(requireNamespace("digest", quietly = TRUE),
          requireNamespace("shiny", quietly = TRUE),
          requireNamespace("bslib", quietly = TRUE))

independent_ru_w2_export_v2 <- function() {
  target_root <- tempfile("l5-refusal-v2-")
  stopifnot(!file.exists(target_root))
  dir.create(target_root, recursive = TRUE, mode = "0700")
  on.exit(unlink(target_root, recursive = TRUE), add = TRUE)
  path <- function(tag) file.path(target_root, paste0(tag, ".txt"))
  marker <- "L5_RAW_SYNTHETIC_ROW_B4_NOT_FOR_EXPORT"
  d <- data.frame(row_key = c(marker, "0008", "0009", "0010"),
                  site_group = c("N", "N", "S", "S"),
                  reading = c(13, NA_real_, 18, 20), stringsAsFactors = FALSE)
  data_before <- serialize(d, NULL, version = 3L)
  hash <- function(x) digest::digest(x, algo = "sha256", serialize = TRUE,
                                     serializeVersion = 3L)
  provenance_sha <- digest::digest("L5 source synthetic-v2", algo = "sha256",
                                    serialize = FALSE)
  ctx <- list(
    schema_version = "ru.source_context.v1",
    source = list(kind = "constructed_in_memory",
      source_id = "ru.l5.independent.export_v2", content_version = "1",
      source_file_sha256 = NULL,
      source_provenance = list(author = "L5 independent synthetic QA",
        declaration_sha256 = provenance_sha, verification_state = "DECLARED_ONLY",
        installed = FALSE)),
    parse = NULL,
    bindings = list(
      list(original_name = "row_key", storage_type = "character",
           analytic_role = "record_key", measurement_unit = NULL),
      list(original_name = "site_group", storage_type = "character",
           analytic_role = "grouping_category", measurement_unit = NULL),
      list(original_name = "reading", storage_type = "double",
           analytic_role = "outcome",
           measurement_unit = list(declared_code = "degree_Celsius",
             canonical_code = "degree_Celsius", unit_vocab_version = "ru-units-v1",
             declaration_evidence = "explicit independent constructed example"))),
    snapshot = list(encoder_id = "ru.r-serialize-v3.local.v1",
      sha256 = hash(list(codec = "ru.r-serialize-v3.local.v1", data = d)),
      row_count = nrow(d), column_count = ncol(d),
      column_order = names(d), row_names_kind = "automatic",
      missingness_by_column = vapply(d, function(x) sum(is.na(x)), integer(1L)),
      data_revision = 1L),
    identity_contract = list(source_context_version = "ru.source_context.v1",
      method_dictionary_version = "1.1-draft.v2",
      identity_codec_id = "ru.r-serialize-v3.local.v1",
      source_context_binding = "CURRENT_DATA_REQUIRED"),
    review = list(editorial = "NOT_REVIEWED", statistical = "NOT_REVIEWED",
      instructional = "NOT_REVIEWED", accessibility = "NOT_REVIEWED",
      rights = "NOT_CLEARED", release = "NOT_REVIEWED"))
  spec <- list(schema_version = "1.1-draft.v2",
    method_id = "describe.numeric", operation = "summary.only",
    parameters = list(report_nonfinite = TRUE), objective = "describe",
    estimand = "empirical_sample_distribution", outcome = "reading",
    predictors = NULL, grouping = NULL, unit_id = NULL,
    dependence = "unknown", design = "descriptive", sampling = "not_applicable",
    missingness_policy = "complete_case_with_consent",
    inference_target = "sample_only", confidence_level = NULL,
    user_attestations = list(missingness_exclusion_consent = list(
      value = TRUE, source = "user", revision = 1L,
      captured_at = "2026-10-24T14:00:00-07:00")))
  bundle <- list(data = d, source_context = ctx)
  failures <- 0L
  n <- 0L
  mark <- function(label, status, reason, got, denied_target = NULL) {
    actual <- tryCatch(
      if (is.list(got)) c(got$status, got$reason) else "<NOT_LIST>",
      error = function(e) paste0("<ERROR>", conditionMessage(e)))
    ok <- identical(actual, c(status, reason))
    absent <- is.null(denied_target) || !file.exists(denied_target)
    n <<- n + 1L
    if (!ok || !absent) failures <<- failures + 1L
    cat("L5_EXPORT_V2 ", label, " EXPECTED ", status, "/", reason,
        " ACTUAL ", paste(actual, collapse = "/"),
        " DESTINATION_ABSENT ", absent, " ",
        if (ok && absent) "PASS" else "FAIL", "\n", sep = "")
  }
  check_bool <- function(label, ok) {
    n <<- n + 1L
    ok <- isTRUE(ok)
    if (!ok) failures <<- failures + 1L
    cat("L5_EXPORT_V2 ", label, " ",
        if (ok) "PASS" else "FAIL", "\n", sep = "")
  }
  plan <- ru_analyze_plan(spec, d, source_context = ctx)
  mark("plan_approved", "READY", "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN", plan)
  if (!identical(plan$status, "READY")) stop("Valid synthetic plan not READY")
  run <- ru_analyze_execute(plan, bundle, confirm = TRUE)
  mark("execution_succeeded", "SUCCEEDED", "DESCRIPTIVE_RESULT_ONLY", run)
  if (!identical(run$status, "SUCCEEDED")) stop("Cannot assess export without execution")
  check_bool("independent_mean17_variance13",
             isTRUE(all.equal(run$value$mean, 17)) &&
             isTRUE(all.equal(run$value$sd^2, 13)) &&
             identical(run$value$n_missing, 1L))
  export <- function(destination, res = run, data = bundle,
                     include_data = FALSE, p = plan) {
    tryCatch(ru_analyze_export(p, result = res, path = destination,
                              include_data = include_data, data = data),
             error = function(e) list(status = "<ERROR>",
                                       reason = conditionMessage(e)))
  }
  token <- function(dest, res = run, include_data = FALSE) {
    authorize(dest, plan, result = res, include_data = include_data, consent = TRUE)
  }
  # Permission-first status protects the current-data state from a raw filename.
  a <- path("bare-missing")
  mark("plain_path_no_data", "REFUSED", "FRESH_EXPORT_CONSENT_REQUIRED",
       export(a, data = NULL), a)
  changed <- d
  changed$reading[[4L]] <- 21
  a <- path("bare-stale")
  mark("plain_path_stale_data", "REFUSED", "FRESH_EXPORT_CONSENT_REQUIRED",
       export(a, data = list(data = changed, source_context = ctx)), a)
  check_bool("plain_path_did_not_disclose_data_diagnostic", !file.exists(a))
  # Once there is new correctly scoped permission, data diagnostics are specific.
  a <- path("token-missing")
  t <- token(a)
  mark("fresh_token_missing_data", "REFUSED", "CURRENT_DATA_REQUIRED",
       export(t, data = NULL), a)
  mark("missing_data_refusal_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t), a)
  mutated <- list(
    changed_outcome = list(data = changed, source_context = ctx),
    changed_row_id = { x <- d; x$row_key[1L] <- "OTHER"; list(data = x, source_context = ctx) },
    changed_row_order = list(data = d[c(2L, 1L, 3L, 4L), , drop = FALSE],
                             source_context = ctx),
    changed_source_revision = {
      x <- ctx; x$snapshot$data_revision <- 2L
      list(data = d, source_context = x)
    },
    changed_declared_unit = {
      x <- ctx
      x$bindings[[3L]]$measurement_unit$declared_code <- "degree_Fahrenheit"
      x$bindings[[3L]]$measurement_unit$canonical_code <- "degree_Fahrenheit"
      list(data = d, source_context = x)
    }
  )
  for (name in names(mutated)) {
    a <- path(paste0("stale-", name))
    t <- token(a)
    mark(name, "REFUSED", "REVALIDATION_REQUIRED",
         export(t, data = mutated[[name]]), a)
    mark(paste0(name, "_token_consumed"), "REFUSED",
         "FRESH_EXPORT_CONSENT_REQUIRED", export(t), a)
  }
  # A malformed plan/argument is refused, and a provided typed token cannot
  # be recycled after that refused attempt, despite a later corrected request.
  a <- path("tampered-plan")
  t <- token(a)
  bad <- plan
  bad$spec$objective <- "causal"
  mark("tampered_plan", "REFUSED", "PLAN_NOT_READY_OR_MODIFIED",
       export(t, p = bad), a)
  mark("tampered_plan_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t), a)
  a <- path("malformed-flag")
  t <- token(a)
  mark("malformed_include_data", "REFUSED", "INCLUDE_DATA_ARGUMENT_INVALID",
       export(t, include_data = NA), a)
  mark("malformed_flag_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t), a)
  a <- path("raw-data")
  t <- token(a, include_data = TRUE)
  mark("raw_data_forbidden", "REFUSED", "RAW_DATA_EXPORT_UNSUPPORTED",
       export(t, include_data = TRUE), a)
  mark("raw_data_refusal_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t, include_data = TRUE), a)
  a <- path("cancelled")
  cancelled <- ru_analyze_execute(plan, bundle, confirm = FALSE)
  mark("unconfirmed_run", "CANCELLED", "RUN_NOT_CONFIRMED", cancelled)
  t <- token(a, res = cancelled)
  mark("cancelled_not_exportable", "REFUSED", "RESULT_NOT_EXPORTABLE",
       export(t, res = cancelled), a)
  mark("cancelled_refusal_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t, res = cancelled), a)
  a <- path("occupied")
  writeLines("PRESERVE_EXISTING", a, useBytes = TRUE)
  t <- token(a)
  mark("occupied_path_refused", "REFUSED", "PATH_EXISTS_OR_INVALID", export(t))
  check_bool("occupied_file_not_overwritten",
             identical(readLines(a, warn = FALSE), "PRESERVE_EXISTING"))
  mark("occupied_refusal_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t))
  # Inspectable code is labelled NOT_EXECUTED and mechanically stops if sourced.
  a <- path("code-preview")
  t <- token(a, res = NULL)
  mark("guarded_code_only", "EXPORTED", "CODE_ONLY_NOT_EXECUTED",
       export(t, res = NULL, data = NULL))
  code <- if (file.exists(a)) readLines(a, warn = FALSE) else character()
  check_bool("guarded_code_not_executed",
    length(code) > 4L && any(grepl("NOT_EXECUTED", code, fixed = TRUE)) &&
    any(grepl("stop(", code, fixed = TRUE)) &&
    !any(grepl(marker, code, fixed = TRUE)))
  mark("code_only_success_consumes_token", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t, res = NULL), NULL)
  a <- path("approved-result")
  t <- token(a)
  mark("approved_current_export", "EXPORTED", "BOUND_RESULT", export(t))
  lines <- if (file.exists(a)) readLines(a, warn = FALSE) else character()
  check_bool("approved_file_contains_only_summary",
             any(grepl("Mean: 17", lines, fixed = TRUE)) &&
             !any(grepl(marker, lines, fixed = TRUE)))
  mark("approved_export_cannot_replay", "REFUSED",
       "FRESH_EXPORT_CONSENT_REQUIRED", export(t))
  check_bool("no_input_data_mutation",
             identical(data_before, serialize(d, NULL, version = 3L)))
  # Distinguish ABSENT interval_closure key from PRESENT NULL with R list
  # bracket assignment; $<-NULL deletes the element and would be a test error.
  h <- spec
  h$operation <- "summary.histogram"
  h$parameters <- list(breaks = c(0, 10, 20, 30),
    histogram_scale = "count", density_curve = "none",
    report_nonfinite = TRUE, interval_closure = "left_closed_right_open",
    include_lowest = TRUE)
  absent <- h
  absent$parameters$interval_closure <- NULL
  check_bool("missing_closure_key_is_actually_absent",
             !"interval_closure" %in% names(absent$parameters))
  mark("histogram_closure_missing", "NEEDS_INPUT", "HISTOGRAM_PARAMETERS_REQUIRED",
       ru_analyze_plan(absent, d, source_context = ctx))
  present_null <- h
  present_null$parameters["interval_closure"] <- list(NULL)
  check_bool("present_null_closure_key_retained",
             "interval_closure" %in% names(present_null$parameters) &&
             is.null(present_null$parameters$interval_closure))
  mark("histogram_closure_present_null", "INVALID", "INVALID_HISTOGRAM_PARAMETERS",
       ru_analyze_plan(present_null, d, source_context = ctx))
  # Server-level Shiny checkbox scope; testServer is NOT a browser or AT test.
  app <- ru_analyze(bundle)
  check_bool("Shiny_app_not_auto_launched", inherits(app, "shiny.appobj"))
  shiny::testServer(app$serverFuncSource(), {
    a <- path("UI-destination-A")
    b <- path("UI-destination-B")
    c <- path("UI-destination-C")
    session$setInputs(data_choice = "provided", question_choice = "summary",
      outcome_choice = "reading", missing_choice = "complete_case_with_consent",
      consent_choice = "grant", run_confirm = FALSE, export_kind = "result",
      export_consent = FALSE)
    session$setInputs(plan_btn = 1)
    check_bool("UI_plan_ready_before_execution",
               identical(current_plan()$status, "READY") &&
               is.null(execution_result()))
    session$setInputs(run_btn = 1)
    mark("UI_no_implicit_run", "CANCELLED", "RUN_NOT_CONFIRMED",
         execution_result())
    session$setInputs(run_confirm = TRUE, run_btn = 2)
    mark("UI_affirmative_run", "SUCCEEDED", "DESCRIPTIVE_RESULT_ONLY",
         execution_result())
    session$setInputs(export_path = a, export_consent = FALSE, export_btn = 1)
    mark("UI_checkbox_unchecked", "REFUSED",
         "EXPLICIT_EXPORT_CONSENT_REQUIRED", export_receipt(), a)
    session$setInputs(export_consent = TRUE)
    session$setInputs(export_path = b)
    session$setInputs(export_btn = 2)
    mark("UI_changed_destination_stale_checkbox", "REFUSED",
         "FRESH_DESTINATION_CONSENT_REQUIRED", export_receipt(), b)
    check_bool("UI_original_destination_still_absent", !file.exists(a))
    session$setInputs(export_consent = FALSE)
    session$setInputs(export_consent = TRUE, export_btn = 3)
    mark("UI_new_consent_for_B", "EXPORTED", "BOUND_RESULT", export_receipt())
    check_bool("UI_valid_B_export_has_no_raw_row",
               file.exists(b) && !any(grepl(marker,
                 readLines(b, warn = FALSE), fixed = TRUE)))
    session$setInputs(export_kind = "code", export_path = c)
    session$setInputs(export_consent = TRUE)
    session$setInputs(export_kind = "result")
    session$setInputs(export_btn = 4)
    mark("UI_changed_export_kind", "REFUSED",
         "FRESH_DESTINATION_CONSENT_REQUIRED", export_receipt(), c)
    session$setInputs(export_consent = FALSE)
    session$setInputs(export_consent = TRUE)
    session$setInputs(plan_btn = 2)
    session$setInputs(export_btn = 5)
    mark("UI_new_plan_revokes_prior_checkbox", "REFUSED",
         "FRESH_DESTINATION_CONSENT_REQUIRED", export_receipt(), c)
    session$setInputs(export_consent = FALSE)
    session$setInputs(export_kind = "code", export_consent = TRUE,
                      export_btn = 6)
    mark("UI_fresh_guarded_code", "EXPORTED", "CODE_ONLY_NOT_EXECUTED",
         export_receipt())
    check_bool("UI_guarded_code_no_raw_rows",
               file.exists(c) && any(grepl("NOT_EXECUTED",
                 readLines(c, warn = FALSE), fixed = TRUE)) &&
               !any(grepl(marker, readLines(c, warn = FALSE), fixed = TRUE)))
  })
  cat("L5_EXPORT_V2 TOTAL=", n, " FAILURES=", failures,
      " CONTRACT=ru.export.refusal.v2", "\n", sep = "")
  if (failures) stop("Independent current export v2 QA mismatches: ", failures)
  invisible(n)
}
independent_ru_w2_export_v2()