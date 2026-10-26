# A2 W3-R3 contract tests. These assertions do not establish human learning.
teach <- getFromNamespace(".ru_w3_teach", "rulearn")
assert <- function(ok, message) if (!isTRUE(ok)) stop(message, call. = FALSE)

# Typed independent oracle for the installed A2-only package. When A3 is
# installed, the same tests exercise actual A3 parse/compute objects instead.
has_a3 <- all(vapply(c(".ru_w3_parse", ".ru_w3_compute"), exists,
  logical(1L), envir = asNamespace("rulearn"), inherits = FALSE))
if (has_a3) {
  parse_a3 <- getFromNamespace(".ru_w3_parse", "rulearn")
  compute_a3 <- getFromNamespace(".ru_w3_compute", "rulearn")
}
fixture <- function(a, b, requested = c("pmf", "cdf", "expected_value",
                                         "variance", "events")) {
  if (has_a3) {
    q <- sprintf("PMF CDF expected value variance of sum of %d-sided and %d-sided fair independent dice; P(X=4)",
                 a, b)
    result <- compute_a3(parse_a3(q))
    assert(identical(result$status, "SOLVED"), "Real A3 fixture did not solve")
    return(result)
  }
  # Fixture result mirrors the nested, validated ru.guided.v1 A3 result.
  pairs <- as.vector(outer(seq_len(a), seq_len(b), "+"))
  counts <- tabulate(pairs - 1L, nbins = a + b)[seq.int(2L, a + b) - 1L]
  support <- seq.int(2L, a + b)
  probabilities <- as.double(counts) / length(pairs)
  pmf <- data.frame(sum = as.integer(support), count = as.integer(counts),
                    probability = probabilities, cdf = cumsum(probabilities))
  expectation <- sum(pmf$sum * pmf$probability)
  variance <- sum((pmf$sum - expectation)^2 * pmf$probability)
  code <- paste(c(
    "# R code preview only: not automatically executed by RU.",
    "# Mathematical model assumption: both dice fair; rolls independent.",
    sprintf("die1_faces <- %dL", a),
    sprintf("die2_faces <- %dL", b),
    "roll_sums <- as.vector(outer(seq_len(die1_faces),",
    "                             seq_len(die2_faces), \"+\"))",
    "support <- seq.int(2L, die1_faces + die2_faces)",
    "counts <- tabulate(roll_sums - 1L, nbins = die1_faces + die2_faces)[support - 1L]",
    "pmf <- data.frame(sum = support, count = counts,",
    "                  probability = counts / length(roll_sums))",
    "pmf$cdf <- cumsum(pmf$probability)",
    "total_outcomes <- length(roll_sums)",
    "expected_value <- sum(pmf$sum * pmf$probability)",
    "# Population/distribution variance, not stats::var() sample variance:",
    "variance <- sum((pmf$sum - expected_value)^2 * pmf$probability)",
    "events <- data.frame(label = 'P(X=4)', probability = sum(pmf$probability[pmf$sum == 4L]))",
    "list(pmf = pmf, total_outcomes = total_outcomes,",
    "     expected_value = expected_value, variance = variance, events = events)"
  ), collapse = "\n")
  list(schema_version = "ru.guided.v1", status = "SOLVED",
       reason_code = "DICE_SUM_VERIFIED",
       original_question = sprintf("Sum of %d-sided and %d-sided fair independent dice", a, b),
       family_id = "dice_sum_independent_fair",
       inputs = list(die1_faces = as.integer(a), die2_faces = as.integer(b),
                     events = list()),
       requested_outputs = requested,
       assumptions = list(fair = TRUE, independent = TRUE),
       answer = list(pmf = pmf, total_outcomes = as.integer(a*b),
                     expected_value = as.double(expectation),
                     variance = as.double(variance),
                     events = data.frame(label = "P(X=4)",
                       probability = as.double(sum(probabilities[support==4L])))),
       checks = list(count_total = TRUE, probability_mass_sum = 1,
                     mass_is_one = TRUE, cdf_is_valid = TRUE, verified = TRUE),
       code_preview = code, executed = FALSE, missing_inputs = character())
}
make_status <- function(status, family, question, reason = "CONCEPT_ONLY",
                        requested = character(), missing = character()) {
  list(schema_version = "ru.guided.v1", status = status,
       reason_code = reason, original_question = question,
       family_id = family, inputs = list(), requested_outputs = requested,
       assumptions = list(), answer = NULL, checks = list(verified = FALSE),
       code_preview = "", executed = FALSE, missing_inputs = missing)
}
lessons <- list()
for (case in list(c(6L,4L),c(4L,8L),c(6L,6L))) {
  comp <- fixture(case[[1L]], case[[2L]])
  lesson <- teach(comp)
  lessons[[length(lessons)+1L]] <- lesson
  assert(identical(lesson$status, "SOLVED"), "status")
  assert(identical(lesson$reason_code, comp$reason_code), "reason code")
  assert(identical(lesson$requested_outputs, comp$requested_outputs), "requested outputs")
  assert(is.list(lesson$expected_output), "structured expected_output")
  assert(identical(names(lesson$expected_output),
                   c("answer","requested_outputs","summary_lines")), "expected_output keys")
  assert(identical(lesson$expected_output$answer, comp$answer), "A3 result changed")
  assert(identical(lesson$expected_output$requested_outputs,
                   comp$requested_outputs), "output intent changed")
  assert(is.character(lesson$expected_output$summary_lines), "textual summary")
  assert(identical(lesson$runnable_code, comp$code_preview), "code preview rewritten")
  assert(identical(names(lesson$hints), paste0("H",0:3)), "hint levels")
  assert(length(unique(unlist(lesson$hints))) == 4L, "hints not distinct")
  assert(all(vapply(lesson$hints, nzchar, logical(1L))), "empty hint")
  assert(all(c("die1_faces","die2_faces") %in%
             c(if (any(grepl("die1_faces",lesson$change_this,fixed=TRUE))) "die1_faces",
               if (any(grepl("die2_faces",lesson$change_this,fixed=TRUE))) "die2_faces")),
         "What to edit does not use actual code variables")
  assert(length(lesson$step_by_step) >= 8L, "missing step-by-step reasoning")
  assert(any(grepl("tabulate(",lesson$step_by_step,fixed=TRUE)), "missing tabulate")
  assert(any(grepl("seq_len(",lesson$step_by_step,fixed=TRUE)), "missing seq_len")
  assert(any(grepl("counts / length(roll_sums)",lesson$step_by_step,fixed=TRUE)), "missing division")
  assert(any(grepl("cumsum(",lesson$step_by_step,fixed=TRUE)), "missing CDF code")
  assert(any(grepl("optional alternative",lesson$explanation_sections,fixed=TRUE)),
         "equivalent table()/prop.table() must be marked optional")
  assert(any(grepl("not used in the displayed preview",lesson$explanation_sections,fixed=TRUE)),
         "wrong method attribution")
  assert(all(!grepl("^TRUE$|^FALSE$", lesson$assumptions)), "bare booleans")
  assert(any(grepl("fair",lesson$assumptions,fixed=TRUE)) &&
         any(grepl("independent",lesson$assumptions,fixed=TRUE)), "missing model assumptions")
  assert(any(grepl(as.character(comp$answer$total_outcomes),
                   lesson$expected_output$summary_lines, fixed=TRUE)), "total outcome mismatch")
  assert(any(grepl(paste0("E(X): ",
                          format(comp$answer$expected_value, scientific=FALSE,trim=TRUE)),
                   lesson$expected_output$summary_lines,fixed=TRUE)), "expected value missing")
  # Running code in this test env is separate from RU's preview-only behavior.
  e <- new.env(parent=baseenv())
  observed <- eval(parse(text=lesson$runnable_code), envir=e)
  assert(isTRUE(all.equal(observed$pmf, comp$answer$pmf, tolerance=1e-12,
                          check.attributes=FALSE)), "code/PMF mismatch")
  assert(isTRUE(all.equal(observed$expected_value, comp$answer$expected_value,
                          tolerance=1e-11)), "code/mean mismatch")
  assert(isTRUE(all.equal(observed$variance, comp$answer$variance,
                          tolerance=1e-11)), "code/variance mismatch")
  assert(isTRUE(all.equal(observed$events$probability,
                          comp$answer$events$probability, tolerance=1e-12)),
         "code/events mismatch")
}
assert(!identical(lessons[[1]]$expected_output,lessons[[2]]$expected_output),
       "6+4 and 4+8 same values")
