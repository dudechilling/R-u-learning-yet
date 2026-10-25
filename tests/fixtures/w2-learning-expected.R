# L5-independent W2 learning expectations from frozen G1 source and curriculum.
# These are requirements/positive-negative probes, not proof a learnr UI passed.
ru_w2_learning_expectations <- function() {
  list(
    contract_version = "ru.w2.l5.learning.v1",
    required_lesson_ids = c("ru.learning.foundation.01",
                            "ru.learning.foundation.02",
                            "ru.learning.foundation.03"),
    foundation_outcomes = c("ORI-01", "ORI-02", "ORI-03",
                             "R-01", "R-02", "R-03", "R-04", "DAT-01"),
    prereq = list(
      "ORI-01" = character(),
      "ORI-02" = "ORI-01",
      "ORI-03" = "ORI-02",
      "R-01" = "ORI-02",
      "R-02" = "R-01",
      "R-03" = "R-01",
      "R-04" = c("R-02", "R-03"),
      "DAT-01" = c("ORI-03", "R-04")
    ),
    required_help_steps = c("H0", "H1", "H2", "H3"),
    required_checker_outcomes = c("correct", "valid_correct_alternative",
                                   "incorrect_with_reason", "blank_rejected",
                                   "malformed_R_error_explained"),
    required_execution_contexts = c("Source", "Console"),
    source_transfer_requires_saved_editable_project_script = TRUE,
    console_execution_does_not_alone_prove_source_transfer = TRUE,
    independent_credit_requires_new_unhinted_problem = TRUE,
    guided_asset_expected_bytes = 81L,
    heldout_asset_expected_bytes = 162L,
    guided_types = c(row_key = "character", site_group = "character",
                     reading = "double"),
    declared_guided_unit = "degree_Celsius",
    declared_heldout_unit = "degree_Fahrenheit",
    row_id_leading_zero = "0007",
    row_id_must_remain_character = TRUE,
    site_is_category_not_subject = TRUE,
    progress_statuses = c("introduced", "practised", "performed_independently")
  )
}
ru_w2_learning_oracle_selftest <- function() {
  c <- ru_w2_learning_expectations()
  stopifnot(length(c$foundation_outcomes) == 8L,
            length(c$required_lesson_ids) == 3L,
            length(unique(c$required_lesson_ids)) == 3L,
            identical(c$required_help_steps, paste0("H",0:3)),
            all(names(c$prereq) %in% c$foundation_outcomes),
            all(unlist(c$prereq) %in% c$foundation_outcomes),
            identical(c$prereq[["DAT-01"]], c("ORI-03","R-04")),
            identical(c$guided_asset_expected_bytes, 81L),
            identical(c$heldout_asset_expected_bytes, 162L),
            identical(c$declared_guided_unit, "degree_Celsius"),
            identical(c$declared_heldout_unit, "degree_Fahrenheit"))
  visited <- character()
  ordered <- character()
  visit <- function(node) {
    if (node %in% ordered) return()
    stopifnot(!node %in% visited)
    visited <<- c(visited, node)
    for (p in c$prereq[[node]]) visit(p)
    ordered <<- c(ordered, node)
    visited <<- setdiff(visited,node)
  }
  for (node in names(c$prereq)) visit(node)
  stopifnot(setequal(ordered,c$foundation_outcomes))
  values <- c(13,NA_real_,18,20)
  a <- values[!is.na(values)]
  b <- values[which(!is.na(values))]
  stopifnot(identical(a,b),identical(a,c(13,18,20)),
            identical(mean(values,na.rm=TRUE), 17),
            abs(sum(values[!is.na(values)])/sum(!is.na(values))-17)<1e-12)
  # A genuine character key survives an import; a numeric parse loses leading zeros.
  k <- "0007"
  stopifnot(identical(k,sprintf("%04d",as.integer(k))),
            !identical(k,as.character(as.integer(k))))
  cat("L5_INDEPENDENT_W2_LEARNING_ORACLE_PASS 3 lessons 8 outcomes DAG; alternative R methods agree\n")
  invisible(TRUE)
}