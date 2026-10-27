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
  # NULL represents an absent optional A3 field. Base R also regards NULL
  # as an empty pairlist, so validate absence before banning pairlists.
  if (is.null(x)) return(TRUE)
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

.ru_w4_typed_field <- function(value, type, cap = 256L) {
  number <- (is.double(value) || is.integer(value)) &&
    !is.object(value) && length(value) == 1L && !is.na(value) &&
    is.finite(value) && abs(value) <= 1e9
  vector <- (is.double(value) || is.integer(value)) &&
    !is.object(value) && length(value) >= 1L &&
    length(value) <= min(cap, 256L) && !anyNA(value) &&
    all(is.finite(value)) && all(abs(value) <= 1e9)
  switch(type,
    finite_scalar = number,
    positive_scalar = number && value > 0,
    nonnegative_scalar = number && value >= 0,
    bounded_probability = number && value >= 0 && value <= 1,
    bounded_integer = number && value >= 0 && value <= 1000000 &&
      value == trunc(value),
    trial_count = number && value >= 0 && value <= 5000 &&
      value == trunc(value),
    signed_integer_threshold = number && value == trunc(value),
    finite_vector = vector,
    operation_id = .ru_w4_output_id(value),
    side = .ru_w4_scalar(value) &&
      value %in% c("two.sided", "less", "greater"),
    variance_convention = .ru_w4_scalar(value) &&
      value %in% c("sample", "population"),
    inference_mode = .ru_w4_scalar(value) &&
      value %in% c("test", "interval"),
    declared_model = .ru_w4_scalar(value),
    confidence_level = number && value > 0 && value < 1,
    typed_event = .ru_w4_valid_event(value),
    FALSE)
}

.ru_w4_valid_event <- function(event) {
  if (is.null(event)) return(TRUE)
  if (!is.list(event) || !identical(class(event), "list") ||
      is.null(names(event)) || anyNA(names(event)) ||
      anyDuplicated(names(event)) || !.ru_w4_scalar(event$type))
    return(FALSE)
  type <- event$type
  if (type %in% c("exact", "cdf", "below", "at_least", "above")) {
    if (!setequal(names(event), c("type", "k"))) return(FALSE)
    return(.ru_w4_typed_field(event$k, "finite_scalar"))
  }
  if (identical(type, "interval")) {
    if (!setequal(names(event), c("type", "lower", "upper")))
      return(FALSE)
    return(.ru_w4_typed_field(event$lower, "finite_scalar") &&
      .ru_w4_typed_field(event$upper, "finite_scalar") &&
      event$lower < event$upper)
  }
  if (identical(type, "quantile")) {
    if (!setequal(names(event), c("type", "probability")))
      return(FALSE)
    return(.ru_w4_typed_field(event$probability, "confidence_level"))
  }
  FALSE
}

