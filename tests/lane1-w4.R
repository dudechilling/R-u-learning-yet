# W4-R1 A1: installed-package contract and candidate-dispatch acceptance.
# No A3/A2/A4 code or numerical implementation is substituted.
# Synthetic typed fixtures test validation, not claims of W4 computation.
suppressPackageStartupMessages(library(rulearn))
stopifnot(as.character(packageVersion("rulearn")) == "0.4.2.9001")

ns <- asNamespace("rulearn")
private <- function(name) get(name, envir = ns, inherits = FALSE)
registry <- private(".ru_w4_registry")
family <- private(".ru_w4_family")
enabled <- private(".ru_w4_family_enabled")
valid_registry <- private(".ru_w4_validate_registry")
valid_family <- private(".ru_w4_validate_family")
valid_parsed <- private(".ru_w4_validate_parsed")
valid_computed <- private(".ru_w4_validate_computed")
valid_answer <- private(".ru_w4_validate_answer")
valid_inputs <- private(".ru_w4_validate_typed_inputs")
dispatch_parsed <- private(".ru_w4_dispatch_parsed")
dispatch <- private(".ru_w4_dispatch")
peer <- private(".ru_w4_peer_function")
checked <- 0L
pass <- function(label, f) {
  force(f)
  checked <<- checked + 1L
  cat("W4_A1_PASS ", label, "\n", sep = "")
}
baseline <- "9be43f32110c871ca4170e1e41e39f8f160c5e0e"
ids <- c("descriptive.numeric", "probability.event_scalar",
         "distribution.binomial", "distribution.poisson",
         "distribution.normal", "distribution.uniform_continuous",
         "inference.one_sample_t", "regression.simple_ols")

pass("exact closed eight-family registry and 33 legacy public exports", {
  a <- registry()
  stopifnot(identical(names(a), ids), length(a) == 8L,
            valid_registry(a),
            all(vapply(a, valid_family, logical(1L))),
            all(vapply(a, function(x)
              identical(x$schema_version, "ru.family.v1") &&
              identical(x$execution_scope, "INLINE_LITERAL_ONLY") &&
              identical(x$qa_status, "CANDIDATE") &&
              identical(x$enabled, FALSE) &&
              identical(x$family_version, 1L), logical(1L))),
            identical(sort(names(a)), sort(ids)),
            length(getNamespaceExports("rulearn")) == 33L,
            "ru_solve" %in% getNamespaceExports("rulearn"),
            !any(grepl("^\\.ru_w4", getNamespaceExports("rulearn"))),
            identical(names(formals(ru_solve)),
                      c("question", "open", "level")),
            identical(names(formals(ru_find)),
                      c("query", "n", "type")))
  stopifnot(all(vapply(ids, function(x) identical(enabled(x), FALSE),
                       logical(1L))))
})

pass("all registered topic/curriculum crosswalks resolve to real indexes", {
  topic <- utils::read.csv(system.file("extdata", "coverage.csv",
                                        package = "rulearn"),
                           stringsAsFactors = FALSE)
  curriculum <- utils::read.csv(
    system.file("extdata", "ru-curriculum.csv", package = "rulearn"),
    stringsAsFactors = FALSE)
  stopifnot(nrow(topic) == 174L, nrow(curriculum) == 40L)
  for (entry in registry()) {
    stopifnot(all(entry$coverage_ids %in% topic$id),
              all(entry$curriculum_ids %in% curriculum$id),
              length(entry$coverage_ids) > 0L,
              length(entry$curriculum_ids) > 0L)
  }
})

pass("registry is immutable to caller and rejects unauthorized metadata", {
  a <- registry()
  a[[1L]]$enabled <- TRUE
  a[[1L]]$qa_status <- "INDEPENDENT_QA_ACCEPTED"
  stopifnot(!valid_registry(a),
            identical(registry()[[1L]]$enabled, FALSE),
            !enabled(ids[[1L]]),
            is.null(family("../other")),
            is.null(family("unknown.family")),
            identical(family(ids[[2L]])$family_id, ids[[2L]]))
  b <- registry()
  b[[3L]]$adapter_ids[["compute"]] <- "system"
  stopifnot(!valid_family(b[[3L]]), !valid_registry(b))
  c <- registry()
  c[[4L]]$operations <- c("pmf", "pmf")
  stopifnot(!valid_family(c[[4L]]), !valid_registry(c))
  d <- registry()
  d[[5L]]$input_schema[["mu"]] <- "arbitrary_function"
  stopifnot(!valid_family(d[[5L]]), !valid_registry(d))
  e <- registry()
  e[[6L]]$model_id <- "untrusted_model"
  stopifnot(!valid_registry(e))
  f <- registry()
  f[[7L]]$qa_status <- c("CANDIDATE", "INDEPENDENT_QA_ACCEPTED")
  stopifnot(!valid_family(f[[7L]]))
})

