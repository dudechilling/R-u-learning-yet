# L5-owned W2-R1 acceptance oracle, composed before inspecting W2 runtime source.
# These are synthetic facts and expected decisions, not product-generated outputs.
# Do not change numerical expectations to accommodate a failing implementation.

ru_w2_independent_oracle <- function() {
  guided <- data.frame(
    row_key = c("G001", "G002", "G003", "G004"),
    site_group = c("North", "North", "South", "South"),
    reading = c(13, NA_real_, 18, 20),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  # Hypothetical transfer-only identity example, NOT the shipped held-out CSV.
  # The exact L2 sites-transfer-v1.csv is independently verified in
  # tests/production-w2-csv.R (162 bytes; 5 rows; 4 columns).
  transfer <- data.frame(
    row_key = c("0007", "0008", "0009", "0010"),
    site_group = c("West", "West", "East", "East"),
    temp_f = c(68, 71.6, NA_real_, 75.2),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  list(
    contract = "ru.w2.l5.independent.v1",
    guided = guided,
    guided_outcome = "reading", guided_unit = "degree_Celsius",
    source_identity = "sites-intro-v1", source_identity_kind = "authored_csv",
    site_group_is_subject_id = FALSE,
    transfer = transfer,
    transfer_outcome = "temp_f", transfer_unit = "degree_Fahrenheit",
    transfer_id_storage = "character",
    expected_numeric = list(
      n_raw = 4L, n_observed = 3L, n_missing = 1L,
      sum = 51, mean = 17, median = 18, sample_variance = 13,
      sample_sd = 3.605551275463989, minimum = 13,
      q1_type7 = 15.5, q3_type7 = 19,
      maximum = 20, observed_range = 7, iqr_type7 = 3.5
    ),
    policy_cases = list(
      consent_approved = list(
        missingness_policy = "complete_case_with_consent",
        consent = TRUE, status = "READY",
        reason = "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN"),
      consent_denied = list(
        missingness_policy = "complete_case_with_consent",
        consent = FALSE, status = "UNSUPPORTED", reason = "CONSENT_DENIED"),
      consent_unanswered = list(
        missingness_policy = "complete_case_with_consent",
        consent = NA, status = "NEEDS_INPUT",
        reason = "EXCLUSION_CONSENT_REQUIRED"),
      fail_with_actual_na = list(
        missingness_policy = "fail", consent = NA, status = "INVALID",
        reason = "MISSINGNESS_POLICY_VIOLATION"),
      report_only_with_center = list(
        missingness_policy = "report", consent = NA, status = "NEEDS_INPUT",
        reason = "MISSINGNESS_TREATMENT_REQUIRED"),
      clustered_descriptive_is_allowed = list(
        missingness_policy = "complete_case_with_consent",
        consent = TRUE, dependence = "clustered", status = "READY",
        reason = "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN")
    ),
    replay_expectations = list(
      changed_reading = list(affected = "raw_and_contextual_snapshot",
                             permission = "DENIED", reason = "REVALIDATION_REQUIRED"),
      changed_site_label = list(affected = "raw_and_contextual_snapshot",
                                permission = "DENIED", reason = "REVALIDATION_REQUIRED"),
      changed_row_order = list(affected = "raw_and_contextual_snapshot",
                               permission = "DENIED", reason = "REVALIDATION_REQUIRED"),
      changed_attestation_revision = list(affected = "contextual_plan_binding",
                                          permission = "DENIED", reason = "REVALIDATION_REQUIRED"),
      cancelled_execution = list(permission = "DENIED", reason = "RESULT_NOT_EXPORTABLE"),
      export_without_current_data = list(permission = "DENIED", reason = "CURRENT_DATA_REQUIRED")
    ),
    publication = list(
      numeric_summary_is_not_histogram = TRUE,
      numeric_description_is_not_independence_proof = TRUE,
      unit_codes_are_not_sampling_units = TRUE,
      code_only_export_state = "NOT_EXECUTED",
      result_bound_export_needs_fresh_current_data = TRUE,
      no_raw_research_rows_in_plan_or_logs = TRUE
    )
  )
}

ru_w2_oracle_selftest <- function() {
  x <- ru_w2_independent_oracle()
  d <- x$guided; z <- d$reading
  stopifnot(identical(names(d), c("row_key","site_group","reading")),
            identical(vapply(d, typeof, character(1L)),
                      c(row_key="character",site_group="character",reading="double")),
            identical(z, c(13,NA_real_,18,20)),
            identical(which(is.na(z)), 2L),
            identical(x$guided_outcome, "reading"),
            identical(x$guided_unit,"degree_Celsius"),
            identical(x$site_group_is_subject_id, FALSE),
            length(z) == 4L, sum(!is.na(z)) == 3L,
            sum(is.na(z)) == 1L,
            identical(sum(z,na.rm=TRUE), 51),
            isTRUE(all.equal(mean(z,na.rm=TRUE),17)),
            isTRUE(all.equal(stats::median(z,na.rm=TRUE),18)),
            isTRUE(all.equal(stats::var(z,na.rm=TRUE),13)),
            isTRUE(all.equal(stats::sd(z,na.rm=TRUE),sqrt(13))),
            isTRUE(all.equal(stats::quantile(z,probs=c(.25,.75),na.rm=TRUE,
                                            names=FALSE,type=7),c(15.5,19))),
            identical(range(z,na.rm=TRUE),c(13,20)),
            identical(x$transfer$row_key,c("0007","0008","0009","0010")),
            identical(typeof(x$transfer$row_key),"character"),
            identical(x$transfer_unit, "degree_Fahrenheit"))
  altered <- d;altered$reading[[4L]] <- 21
  stopifnot(abs(mean(altered$reading,na.rm=TRUE)-17.3333333333333)<1e-12,
            !identical(serialize(d,NULL,version=3L),
                       serialize(altered,NULL,version=3L)))
  altered <- d; altered$site_group[[1L]] <- "South"
  stopifnot(identical(altered$reading,d$reading),
            !identical(serialize(d,NULL,version=3L),
                       serialize(altered,NULL,version=3L)))
  altered <- d[c(2L,1L,3L,4L),,drop=FALSE]
  stopifnot(!identical(serialize(d,NULL,version=3L),
                       serialize(altered,NULL,version=3L)))
  expected <- x$policy_cases
  stopifnot(
    identical(expected$consent_approved$status,"READY"),
    identical(expected$consent_denied$reason,"CONSENT_DENIED"),
    identical(expected$consent_unanswered$status,"NEEDS_INPUT"),
    identical(expected$fail_with_actual_na$status,"INVALID"),
    identical(expected$report_only_with_center$reason,
              "MISSINGNESS_TREATMENT_REQUIRED"))
  cat("L5_INDEPENDENT_W2_NUMERIC_ORACLE_PASS n=4 complete=3 missing=1 mean=17 median=18 variance=13\n")
  invisible(TRUE)
}