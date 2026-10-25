# Versioned source provenance and current-data metadata, not an analysis engine.
# The local serialize-v3 fingerprints are NOT L3 canonical portable plan hashes.
.ru_source_validate <- function(record) {
  .ru_named_fields(record,
                   c("schema_version", "source", "parse", "bindings",
                     "snapshot", "identity_contract", "review"), "source_context")
  if (!identical(record$schema_version, "ru.source_context.v1"))
    .ru_error("ru_invalid_argument", "Unsupported source_context schema.")
  source <- record$source
  .ru_named_fields(source,
                   c("kind", "source_id", "content_version", "source_file_sha256",
                     "source_provenance"), "source")
  .ru_exact_choice(source$kind, "source.kind",
                   c("authored_installed_csv", "constructed_in_memory", "caller_declared"))
  if (!.ru_content_safe_id(source$source_id))
    .ru_error("ru_invalid_argument", "Invalid source ID.", "source_id")
  .ru_scalar_string(source$content_version, "content_version")
  .ru_digest_string(source$source_file_sha256, "source_file_sha256", nullable = TRUE)
  if (source$kind == "constructed_in_memory" && !is.null(source$source_file_sha256))
    .ru_error("ru_invalid_argument", "Constructed data have no source-file bytes.")
  if (source$kind == "authored_installed_csv" && is.null(source$source_file_sha256))
    .ru_error("ru_invalid_argument", "Authored CSV requires an exact source SHA-256.")
  prov <- source$source_provenance
  .ru_named_fields(prov,
                   c("author", "declaration_sha256", "verification_state", "installed"),
                   "source_provenance")
  .ru_scalar_string(prov$author, "author")
  .ru_digest_string(prov$declaration_sha256, "declaration_sha256")
  .ru_exact_choice(prov$verification_state, "verification_state",
                   c("DECLARED_ONLY", "SOURCE_BYTES_CHECKED",
                     "INSTALLED_SOURCE_CHECKED", "UNKNOWN"))
  .ru_scalar_flag(prov$installed, "installed")
  if (isTRUE(prov$installed) &&
      prov$verification_state != "INSTALLED_SOURCE_CHECKED")
    .ru_error("ru_invalid_argument", "Installed source needs installed-source evidence.")
  if (source$kind == "constructed_in_memory" && !is.null(record$parse))
    .ru_error("ru_invalid_argument", "Constructed data have no CSV parser.")
  if (!is.null(record$parse)) {
    .ru_named_fields(record$parse,
                     c("format", "encoding", "has_header", "delimiter",
                       "na_strings", "column_classes", "parser_contract"), "parse")
    .ru_exact_choice(record$parse$format, "parse.format", "csv")
    .ru_exact_choice(record$parse$encoding, "parse.encoding", "UTF-8")
    .ru_scalar_flag(record$parse$has_header, "parse.has_header")
    .ru_exact_choice(record$parse$delimiter, "parse.delimiter", ",")
    if (!is.character(record$parse$na_strings) || anyNA(record$parse$na_strings) ||
        !is.character(record$parse$column_classes))
      .ru_error("ru_invalid_argument", "Invalid parser configuration.")
    .ru_scalar_string(record$parse$parser_contract, "parser_contract")
  }
  if (!is.list(record$bindings) || !length(record$bindings))
    .ru_error("ru_invalid_argument", "Source bindings must be a nonempty ordered list.")
  columns <- vapply(record$bindings, function(b) {
    .ru_named_fields(b, c("original_name", "storage_type", "analytic_role",
                          "measurement_unit"), "binding")
    name <- .ru_scalar_string(b$original_name, "original_name")
    if (!.ru_content_safe_id(name))
      .ru_error("ru_invalid_argument", "Column names must be safe exact identities.")
    .ru_exact_choice(b$storage_type, "storage_type",
                     c("character", "double", "integer", "logical"))
    .ru_exact_choice(b$analytic_role, "analytic_role",
                     c("record_key", "grouping_category", "outcome", "other"))
    if (!is.null(b$measurement_unit)) {
      .ru_named_fields(b$measurement_unit,
                       c("declared_code", "canonical_code",
                         "unit_vocab_version", "declaration_evidence"), "measurement_unit")
      .ru_exact_choice(b$measurement_unit$unit_vocab_version,
                       "unit_vocab_version", "ru-units-v1")
      declared <- .ru_exact_choice(b$measurement_unit$declared_code,
                                   "declared_code",
                                   c("degree_Celsius", "degree_Fahrenheit", "degC"))
      canonical <- .ru_exact_choice(b$measurement_unit$canonical_code,
                                    "canonical_code",
                                    c("degree_Celsius", "degree_Fahrenheit"))
      .ru_scalar_string(b$measurement_unit$declaration_evidence,
                        "declaration_evidence")
      if (!identical(canonical, if (declared == "degC") "degree_Celsius" else declared))
        .ru_error("ru_invalid_argument", "Unit alias and canonical code conflict.")
    }
    name
  }, character(1L))
  if (anyDuplicated(columns) ||
      sum(vapply(record$bindings, function(x)
          identical(x$analytic_role, "outcome"), logical(1L))) != 1L)
    .ru_error("ru_invalid_argument", "Bindings must identify one unique outcome.")
  snapshot <- record$snapshot
  .ru_named_fields(snapshot,
                   c("encoder_id", "sha256", "row_count", "column_count",
                     "column_order", "row_names_kind", "missingness_by_column",
                     "data_revision"), "snapshot",
                   optional = c("raw_snapshot_sha256", "contextual_snapshot_sha256",
                                "fingerprint_status"))
  .ru_scalar_string(snapshot$encoder_id, "encoder_id")
  .ru_digest_string(snapshot$sha256, "snapshot.sha256")
  .ru_scalar_count(snapshot$row_count, "row_count")
  if (.ru_scalar_count(snapshot$column_count, "column_count", 1L) != length(columns) ||
      !identical(snapshot$column_order, unname(columns)))
    .ru_error("ru_invalid_argument", "Snapshot column order differs from bindings.")
  .ru_exact_choice(snapshot$row_names_kind, "row_names_kind", "automatic")
  if (!is.numeric(snapshot$missingness_by_column) ||
      !identical(names(snapshot$missingness_by_column), unname(columns)) ||
      anyNA(snapshot$missingness_by_column) ||
      any(snapshot$missingness_by_column < 0L) ||
      any(snapshot$missingness_by_column > snapshot$row_count) ||
      any(snapshot$missingness_by_column != trunc(snapshot$missingness_by_column)))
    .ru_error("ru_invalid_argument", "Invalid typed missingness counts.")
  .ru_scalar_count(snapshot$data_revision, "data_revision", 1L)
  for (key in intersect(c("raw_snapshot_sha256", "contextual_snapshot_sha256"),
                        names(snapshot)))
    .ru_digest_string(snapshot[[key]], key)
  .ru_named_fields(record$identity_contract,
                   c("source_context_version", "method_dictionary_version",
                     "identity_codec_id", "source_context_binding"), "identity_contract")
  if (!identical(record$identity_contract$source_context_version, "ru.source_context.v1"))
    .ru_error("ru_invalid_argument", "Source identity contract version mismatch.")
  for (key in c("method_dictionary_version", "identity_codec_id", "source_context_binding"))
    .ru_scalar_string(record$identity_contract[[key]], key)
  if (!is.list(record$review) ||
      !setequal(names(record$review),
                c("editorial", "statistical", "instructional", "accessibility",
                  "rights", "release")))
    .ru_error("ru_invalid_argument", "Review dimensions must be complete.")
  for (key in names(record$review))
    .ru_exact_choice(record$review[[key]], paste0("review.", key),
                     if (key == "rights") c("UNKNOWN", "NOT_CLEARED", "CLEARED_WITH_EVIDENCE")
                     else c("NOT_REVIEWED", "CHANGES_REQUIRED", "REVIEWED_WITH_EVIDENCE"))
  invisible(TRUE)
}

