# W4-R1 internal bridge. No candidate family can solve until promoted,
# independently validated and provided with all approved peer adapters.
# The question is never evaluated as R code or an ambient object name.

.ru_w4_statuses <- c("SOLVED", "GUIDED_REFERENCE", "NEEDS_INPUT",
                      "UNSUPPORTED", "INVALID")
.ru_w4_peer_function <- function(stage) {
  # Strictly fixed package-local allowlist. stage is never derived from
  # question text, a registry file, an R expression or a caller callback.
  if (!is.character(stage) || length(stage) != 1L || is.na(stage) ||
      !stage %in% names(.ru_w4_adapter_ids))
    return(NULL)
  name <- unname(.ru_w4_adapter_ids[[stage]])
  ns <- asNamespace("rulearn")
  if (!exists(name, envir = ns, mode = "function", inherits = FALSE))
    return(NULL)
  get(name, envir = ns, mode = "function", inherits = FALSE)
}
.ru_w4_reason <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    grepl("^[A-Z][A-Z0-9_]{0,95}$", x)
}
.ru_w4_family_name <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    grepl("^[a-z][a-z0-9_.]{0,79}$", x)
}

# Inline literals only: no data.frames, calls, expressions, environments,
# formulas, objects, classed vectors, or arbitrary user workspace references.
.ru_w4_literal <- function(x, depth = 0L, budget = 20000L) {
  if (depth > 4L || length(x) > budget ||
      is.object(x) || is.environment(x) || is.language(x) ||
      is.expression(x) || is.function(x) || is.pairlist(x))
    return(FALSE)
  if (is.list(x)) {
    if (!identical(class(x), "list")) return(FALSE)
    if (length(x) && !is.null(names(x)) &&
        (anyNA(names(x)) || anyDuplicated(names(x)) ||
         !all(grepl("^[a-z][a-z0-9_]{0,63}$", names(x)))))
      return(FALSE)
    return(all(vapply(x, .ru_w4_literal, logical(1L),
                      depth = depth + 1L, budget = budget)))
  }
  if (is.numeric(x)) return(!anyNA(x) && all(is.finite(x)))
  if (is.logical(x)) return(!anyNA(x))
  if (is.character(x)) {
    return(!anyNA(x) &&
      all(vapply(x, function(v)
        validUTF8(v) && nchar(v, type = "bytes") <= 256L,
        logical(1L))))
  }
  is.null(x)
}

.ru_w4_typed_field <- function(value, type, cap = 20000L) {
  number <- is.numeric(value) && length(value) == 1L &&
    !is.object(value) && !is.na(value) && is.finite(value)
  switch(type,
    finite_scalar = number,
    positive_scalar = number && value > 0,
    bounded_probability = number && value >= 0 && value <= 1,
    bounded_integer = number && value >= 0 && value <= 1000000 &&
      value == trunc(value),
    finite_vector = is.numeric(value) && !is.object(value) &&
      length(value) >= 1L && length(value) <= cap &&
      !anyNA(value) && all(is.finite(value)),
    operation_id = .ru_w4_output_id(value),
    side = .ru_w4_scalar(value) &&
      value %in% c("two.sided", "less", "greater"),
    declared_model = .ru_w4_scalar(value),
    confidence_level = number && value > 0 && value < 1,
    FALSE)
}

.ru_w4_validate_typed_inputs <- function(inputs, family_id) {
  item <- .ru_w4_family(family_id)
  if (is.null(item)) return(TRUE) # Unimplemented families may still abstain.
  if (!is.list(inputs) || !identical(class(inputs), "list") ||
      (length(inputs) && (is.null(names(inputs)) ||
       anyNA(names(inputs)) || anyDuplicated(names(inputs)))))
    return(FALSE)
  known <- intersect(names(inputs), names(item$input_schema))
  all(vapply(known, function(name)
    .ru_w4_typed_field(inputs[[name]], item$input_schema[[name]],
                       cap = item$resource_caps$max_vector),
    logical(1L)))
}

