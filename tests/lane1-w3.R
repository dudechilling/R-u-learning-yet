# A1 public API regression using an INSTALLED package and typed peer fixtures.
# The fixture implementation lives ONLY in a disposable package source copy.
library(rulearn)
ns <- asNamespace("rulearn")
assert <- function(ok, label) if (!isTRUE(ok)) stop(label, call. = FALSE)
state <- new.env(parent = emptyenv())
state$viewer_ready <- FALSE
state$guided <- list()
state$legacy_views <- 0L
state$parsed <- character()

make_parsed <- function(q) {
  key <- tolower(trimws(q))
  pmf <- key %in% c("pmf", "what is a pmf?")
  cdf <- key %in% c("cdf", "what is a cdf?")
  loaded <- grepl("loaded|biased|dependent", key)
  dice <- grepl("die|dice", key) && !loaded
  status <- if (loaded) "NEEDS_INPUT" else if (dice) "SOLVED" else
    if (pmf || cdf) "GUIDED_REFERENCE" else "UNSUPPORTED"
  reason <- if (loaded) "DIE_PROBABILITIES_REQUIRED" else
    if (dice) "FAIR_DICE_SUM" else if (pmf || cdf) "CONCEPT_ONLY" else
    "NOT_SUPPORTED"
  family <- if (dice) "dice_sum_independent_fair" else
    if (pmf) "discrete_pmf" else if (cdf) "discrete_cdf" else NA_character_
  list(schema_version = "ru.guided.v1", status = status,
       reason_code = reason, original_question = q, family_id = family,
       inputs = if (dice) list(die1_faces = 6L, die2_faces = 4L) else list(),
       requested_outputs = if (dice) c("pmf", "expected_value", "variance") else
         if (pmf) "pmf" else if (cdf) "cdf" else character(),
       assumptions = if (dice) list(fair = TRUE, independent = TRUE) else list(),
       missing_inputs = if (loaded) "die face probabilities" else character(),
       parser_rule_id = "installed-fixture")
}
parse_mock <- function(q) {
  state$parsed <- c(state$parsed, q)
  make_parsed(q)
}
compute_mock <- function(p) {
  counts <- c(1L, 2L, 3L, 4L, 4L, 4L, 3L, 2L, 1L)
  table <- data.frame(sum = 2:10, count = counts,
                      probability = counts/24,
                      cdf = cumsum(counts/24))
  c(p[c("schema_version", "status", "reason_code", "original_question",
        "family_id", "inputs", "requested_outputs", "assumptions")],
    list(answer = if (identical(p$status, "SOLVED"))
        list(pmf = table, total_outcomes = 24L,
             expected_value = 6, variance = 25/6,
             events = data.frame(label = character(), probability = double()))
      else list(),
      checks = if (identical(p$status, "SOLVED"))
        list(probabilities_sum_to_one = TRUE) else list(),
      code_preview = if (identical(p$status, "SOLVED"))
        "die1_faces <- 6L; die2_faces <- 4L" else "",
      executed = FALSE))
}
teach_mock <- function(comp) {
  solved <- identical(comp$status, "SOLVED")
  list(schema_version = "ru.guided.v1", status = comp$status,
       reason_code = comp$reason_code,
       title = if (identical(comp$family_id, "discrete_cdf"))
         "Understanding the CDF" else if (identical(comp$family_id, "discrete_pmf"))
         "Understanding the PMF" else "Guided lesson",
       question = comp$original_question,
       explanation_sections = c("Define the random variable.",
         "Explain the probability model.", "List possible outcomes.",
         "Count the outcomes.", "Form the PMF.", "Explain moments and variance.",
         "Explain the CDF and events."),
       step_by_step = paste0(seq_len(7L), ". ",
         c("Name the variables.", "Enumerate outcomes.", "Count sums.",
           "Divide by total outcomes.", "Calculate the expected value.",
           "Calculate the variance.", "Calculate the CDF.")),
       runnable_code = comp$code_preview,
       expected_output = if (solved)
         list(answer = comp$answer, requested_outputs = comp$requested_outputs,
              summary_lines = "Verified numeric output") else character(),
       checks = comp$checks,
       interpretations = c("Interpret the expected value and variance.",
                           "Interpret the CDF and assumptions."),
       change_this = if (solved) c("Edit die1_faces.", "Edit die2_faces.") else
         "Specify an actual probability model before computing.",
       hints = list(H0 = "Goal", H1 = "Model clue", H2 = "Method",
                    H3 = "Worked reasoning"),
       transfer_question = "Explain a related example independently.",
       links = c("ru_reference('discrete_pmf')"),
       assumptions = comp$assumptions)
}
render_mock <- function(lesson, open = TRUE) {
  state$guided[[length(state$guided) + 1L]] <- list(lesson = lesson, open = open)
  list(status = lesson$status, opened = FALSE,
       capability_status = if (open) "UNAVAILABLE" else "NOT_REQUESTED")
}
ready_mock <- function(capability) {
  assert(identical(capability, "viewer"), "Viewer capability name")
  isTRUE(state$viewer_ready)
}
legacy_mock <- function(...) {
  state$legacy_views <- state$legacy_views + 1L
  invisible(NULL)
}
mocks <- list(.ru_w3_parse = parse_mock,
              .ru_w3_compute = compute_mock,
              .ru_w3_teach = teach_mock,
              .ru_w3_render = render_mock,
              .ru_rstudio_ready = ready_mock,
              .ru_viewer_show = legacy_mock)