.ru_w4_validate_typed_inputs <- function(inputs, family_id,
                                         status = "SOLVED",
                                         requested_outputs = character()) {
  item <- .ru_w4_family(family_id)
  if (!is.list(inputs) || !identical(class(inputs), "list") ||
      (length(inputs) && (is.null(names(inputs)) ||
        anyNA(names(inputs)) || anyDuplicated(names(inputs)) ||
        !all(vapply(names(inputs), .ru_w4_output_id, logical(1L))))))
    return(FALSE)
  # Unknown models may abstain, but cannot carry arbitrary pseudo-data.
  if (is.null(item)) return(!identical(status, "SOLVED") &&
                            !length(inputs))
  if (!all(names(inputs) %in% names(item$input_schema))) return(FALSE)
  for (name in names(inputs)) {
    value <- inputs[[name]]
    # A3 may preserve missing optional fields as NULL in NEEDS_INPUT.
    # NULL is not numerical input and cannot silently supply a required role.
    if (is.null(value)) next
    if (!.ru_w4_typed_field(value, item$input_schema[[name]],
                            cap = item$resource_caps$max_vector))
      return(FALSE)
  }
  if (!identical(status, "SOLVED")) return(TRUE)
  have <- function(name) name %in% names(inputs) &&
    !is.null(inputs[[name]])
  outs <- requested_outputs
  id <- family_id
  if (identical(id, "descriptive.numeric")) {
    if (!have("values") || length(inputs$values) < 2L) return(FALSE)
    if (any(outs %in% c("sample_variance", "population_variance",
                       "sample_sd", "population_sd"))) {
      if (!have("convention") ||
          !identical(inputs$convention, if (any(grepl("^sample_", outs)))
            "sample" else "population"))
        return(FALSE)
      if (any(grepl("^sample_", outs)) &&
          any(grepl("^population_", outs))) return(FALSE)
    }
    if ("quantile" %in% outs && !have("quantile_probability"))
      return(FALSE)
  } else if (identical(id, "probability.event_scalar")) {
    if (length(outs) != 1L) return(FALSE)
    needed <- switch(outs[[1L]],
      union = c("p_a", "p_b", "p_intersection"),
      conditional = c("p_b", "p_intersection"),
      complement = "p_a", character())
    if (!length(needed) ||
        !all(vapply(needed, have, logical(1L)))) return(FALSE)
    a <- if (have("p_a")) inputs$p_a else NULL
    b <- if (have("p_b")) inputs$p_b else NULL
    j <- if (have("p_intersection")) inputs$p_intersection else NULL
    if (!is.null(j) && !is.null(a) && j > a + 1e-12) return(FALSE)
    if (!is.null(j) && !is.null(b) && j > b + 1e-12) return(FALSE)
    if (!is.null(a) && !is.null(b) && !is.null(j) &&
        j < max(0, a + b - 1) - 1e-12) return(FALSE)
    if ("conditional" %in% outs && b <= 0) return(FALSE)
  } else if (id %in% c("distribution.binomial", "distribution.poisson",
                       "distribution.normal",
                       "distribution.uniform_continuous")) {
    required <- switch(id,
      "distribution.binomial" = c("n", "p"),
      "distribution.poisson" = "lambda",
      "distribution.normal" = c("mu", "sigma"),
      "distribution.uniform_continuous" = c("a", "b"))
    if (!all(vapply(required, have, logical(1L)))) return(FALSE)
    if (identical(id, "distribution.normal") && inputs$sigma <= 0)
      return(FALSE)
    if (identical(id, "distribution.uniform_continuous") &&
        inputs$a >= inputs$b) return(FALSE)
    ev <- inputs$event
    needs_prob <- "probability" %in% outs
    needs_quantile <- "quantile" %in% outs
    if ((needs_prob || needs_quantile) && is.null(ev)) return(FALSE)
    if (!is.null(ev)) {
      tp <- ev$type
      if (id %in% c("distribution.binomial", "distribution.poisson")) {
        if (!tp %in% c("exact", "cdf", "below", "at_least", "above") ||
            ev$k != trunc(ev$k) || !needs_prob) return(FALSE)
      } else {
        if (!tp %in% c("cdf", "below", "at_least", "above",
                       "interval", "quantile")) return(FALSE)
        if (identical(tp, "quantile")) {
          if (!identical(id, "distribution.normal") ||
              !needs_quantile || needs_prob) return(FALSE)
        } else if (!needs_prob || needs_quantile) return(FALSE)
      }
    }
  } else if (identical(id, "inference.one_sample_t")) {
    if (!have("values") || length(inputs$values) < 3L ||
        stats::var(inputs$values) <= 0 ||
        !have("mode") || !have("alternative"))
      return(FALSE)
    if (identical(inputs$mode, "test")) {
      if (!have("mu0") ||
          !setequal(outs, c("t_statistic", "degrees_freedom", "p_value")))
        return(FALSE)
    } else if (!have("confidence_level") ||
               !identical(inputs$alternative, "two.sided") ||
               !setequal(outs, c("ci_lower", "ci_upper"))) {
      return(FALSE)
    }
  } else if (identical(id, "regression.simple_ols")) {
    if (!have("x") || !have("y") ||
        length(inputs$x) != length(inputs$y) ||
        length(inputs$x) < 3L ||
        stats::var(inputs$x) <= 0 || stats::var(inputs$y) <= 0)
      return(FALSE)
    if ("prediction" %in% outs) {
      if (!have("prediction_x") ||
          inputs$prediction_x < min(inputs$x) ||
          inputs$prediction_x > max(inputs$x)) return(FALSE)
    } else if (have("prediction_x")) return(FALSE)
  }
  TRUE
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
      length(x$inputs) > 36L || !isTRUE(.ru_w4_literal(x$inputs)) ||
      !.ru_w4_validate_typed_inputs(x$inputs, x$family_id, x$status,
                                    x$requested_outputs) ||
      !is.character(x$requested_outputs) ||
      anyNA(x$requested_outputs) ||
      anyDuplicated(x$requested_outputs) ||
      length(x$requested_outputs) > 24L ||
      !all(vapply(x$requested_outputs, .ru_w4_output_id, logical(1L))) ||
      !is.list(x$assumptions) ||
      !identical(class(x$assumptions), "list") ||
      length(x$assumptions) > 24L ||
      !isTRUE(.ru_w4_literal(x$assumptions)) ||
      (length(x$assumptions) &&
       (is.null(names(x$assumptions)) ||
        anyDuplicated(names(x$assumptions)) ||
        !all(vapply(names(x$assumptions), .ru_w4_output_id,
                    logical(1L))))) ||
      !is.character(x$missing_inputs) ||
      anyNA(x$missing_inputs) || anyDuplicated(x$missing_inputs) ||
      length(x$missing_inputs) > 32L ||
      !all(vapply(x$missing_inputs, .ru_w4_output_id, logical(1L))) ||
      !.ru_w4_scalar(x$parser_rule_id))
    return(FALSE)
  for (key in intersect(optional, names(x))) {
    if (!.ru_w4_scalar(x[[key]]) &&
        !(key %in% c("method_id", "model_id", "estimand") &&
          !identical(x$status, "SOLVED") &&
          identical(x[[key]], NA_character_)))
      return(FALSE)
  }
  if ("execution_scope" %in% names(x) &&
      !identical(x$execution_scope, "INLINE_LITERAL_ONLY"))
    return(FALSE)
  item <- .ru_w4_family(x$family_id)
  if (identical(x$status, "SOLVED")) {
    if (is.null(item) ||
        !identical(x$reason_code, "W4_INPUTS_VALID") ||
        !length(x$requested_outputs) || length(x$missing_inputs) ||
        !all(x$requested_outputs %in% item$operations) ||
        !all(c("method_id", "model_id", "estimand", "study_design",
               "execution_scope") %in% names(x)) ||
        !identical(x$method_id, item$method_id) ||
        !identical(x$model_id, item$model_id) ||
        !identical(x$estimand, if (identical(x$family_id,
                                             "inference.one_sample_t"))
          "population_mean" else "model_quantity") ||
        !identical(x$study_design,
          if (identical(x$family_id, "inference.one_sample_t"))
            "one_sample"
          else if (identical(x$family_id, "regression.simple_ols"))
            "observed_pairs" else "theoretical"))
      return(FALSE)
    expected <- switch(x$family_id,
      "descriptive.numeric" =
        if ("convention" %in% names(x$inputs) &&
            !is.null(x$inputs$convention))
          c("convention", "missing") else "missing",
      "probability.event_scalar" = "model",
      "inference.one_sample_t" = c("independence", "normality"),
      "regression.simple_ols" = c("model", "inference"),
      "model")
    if (!setequal(names(x$assumptions), expected) ||
        !all(vapply(x$assumptions, .ru_w4_scalar, logical(1L))))
      return(FALSE)
    if (identical(x$family_id, "descriptive.numeric") &&
        "convention" %in% names(x$inputs) &&
        !identical(x$assumptions$convention, x$inputs$convention))
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
  ids <- c(x$quantities$output_id, tab)
  if (!length(requested) || anyDuplicated(requested) ||
      anyDuplicated(ids) || length(ids) != length(requested) ||
      !setequal(ids, requested) ||
      !all(ids %in% item$operations) ||
      !all(requested %in% item$operations))
    return(FALSE)
  q <- x$quantities
  probability_ids <- c("probability", "union", "conditional",
                       "complement", "p_value", "r_squared")
  if (any(q$output_id %in% probability_ids &
          (q$value < -1e-12 | q$value > 1+1e-12)))
    return(FALSE)
  df <- q$value[q$output_id == "degrees_freedom"]
  if (length(df) && any(df < 1 | df != trunc(df))) return(FALSE)
  TRUE
}