.ru_w4_validate_parsed <- function(x, question) {
  required <- c("schema_version", "status", "reason_code",
                "original_question", "family_id", "inputs",
                "requested_outputs", "assumptions", "missing_inputs",
                "parser_rule_id")
  optional <- c("method_id", "model_id", "estimand",
                "study_design", "execution_scope")
  if (!is.list(x) || !all(required %in% names(x)) ||
      anyDuplicated(names(x)) ||
      !all(names(x) %in% c(required, optional)) ||
      !identical(x$schema_version, "ru.guided.v1") ||
      !is.character(x$status) || length(x$status) != 1L ||
      is.na(x$status) || !x$status %in% .ru_w4_statuses ||
      !.ru_w4_reason(x$reason_code) ||
      !is.character(x$original_question) ||
      !identical(x$original_question, question) ||
      !(.ru_w4_family_name(x$family_id) ||
        (!identical(x$status, "SOLVED") &&
         identical(x$family_id, NA_character_))) ||
      !is.list(x$inputs) || !identical(class(x$inputs), "list") ||
      length(x$inputs) > 36L || !.ru_w4_literal(x$inputs) ||
      !.ru_w4_validate_typed_inputs(x$inputs, x$family_id) ||
      !is.character(x$requested_outputs) ||
      anyNA(x$requested_outputs) ||
      anyDuplicated(x$requested_outputs) ||
      length(x$requested_outputs) > 24L ||
      !all(vapply(x$requested_outputs, .ru_w4_output_id, logical(1L))) ||
      !is.list(x$assumptions) ||
      !identical(class(x$assumptions), "list") ||
      length(x$assumptions) > 24L || !.ru_w4_literal(x$assumptions) ||
      !is.character(x$missing_inputs) ||
      anyNA(x$missing_inputs) || anyDuplicated(x$missing_inputs) ||
      length(x$missing_inputs) > 32L ||
      !all(vapply(x$missing_inputs, .ru_w4_output_id, logical(1L))) ||
      !.ru_w4_scalar(x$parser_rule_id))
    return(FALSE)
  for (key in intersect(optional, names(x))) {
    if (!.ru_w4_scalar(x[[key]])) return(FALSE)
  }
  if ("execution_scope" %in% names(x) &&
      !identical(x$execution_scope, "INLINE_LITERAL_ONLY"))
    return(FALSE)
  item <- .ru_w4_family(x$family_id)
  if (!is.null(item) && identical(x$status, "SOLVED")) {
    if (!length(x$requested_outputs) || length(x$missing_inputs) ||
        !all(x$requested_outputs %in% item$operations))
      return(FALSE)
    if ("method_id" %in% names(x) &&
        !identical(x$method_id, item$method_id))
      return(FALSE)
    if ("model_id" %in% names(x) &&
        !identical(x$model_id, item$model_id))
      return(FALSE)
  }
  # Do not infer an answer from a single word naming a method. A complete
  # model/operation is still subject to A3's family-specific constraints.
  TRUE
}

.ru_w4_validate_quantities <- function(x) {
  required <- c("output_id", "label", "value", "units")
  if (!is.data.frame(x) ||
      !identical(class(x), "data.frame") ||
      !identical(names(x), required) || nrow(x) > 1024L ||
      !is.character(x$output_id) || !is.character(x$label) ||
      !is.double(x$value) || !is.character(x$units) ||
      anyNA(x$output_id) || anyNA(x$label) ||
      anyNA(x$units) || anyNA(x$value) ||
      !all(is.finite(x$value)) ||
      !all(vapply(x$output_id, .ru_w4_output_id, logical(1L))))
    return(FALSE)
  label_ok <- function(v, max_bytes) {
    validUTF8(v) && nchar(v, type = "bytes") <= max_bytes
  }
  all(nzchar(x$label)) &&
    all(vapply(x$label, label_ok, logical(1L), max_bytes = 256L)) &&
    all(vapply(x$units, label_ok, logical(1L), max_bytes = 128L))
}

.ru_w4_validate_table <- function(x, caps) {
  if (is.null(x)) return(TRUE)
  if (!is.data.frame(x) || !identical(class(x), "data.frame") ||
      nrow(x) > caps$max_vector ||
      nrow(x) * ncol(x) > caps$max_table_cells ||
      ncol(x) < 1L || ncol(x) > 64L ||
      is.null(names(x)) || anyDuplicated(names(x)) ||
      !all(vapply(names(x), .ru_w4_output_id, logical(1L))))
    return(FALSE)
  all(vapply(x, function(col)
    (is.integer(col) || is.double(col)) &&
      !is.object(col) && all(is.finite(col)),
    logical(1L)))
}

