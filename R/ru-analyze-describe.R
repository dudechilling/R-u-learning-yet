# RU W2 AN-01: one descriptive numeric workflow.
# No inference, data mutation, parser evaluation, network or package installation.
# These routines are staged until L1 owns the public NAMESPACE/Rd integration.

.ru_an_codec <- "ru.describe.numeric.ascii-base-v1"
.ru_an_engine <- "ru.describe.numeric.w2-r1"
.ru_an_spec_fields <- c("schema_version", "method_id", "operation",
  "parameters", "objective", "estimand", "outcome", "predictors", "grouping",
  "unit_id", "dependence", "design", "sampling", "missingness_policy",
  "inference_target", "confidence_level", "user_attestations")
.ru_an_known_methods <- c("describe.numeric", "describe.categorical",
  "prepare.tabular", "estimate.mean", "estimate.proportion",
  "compare.independent", "compare.paired", "compare.multigroup",
  "categorical.independence", "association.pearson", "association.spearman",
  "model.linear", "model.logistic", "correct.multiple",
  "probability.discrete", "probability.continuous", "temporal.explore",
  "resample.bootstrap")

.ru_an_reply <- function(status, reason, ...) {
  structure(c(list(status = status, reason = reason), list(...)),
            class = c("ru_analysis_plan", "list"))
}
.ru_an_result <- function(status, reason, ...) {
  structure(c(list(status = status, reason = reason), list(...)),
            class = c("ru_analysis_result", "list"))
}
.ru_an_flag <- function(x) is.logical(x) && length(x) == 1L && !is.na(x)
.ru_an_scalar <- function(x) is.character(x) && length(x) == 1L &&
  !is.na(x) && nzchar(x)
.ru_an_finite <- function(x) is.numeric(x) && length(x) == 1L &&
  !is.na(x) && is.finite(x)
.ru_an_sha <- function(bytes) {
  if (!requireNamespace("digest", quietly = TRUE))
    stop("Portable SHA-256 dependency unavailable.", call. = FALSE)
  digest::digest(bytes, algo = "sha256", serialize = FALSE)
}
.ru_an_len <- function(n) {
  if (length(n) != 1L || !is.finite(n) || n < 0 || n != trunc(n) ||
      n > 2^53)
    stop("Canonical payload length is unsupported.", call. = FALSE)
  result <- raw(8L)
  for (j in 8:1) {
    result[[j]] <- as.raw(n %% 256)
    n <- floor(n / 256)
  }
  result
}
.ru_an_pack <- function(tag, body = raw()) {
  c(charToRaw(tag), .ru_an_len(length(body)), body)
}
.ru_an_chars <- function(s) {
  if (!is.character(s) || anyNA(s))
    stop("Unsupported character identity.", call. = FALSE)
  for (value in s) {
    # Explicitly restricted portable domain: ASCII characters only.
    if (any(utf8ToInt(enc2utf8(value)) > 127L))
      stop("Non-ASCII data are outside the qualified identity domain.",
           call. = FALSE)
  }
  invisible(TRUE)
}
.ru_an_string <- function(s) {
  .ru_an_chars(s)
  .ru_an_pack("S", charToRaw(enc2utf8(s)))
}
.ru_an_encode_scalar <- function(x) {
  if (is.logical(x)) {
    if (is.na(x)) return(.ru_an_pack("X", charToRaw("L1")))
    return(.ru_an_pack("L", as.raw(as.integer(x))))
  }
  if (is.integer(x)) {
    if (is.na(x)) return(.ru_an_pack("X", charToRaw("I1")))
    return(.ru_an_pack("I", writeBin(x, raw(), size = 4L, endian = "big")))
  }
  if (is.double(x)) {
    if (is.na(x) && !is.nan(x))
      return(.ru_an_pack("X", charToRaw("D1")))
    if (is.nan(x)) return(.ru_an_pack("X", charToRaw("D2")))
    if (is.infinite(x))
      return(.ru_an_pack("X", charToRaw(if (x > 0) "D3" else "D4")))
    return(.ru_an_pack("D", writeBin(x, raw(), size = 8L, endian = "big")))
  }
  if (is.character(x)) return(.ru_an_string(x))
  stop("Unsupported scalar type.", call. = FALSE)
}
.ru_an_encode <- function(x) {
  if (is.null(x)) return(.ru_an_pack("N"))
  if (is.data.frame(x)) {
    if (!identical(class(x), "data.frame") ||
        base::.row_names_info(x, 1L) != -nrow(x))
      stop("Unsupported data.frame identity.", call. = FALSE)
    if (is.null(names(x)) || anyNA(names(x)) ||
        anyDuplicated(names(x)) || any(!nzchar(names(x))))
      stop("Unsupported column identities.", call. = FALSE)
    .ru_an_chars(names(x))
    body <- c(.ru_an_len(nrow(x)), .ru_an_len(ncol(x)),
              .ru_an_string("automatic"))
    for (i in seq_along(x)) {
      column <- x[[i]]
      if (!is.null(attributes(column)) ||
          !typeof(column) %in% c("logical", "integer", "double", "character"))
        stop("Unsupported column storage/attributes.", call. = FALSE)
      body <- c(body, .ru_an_string(names(x)[i]),
                .ru_an_string(typeof(column)), .ru_an_encode(column))
    }
    return(.ru_an_pack("B", body))
  }
  if (is.list(x)) {
    if (!identical(class(x), "list"))
      stop("Unsupported list object class.", call. = FALSE)
    keys <- names(x)
    if (is.null(keys)) {
      body <- .ru_an_len(length(x))
      for (part in x) body <- c(body, .ru_an_encode(part))
      return(.ru_an_pack("A", body))
    }
    if (length(keys) != length(x) || anyNA(keys) ||
        any(!nzchar(keys)) || anyDuplicated(keys))
      stop("Invalid named-list identity.", call. = FALSE)
    .ru_an_chars(keys)
    order <- order(keys, method = "radix")
    body <- .ru_an_len(length(keys))
    for (j in order) body <- c(body, .ru_an_string(keys[j]),
                               .ru_an_encode(x[[j]]))
    return(.ru_an_pack("O", body))
  }
  if (is.atomic(x) && typeof(x) %in% c("logical", "integer", "double", "character")) {
    if (!is.null(attributes(x)) &&
        (!identical(names(attributes(x)), "names") ||
         is.null(names(x)) || anyNA(names(x))))
      stop("Unsupported atomic attributes.", call. = FALSE)
    if (length(x) == 1L && is.null(names(x)))
      return(.ru_an_encode_scalar(x))
    body <- c(.ru_an_len(length(x)), .ru_an_string(typeof(x)))
    if (is.null(names(x))) body <- c(body, .ru_an_pack("N"))
    else body <- c(body, .ru_an_encode(unname(names(x))))
    for (j in seq_along(x)) body <- c(body, .ru_an_encode_scalar(x[[j]]))
    return(.ru_an_pack("V", body))
  }
  stop("Unsupported canonical identity type.", call. = FALSE)
}
.ru_an_hash <- function(x) .ru_an_sha(.ru_an_encode(x))

