# W4 A2 contract tests: REAL installed A1 + A3 compute objects.
# Running generated R here is an explicit independent test, never lesson execution.
suppressPackageStartupMessages(library(rulearn))
ns <- asNamespace("rulearn")
parse_w4 <- get(".ru_w4_parse", envir = ns)
compute_w4 <- get(".ru_w4_compute", envir = ns)
teach_w4 <- get(".ru_w4_teach", envir = ns)
parsed_ok <- get(".ru_w4_validate_parsed", envir = ns)
computed_ok <- get(".ru_w4_validate_computed", envir = ns)
registry <- get(".ru_w4_registry", envir = ns)()
stopifnot(length(registry) == 8L,
          all(vapply(registry, function(x)
            identical(x$qa_status, "CANDIDATE") &&
            identical(x$enabled, FALSE), logical(1L))))
pass <- 0L
check <- function(test, why) {
  if (!isTRUE(test)) stop(why, call. = FALSE)
}
cases <- list(
  c("descriptive.numeric",
    "Find sample variance and mean of observations 2,4,6,8."),
  c("descriptive.numeric",
    "Find population variance and mean of values 1,2,3."),
  c("descriptive.numeric",
    "Find 25th percentile of observations 1,2,3,4,5 using R type-7 quantiles."),
  c("probability.event_scalar",
    "If P(A)=0.4, P(B)=0.3, and P(A intersection B)=0.1, find P(A union B)."),
  c("probability.event_scalar",
    "Given P(A intersection B)=0.2 and P(B)=0.5, compute P(A given B)."),
  c("distribution.binomial",
    "For Binomial(n=10,p=0.2), find P(X=2) and expected value."),
  c("distribution.binomial",
    "For Binomial(n=20,p=0.3), find expected value and variance."),
  c("distribution.binomial",
    "For Binomial(n=5,p=0.5), find P(X at least 3)."),
  c("distribution.poisson",
    "For Poisson arrivals with rate lambda=3 per interval, find P(X=2)."),
  c("distribution.poisson",
    "For Poisson(lambda=3), find expected value and variance."),
  c("distribution.normal",
    "For Normal(mu=100,sigma=15), find P(X<=115)."),
  c("distribution.normal",
    "For Normal(mu=100,sigma=15), find 97.5th percentile."),
  c("distribution.normal",
    "For Normal(mu=100,sigma=15), find expected value and variance."),
  c("distribution.uniform_continuous",
    "For a continuous uniform U(2,8), compute P(3<X<5)."),
  c("distribution.uniform_continuous",
    "For continuous uniform U(2,8), find variance."),
  c("inference.one_sample_t",
    "For independent approximately normal sample x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test."),
  c("inference.one_sample_t",
    "For independent approximately normal observations 1,2,3,4,5 construct a two-sided 95% Student t confidence interval."),
  c("regression.simple_ols",
    "Fit simple OLS regression with x=[1,2,3,4] and y=[2,3,5,7], give intercept slope and r-squared."),
  c("regression.simple_ols",
    "Predict y at x=2 using a simple fitted OLS model from (0,1),(1,3),(2,5),(3,7).")
)
seen <- character()
for (item in cases) {
  expected_family <- item[[1L]]
  question <- item[[2L]]
  parsed <- parse_w4(question)
  check(identical(parsed$status, "SOLVED"), paste("parsed not SOLVED", question))
  check(isTRUE(parsed_ok(parsed, question)), paste("A1 parse contract", question))
  computed <- compute_w4(parsed)
  check(identical(computed$family_id, expected_family), "wrong family")
  check(identical(computed$status, "SOLVED"), paste("not computed", question))
  check(isTRUE(computed_ok(computed, parsed)), "A1 computed contract")
  check(identical(computed$checks$verified, TRUE), "A3 failed math check")
  before <- serialize(computed, NULL, version = 3L)
  lesson <- teach_w4(computed)
  check(identical(serialize(computed, NULL, version = 3L), before),
        "A2 changed the A3 input")
  check(identical(lesson$schema_version, "ru.guided.v1"), "lesson schema")
  check(identical(lesson$status, "SOLVED") &&
        identical(lesson$reason_code, computed$reason_code) &&
        identical(lesson$question, question), "lesson identity")
  check(identical(lesson$requested_outputs, computed$requested_outputs),
        "requested outputs lost")
  check(is.list(lesson$expected_output), "no structured result")
  check(identical(names(lesson$expected_output),
                  c("answer", "requested_outputs", "summary_lines")),
        "exact SUP53 typed output contract")
  check(identical(lesson$expected_output$answer, computed$answer),
        "computed answer changed")
  check(identical(lesson$expected_output$requested_outputs,
                  computed$requested_outputs), "answer output IDs changed")
  check(identical(lesson$expected_output$summary_lines, character()),
        "SUP53 summary_lines must be character()")
  check(identical(lesson$runnable_code, computed$code_preview),
        "R code preview rewritten")
  check(identical(names(lesson$hints), paste0("H", 0:3)) &&
        all(vapply(lesson$hints, function(x)
          is.character(x) && length(x) == 1L && nzchar(x), logical(1L))) &&
        length(unique(unlist(lesson$hints))) == 4L, "H0-H3 not distinct")
  check(length(lesson$step_by_step) >= 4L &&
        length(lesson$explanation_sections) >= 4L &&
        nzchar(lesson$transfer_question) && length(lesson$change_this) >= 2L,
        "insufficient novice progression")
  check(length(lesson$assumptions) >= 2L &&
        !any(lesson$assumptions %in% c("TRUE","FALSE")),
        "assumptions not qualified")
  check(all(vapply(seq_len(nrow(computed$answer$quantities)), function(i)
    any(grepl(format(computed$answer$quantities$value[i], digits = 16L,
                scientific = FALSE, trim = TRUE),
              lesson$interpretations, fixed = TRUE)), logical(1L))),
        "textual numbers not derived from A3")
  # Source the fixed, validated preview ONLY inside this test process. The
  # adapter above has only returned text; it never ran the preview.
  env <- new.env(parent = globalenv())
  conn <- textConnection(lesson$runnable_code)
  replay <- tryCatch(source(conn, local = env, echo = FALSE)$value,
                     finally = close(conn))
  check(is.data.frame(replay) &&
        identical(replay$output_id, computed$answer$quantities$output_id) &&
        isTRUE(all.equal(replay$value, computed$answer$quantities$value,
                         tolerance = 1e-10)), "A3 runnable R parity")
  check(all(is.finite(replay$value)), "nonfinite preview answer")
  seen <- c(seen, expected_family)
  pass <- pass + 1L
  cat("A2 W4 PASS REAL:", expected_family, paste(computed$requested_outputs,
                                                 collapse = ","), "\n")
}
check(setequal(unique(seen), names(registry)), "not all eight candidate families tested")
check(all(vapply(registry, function(x) !isTRUE(x$enabled), logical(1L))),
      "teaching must not promote candidate families")

