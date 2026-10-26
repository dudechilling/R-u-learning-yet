# W3 theoretical computation for bounded fair, independent two-die sums.
# No arbitrary R expression, filesystem action, network access, or user data.
.ru_w3_computed <- function(parsed, status, reason_code, answer = NULL,
                            checks = list(verified = FALSE), code_preview = "") {
  scalar <- function(name, default) {
    val <- if (is.list(parsed)) parsed[[name]] else NULL
    if (is.character(default)) {
      if (!is.character(val) || length(val) != 1L || is.na(val)) default else val
    } else default
  }
  structure(list(
    schema_version = "ru.guided.v1",
    status = status, reason_code = reason_code,
    original_question = scalar("original_question", ""),
    family_id = scalar("family_id", NA_character_),
    inputs = if (is.list(parsed) && is.list(parsed$inputs))
      parsed$inputs else list(),
    requested_outputs = if (is.list(parsed) &&
                            is.character(parsed$requested_outputs))
      parsed$requested_outputs else character(),
    assumptions = if (is.list(parsed) && is.list(parsed$assumptions))
      parsed$assumptions else list(),
    answer = answer, checks = checks,
    code_preview = code_preview, executed = FALSE,
    # Additive guidance field: concept/incomplete-question consumers need this.
    missing_inputs = if (is.list(parsed) &&
                          is.character(parsed$missing_inputs))
      parsed$missing_inputs else character()
  ), class = c("ru_w3_computed", "list"))
}

.ru_w3_valid_parsed <- function(parsed) {
  if (!is.list(parsed) ||
      !identical(parsed$schema_version, "ru.guided.v1") ||
      !identical(parsed$status, "SOLVED") ||
      !identical(parsed$family_id, "dice_sum_independent_fair") ||
      !is.character(parsed$original_question) ||
      length(parsed$original_question) != 1L ||
      is.na(parsed$original_question) ||
      !validUTF8(parsed$original_question) ||
      nchar(parsed$original_question, type = "bytes") > 4096L ||
      !is.list(parsed$inputs) || !is.list(parsed$assumptions) ||
      !identical(parsed$assumptions$fair, TRUE) ||
      !identical(parsed$assumptions$independent, TRUE) ||
      !identical(parsed$parser_rule_id, "two_fair_independent_dice_v1") ||
      !is.character(parsed$requested_outputs) ||
      !length(parsed$requested_outputs) ||
      !is.character(parsed$missing_inputs) ||
      length(parsed$missing_inputs))
    return(FALSE)
  outs <- parsed$requested_outputs
  allowed <- c("pmf", "cdf", "expected_value", "variance", "events")
  if (anyDuplicated(outs) || !all(outs %in% allowed))
    return(FALSE)
  inputs <- parsed$inputs
  if (!identical(sort(names(inputs)), sort(c("die1_faces", "die2_faces", "events"))))
    return(FALSE)
  a <- inputs$die1_faces
  b <- inputs$die2_faces
  valid_face <- function(x) is.integer(x) && length(x) == 1L &&
    !is.na(x) && x >= 2L && x <= 10000L
  if (!valid_face(a) || !valid_face(b) ||
      as.double(a) * as.double(b) > 200000 ||
      as.double(a) + as.double(b) > 20000)
    return(FALSE)
  events <- inputs$events
  if (!is.list(events) || length(events) > 12L ||
      (length(events) > 0L && !("events" %in% outs)) ||
      ("events" %in% outs && length(events) == 0L))
    return(FALSE)
  for (event in events) {
    if (!is.list(event) || !identical(sort(names(event)),
      sort(c("type", "values", "label"))) ||
      !is.character(event$type) || length(event$type) != 1L ||
      !event$type %in% c("equal", "at_most", "even", "one_of") ||
      !is.integer(event$values) || anyNA(event$values) ||
      any(abs(as.double(event$values)) > 1000000000) ||
      !is.character(event$label) || length(event$label) != 1L ||
      is.na(event$label))
      return(FALSE)
    number_expected <- switch(event$type, equal = 1L, at_most = 1L,
                              even = 0L, one_of = 2L)
    if (length(event$values) != number_expected ||
        !identical(event$label,
                   .ru_w3_event(event$type, event$values)$label))
      return(FALSE)
  }
  TRUE
}

.ru_w3_event_probability <- function(event, pmf) {
  selected <- switch(event$type,
    equal = pmf$sum == event$values[[1L]],
    at_most = pmf$sum <= event$values[[1L]],
    even = pmf$sum %% 2L == 0L,
    one_of = pmf$sum %in% event$values)
  as.double(sum(pmf$probability[selected]))
}

.ru_w3_event_code <- function(event) {
  switch(event$type,
    equal = sprintf("sum(pmf$probability[pmf$sum == %dL])",
                    event$values[[1L]]),
    at_most = sprintf("sum(pmf$probability[pmf$sum <= %dL])",
                      event$values[[1L]]),
    even = "sum(pmf$probability[pmf$sum %% 2L == 0L])",
    one_of = sprintf(
      "sum(pmf$probability[pmf$sum %%in%% c(%dL, %dL)])",
      event$values[[1L]], event$values[[2L]]))
}