.ru_an_data_check <- function(data) {
  if (!is.data.frame(data) || !identical(class(data), "data.frame") ||
      !is.list(data) || is.null(names(data)) || anyNA(names(data)) ||
      anyDuplicated(names(data)) || any(!nzchar(names(data))))
    return("INVALID_DATA_FRAME")
  if (!identical(base::.row_names_info(data, 1L), -as.integer(nrow(data))))
    return("EXPLICIT_ROW_NAMES_UNSUPPORTED")
  if (!all(vapply(data, function(col) {
    !is.object(col) && typeof(col) %in%
      c("logical", "integer", "double", "character") &&
      is.null(attributes(col))
  }, logical(1L))))
    return("UNSUPPORTED_COLUMN_TYPE")
  if (any(!vapply(c(names(data), unlist(lapply(data, function(x)
    if (is.character(x)) x else character()), use.names = FALSE)),
    function(x) is.na(x) || all(utf8ToInt(enc2utf8(x)) <= 127L), logical(1L))))
    return("NON_ASCII_IDENTITY_UNSUPPORTED")
  NULL
}
.ru_an_attest <- function(a) {
  is.list(a) && identical(class(a), "list") &&
    setequal(names(a), c("value", "source", "revision", "captured_at")) &&
    .ru_an_flag(a$value) && identical(a$source, "user") &&
    is.numeric(a$revision) && length(a$revision) == 1L &&
    !is.na(a$revision) && a$revision >= 1 && a$revision == trunc(a$revision) &&
    (is.null(a$captured_at) || .ru_an_scalar(a$captured_at))
}
.ru_an_clean_attest <- function(ats) {
  lapply(ats, function(a) list(source = a$source,
                               revision = as.integer(a$revision),
                               value = a$value))
}
.ru_an_source_closed <- function(rec, ncols) {
  exact <- function(x, names_required, optional = character()) {
    is.list(x) && identical(class(x), "list") &&
      !is.null(names(x)) && !anyDuplicated(names(x)) &&
      all(names_required %in% names(x)) &&
      all(names(x) %in% c(names_required, optional))
  }
  sha <- function(s) .ru_an_scalar(s) && grepl("^[0-9a-f]{64}$", s)
  nonempty <- function(s) .ru_an_scalar(s) && !any(utf8ToInt(enc2utf8(s)) > 127L)
  if (!exact(rec$source,
             c("kind","source_id","content_version","source_file_sha256",
               "source_provenance")) ||
      !exact(rec$source$source_provenance,
             c("author","declaration_sha256","verification_state","installed")) ||
      !nonempty(rec$source$kind) ||
      !nonempty(rec$source$source_id) ||
      !nonempty(rec$source$content_version) ||
      !nonempty(rec$source$source_provenance$author) ||
      !sha(rec$source$source_provenance$declaration_sha256) ||
      !rec$source$source_provenance$verification_state %in%
        c("DECLARED_ONLY","SOURCE_BYTES_CHECKED",
          "INSTALLED_SOURCE_CHECKED","UNKNOWN") ||
      !.ru_an_flag(rec$source$source_provenance$installed))
    return(FALSE)
  if (isTRUE(rec$source$source_provenance$installed) &&
      rec$source$source_provenance$verification_state !=
        "INSTALLED_SOURCE_CHECKED")
    return(FALSE)
  # A constructed in-memory frame has no CSV parser or source-file bytes.
  # This is a schema contradiction, not an optional parsing enhancement.
  if (identical(rec$source$kind,"constructed_in_memory") &&
      !is.null(rec$parse))
    return(FALSE)
  if (!is.null(rec$parse)) {
    if (!exact(rec$parse,
               c("format","encoding","has_header","delimiter",
                 "na_strings","column_classes","parser_contract")) ||
        !identical(rec$parse$format,"csv") ||
        !identical(rec$parse$encoding,"UTF-8") ||
        !identical(rec$parse$delimiter,",") ||
        !.ru_an_flag(rec$parse$has_header) ||
        !is.character(rec$parse$na_strings) ||
        anyNA(rec$parse$na_strings) ||
        !is.character(rec$parse$column_classes) ||
        anyNA(rec$parse$column_classes) ||
        length(rec$parse$column_classes) != ncols ||
        !nonempty(rec$parse$parser_contract))
      return(FALSE)
  }
  if (!exact(rec$snapshot,
             c("encoder_id","sha256","row_count","column_count",
               "column_order","row_names_kind","missingness_by_column",
               "data_revision"),
             c("raw_snapshot_sha256","contextual_snapshot_sha256",
               "fingerprint_status")) ||
      !nonempty(rec$snapshot$encoder_id) ||
      !sha(rec$snapshot$sha256) ||
      !is.character(rec$snapshot$column_order) ||
      anyNA(rec$snapshot$column_order) ||
      !is.numeric(rec$snapshot$missingness_by_column) ||
      !is.null(dim(rec$snapshot$missingness_by_column)) ||
      anyNA(rec$snapshot$missingness_by_column))
    return(FALSE)
  for (k in c("raw_snapshot_sha256","contextual_snapshot_sha256")) {
    if (k %in% names(rec$snapshot) && !sha(rec$snapshot[[k]]))
      return(FALSE)
  }
  if ("fingerprint_status" %in% names(rec$snapshot) &&
      !rec$snapshot$fingerprint_status %in%
        c("LOCAL_R_SERIALIZE_V3_ONLY","DECLARED_NOT_CHECKED"))
    return(FALSE)
  if (!exact(rec$identity_contract,
             c("source_context_version","method_dictionary_version",
               "identity_codec_id","source_context_binding")) ||
      !identical(rec$identity_contract$source_context_version,
                 "ru.source_context.v1") ||
      !all(vapply(rec$identity_contract[c("method_dictionary_version",
           "identity_codec_id","source_context_binding")],
           nonempty, logical(1L))))
    return(FALSE)
  review_fields <- c("editorial","statistical","instructional",
                     "accessibility","rights","release")
  if (!exact(rec$review,review_fields))
    return(FALSE)
  for (k in review_fields) {
    allowed <- if (k == "rights")
      c("UNKNOWN","NOT_CLEARED","CLEARED_WITH_EVIDENCE") else
      c("NOT_REVIEWED","CHANGES_REQUIRED","REVIEWED_WITH_EVIDENCE")
    if (!.ru_an_scalar(rec$review[[k]]) ||
        !rec$review[[k]] %in% allowed)
      return(FALSE)
  }
  if (!is.list(rec$bindings) || length(rec$bindings) != ncols ||
      !identical(class(rec$bindings),"list"))
    return(FALSE)
  for (b in rec$bindings) {
    if (!exact(b,c("original_name","storage_type","analytic_role",
                   "measurement_unit")) ||
        !nonempty(b$original_name) ||
        !.ru_an_scalar(b$storage_type) ||
        !.ru_an_scalar(b$analytic_role) ||
        !b$analytic_role %in%
          c("record_key","grouping_category","outcome","other"))
      return(FALSE)
    if (!is.null(b$measurement_unit)) {
      u <- b$measurement_unit
      if (!exact(u,c("declared_code","canonical_code",
                    "unit_vocab_version","declaration_evidence")) ||
          !identical(u$unit_vocab_version,"ru-units-v1") ||
          !nonempty(u$declaration_evidence) ||
          !u$declared_code %in%
            c("degree_Celsius","degree_Fahrenheit","degC") ||
          !u$canonical_code %in%
            c("degree_Celsius","degree_Fahrenheit"))
        return(FALSE)
    }
  }
  TRUE
}
.ru_an_source_check <- function(record, data, outcome) {
  if (is.null(record))
    return(list(reason = NULL, metadata = NULL, unit = NULL,
                evidence = "NOT_DECLARED"))
  if (!is.list(record) || !setequal(names(record),
      c("schema_version","source","parse","bindings","snapshot",
        "identity_contract","review")) ||
      !identical(record$schema_version, "ru.source_context.v1"))
    return(list(reason = "SOURCE_CONTEXT_SCHEMA_INVALID"))
  rec <- unclass(record)
  if (!isTRUE(tryCatch(.ru_an_source_closed(rec, ncol(data)),
                       error = function(e) FALSE)))
    return(list(reason = "SOURCE_CONTEXT_SCHEMA_INVALID"))
  if (!is.list(rec$source) || !is.list(rec$snapshot) ||
      !is.list(rec$bindings) || length(rec$bindings) != ncol(data))
    return(list(reason = "SOURCE_CONTEXT_SCHEMA_INVALID"))
  source <- rec$source; snap <- rec$snapshot
  count_ok <- function(x, minimum=0) is.numeric(x) && length(x)==1L &&
    !is.na(x) && is.finite(x) && x>=minimum && x==trunc(x)
  if (!count_ok(snap$row_count) || !count_ok(snap$column_count,1) ||
      !is.character(snap$column_order) ||
      !is.list(source$source_provenance) ||
      !setequal(names(source$source_provenance),
        c("author","declaration_sha256","verification_state","installed")) ||
      !is.list(rec$identity_contract) || !is.list(rec$review))
    return(list(reason="SOURCE_CONTEXT_SCHEMA_INVALID"))
  if (!count_ok(snap$data_revision,1))
    return(list(reason="SOURCE_CONTEXT_SCHEMA_MISMATCH"))
  required_source <- c("kind","source_id","content_version",
                       "source_file_sha256","source_provenance")
  if (!setequal(names(source), required_source) ||
      !source$kind %in% c("constructed_in_memory","authored_installed_csv",
                          "caller_declared") ||
      !.ru_an_scalar(source$source_id) ||
      !.ru_an_scalar(source$content_version) ||
      !identical(snap$row_names_kind, "automatic") ||
      !identical(unname(snap$column_order), unname(names(data))) ||
      !identical(as.integer(snap$row_count), as.integer(nrow(data))) ||
      !identical(as.integer(snap$column_count), as.integer(ncol(data))))
    return(list(reason = "SOURCE_CONTEXT_SCHEMA_MISMATCH"))
  if (identical(source$kind,"authored_installed_csv") &&
      (!.ru_an_scalar(source$source_file_sha256) ||
       !grepl("^[0-9a-f]{64}$", source$source_file_sha256)))
    return(list(reason = "SOURCE_FILE_IDENTITY_REQUIRED"))
  if (identical(source$kind,"constructed_in_memory") &&
      !is.null(source$source_file_sha256))
    return(list(reason = "SOURCE_CONTEXT_SCHEMA_MISMATCH"))
  types <- vapply(data, typeof, character(1L))
  missing <- vapply(data, function(x) sum(is.na(x)), integer(1L))
  if (!is.numeric(snap$missingness_by_column) ||
      !identical(names(snap$missingness_by_column), names(data)) ||
      !identical(unname(as.integer(snap$missingness_by_column)),
                 unname(missing)))
    return(list(reason = "SOURCE_MISSINGNESS_MISMATCH"))
  unit <- NULL
  for (i in seq_along(rec$bindings)) {
    bind <- rec$bindings[[i]]
    if (!is.list(bind) || !setequal(names(bind),
        c("original_name","storage_type","analytic_role","measurement_unit")) ||
        !identical(bind$original_name, names(data)[i]) ||
        !identical(bind$storage_type, unname(types[i])))
      return(list(reason = "SOURCE_COLUMN_BINDING_MISMATCH"))
    if (identical(bind$original_name, outcome)) {
      if (!identical(bind$analytic_role, "outcome"))
        return(list(reason = "SOURCE_OUTCOME_ROLE_CONFLICT"))
      u <- bind$measurement_unit
      if (!is.null(u)) {
        if (!is.list(u) ||
            !setequal(names(u), c("declared_code","canonical_code",
                                   "unit_vocab_version","declaration_evidence")) ||
            !identical(u$unit_vocab_version,"ru-units-v1") ||
            !u$canonical_code %in% c("degree_Celsius","degree_Fahrenheit") ||
            !u$declared_code %in% c("degree_Celsius","degree_Fahrenheit","degC") ||
            !identical(u$canonical_code, if (u$declared_code == "degC")
              "degree_Celsius" else u$declared_code) ||
            !.ru_an_scalar(u$declaration_evidence))
          return(list(reason = "UNIT_METADATA_CONFLICT"))
        unit <- u$canonical_code
      }
    }
  }
  if (sum(vapply(rec$bindings,
                 function(b) identical(b$analytic_role, "outcome"),
                 logical(1L))) != 1L)
    return(list(reason = "SOURCE_CONTEXT_SCHEMA_INVALID"))
  # Avoid using local serialize-v3 digests as portable plan identity.
  snap$fingerprint_status <- NULL
  snap$raw_snapshot_sha256 <- NULL
  snap$contextual_snapshot_sha256 <- NULL
  snap$sha256 <- NULL
  rec$snapshot <- snap
  list(reason = NULL, metadata = rec, unit = unit,
       evidence = "SOURCE_DECLARATION_RECORDED_NOT_INDEPENDENTLY_VERIFIED")
}
.ru_an_pack_input <- function(data, need_context) {
  if (!need_context) {
    if (is.data.frame(data)) return(list(data = data, source_context = NULL))
    return(NULL)
  }
  if (!is.list(data) || !identical(class(data), "list") ||
      !setequal(names(data), c("data", "source_context")))
    return(NULL)
  data
}
.ru_an_seal <- function(plan) {
  core <- unclass(plan[setdiff(names(plan), "seal")])
  if (!is.null(core$spec$user_attestations))
    core$spec$user_attestations <-
      .ru_an_clean_attest(core$spec$user_attestations)
  .ru_an_hash(core)
}
.ru_an_verify <- function(plan) {
  is.list(plan) && inherits(plan, "ru_analysis_plan") &&
    identical(plan$status, "READY") && .ru_an_scalar(plan$plan_id) &&
    .ru_an_scalar(plan$seal) &&
    isTRUE(tryCatch(identical(.ru_an_seal(plan), plan$seal),
                    error = function(e) FALSE))
}
.ru_an_ready <- function(plan) {
  plan$seal <- .ru_an_seal(plan)
  plan
}