.ru_w4_validate_computed <- function(x, parsed) {
  required <- c("schema_version", "status", "reason_code",
                "original_question", "family_id", "inputs",
                "requested_outputs", "assumptions", "answer",
                "checks", "code_preview", "executed", "missing_inputs")
  optional <- c("method_id", "model_id", "estimand",
                "study_design", "execution_scope")
  if (!is.list(parsed) || !is.character(parsed$original_question) ||
      length(parsed$original_question) != 1L ||
      is.na(parsed$original_question) ||
      !.ru_w4_validate_parsed(parsed, parsed$original_question) ||
      !is.list(x) || !all(required %in% names(x)) ||
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
      (length(x$checks) &&
       (is.null(names(x$checks)) || anyDuplicated(names(x$checks)))) ||
      !all(vapply(x$checks, function(v)
        is.logical(v) && length(v) == 1L && !is.na(v),
        logical(1L))) ||
      !is.character(x$code_preview) ||
      length(x$code_preview) != 1L || is.na(x$code_preview) ||
      !validUTF8(x$code_preview) ||
      nchar(x$code_preview, type = "bytes") > 65536L ||
      !identical(intersect(optional, names(x)),
                 intersect(optional, names(parsed))))
    return(FALSE)
  for (key in intersect(optional, names(x))) {
    if (!identical(x[[key]], parsed[[key]])) return(FALSE)
  }
  if ("execution_scope" %in% names(x) &&
      !identical(x$execution_scope, "INLINE_LITERAL_ONLY"))
    return(FALSE)
  if (identical(x$status, "SOLVED")) {
    if (!identical(parsed$status, "SOLVED") ||
        !identical(x$reason_code, "W4_COMPUTATION_VERIFIED") ||
        !length(x$checks) ||
        !all(vapply(x$checks, isTRUE, logical(1L))) ||
        !identical(x$checks$verified, TRUE) ||
        !nzchar(x$code_preview) ||
        length(x$missing_inputs) ||
        !.ru_w4_validate_answer(x$answer, x$requested_outputs,
                                x$family_id))
      return(FALSE)
  } else {
    if (identical(parsed$status, "SOLVED") &&
        !identical(x$status, "INVALID")) return(FALSE)
    if (!identical(parsed$status, "SOLVED") &&
        (!identical(x$status, parsed$status) ||
         !identical(x$reason_code, parsed$reason_code)))
      return(FALSE)
    if (!is.list(x$answer) || length(x$answer) ||
        nzchar(x$code_preview) ||
        isTRUE(x$checks$verified))
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