.ru_w4_validate_answer <- function(x, requested, family_id) {
  item <- .ru_w4_family(family_id)
  if (is.null(item) || !is.list(x) ||
      !identical(class(x), "list") ||
      !setequal(names(x), c("schema_version", "quantities", "table",
                           "table_output_id", "method_note")) ||
      anyDuplicated(names(x)) ||
      !identical(x$schema_version, "ru.w4.answer.v1") ||
      !.ru_w4_validate_quantities(x$quantities) ||
      !.ru_w4_validate_table(x$table, item$resource_caps) ||
      !is.character(x$method_note) ||
      length(x$method_note) != 1L || is.na(x$method_note) ||
      !validUTF8(x$method_note) ||
      nchar(x$method_note, type = "bytes") > 2048L ||
      !is.character(x$table_output_id) ||
      length(x$table_output_id) != 1L)
    return(FALSE)
  tab <- x$table_output_id
  if (is.null(x$table)) {
    if (!identical(tab, NA_character_)) return(FALSE)
    tab <- character()
  } else if (is.na(tab) || !.ru_w4_output_id(tab)) {
    return(FALSE)
  }
  ids <- unique(c(x$quantities$output_id, tab))
  length(requested) > 0L && !anyDuplicated(requested) &&
    setequal(ids, requested) &&
    all(ids %in% item$operations) &&
    all(requested %in% item$operations)
}

.ru_w4_validate_computed <- function(x, parsed) {
  required <- c("schema_version", "status", "reason_code",
                "original_question", "family_id", "inputs",
                "requested_outputs", "assumptions", "answer",
                "checks", "code_preview", "executed", "missing_inputs")
  optional <- c("method_id", "model_id", "estimand",
                "study_design", "execution_scope")
  if (!is.list(x) || !all(required %in% names(x)) ||
      anyDuplicated(names(x)) ||
      !all(names(x) %in% c(required, optional)) ||
      !identical(x$schema_version, "ru.guided.v1") ||
      !is.character(x$status) || length(x$status) != 1L ||
      is.na(x$status) || !x$status %in% .ru_w4_statuses ||
      !.ru_w4_reason(x$reason_code) ||
      !identical(x$original_question, parsed$original_question) ||
      !identical(x$family_id, parsed$family_id) ||
      !identical(x$requested_outputs, parsed$requested_outputs) ||
      !identical(x$inputs, parsed$inputs) ||
      !identical(x$assumptions, parsed$assumptions) ||
      !is.character(x$missing_inputs) ||
      !identical(x$missing_inputs, parsed$missing_inputs) ||
      !identical(x$executed, FALSE) ||
      !is.list(x$checks) || !identical(class(x$checks), "list") ||
      !is.character(x$code_preview) ||
      length(x$code_preview) != 1L || is.na(x$code_preview) ||
      !validUTF8(x$code_preview) ||
      nchar(x$code_preview, type = "bytes") > 65536L)
    return(FALSE)
  if (!all(intersect(optional, names(parsed)) %in% names(x)))
    return(FALSE)
  for (key in intersect(optional, names(x))) {
    if (!.ru_w4_scalar(x[[key]])) return(FALSE)
    if (key %in% names(parsed) && !identical(x[[key]], parsed[[key]]))
      return(FALSE)
  }
  if ("execution_scope" %in% names(x) &&
      !identical(x$execution_scope, "INLINE_LITERAL_ONLY"))
    return(FALSE)
  if (identical(x$status, "SOLVED")) {
    if (!identical(x$checks$verified, TRUE) ||
        !nzchar(x$code_preview) ||
        length(x$missing_inputs) ||
        !.ru_w4_validate_answer(x$answer, x$requested_outputs,
                                x$family_id))
      return(FALSE)
  } else {
    if (!is.list(x$answer) || length(x$answer) ||
        nzchar(x$code_preview))
      return(FALSE)
  }
  TRUE
}