#' Propose a typed observed-sample descriptive workflow.
#' @param spec Closed G1 R1-v2 method specification for describe.numeric.
#' @param data Ordinary base data.frame. Never mutated or stored in plan.
#' @param source_context Optional typed ru.source_context.v1 declaration.
#' @return A four-state plan with no raw research rows.
ru_analyze_plan <- function(spec, data = NULL, source_context = NULL) {
  if (!is.list(spec) || !identical(class(spec), "list") ||
      !setequal(names(spec), .ru_an_spec_fields) ||
      anyDuplicated(names(spec)))
    return(.ru_an_reply("INVALID","MALFORMED_SPEC"))
  if (!identical(spec$schema_version, "1.1-draft.v2"))
    return(.ru_an_reply("INVALID","SCHEMA_VERSION_UNSUPPORTED"))
  if (is.null(spec$method_id))
    return(.ru_an_reply("NEEDS_INPUT","METHOD_ID_REQUIRED"))
  if (!.ru_an_scalar(spec$method_id) ||
      !spec$method_id %in% .ru_an_known_methods)
    return(.ru_an_reply("INVALID","UNKNOWN_METHOD_ID"))
  if (spec$method_id != "describe.numeric")
    return(.ru_an_reply("UNSUPPORTED","METHOD_NOT_IMPLEMENTED"))
  if (is.null(spec$operation))
    return(.ru_an_reply("NEEDS_INPUT","OPERATION_REQUIRED"))
  if (!.ru_an_scalar(spec$operation))
    return(.ru_an_reply("INVALID","INVALID_OPERATION"))
  if (!spec$operation %in% c("summary.only","summary.histogram"))
    return(.ru_an_reply("UNSUPPORTED","DESCRIBE_OPERATION_UNSUPPORTED"))
  scalar_fields <- c("objective","estimand","design","inference_target",
                     "dependence","sampling","missingness_policy")
  if (!all(vapply(spec[scalar_fields], .ru_an_scalar, logical(1L))))
    return(.ru_an_reply("INVALID","MALFORMED_SPEC"))
  if (!identical(spec$objective,"describe") ||
      !identical(spec$estimand,"empirical_sample_distribution") ||
      !identical(spec$design,"descriptive") ||
      !identical(spec$inference_target,"sample_only") ||
      !is.null(spec$confidence_level) || !is.null(spec$predictors) ||
      !is.null(spec$grouping) ||
      !(spec$dependence %in% c("unknown","independent","clustered","paired",
                               "repeated","time_ordered","not_applicable")) ||
      !(spec$sampling %in% c("not_applicable","unknown","simple_random",
                            "convenience","clustered","complex_survey")))
    return(.ru_an_reply("INVALID","DESCRIPTIVE_SPEC_CONTRADICTION"))
  if (!is.null(spec$unit_id) && !.ru_an_scalar(spec$unit_id))
    return(.ru_an_reply("INVALID","INVALID_UNIT_ID"))
  if (!.ru_an_scalar(spec$outcome))
    return(.ru_an_reply("NEEDS_INPUT","OUTCOME_REQUIRED"))
  if (!is.list(spec$parameters) ||
      !identical(class(spec$parameters), "list") ||
      anyDuplicated(names(spec$parameters)) ||
      !is.list(spec$user_attestations) ||
      !identical(class(spec$user_attestations), "list") ||
      anyDuplicated(names(spec$user_attestations)) ||
      !all(names(spec$user_attestations) %in% "missingness_exclusion_consent") ||
      !all(vapply(spec$user_attestations, .ru_an_attest, logical(1L))))
    return(.ru_an_reply("INVALID","INVALID_PARAMETERS_OR_ATTESTATIONS"))
  if (!spec$missingness_policy %in%
      c("report","fail","complete_case_with_consent","not_applicable"))
    return(.ru_an_reply("INVALID","INVALID_MISSINGNESS_POLICY"))
  params <- spec$parameters
  if (!"report_nonfinite" %in% names(params))
    return(.ru_an_reply("NEEDS_INPUT","REPORT_NONFINITE_REQUIRED"))
  if (!.ru_an_flag(params$report_nonfinite))
    return(.ru_an_reply("INVALID","INVALID_REPORT_NONFINITE"))
  if (spec$operation == "summary.only") {
    if (!setequal(names(params),"report_nonfinite"))
      return(.ru_an_reply("INVALID","UNDECLARED_PARAMETERS"))
  } else {
    required <- c("breaks","histogram_scale","density_curve",
                  "report_nonfinite","interval_closure","include_lowest")
    if (!setequal(names(params),required))
      return(.ru_an_reply("NEEDS_INPUT","HISTOGRAM_PARAMETERS_REQUIRED"))
    if (!is.numeric(params$breaks) || length(params$breaks) < 2L ||
        anyNA(params$breaks) || any(!is.finite(params$breaks)) ||
        any(diff(params$breaks) <= 0) ||
        !.ru_an_scalar(params$histogram_scale) ||
        !.ru_an_scalar(params$interval_closure) ||
        !params$histogram_scale %in% c("count","density") ||
        !identical(params$density_curve,"none") ||
        !params$interval_closure %in%
          c("left_closed_right_open","right_closed_left_open") ||
        !.ru_an_flag(params$include_lowest))
      return(.ru_an_reply("INVALID","INVALID_HISTOGRAM_PARAMETERS"))
    if (length(unique(diff(params$breaks))) > 1L &&
        identical(params$histogram_scale,"count"))
      return(.ru_an_reply("NEEDS_INPUT","UNEQUAL_WIDTH_REQUIRES_DENSITY"))
  }
  if (is.null(data))
    return(.ru_an_reply("NEEDS_INPUT","CURRENT_DATA_REQUIRED"))
  frame_issue <- .ru_an_data_check(data)
  if (!is.null(frame_issue)) {
    state <- if (frame_issue %in%
      c("EXPLICIT_ROW_NAMES_UNSUPPORTED","UNSUPPORTED_COLUMN_TYPE",
        "NON_ASCII_IDENTITY_UNSUPPORTED")) "UNSUPPORTED" else "INVALID"
    return(.ru_an_reply(state,frame_issue))
  }
  if (!spec$outcome %in% names(data) ||
      (!is.null(spec$unit_id) && !spec$unit_id %in% names(data)))
    return(.ru_an_reply("INVALID","COLUMN_ROLE_NOT_FOUND"))
  values <- data[[spec$outcome]]
  if (!typeof(values) %in% c("double","integer"))
    return(.ru_an_reply("INVALID","NUMERIC_OUTCOME_REQUIRED"))
  if (length(values) == 0L)
    return(.ru_an_reply("INVALID","EMPTY_OUTCOME"))
  if (any(is.infinite(values)) || any(is.nan(values)))
    return(.ru_an_reply("UNSUPPORTED","NONFINITE_NUMERIC_OUTCOME_UNSUPPORTED"))
  missing <- sum(is.na(values))
  observed <- length(values) - missing
  if (observed == 0L)
    return(.ru_an_reply("INVALID","NO_OBSERVED_NUMERIC_VALUES"))
  ctx <- .ru_an_source_check(source_context, data, spec$outcome)
  if (!is.null(ctx$reason))
    return(.ru_an_reply("INVALID",ctx$reason))
  if (missing && spec$missingness_policy == "fail")
    return(.ru_an_reply("INVALID","MISSINGNESS_POLICY_VIOLATION"))
  if (missing && spec$missingness_policy %in% c("report","not_applicable"))
    return(.ru_an_reply("NEEDS_INPUT","MISSINGNESS_TREATMENT_REQUIRED"))
  consent <- spec$user_attestations$missingness_exclusion_consent
  if (!is.null(consent) && isFALSE(consent$value) &&
      spec$missingness_policy == "complete_case_with_consent")
    return(.ru_an_reply("UNSUPPORTED","CONSENT_DENIED"))
  if (missing && spec$missingness_policy == "complete_case_with_consent" &&
      is.null(consent))
    return(.ru_an_reply("NEEDS_INPUT","EXCLUSION_CONSENT_REQUIRED"))
  if (spec$operation == "summary.histogram") {
    observed_values <- values[!is.na(values)]
    if (params$breaks[1] > min(observed_values) ||
        tail(params$breaks, 1L) < max(observed_values))
      return(.ru_an_reply("INVALID","BREAKS_DO_NOT_COVER_DATA"))
  }
  if (!requireNamespace("digest", quietly = TRUE))
    return(.ru_an_reply("NEEDS_INPUT","PORTABLE_DIGEST_DEPENDENCY_REQUIRED"))
  clean_spec <- spec
  clean_spec$user_attestations <- .ru_an_clean_attest(spec$user_attestations)
  binding <- tryCatch(list(
    codec = .ru_an_codec, data_sha256 = .ru_an_hash(data),
    source_sha256 = if (is.null(ctx$metadata)) NULL else
      .ru_an_hash(ctx$metadata),
    rows = nrow(data), columns = names(data),
    storage = unname(vapply(data, typeof, character(1L))),
    revision = if (is.null(ctx$metadata)) NULL else
      as.integer(ctx$metadata$snapshot$data_revision)),
    error = function(e) NULL)
  if (is.null(binding))
    return(.ru_an_reply("UNSUPPORTED","PORTABLE_IDENTITY_UNAVAILABLE"))
  identity <- tryCatch(.ru_an_hash(list(
    domain = .ru_an_engine, codec = .ru_an_codec, spec = clean_spec,
    binding = binding, source_metadata = ctx$metadata)),
    error = function(e) NULL)
  if (is.null(identity))
    return(.ru_an_reply("UNSUPPORTED","PLAN_IDENTITY_UNAVAILABLE"))
  .ru_an_ready(.ru_an_reply(
    "READY", "ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN",
    plan_id = identity, engine_version = .ru_an_engine,
    spec = spec, binding = binding, source_metadata = ctx$metadata,
    measurement_unit = ctx$unit, unit_evidence = ctx$evidence,
    checked = list(n_raw = length(values), n_observed = observed,
                   n_missing = missing, outcome_type = typeof(values)),
    exclusion = list(policy = spec$missingness_policy,
                     consent_revision = if (is.null(consent)) NULL else
                       as.integer(consent$revision),
                     excluded_n = missing)
  ))
}
.ru_an_code_string <- function(plan) {
  col <- encodeString(plan$spec$outcome, quote = '"')
  args <- plan$spec$parameters
  code <- c("# RU inspectable preview: NOT_EXECUTED; no data embedded",
            paste0("# Plan identity (check through RU before execution): ",
                   plan$plan_id),
            paste0("observed <- data[[",col,"]]"),
            "stopifnot(is.numeric(observed))",
            "n_raw <- length(observed)",
            "n_missing <- sum(is.na(observed))",
            "x <- observed[!is.na(observed)]",
            "stopifnot(length(x) > 0L)",
            "summary <- list(n_raw = n_raw, n_observed = length(x),",
            "  n_missing = n_missing, mean = mean(x),",
            "  median = stats::median(x),",
            "  sd = if (length(x) >= 2L) stats::sd(x) else NA_real_,",
            "  min = min(x), max = max(x))")
  if (plan$spec$operation == "summary.histogram") {
    breaks <- paste(format(args$breaks, scientific = FALSE, trim = TRUE),
                    collapse = ", ")
    code <- c(code,
       paste0("h <- graphics::hist(x, breaks = c(",breaks,"), plot = FALSE,"),
       paste0("  right = ",
              if (args$interval_closure == "right_closed_left_open") "TRUE" else "FALSE",
              ", include.lowest = ",
              if (isTRUE(args$include_lowest)) "TRUE" else "FALSE", ")"),
       "summary$histogram <- list(breaks = h$breaks, counts = h$counts,",
       "  density = h$density)")
  }
  paste(c(code,"summary"),collapse = "\n")
}