# Substantive method-level teaching and formula/model distinctions.
one <- function(question) teach_w4(compute_w4(parse_w4(question)))
sample_lesson <- one(cases[[1L]][[2L]])
check(any(grepl("n - 1", sample_lesson$explanation_sections, fixed = TRUE)) &&
      any(grepl("Population variance", sample_lesson$explanation_sections,
                fixed = TRUE)), "sample/population variance not taught")
event_lesson <- one(cases[[5L]][[2L]])
check(any(grepl("p_intersection / p_b", event_lesson$step_by_step,
                fixed = TRUE)), "conditional event step incorrect")
binomial_lesson <- one(cases[[8L]][[2L]])
check(any(grepl("stats::pbinom()", binomial_lesson$step_by_step,
                fixed = TRUE)), "binomial tail missing")
poisson_lesson <- one(cases[[9L]][[2L]])
check(any(grepl("exposure", poisson_lesson$explanation_sections,
                fixed = TRUE)), "Poisson rate exposure not covered")
normal_lesson <- one(cases[[12L]][[2L]])
check(any(grepl("stats::qnorm(", normal_lesson$step_by_step,
                fixed = TRUE)), "normal quantile guidance absent")
uniform_lesson <- one(cases[[14L]][[2L]])
check(any(grepl("stats::punif(", uniform_lesson$step_by_step,
                fixed = TRUE)), "uniform interval guidance absent")