.ru_w4_refusal <- function(parsed, status = "UNSUPPORTED",
                           reason = "FAMILY_NOT_QUALIFIED") {
  if (!is.character(status) || length(status) != 1L ||
      is.na(status) || !(status %in% setdiff(.ru_w4_statuses, "SOLVED")) ||
      !.ru_w4_reason(reason))
    stop("Invalid internal W4 refusal.", call. = FALSE)
  fields <- if (is.list(parsed)) parsed else list()
  scalar <- function(name, otherwise = "") {
    val <- fields[[name]]
    if (is.character(val) && length(val) == 1L &&
        !is.na(val) && validUTF8(val) && nchar(val, type = "bytes") <= 4096L)
      val else otherwise
  }
  result <- list(schema_version = "ru.guided.v1",
    status = status, reason_code = reason,
    original_question = scalar("original_question"),
    family_id = scalar("family_id", NA_character_),
    inputs = if (is.list(fields$inputs) &&
                 .ru_w4_literal(fields$inputs)) fields$inputs else list(),
    requested_outputs = if (is.character(fields$requested_outputs) &&
                             !anyNA(fields$requested_outputs))
      fields$requested_outputs else character(),
    assumptions = if (is.list(fields$assumptions) &&
                       .ru_w4_literal(fields$assumptions))
      fields$assumptions else list(),
    answer = list(), checks = list(verified = FALSE),
    code_preview = "", executed = FALSE,
    missing_inputs = if (is.character(fields$missing_inputs) &&
                         !anyNA(fields$missing_inputs))
      fields$missing_inputs else character())
  structure(result, class = c("ru_w4_computed", "list"))
}

# Separation permits contract tests with typed peer fixtures, without
# injecting mocks into the installed package or calling a candidate solver.
.ru_w4_dispatch_parsed <- function(parsed, question) {
  if (!.ru_w4_validate_parsed(parsed, question))
    return(.ru_w4_refusal(
      list(original_question = question),
      "INVALID", "W4_PARSED_SCHEMA_INVALID"))
  if (!identical(parsed$status, "SOLVED"))
    return(.ru_w4_refusal(parsed, parsed$status, parsed$reason_code))
  family <- .ru_w4_family(parsed$family_id)
  if (is.null(family))
    return(.ru_w4_refusal(parsed, "UNSUPPORTED", "FAMILY_NOT_REGISTERED"))
  if (!.ru_w4_family_enabled(parsed$family_id))
    return(.ru_w4_refusal(parsed, "UNSUPPORTED", "FAMILY_NOT_QUALIFIED"))
  # Do not return numerical answers until the *entire* W4 teaching/Viewer
  # chain is installed, registered and independently approved.
  compute <- .ru_w4_peer_function("compute")
  if (is.null(compute) ||
      is.null(.ru_w4_peer_function("teach")) ||
      is.null(.ru_w4_peer_function("render")))
    return(.ru_w4_refusal(parsed, "UNSUPPORTED", "W4_ADAPTERS_UNAVAILABLE"))
  computed <- tryCatch(compute(parsed), error = function(e) NULL)
  if (!.ru_w4_validate_computed(computed, parsed))
    return(.ru_w4_refusal(parsed, "INVALID", "W4_COMPUTED_SCHEMA_INVALID"))
  structure(computed, class = c("ru_w4_computed", "list"))
}

.ru_w4_dispatch <- function(question) {
  parser <- .ru_w4_peer_function("parse")
  if (is.null(parser)) return(NULL)
  # The frozen W3 dice parser owns every dice question, including its
  # adversarial extra-components, dependence and transformation refusals.
  # A newly recognized W4 model must never override those protections.
  if (grepl("\\b(?:die|dice)\\b|(?<![[:alpha:]])[0-9]*d[0-9]+\\b",
            tolower(question), perl = TRUE))
    return(NULL)
  parsed <- tryCatch(parser(question),
                     error = function(e) structure(list(),
                       class = "ru_w4_parser_failure"))
  if (is.null(parsed)) return(NULL)
  if (inherits(parsed, "ru_w4_parser_failure"))
    return(.ru_w4_refusal(
      list(original_question = question),
      "INVALID", "W4_PARSER_FAILURE"))
  .ru_w4_dispatch_parsed(parsed, question)
}