#' Return visible R calculation code; never execute it.
ru_analyze_code <- function(plan) {
  if (!.ru_an_verify(plan))
    return(list(status = "UNAVAILABLE", reason = "PLAN_NOT_READY_OR_MODIFIED",
                code = NULL))
  list(status = "PREVIEW_ONLY", reason = "NOT_EXECUTED",
       plan_id = plan$plan_id, code = .ru_an_code_string(plan))
}
.ru_an_current_check <- function(plan, input) {
  bundled <- .ru_an_pack_input(input, !is.null(plan$source_metadata))
  if (is.null(bundled))
    return(list(ok = FALSE, reason = "FRESH_SOURCE_CONTEXT_REQUIRED"))
  fresh <- ru_analyze_plan(plan$spec, bundled$data, bundled$source_context)
  if (!identical(fresh$status, "READY"))
    return(list(ok = FALSE, reason = paste0("CURRENT_",fresh$reason)))
  if (!identical(fresh$plan_id, plan$plan_id) ||
      !identical(fresh$binding,plan$binding))
    return(list(ok = FALSE, reason = "CURRENT_DATA_OR_CONFIGURATION_CHANGED"))
  list(ok = TRUE, data = bundled$data, binding = fresh$binding)
}
.ru_an_compute <- function(plan, data) {
  observed <- data[[plan$spec$outcome]]
  x <- observed[!is.na(observed)]
  value <- list(n_raw = length(observed), n_observed = length(x),
                n_missing = sum(is.na(observed)), mean = mean(x),
                median = stats::median(x),
                sd = if (length(x) >= 2L) stats::sd(x) else NA_real_,
                min = min(x), max = max(x))
  if (identical(plan$spec$operation,"summary.histogram")) {
    p <- plan$spec$parameters
    h <- graphics::hist(x, breaks = p$breaks, plot = FALSE,
      right = identical(p$interval_closure,"right_closed_left_open"),
      include.lowest = p$include_lowest)
    value$histogram <- list(breaks = h$breaks, counts = h$counts,
      density = h$density, closure = p$interval_closure,
      include_lowest = p$include_lowest)
  }
  value
}
.ru_an_result_sha <- function(result) {
  .ru_an_hash(list(plan_id = result$plan_id,
      binding = result$binding, value = result$value,
      measurement_unit = result$measurement_unit,
      engine_version = result$engine_version))
}