.ru_w3_code_preview <- function(a, b, events) {
  lines <- c(
    "# R code preview only: not automatically executed by RU.",
    "# Mathematical model assumption: both dice fair; rolls independent.",
    sprintf("die1_faces <- %dL", a),
    sprintf("die2_faces <- %dL", b),
    "roll_sums <- as.vector(outer(seq_len(die1_faces),",
    '                             seq_len(die2_faces), "+"))',
    "support <- seq.int(2L, die1_faces + die2_faces)",
    "counts <- tabulate(roll_sums - 1L, nbins = die1_faces + die2_faces)[support - 1L]",
    "pmf <- data.frame(sum = support, count = counts,",
    "                  probability = counts / length(roll_sums))",
    "pmf$cdf <- cumsum(pmf$probability)",
    "total_outcomes <- length(roll_sums)",
    "expected_value <- sum(pmf$sum * pmf$probability)",
    "# Population/distribution variance, not stats::var() sample variance:",
    "variance <- sum((pmf$sum - expected_value)^2 * pmf$probability)"
  )
  if (!length(events)) {
    lines <- c(lines,
      "events <- data.frame(label = character(), probability = double())")
  } else {
    labels <- vapply(events, function(event) event$label, character(1L))
    event_code <- vapply(events, .ru_w3_event_code, character(1L))
    lines <- c(lines,
      sprintf("event_labels <- c(%s)", paste(encodeString(labels, quote = '"'),
                                             collapse = ", ")),
      sprintf("event_probabilities <- c(%s)", paste(event_code,
                                                    collapse = ", ")),
      "events <- data.frame(label = event_labels,",
      "                     probability = event_probabilities)")
  }
  lines <- c(lines,
    "list(pmf = pmf, total_outcomes = total_outcomes,",
    "     expected_value = expected_value, variance = variance, events = events)")
  paste(lines, collapse = "\n")
}

.ru_w3_compute <- function(parsed) {
  status_values <- c("SOLVED", "GUIDED_REFERENCE", "NEEDS_INPUT",
                     "UNSUPPORTED", "INVALID")
  if (!is.list(parsed) ||
      !identical(parsed$schema_version, "ru.guided.v1") ||
      !is.character(parsed$status) || length(parsed$status) != 1L ||
      is.na(parsed$status) || !(parsed$status %in% status_values))
    return(.ru_w3_computed(parsed, "INVALID", "PARSED_SCHEMA_INVALID"))
  if (!identical(parsed$status, "SOLVED")) {
    # Preserve honest non-computation statuses, never manufacture answers.
    reason <- parsed$reason_code
    if (!is.character(reason) || length(reason) != 1L ||
        is.na(reason) || !nzchar(reason))
      return(.ru_w3_computed(parsed, "INVALID", "PARSED_SCHEMA_INVALID"))
    return(.ru_w3_computed(parsed, parsed$status, reason))
  }
  if (!.ru_w3_valid_parsed(parsed))
    return(.ru_w3_computed(parsed, "INVALID", "PARSED_SCHEMA_INVALID"))

  a <- parsed$inputs$die1_faces
  b <- parsed$inputs$die2_faces
  total <- as.integer(as.double(a) * as.double(b))
  support <- seq.int(2L, a + b)
  # Independent convolution counting pairs (i,j) with i+j=s, not simulation.
  lower <- pmax.int(1L, support - b)
  upper <- pmin.int(a, support - 1L)
  counts <- as.integer(pmax.int(0L, upper - lower + 1L))
  probability <- as.double(counts) / as.double(total)
  pmf <- data.frame(sum = as.integer(support),
                    count = counts, probability = probability,
                    cdf = cumsum(probability))
  # Independent analytical oracle, not an R sample variance estimate.
  formula_mean <- (as.double(a) + 1 + as.double(b) + 1) / 2
  formula_variance <- ((as.double(a)^2 - 1) +
                       (as.double(b)^2 - 1)) / 12
  pmf_mean <- sum(pmf$sum * pmf$probability)
  pmf_variance <- sum((pmf$sum - pmf_mean)^2 * pmf$probability)
  events <- parsed$inputs$events
  event_frame <- if (!length(events)) {
    data.frame(label = character(), probability = double())
  } else {
    data.frame(
      label = vapply(events, function(event) event$label, character(1L)),
      probability = vapply(events, .ru_w3_event_probability, numeric(1L),
                           pmf = pmf),
      stringsAsFactors = FALSE)
  }
  checks <- list(
    count_total = identical(as.integer(sum(counts)), total),
    nonnegative_mass = all(is.finite(probability) & probability >= 0),
    probability_mass_sum = sum(probability),
    mass_is_one = isTRUE(all.equal(sum(probability), 1, tolerance = 1e-12)),
    support_is_complete = identical(pmf$sum, seq.int(2L, a + b)),
    count_symmetry = identical(counts, rev(counts)),
    cdf_is_valid = all(diff(pmf$cdf) >= -1e-12) &&
      isTRUE(all.equal(tail(pmf$cdf, 1L), 1, tolerance = 1e-12)),
    mean_matches_formula = isTRUE(all.equal(
      pmf_mean, formula_mean, tolerance = 1e-11)),
    variance_matches_formula = isTRUE(all.equal(
      pmf_variance, formula_variance, tolerance = 1e-11)),
    events_bounded = all(is.finite(event_frame$probability) &
      event_frame$probability >= 0 & event_frame$probability <= 1),
    analytical_mean = formula_mean,
    analytical_variance = formula_variance
  )
  booleans <- checks[vapply(checks, is.logical, logical(1L))]
  checks$verified <- all(unlist(booleans, use.names = FALSE))
  if (!checks$verified)
    return(.ru_w3_computed(parsed, "INVALID", "COMPUTATION_INVARIANT_FAILED",
                           checks = checks))
  answer <- list(
    pmf = pmf, total_outcomes = total,
    expected_value = as.double(formula_mean),
    variance = as.double(formula_variance),
    events = event_frame
  )
  .ru_w3_computed(parsed, "SOLVED", "DICE_SUM_VERIFIED",
                  answer = answer, checks = checks,
                  code_preview = .ru_w3_code_preview(a, b, events))
}