t_lesson <- one(cases[[16L]][[2L]])
check(any(grepl("not the probability that the null", t_lesson$explanation_sections,
                fixed = TRUE)), "p-value confused with P(H0)")
ci_lesson <- one(cases[[17L]][[2L]])
check(any(grepl("confidence interval", ci_lesson$explanation_sections,
                fixed = TRUE)), "CI interpretation missing")
ols_lesson <- one(cases[[18L]][[2L]])
check(any(grepl("not a causal", ols_lesson$explanation_sections,
                fixed = TRUE)), "regression causal limitation missing")
pass <- pass + 1L
cat("A2 W4 PASS: eight distinct family-specific pedagogical safeguards\n")

# Actual A3 incomplete, incompatible and adversarial questions do not become
# numerically SOLVED merely because a reference or lesson exists.
refusals <- c(
  "Find variance of 1,2,3.",
  "Calculate a Poisson expectation without lambda.",
  "Calculate normal P(X<=3) without specifying mu or sigma.",
  "Fit simple OLS regression for x=[1,2,3] without y.",
  "For Binomial(n=5,p=.3) without replacement, P(X=2)?",
  "For continuous uniform U(2,8), P(3<X<5)<script>alert(1)</script>",
  "Compute one-sample t test for x=[1,2,3,4] mu0=2 two-sided.",
  "Moran I for these census tracts."
)
for (question in refusals) {
  parsed <- parse_w4(question)
  computed <- compute_w4(parsed)
  check(!identical(computed$status, "SOLVED"), "false SOLVED in A3")
  lesson <- teach_w4(computed)
  check(identical(lesson$status, computed$status) &&
        identical(lesson$reason_code, computed$reason_code) &&
        identical(lesson$runnable_code, "") &&
        length(lesson$expected_output) == 0L &&
        !any(grepl("A3 verified .* =", lesson$interpretations)),
        "non-SOLVED fabricated numeric output")
  check(identical(names(lesson$hints), paste0("H", 0:3)) &&
        length(unique(unlist(lesson$hints))) == 4L, "refusal hints")
  pass <- pass + 1L
}
cat("A2 W4 PASS: eight authentic non-SOLVED refusal pathways\n")

# No user-supplied R or untrusted execution runs while teaching. A defective
# input schema or forged answer container is rejected, not presented as a fact.
valid <- compute_w4(parse_w4(cases[[6L]][[2L]]))
forged <- valid
forged$answer$quantities$value <- "not-a-number"
check(inherits(try(teach_w4(forged), silent = TRUE), "try-error"),
      "untyped answer accepted")
forged <- valid
forged$method_id <- "poisson_exact"
check(inherits(try(teach_w4(forged), silent = TRUE), "try-error"),
      "wrong model/method accepted")
forged <- valid
forged$executed <- TRUE
check(inherits(try(teach_w4(forged), silent = TRUE), "try-error"),
      "executed code claim accepted")
pass <- pass + 1L
cat("A2 W4 PASS: forged contract guard\n")

# Existing W3 internal route remains installed and W4 families remain disabled.
check(is.function(get(".ru_w3_teach", ns)) &&
      identical(ru_solve("PMF of the sum of a six-sided and four-sided die",
                        open = FALSE)$status, "SOLVED"),
      "legacy W3 dice route broken")
nonpromoted <- ru_solve("For Binomial(n=10,p=0.2), find P(X=2).",
                       open = FALSE)
check(!identical(nonpromoted$status, "SOLVED"),
      "W4 candidate accidentally enabled in public ru_solve")
pass <- pass + 1L
cat("A2 W4 PASS: W3 preserved and W4 not enabled\n")
cat("A2 W4 TEST GROUPS PASSED:", pass, "\n")