#' Confirm and execute an eligible descriptive plan against fresh data.
#' @param plan READY result of ru_analyze_plan.
#' @param data Fresh data.frame or list(data=...,source_context=...) when sourced.
#' @param confirm Explicit TRUE from the user's Run action.
ru_analyze_execute <- function(plan, data, confirm = FALSE) {
  if (!.ru_an_verify(plan))
    return(.ru_an_result("FAILED","PLAN_NOT_READY_OR_MODIFIED"))
  if (!.ru_an_flag(confirm))
    return(.ru_an_result("FAILED","CONFIRMATION_ARGUMENT_INVALID"))
  if (!confirm)
    return(.ru_an_result("CANCELLED","RUN_NOT_CONFIRMED",
                         plan_id = plan$plan_id))
  fresh <- .ru_an_current_check(plan, data)
  if (!fresh$ok)
    return(.ru_an_result("REVALIDATION_REQUIRED",fresh$reason,
                         plan_id = plan$plan_id))
  tryCatch({
    value <- .ru_an_compute(plan, fresh$data)
    result <- .ru_an_result("SUCCEEDED","DESCRIPTIVE_RESULT_ONLY",
      plan_id = plan$plan_id, binding = plan$binding,
      value = value, measurement_unit = plan$measurement_unit,
      engine_version = plan$engine_version)
    result$result_sha256 <- .ru_an_result_sha(result)
    result
  }, error = function(e) .ru_an_result("FAILED","COMPUTATION_FAILED",
                                        plan_id = plan$plan_id))
}
.ru_an_export_authorizations <- local({
  e <- new.env(parent = emptyenv())
  e$next_id <- 0L
  e
})
# Private integration surface: the UI must call this only after an affirmative
# destination-specific human export action. Not part of plan identity.
.ru_an_authorize_export <- function(path, plan, result = NULL,
                                    include_data = FALSE, consent = FALSE) {
  if (!.ru_an_flag(consent) || !isTRUE(consent) ||
      !.ru_an_scalar(path) || !.ru_an_verify(plan) ||
      !.ru_an_flag(include_data))
    stop("Explicit, correctly scoped export consent required.", call. = FALSE)
  .ru_an_export_authorizations$next_id <-
    .ru_an_export_authorizations$next_id + 1L
  token <- paste0("export-",.ru_an_export_authorizations$next_id)
  record <- list(path = path, plan_id = plan$plan_id,
                 result_sha256 = if (is.null(result)) NULL else result$result_sha256,
                 include_data = include_data)
  assign(token, record, envir = .ru_an_export_authorizations)
  structure(list(path = path, token = token),
            class = "ru_analysis_export_destination")
}
.ru_an_take_export_consent <- function(target, plan, result, include_data) {
  if (!inherits(target,"ru_analysis_export_destination") ||
      !is.list(target) || !.ru_an_scalar(target$token) ||
      !exists(target$token, envir=.ru_an_export_authorizations,
              inherits = FALSE))
    return(NULL)
  record <- get(target$token,envir=.ru_an_export_authorizations)
  rm(list=target$token,envir=.ru_an_export_authorizations)
  if (!identical(target$path,record$path) ||
      !identical(record$plan_id,plan$plan_id) ||
      !identical(record$include_data,include_data) ||
      !identical(record$result_sha256,
                 if (is.null(result)) NULL else result$result_sha256))
    return(NULL)
  record$path
}
#' Export code preview or a verified successful result only after scoped consent.
#' @param path Typed one-shot destination from the UI's affirmative action.
#' @param data Current source-bound input, mandatory for result export.
ru_analyze_export <- function(plan, result = NULL, path,
                              include_data = FALSE, data = NULL) {
  # ALWAYS consume an identified one-shot destination token before any
  # plan/argument/identity checks. Otherwise a token that was refused once
  # (tampered plan or malformed include_data) could be replayed successfully.
  # A raw string path never creates or consumes an authorization.
  destination <- .ru_an_take_export_consent(path,
       if (is.list(plan)) plan else list(plan_id=NULL),
       if (is.list(result)) result else NULL, include_data)
  if (!.ru_an_verify(plan))
    return(list(status="REFUSED",reason="PLAN_NOT_READY_OR_MODIFIED"))
  if (!.ru_an_flag(include_data))
    return(list(status="REFUSED",reason="INCLUDE_DATA_ARGUMENT_INVALID"))
  if (is.null(destination))
    return(list(status="REFUSED",reason="FRESH_EXPORT_CONSENT_REQUIRED"))
  if (include_data)
    return(list(status="REFUSED",reason="RAW_DATA_EXPORT_UNSUPPORTED"))
  if (!is.null(result)) {
    if (!inherits(result,"ru_analysis_result") ||
        !identical(result$status,"SUCCEEDED") ||
        !identical(result$plan_id, plan$plan_id) ||
        !identical(result$binding,plan$binding) ||
        !identical(result$engine_version,plan$engine_version) ||
        !identical(tryCatch(.ru_an_result_sha(result),
                            error=function(e) NULL),
                    result$result_sha256))
      return(list(status="REFUSED",reason="RESULT_NOT_EXPORTABLE"))
    if (is.null(data))
      return(list(status="REFUSED",reason="CURRENT_DATA_REQUIRED"))
    match <- .ru_an_current_check(plan, data)
    if (!match$ok)
      return(list(status="REFUSED",reason="REVALIDATION_REQUIRED"))
  }
  if (!.ru_an_scalar(destination) || file.exists(destination) ||
      dir.exists(destination))
    return(list(status="REFUSED",reason="PATH_EXISTS_OR_INVALID"))
  parent <- dirname(destination)
  if (!dir.exists(parent) || file.access(parent,2L) != 0L)
    return(list(status="REFUSED",reason="EXPORT_DESTINATION_UNAVAILABLE"))
  if (is.null(result)) {
    preview <- ru_analyze_code(plan)
    text <- c("# RU code-only export: NOT_EXECUTED / CURRENT_DATA_NOT_VERIFIED",
              "# Do not run calculations from a stale plan.",
              "# Recreate/confirm the plan with current source data first.",
              "# The lines below are illustrative only, not a verified execution.",
              "stop('RU code-only export has no verified current-data binding.')",
              preview$code)
    export_type <- "CODE_ONLY_NOT_EXECUTED"
  } else {
    # Fixed-key scalar/derived summaries only; never raw observations.
    val <- result$value
    lines <- c("RU analysis: DESCRIPTIVE_RESULT_ONLY",
       paste0("Plan: ",plan$plan_id),
       paste0("Result SHA-256: ",result$result_sha256),
       paste0("Outcome: ",plan$spec$outcome),
       paste0("Measurement unit: ",if (is.null(plan$measurement_unit))
              "NOT_DECLARED" else plan$measurement_unit),
       paste0("Rows: ",val$n_raw," observed: ",val$n_observed,
              " missing: ",val$n_missing),
       paste0("Mean: ",format(val$mean,digits=15)),
       paste0("Median: ",format(val$median,digits=15)),
       paste0("SD: ",format(val$sd,digits=15)),
       paste0("Min: ",format(val$min,digits=15)),
       paste0("Max: ",format(val$max,digits=15)))
    if (!is.null(val$histogram))
      lines <- c(lines,
        paste0("Histogram closure: ",val$histogram$closure),
        paste0("Breaks: ",paste(val$histogram$breaks,collapse=", ")),
        paste0("Counts: ",paste(val$histogram$counts,collapse=", ")))
    text <- lines
    export_type <- "BOUND_RESULT"
  }
  # Fail closed on existing destination. Exclusivity against other processes
  # is not guaranteed on all filesystems: L1 must review the final file writer.
  if (file.exists(destination))
    return(list(status="REFUSED",reason="PATH_EXISTS"))
  success <- tryCatch({
    con <- file(destination,open="wx")
    on.exit(close(con),add=TRUE)
    writeLines(text,con,useBytes=TRUE)
    TRUE
  }, error=function(e) FALSE)
  if (!success)
    return(list(status="REFUSED",reason="EXPORT_WRITE_FAILED"))
  list(status="EXPORTED",reason=export_type,
       path=destination,plan_id=plan$plan_id)
}