pass("package-local adapters are fixed and cannot call untrusted functions", {
  stopifnot(is.null(peer("system")), is.null(peer("source")),
            is.null(peer("eval")), is.null(peer("unknown")),
            is.null(peer("print")), is.null(peer(NA_character_)),
            is.null(peer(c("parse", "compute"))))
  for (kind in c("parse", "compute", "teach", "render")) {
    out <- peer(kind)
    stopifnot(is.null(out) || is.function(out))
  }
})

pass("typed inline operands reject unsafe values and incompatible ranges", {
  stopifnot(valid_inputs(list(n = 10L, p = 0.2, k = 2L),
                         "distribution.binomial"),
            valid_inputs(list(values = c(2,4,6,8)),
                         "descriptive.numeric"),
            valid_inputs(list(values = c(7,9,10,12,12),
                              confidence = .95, alternative = "two.sided"),
                         "inference.one_sample_t"),
            !valid_inputs(list(n = -1, p = .2, k = 2L),
                          "distribution.binomial"),
            !valid_inputs(list(n = 10, p = 1.2, k = 2L),
                          "distribution.binomial"),
            !valid_inputs(list(n = 1.5, p = .2, k = 2L),
                          "distribution.binomial"),
            !valid_inputs(list(lambda = 0), "distribution.poisson"),
            !valid_inputs(list(values = c(2, NA_real_)),
                          "descriptive.numeric"),
            !valid_inputs(list(values = data.frame(secret = 1:3)),
                          "descriptive.numeric"),
            !valid_inputs(list(alternative = "one.tailed"),
                          "inference.one_sample_t"),
            !valid_inputs(list(values = rep(1, 20001L)),
                          "inference.one_sample_t"))
})

make_parsed <- function(family_id = "distribution.binomial",
                        status = "SOLVED",
                        reason = "MODEL_RECOGNIZED",
                        question = "Binomial(10, 0.2), P(X=2)",
                        inputs = list(n = 10L, p = .2, k = 2L),
                        outputs = "pmf") {
  list(schema_version = "ru.guided.v1",
       status = status, reason_code = reason,
       original_question = question, family_id = family_id,
       inputs = inputs, requested_outputs = outputs,
       assumptions = list(iid = TRUE, fixed_n = TRUE),
       missing_inputs = character(),
       parser_rule_id = "binomial_named_rule_v1",
       execution_scope = "INLINE_LITERAL_ONLY")
}

pass("typed W4 parse validates family evidence without executing it", {
  p <- make_parsed()
  stopifnot(valid_parsed(p, p$original_question))
  p_bad <- p
  p_bad$inputs$p <- 1.5
  stopifnot(!valid_parsed(p_bad, p_bad$original_question))
  p_bad <- p
  p_bad$original_question <- "A different question"
  stopifnot(!valid_parsed(p_bad, p$original_question))
  p_bad <- p
  p_bad$execution_scope <- "REMOTE_CALL"
  stopifnot(!valid_parsed(p_bad, p$original_question))
  p_bad <- p
  p_bad$inputs <- list(n = quote(system("touch /tmp/unsafe")))
  stopifnot(!valid_parsed(p_bad, p$original_question))
  p_bad <- p
  p_bad$inputs <- list(object = environment())
  stopifnot(!valid_parsed(p_bad, p$original_question))
  p_bad <- p
  p_bad$method_id <- "one_sample_t"
  stopifnot(!valid_parsed(p_bad, p_bad$original_question))
  p_bad <- p
  p_bad$model_id <- "wrong_poisson_model"
  stopifnot(!valid_parsed(p_bad, p_bad$original_question))
  p_bad <- p
  p_bad$requested_outputs <- c("pmf", "p_value")
  stopifnot(!valid_parsed(p_bad, p_bad$original_question))
  p_bad <- p
  p_bad$requested_outputs <- c("pmf", "pmf")
  stopifnot(!valid_parsed(p_bad, p$original_question))
  p_bad <- p
  p_bad$extra_callback <- "foo"
  stopifnot(!valid_parsed(p_bad, p$original_question))
  unset <- make_parsed(family_id = NA_character_, status = "UNSUPPORTED",
                       reason = "SPATIAL_METHOD_NOT_IMPLEMENTED",
                       question = "Compute spatial lag")
  stopifnot(valid_parsed(unset, unset$original_question))
})