assert(!identical(lessons[[2]]$expected_output,lessons[[3]]$expected_output),
       "4+8 and 6+6 same values")
assert(!identical(lessons[[1]]$title,lessons[[2]]$title), "titles not parameterized")

# Deliberately request multiple objectives and keep every A3 result intact.
multi <- fixture(6L,4L,c("expected_value","variance","cdf","events"))
multi_lesson <- teach(multi)
assert(identical(multi_lesson$requested_outputs, multi$requested_outputs),
       "multipart intent dropped")
assert(identical(multi_lesson$expected_output$answer, multi$answer),
       "multipart verified answer dropped")
assert(any(grepl("CDF",multi_lesson$expected_output$summary_lines,fixed=TRUE)) &&
       any(grepl("Var(X)",multi_lesson$expected_output$summary_lines,fixed=TRUE)) &&
       any(grepl("P(X=",multi_lesson$expected_output$summary_lines,fixed=TRUE)),
       "multipart summary incomplete")
if (exists(".ru_w3_html", envir=asNamespace("rulearn"),inherits=FALSE)) {
  html <- getFromNamespace(".ru_w3_html","rulearn")(lessons[[1]])
  assert(grepl("<table>",html,fixed=TRUE) && grepl("<meter ",html,fixed=TRUE),
         "A4 renderer lost actual numeric table and graph")
}