saved <- list()
for (name in names(mocks)) {
  if (exists(name, envir = ns, inherits = FALSE)) {
    saved[[name]] <- get(name, envir = ns, inherits = FALSE)
    unlockBinding(name, ns)
  }
  assign(name, mocks[[name]], envir = ns)
  lockBinding(name, ns)
}
restore <- function() {
  for (name in names(mocks)) {
    unlockBinding(name, ns)
    if (name %in% names(saved)) assign(name, saved[[name]], envir = ns)
    else rm(list = name, envir = ns)
    if (exists(name, envir = ns, inherits = FALSE)) lockBinding(name, ns)
  }
}
tryCatch({
  q <- paste("Determine the PMF, expected value and variance",
             "of the sum of one six-sided die and one four-sided die.")
  beginner <- ru_solve(q, open = FALSE, level = "beginner")
  concise <- ru_solve(q, open = FALSE, level = "concise")
  assert(inherits(beginner, "ru_solution"), "ru_solution class")
  assert(identical(beginner$schema_version, "ru.guided.v1"), "schema")
  assert(identical(beginner$status, "SOLVED"), "solved status")
  assert(identical(beginner$reason_code, "FAIR_DICE_SUM"), "reason")
  assert(identical(beginner$question, q), "question")
  assert(identical(beginner$answer$total_outcomes, 24L), "ordered outcomes")
  assert(identical(beginner$answer$variance, 25/6), "variance")
  assert(identical(beginner$requested_outputs,
                   c("pmf", "expected_value", "variance")), "composite")
  assert(identical(beginner$code_status, "NOT_EXECUTED") &&
         identical(beginner$executed, FALSE), "preview never executed")
  assert(!beginner$opened &&
         identical(beginner$capability_status, "NOT_REQUESTED"),
         "open=FALSE truthful fallback")
  assert(identical(beginner$guide$presentation_level, "beginner") &&
         identical(concise$guide$presentation_level, "concise"),
         "presentation levels")
  assert(identical(beginner$status, concise$status) &&
         identical(beginner$reason_code, concise$reason_code) &&
         identical(beginner$answer, concise$answer) &&
         identical(beginner$assumptions, concise$assumptions) &&
         identical(beginner$checks, concise$checks) &&
         identical(beginner$inputs, concise$inputs) &&
         identical(beginner$requested_outputs, concise$requested_outputs) &&
         identical(beginner$code_preview, concise$code_preview) &&
         identical(beginner$guide$runnable_code, concise$guide$runnable_code) &&
         identical(beginner$guide$expected_output, concise$guide$expected_output) &&
         identical(beginner$guide$hints, concise$guide$hints) &&
         identical(beginner$guide$change_this, concise$guide$change_this),
         "concise preserves all mathematical and essential guidance contracts")
  assert(length(concise$guide$explanation_sections) <
         length(beginner$guide$explanation_sections), "concise explanation shorter")
  assert(length(concise$guide$step_by_step) <
         length(beginner$guide$step_by_step), "concise method shorter")
  assert(!identical(concise$guide, beginner$guide) &&
         !identical(state$guided[[1L]]$lesson,
                    state$guided[[2L]]$lesson),
         "renderer receives genuinely different content")
  assert(!grepl("^[[:space:]]*[0-9]+[.)]", concise$guide$step_by_step[1L]),
         "concise ordered steps renumber cleanly")
  assert(identical(names(beginner$guide$hints), c("H0", "H1", "H2", "H3")),
         "beginner retains H0-H3")
  for (term in c("PMF", "CDF")) {
    conceptual <- ru_solve(term, open = FALSE)
    assert(identical(conceptual$status, "GUIDED_REFERENCE"), "concept status")
    assert(identical(conceptual$reason_code, "CONCEPT_ONLY"), "concept reason")
    assert(length(conceptual$inputs) == 0L &&
           length(conceptual$answer) == 0L &&
           !nzchar(conceptual$code_preview), "no invented operands or solution")
  }
  unsupported <- ru_solve("Analyze my private survey", open = FALSE)
  refusal <- ru_solve("Calculate the sum of two loaded dice", open = FALSE)
  assert(identical(unsupported$status, "UNSUPPORTED"), "unsupported")
  assert(identical(refusal$status, "NEEDS_INPUT"), "loaded dice refusal")
  assert(identical(refusal$reason_code, "DIE_PROBABILITIES_REQUIRED"),
         "missing probabilities code")
  refusal_concise <- ru_solve("Calculate the sum of two loaded dice",
                              open = FALSE, level = "concise")
  assert(identical(refusal_concise$status, refusal$status) &&
         identical(refusal_concise$reason_code, refusal$reason_code) &&
         identical(refusal_concise$assumptions, refusal$assumptions),
         "concise cannot change refusals")
  for (bad in list(NA_character_, "", "  ", 1, character(), rep("x", 4097L))) {
    invalid <- ru_solve(bad, open = FALSE)
    assert(identical(invalid$status, "INVALID"), "invalid input")
  }
  oversize <- ru_solve(paste(rep("x", 4097L), collapse = ""), open = FALSE)
  assert(identical(oversize$reason_code, "QUESTION_TOO_LONG"), "length guard")
  assert(inherits(try(ru_solve(q, open = NA), silent = TRUE), "try-error"),
         "open flag validation")
  assert(inherits(try(ru_solve(q, level = "intermediate"), silent = TRUE),
         "try-error"), "level validation")
  assert(!ru_solve(q, open = TRUE)$opened, "Viewer launch never invented")

  # Headless ordinary search stays a data.frame; guided viewing is optional.
  f <- withVisible(ru_find("PMF"))
  assert(!f$visible && is.data.frame(f$value) &&
         identical(f$value$id, "discrete_pmf"), "legacy PMF data.frame")
  assert(identical(withVisible(ru_find("CDF"))$value$id, "discrete_cdf"),
         "legacy CDF data.frame")
  assert(is.data.frame(ru_find(q)), "full-question return type")
  assert(identical(formals(ru_find)$n, 10L) &&
         identical(formals(ru_find)$type, NULL), "legacy signature")

  state$viewer_ready <- TRUE
  before <- length(state$guided)
  pmf_hit <- withVisible(ru_find("PMF"))
  assert(!pmf_hit$visible &&
         identical(pmf_hit$value$id, "discrete_pmf"), "PMF hidden return")
  assert(length(state$guided) == before + 1L &&
         identical(tail(state$guided, 1L)[[1L]]$lesson$status, "GUIDED_REFERENCE") &&
         identical(tail(state$guided, 1L)[[1L]]$lesson$title, "Understanding the PMF") &&
         length(tail(state$guided, 1L)[[1L]]$lesson$assumptions) == 0L,
         "PMF concept-first Viewer without imaginary dice")
  before <- length(state$guided)
  cdf_hit <- withVisible(ru_find("CDF"))
  assert(!cdf_hit$visible && identical(cdf_hit$value$id, "discrete_cdf"),
         "CDF hidden return")
  assert(length(state$guided) == before + 1L &&
         identical(tail(state$guided, 1L)[[1L]]$lesson$title, "Understanding the CDF"),
         "CDF concept-first Viewer")
  before <- length(state$guided)
  assert(is.data.frame(ru_find("PMF", type = "walkthrough")) &&
         length(state$guided) == before + 1L, "eligible walkthrough filter")
  before <- length(state$guided)
  for (filter in c("concept", "function")) {
    result <- withVisible(ru_find("PMF", type = filter))
    assert(!result$visible && is.data.frame(result$value) &&
           nrow(result$value) == 0L, "legacy type filter data.frame")
  }
  assert(length(state$guided) == before,
         "incompatible type filters must not trigger Viewer guide")
  state$viewer_ready <- FALSE
  before <- length(state$guided)
  ru_find("PMF")
  assert(length(state$guided) == before,
         "no Viewer means no guided Viewer claim")
  state$viewer_ready <- TRUE
  before <- length(state$guided)
  full <- withVisible(ru_find(q, n = 1L, type = "walkthrough"))
  assert(!full$visible && is.data.frame(full$value) &&
         nrow(full$value) <= 1L &&
         length(state$guided) == before + 1L &&
         identical(tail(state$guided, 1L)[[1L]]$lesson$status, "SOLVED"),
         "full assignment guide and legacy n filter")
  before <- length(state$guided)
  ru_find("Calculate probability of loaded die")
  ru_find("Analyze my private survey")
  assert(length(state$guided) == before, "no fabricated unsupported solution")
  assert(is.data.frame(ru_find(NA_character_)) &&
         nrow(ru_find("")) == 0L, "legacy invalid lookup")
  exported <- getNamespaceExports("rulearn")
  legacy_exports <- c("ru", "ru_find", "ru_plan", "ru_run", "ru_code",
    "ru_topics", "ru_inputs", "ru_hist", "ru_bar", "ru_box",
    "ru_scatter", "ru_data", "ru_datasets", "ru_columns",
    "ru_apply", "ru_guide", "ru_edit", "ru_open", "ru_text",
    "ru_palette", "ru_home", "ru_workspace", "ru_reference",
    "ru_capabilities", "ru_progress", "ru_source_context",
    "ru_learn", "ru_analyze", "ru_analyze_plan", "ru_analyze_code",
    "ru_analyze_execute", "ru_analyze_export")
  assert(length(legacy_exports) == 32L &&
         length(exported) == length(unique(exported)) &&
         length(exported) == 33L &&
         setequal(exported, c(legacy_exports, "ru_solve")),
         "exact preservation of all 32 legacy exports plus ru_solve")
  cat("A1 W3-R3 INSTALLED PUBLIC API REGRESSION PASS\n")
}, finally = restore())