pass("qualified W4 answer schema requires complete, nonfabricated outputs", {
  p <- make_parsed()
  ans <- list(schema_version = "ru.w4.answer.v1",
              quantities = data.frame(output_id = "pmf",
                label = "P(X=2)", value = as.double(0.301989888),
                units = "probability", stringsAsFactors = FALSE),
              table = NULL, table_output_id = NA_character_,
              method_note = "IID fixed-probability Bernoulli trials.")
  solved <- c(p[c("schema_version", "status", "reason_code",
                  "original_question", "family_id", "inputs",
                  "requested_outputs", "assumptions", "missing_inputs")],
    list(answer = ans, checks = list(verified = TRUE),
         code_preview = "stats::dbinom(2L, 10L, .2)",
         executed = FALSE, execution_scope = "INLINE_LITERAL_ONLY"))
  stopifnot(valid_answer(ans, p$requested_outputs, p$family_id),
            valid_computed(solved, p))
  bad <- solved
  bad$requested_outputs <- c("pmf", "cdf")
  stopifnot(!valid_computed(bad, p))
  q <- p
  q$requested_outputs <- c("pmf", "cdf")
  stopifnot(!valid_computed(solved, q),
            !valid_answer(ans, q$requested_outputs, q$family_id))
  q <- p
  q$requested_outputs <- "pmf"
  ans_bad <- ans
  ans_bad$quantities$output_id <- "invented_extra"
  stopifnot(!valid_answer(ans_bad, q$requested_outputs, q$family_id))
  ans_bad <- ans
  ans_bad$quantities$value <- 1L
  stopifnot(!valid_answer(ans_bad, q$requested_outputs, q$family_id))
  ans_bad <- ans
  ans_bad$table <- data.frame(description = "private data")
  ans_bad$table_output_id <- "pmf"
  stopifnot(!valid_answer(ans_bad, q$requested_outputs, q$family_id))
  bad <- solved
  bad$checks$verified <- FALSE
  stopifnot(!valid_computed(bad, p))
  bad <- solved
  bad$executed <- TRUE
  stopifnot(!valid_computed(bad, p))
  bad <- solved
  bad$code_preview <- ""
  stopifnot(!valid_computed(bad, p))
  bad <- solved
  bad$answer <- list()
  stopifnot(!valid_computed(bad, p))
})

pass("candidate dispatch refuses SOLVED without A2/A3/A4 qualification", {
  p <- make_parsed()
  z <- dispatch_parsed(p, p$original_question)
  stopifnot(identical(z$status, "UNSUPPORTED"),
            identical(z$reason_code, "FAMILY_NOT_QUALIFIED"),
            identical(z$family_id, "distribution.binomial"),
            identical(z$executed, FALSE),
            identical(z$code_preview, ""),
            is.list(z$answer), length(z$answer) == 0L,
            identical(z$checks$verified, FALSE))
  x <- make_parsed("distribution.unknown")
  a <- dispatch_parsed(x, x$original_question)
  stopifnot(identical(a$status, "UNSUPPORTED"),
            identical(a$reason_code, "FAMILY_NOT_REGISTERED"))
  x <- make_parsed()
  x$inputs$p <- NA_real_
  a <- dispatch_parsed(x, x$original_question)
  stopifnot(identical(a$status, "INVALID"),
            identical(a$reason_code, "W4_PARSED_SCHEMA_INVALID"))
})

pass("typed negative and incomplete W4 states preserve reason and never solve", {
  for (status in c("NEEDS_INPUT", "UNSUPPORTED", "INVALID",
                   "GUIDED_REFERENCE")) {
    p <- make_parsed(status = status,
                     reason = paste0("EXPLICIT_", status))
    z <- dispatch_parsed(p, p$original_question)
    stopifnot(identical(z$status, status),
              identical(z$reason_code, p$reason_code),
              identical(z$code_preview, ""), identical(z$executed, FALSE),
              identical(z$answer, list()))
  }
})