cdf <- teach(make_status("GUIDED_REFERENCE","discrete_cdf","What is a CDF?",
                         requested="cdf"))
assert(identical(cdf$status,"GUIDED_REFERENCE") &&
       grepl("cumulative distribution",cdf$title,ignore.case=TRUE),
       "CDF reference mislabeled PMF")
assert(any(grepl("less than or equal",cdf$explanation_sections,fixed=TRUE)) &&
       any(grepl("cumsum()",cdf$step_by_step,fixed=TRUE)),
       "CDF concept or mechanics missing")
assert(!nzchar(cdf$runnable_code) && !length(cdf$expected_output),
       "CDF reference fabricated numerical example")
pmf <- teach(make_status("GUIDED_REFERENCE","discrete_pmf","PMF",
                         requested="pmf"))
assert(grepl("probability mass function",pmf$title,ignore.case=TRUE) &&
       !length(pmf$expected_output), "PMF concept fabricated answer")

csv <- teach(make_status("NEEDS_INPUT","data_workflow",
                         "How do I import a CSV?",reason="DATA_SOURCE_REQUIRED",
                         missing="data_source"))
assert(grepl("CSV",csv$title) &&
       any(grepl("read.csv",csv$step_by_step,fixed=TRUE)) &&
       !any(grepl("PMF",unlist(csv$hints),fixed=TRUE)) &&
       !nzchar(csv$runnable_code), "CSV domain route incorrect")
na <- teach(make_status("NEEDS_INPUT","data_workflow",
                        "How to handle missing values?",reason="DATA_SOURCE_REQUIRED",
                        missing="data_source"))
assert(any(grepl("is.na(",na$step_by_step,fixed=TRUE)) &&
       any(grepl("colSums(",unlist(na$hints),fixed=TRUE)),
       "missing-data route incorrect")
hist <- teach(make_status("NEEDS_INPUT","histogram","Draw a histogram",
                          reason="DATA_AND_HISTOGRAM_SPEC_REQUIRED",
                          missing=c("data","histogram_spec")))
assert(any(grepl("hist(",hist$step_by_step,fixed=TRUE)) &&
       any(grepl("bin",hist$explanation_sections,fixed=TRUE)) &&
       !any(grepl("PMF",unlist(hist$hints),fixed=TRUE)) &&
       identical(hist$status,"NEEDS_INPUT"), "histogram route incorrect")
hyp <- teach(make_status("UNSUPPORTED","inference","Perform a t-test",
                         reason="INFERENTIAL_METHOD_NOT_IN_GUIDED_FAMILY"))
assert(grepl("hypothesis",hyp$title) &&
       !length(hyp$expected_output) && !nzchar(hyp$runnable_code),
       "inference refusal should not calculate")
loaded <- teach(make_status("NEEDS_INPUT","dice_sum_independent_fair",
                            "PMF of a loaded six-sided die and a four-sided die",
                            reason="DIE_PROBABILITIES_REQUIRED"))
assert(identical(loaded$status,"NEEDS_INPUT") &&
       !length(loaded$expected_output) && !nzchar(loaded$runnable_code),
       "loaded dice incorrectly solved")
for (status in c("NEEDS_INPUT","UNSUPPORTED","INVALID")) {
  r <- teach(make_status(status,"no_rule","Unrecognized method",reason="NO_RULE"))
  assert(identical(r$status,status) && !length(r$expected_output),
         "unsupported method claims output")
  assert(length(unique(unlist(r$hints)))==4L, "unsupported hints repeated")
}
bad <- fixture(6L,4L);bad$schema_version <- "other"
assert(inherits(try(teach(bad),silent=TRUE),"try-error"), "invalid schema accepted")
bad_code <- fixture(6L,4L);bad_code$code_preview <- "die1_faces <- 6L"
assert(inherits(try(teach(bad_code),silent=TRUE),"try-error"),
       "incomplete code preview accepted")

message("lane2-w3: A2 structured contract, three dice models, CDF, events and domain routes PASS")