ru_source_context <- function(record, data = NULL) {
  .ru_source_validate(record)
  record <- unserialize(serialize(record, NULL, version = 3L))
  if (!is.null(data)) {
    # Validate the input type and basic frame structure before inspecting
    # row names, nrow(), or individual columns; never coerce caller data.
    if (!is.data.frame(data) || !identical(class(data), "data.frame") ||
        !is.list(data) || is.null(attr(data, "row.names")))
      .ru_error("ru_invalid_argument",
                "Current data must be an ordinary, structurally valid data.frame.")
    # Explicit row names are data identity, not "automatic" metadata.
    # .row_names_info(type=1) is negative only for automatic row names.
    if (base::.row_names_info(data, 1L) != -as.integer(nrow(data)))
      .ru_error("ru_invalid_argument",
                "Current row names are explicit but source snapshot declares automatic.")
    if (!identical(names(data), record$snapshot$column_order) ||
        nrow(data) != record$snapshot$row_count ||
        any(vapply(data, is.object, logical(1L))) ||
        !identical(unname(vapply(data, typeof, character(1L))),
                   unname(vapply(record$bindings, function(x) x$storage_type,
                                 character(1L)))) ||
        !identical(unname(vapply(data, function(x) sum(is.na(x)), integer(1L))),
                   unname(as.integer(record$snapshot$missingness_by_column))))
      .ru_error("ru_invalid_argument", "Current data do not match the exact source schema.")
    if (!requireNamespace("digest", quietly = TRUE))
      .ru_error("ru_unavailable_dependency", "Local source fingerprints require digest.")
    # Include the actual data and all attributes only transiently in hashing.
    raw <- digest::digest(list(codec = "ru.r-serialize-v3.local.v1", data = data),
                          algo = "sha256", serialize = TRUE, serializeVersion = 3L)
    context <- digest::digest(
      list(codec = "ru.r-serialize-v3.source-context.v1", raw_sha256 = raw,
           source = record$source, parse = record$parse, bindings = record$bindings,
           revision = record$snapshot$data_revision,
           identity_contract = record$identity_contract),
      algo = "sha256", serialize = TRUE, serializeVersion = 3L)
    record$snapshot$raw_snapshot_sha256 <- raw
    record$snapshot$contextual_snapshot_sha256 <- context
    record$snapshot$fingerprint_status <- "LOCAL_R_SERIALIZE_V3_ONLY"
  } else {
    record$snapshot$fingerprint_status <- "DECLARED_NOT_CHECKED"
  }
  class(record) <- c("ru_source_context", "list")
  record
}