pass("installed package without A3 routes W3 dice and concept questions exactly", {
  stopifnot(is.null(dispatch("PMF of the sum of a d6 and d4")))
  q <- "Find PMF CDF expected value and variance for the sum of a d6 and d4."
  ans <- ru_solve(q, open = FALSE)
  stopifnot(inherits(ans, "ru_solution"),
            identical(ans$schema_version, "ru.guided.v1"),
            identical(ans$status, "SOLVED"),
            identical(ans$family_id, "dice_sum_independent_fair"),
            identical(ans$answer$total_outcomes, 24L),
            identical(ans$answer$pmf$count,
                      as.integer(c(1,2,3,4,4,4,3,2,1))),
            isTRUE(all.equal(ans$answer$expected_value, 6)),
            isTRUE(all.equal(ans$answer$variance, 25/6)),
            identical(ans$code_status, "NOT_EXECUTED"),
            identical(ans$executed, FALSE), identical(ans$opened, FALSE),
            identical(ans$capability_status, "NOT_REQUESTED"))
  for (q in c("PMF", "CDF")) {
    z <- ru_solve(q, open = FALSE)
    stopifnot(identical(z$status, "GUIDED_REFERENCE"),
              identical(z$executed, FALSE),
              identical(z$opened, FALSE))
  }
  for (ab in list(c(4,8), c(6,6))) {
    q <- sprintf("PMF, expectation and variance of sum of d%d and d%d.",
                 ab[1], ab[2])
    z <- ru_solve(q, open = FALSE)
    stopifnot(identical(z$status, "SOLVED"),
              identical(z$answer$total_outcomes,
                        as.integer(prod(ab))))
  }
})

pass("W3 refusal gate preserves known false-positive challenges", {
  questions <- c(
    "PMF of sum of two six-sided dice and one four-sided die",
    "PMF of one six-sided die and two four-sided dice",
    "PMF of d6 and d4 plus a coin toss",
    "PMF of d6 and d4 shifted by 2",
    "PMF of d6 and d4 and one extra spinner",
    "PMF of two dependent dice",
    "Probability model for two biased six-sided dice",
    "What is the sample variance of an unfair die plus a d4?")
  for (q in questions) {
    z <- ru_solve(q, open = FALSE)
    stopifnot(!identical(z$status, "SOLVED"),
              identical(z$executed, FALSE),
              identical(z$code_preview, ""),
              identical(z$opened, FALSE))
  }
  # The A3 W4 parser will repair these current W3 misleading refusal
  # diagnostics. A1 must not falsely reclassify either as solved.
  for (q in c("Uniform U(2,8), P(3<X<5)",
              "Permutation test A=[1,2], B=[3,4]")) {
    z <- ru_solve(q, open = FALSE)
    stopifnot(!identical(z$status, "SOLVED"),
              identical(z$executed, FALSE))
  }
})

pass("original public search, filters, structure and ordinary invalid inputs", {
  for (q in c("PMF", "CDF", "linear regression", "one sample t test")) {
    got <- withVisible(ru_find(q))
    stopifnot(is.data.frame(got$value), !got$visible,
              all(c("id", "type") %in% names(got$value)))
  }
  filt <- withVisible(ru_find("PMF", n = 1L, type = "concept"))
  stopifnot(is.data.frame(filt$value), !filt$visible,
            nrow(filt$value) <= 1L,
            all(filt$value$type == "concept"))
  for (x in list(NA_character_, "", "   ", 1, character(), c("a","b"))) {
    got <- ru_solve(x, open = FALSE)
    stopifnot(identical(got$status, "INVALID"),
              identical(got$executed, FALSE),
              identical(got$code_status, "NOT_EXECUTED"))
  }
  stopifnot(identical(ru_solve(strrep("x", 4097), open = FALSE)$reason_code,
                      "QUESTION_TOO_LONG"),
            inherits(try(ru_solve("PMF", open = NA), silent = TRUE),
                     "try-error"))
})

pass("installed assets, reference preservation and no new dependencies", {
  root <- system.file("lessons", package = "rulearn")
  stopifnot(nzchar(root),
            length(list.files(root, pattern = "[.]md$")) == 84L,
            nzchar(system.file("extdata", "coverage.csv",
                               package = "rulearn")),
            nzchar(system.file("extdata", "ru-curriculum.csv",
                               package = "rulearn")),
            nzchar(system.file("www", "ru-w3-copy.js",
                               package = "rulearn")),
            length(getNamespaceExports("rulearn")) == 33L,
            is.null(dispatch("Completely unrelated question")),
            all(!vapply(registry(), function(x) x$enabled, logical(1L))))
})
cat("W4_A1_REGISTRY_AND_W3_COMPATIBILITY_PASS ",checked," groups\n",sep="")