# W4 candidate-family instruction from an authenticated, validated A3 computation.
# This module never computes a statistic, evaluates a preview, or interprets
# executable content from a student's question.
.ru_w4_teach <- function(computed) {
  statuses <- c("SOLVED", "GUIDED_REFERENCE", "NEEDS_INPUT",
                "UNSUPPORTED", "INVALID")
  scalar <- function(x) is.character(x) && length(x) == 1L &&
    !is.na(x) && validUTF8(x)
  if (!is.list(computed) || !identical(computed$schema_version, "ru.guided.v1") ||
      !scalar(computed$status) || !(computed$status %in% statuses) ||
      !identical(computed$executed, FALSE)) {
    stop("Expected a validated, unexecuted ru.guided.v1 computation",
         call. = FALSE)
  }
  question <- if (scalar(computed$original_question)) computed$original_question else ""
  family <- if (scalar(computed$family_id)) computed$family_id else ""
  reason <- if (scalar(computed$reason_code)) computed$reason_code else ""
  outs <- computed$requested_outputs
  if (!is.character(outs) || anyNA(outs)) outs <- character()
  inputs <- if (is.list(computed$inputs)) computed$inputs else list()
  fmt <- function(x) format(as.double(x), digits = 16L,
                            scientific = FALSE, trim = TRUE)
  shown <- function(x) {
    if (is.numeric(x) && length(x) == 1L && is.finite(x))
      return(fmt(x))
    if (is.character(x) && length(x) == 1L && !is.na(x))
      return(x)
    "not supplied"
  }
  quantity_name <- function(id) gsub("_", " ", id, fixed = TRUE)
  family_names <- c(
    "descriptive.numeric" = "Describing observed numerical values",
    "probability.event_scalar" = "Combining event probabilities",
    "distribution.binomial" = "Fixed-trial binomial counts",
    "distribution.poisson" = "Poisson counts over an exposure interval",
    "distribution.normal" = "Continuous normal probabilities",
    "distribution.uniform_continuous" = "Continuous uniform probabilities",
    "inference.one_sample_t" = "Inference for one population mean",
    "regression.simple_ols" = "Simple least-squares regression"
  )
  assumptions_to_text <- function(x) {
    if (!is.list(x) || !length(x))
      return("No model-specific assumption was supplied; do not infer validity from an absent assumption.")
    statements <- character()
    for (key in names(x)) {
      value <- x[[key]]
      if (is.character(value) && length(value) == 1L && !is.na(value)) {
        statements <- c(statements, paste0("Question/model declaration (",
                             quantity_name(key), "): ", value))
      } else if (is.logical(value) && length(value) == 1L && !is.na(value)) {
        statements <- c(statements, paste0("Question/model declaration (",
          quantity_name(key), "): ", if (value) "asserted" else "not established", "."))
      }
    }
    c(statements,
      "An assumption stated in the question is not evidence that the real-world data satisfy it.")
  }
  check_sentences <- function(x) {
    if (!is.list(x) || !length(x)) return(character())
    result <- character()
    for (key in names(x)) {
      value <- x[[key]]
      if (is.logical(value) && length(value) == 1L && !is.na(value))
        result <- c(result, paste0("A3 computational check '", key,
                                   "' ", if (value) "passed." else "failed."))
    }
    result
  }
  lesson <- list(
    schema_version = "ru.guided.v1",
    status = computed$status,
    reason_code = reason,
    title = if (family %in% names(family_names)) unname(family_names[[family]])
            else "Guided statistical question",
    question = question,
    requested_outputs = outs,
    explanation_sections = character(),
    step_by_step = character(),
    runnable_code = "",
    expected_output = character(),
    checks = character(),
    interpretations = character(),
    change_this = character(),
    hints = list(H0 = "", H1 = "", H2 = "", H3 = ""),
    transfer_question = "",
    links = character(),
    assumptions = assumptions_to_text(computed$assumptions)
  )

  # A non-SOLVED computation is a methodological boundary, not a licence to
  # create example values or a runnable program with invented observations.
  if (!identical(computed$status, "SOLVED")) {
    missing <- if (is.character(computed$missing_inputs) &&
                   !anyNA(computed$missing_inputs))
      computed$missing_inputs else character()
    guidance <- switch(family,
      "descriptive.numeric" = c(
        "Provide the actual numerical observations, not merely a column name.",
        "Specify sample or population variance when its denominator matters; identify how missing observations should be handled.",
        "A mean describes the supplied values; it does not itself estimate an uncertainty interval."),
      "probability.event_scalar" = c(
        "Specify the relevant P(A), P(B), and/or P(A intersection B) as requested.",
        "A conditional probability requires a nonzero conditioning-event probability.",
        "Union cannot be found by adding P(A) and P(B) without correcting their overlap unless exclusivity is established."),
      "distribution.binomial" = c(
        "Specify the fixed number of trials and one common success probability.",
        "Check independence, identical success probability and the count-of-successes outcome before using binomial formulas.",
        "Provide an exact event threshold if requesting an event probability."),
      "distribution.poisson" = c(
        "Supply the expected count lambda for the same exposure interval as the question.",
        "Distinguish counts per interval from waiting times and from a binomial fixed-trial experiment.",
        "Specify which event or moment is requested."),
      "distribution.normal" = c(
        "State that the normal distribution is a model; supply its mean mu and positive standard deviation sigma.",
        "A normal model for individual values is different from a sampling distribution or a hypothesis test.",
        "Specify the event threshold, interval bounds or quantile probability."),
      "distribution.uniform_continuous" = c(
        "Give ordered support bounds a and b and confirm the variable is continuous.",
        "The continuous uniform model is different from equally likely discrete integers.",
        "Specify the event, or request expectation or variance directly."),
      "inference.one_sample_t" = c(
        "Supply the actual sample, the target population mean or confidence level, and the intended test/interval.",
        "State the independence and approximate-normality/design assumptions and whether the population SD is unknown.",
        "A t calculation cannot independently verify sampling design, randomization or normality."),
      "regression.simple_ols" = c(
        "Provide corresponding, finite numerical x and y observations with variation in x.",
        "Specify the desired coefficients, fit description or prediction point.",
        "Simple OLS with an intercept does not prove causality or automatically validate residual and sampling assumptions."),
      c("Identify the required method and data before seeking a numerical result.",
        "This W4 adapter does not claim a verified computation for the requested family.")
    )
    lesson$explanation_sections <- c(
      paste0("Status ", computed$status, "; reason ",
             if (nzchar(reason)) reason else "NOT_SPECIFIED", "."),
      "No validated numerical result is available. RU has not supplied missing values, invented a model or executed R.",
      guidance
    )
    lesson$step_by_step <- c(
      "Identify the outcome, parameter or estimand requested by the question.",
      "Separate stated facts and assumptions from unavailable data or unverified design conditions.",
      "Use the required inputs and a compatible verified method before requesting computation."
    )
    lesson$change_this <- if (length(missing))
      paste0("Provide or clarify: ", paste(gsub("_", " ", missing, fixed = TRUE),
                                            collapse = ", "), ".")
      else "Clarify the model, data, parameters or method incompatibility named in the reason code."
    lesson$hints <- list(
      H0 = "Name the statistical quantity first; a method name alone is not a numerical dataset.",
      H1 = guidance[[1L]],
      H2 = if (length(missing))
        paste0("Check the required field(s): ", paste(missing, collapse = ", "),
               "; do not substitute arbitrary defaults.")
        else guidance[[min(2L, length(guidance))]],
      H3 = paste0("Write a short table: requested quantity; provided data; missing data; model assumptions; ",
                  "compatible method. Explain what would justify each entry before writing executable R.")
    )
    lesson$transfer_question <- paste(
      "Describe a related question in this domain with the necessary information supplied.",
      "Explain why the previously missing input or model condition matters.")
    lesson$links <- c(paste0("ru_find('", if (family %in% names(family_names))
                        quantity_name(family) else "method selection", "')"))
    lesson$checks <- "No numerical computation was accepted as SOLVED."
    return(lesson)
  }

  if (!(family %in% names(family_names)))
    stop("Unknown SOLVED W4 teaching family", call. = FALSE)
  if (!is.list(computed$answer) ||
      !identical(computed$answer$schema_version, "ru.w4.answer.v1") ||
      !is.data.frame(computed$answer$quantities) ||
      !identical(names(computed$answer$quantities),
                 c("output_id", "label", "value", "units")) ||
      !is.character(computed$answer$quantities$output_id) ||
      !is.character(computed$answer$quantities$label) ||
      !is.double(computed$answer$quantities$value) ||
      !is.character(computed$answer$quantities$units) ||
      anyNA(computed$answer$quantities) ||
      !all(is.finite(computed$answer$quantities$value)) ||
      !identical(computed$answer$quantities$output_id, outs) ||
      !scalar(computed$answer$method_note) ||
      !(is.null(computed$answer$table) ||
        (is.data.frame(computed$answer$table) &&
         all(vapply(computed$answer$table, function(col)
           if (is.numeric(col)) all(is.finite(col)) else
             is.character(col) && !anyNA(col), logical(1L))))) ||
      !scalar(computed$code_preview) || !nzchar(computed$code_preview) ||
      !is.list(computed$checks) || !identical(computed$checks$verified, TRUE)) {
    stop("SOLVED teaching requires a validated A3 ru.w4.answer.v1 result and preview",
         call. = FALSE)
  }
  if (exists(".ru_w4_family", mode = "function", inherits = TRUE)) {
    registry <- .ru_w4_family(family)
    if (!is.list(registry) || !identical(computed$method_id, registry$method_id) ||
        !identical(computed$model_id, registry$model_id))
      stop("Teaching family/method/model contract mismatch", call. = FALSE)
  }
  named_inputs <- function(keys) {
    vals <- keys[keys %in% names(inputs)]
    if (!length(vals)) return(character())
    vapply(vals, function(key) paste0(key, " = ", shown(inputs[[key]])),
           character(1L), USE.NAMES = FALSE)
  }
  event_description <- function() {
    ev <- inputs$event
    if (!is.list(ev) || !scalar(ev$type)) return("")
    tp <- ev$type
    if (identical(tp, "interval")) return(paste0(
      "Interval event supplied with lower = ", shown(ev$lower),
      " and upper = ", shown(ev$upper), "."))
    if (identical(tp, "quantile")) return(paste0(
      "Quantile requested at cumulative probability ", shown(ev$probability), "."))
    paste0("Event type '", tp, "' uses the supplied k = ", shown(ev$k),
           ". For integer counts, strict and inclusive inequalities differ by one count.")
  }
  item <- switch(family,
    "descriptive.numeric" = list(
      meaning = c(
        "Descriptive statistics summarize the observed values; they do not automatically make population-level inference.",
        "The arithmetic mean averages observations; the median describes the middle of the ordered values.",
        "Sample variance and sample SD use an n - 1 denominator for a sample-based dispersion calculation. Population variance and SD use n for the fully specified population values.",
        "Quantile estimates in the preview use R's stated type-7 interpolation rule; other conventions can yield different quantiles."
      ),
      steps = c(
        "Use the actual numeric vector named values from the code preview; do not substitute a column name without providing its observations.",
        "Read length(values) as the number of observations and mean(values) as their arithmetic average.",
        "Use stats::median(values) if requested; stats::var(values) and stats::sd(values) implement the sample convention.",
        "For a declared population variance use mean((values - mean(values))^2), and take the square root only when population SD is requested.",
        "For quantiles, stats::quantile(values, probs = ..., type = 7) uses the supplied quantile probability.",
        "Report only the requested A3 quantity rows, and distinguish the sample/population convention when interpreting variability."
      ),
      edit = c("values: replace the literal entries with your own observed numeric values.",
        "convention: choose sample or population before comparing variance or SD; the displayed code uses the appropriate formula.",
        "If a quantile is requested, change the quantile probability in the preview and rerun all lines locally."),
      hints = list(
        H0 = "Start by asking whether you want a centre, a spread or a percentile of the recorded numbers.",
        H1 = "Identify the observed values and decide whether they represent a sample or the full population under the question.",
        H2 = "Use mean(), stats::median(), stats::var(), stats::sd(), or stats::quantile(type = 7) only for the requested output IDs.",
        H3 = "Enter the validated values vector, call mean(values), and if sample spread is requested use stats::var(values) or stats::sd(values). For population spread, use mean((values - mean(values))^2). Compare those distinct denominators."),
      transfer = "Add a new observed numerical value, then calculate and interpret both sample and population variance. Explain why denominators differ and show your R commands.",
      links = c("ru_find('mean')", "ru_find('sample variance')", "ru_find('quantile')")
    ),
    "probability.event_scalar" = list(
      meaning = c(
        "P(A) refers to the chance that event A occurs; P(A intersection B) refers to both events occurring.",
        "P(A or B) uses inclusion-exclusion so the overlap is not counted twice.",
        "P(A given B) conditions on event B and divides their joint probability by P(B), which must be positive.",
        "P(not A) is the complement of A. These are mathematical event probabilities, not estimates from an undisclosed dataset."
      ),
      steps = c(
        "Identify which probabilities p_a, p_b and p_intersection the question actually supplied.",
        "For union use p_a + p_b - p_intersection, rather than assuming the events are disjoint.",
        "For conditional probability, require p_b > 0 and use p_intersection / p_b.",
        "For complement use 1 - p_a. Apply only the operations actually requested.",
        "Read the verified A3 quantity row and check that event probabilities remain between zero and one."
      ),
      edit = c("p_a and p_b: edit only the supplied marginal event probabilities.",
        "p_intersection: update the joint probability when union or conditioning requires it.",
        "Do not replace an unknown intersection with zero unless mutually exclusive events are stated."),
      hints = list(
        H0 = "Ask whether the event means 'or', 'both', 'given' or 'not'.",
        H1 = "Check which marginal and joint event probabilities were supplied; conditioning needs a nonzero denominator.",
        H2 = "Use p_a + p_b - p_intersection for union, p_intersection / p_b for conditioning, or 1 - p_a for complement.",
        H3 = "Write the named R assignments from the preview. Select only the expression matching the requested event, then compare w4_result with the probability axioms and explain the role of any overlap."),
      transfer = "Change one supplied marginal or joint event probability to another consistent set; recalculate a different event operation and explain the compatibility conditions.",
      links = c("ru_find('probability union')", "ru_find('conditional probability')")
    ),
    "distribution.binomial" = list(
      meaning = c(
        "A binomial random variable counts successes in a fixed number n of trials, each with the same success probability p.",
        "Independent Bernoulli trials and the count response are model requirements, not properties inferred from the question's labels.",
        "An exact event uses stats::dbinom(); a cumulative or upper-tail event uses stats::pbinom() with the correct inequality.",
        "The binomial expectation and variance are model quantities, not a sample mean or sample variance."
      ),
      steps = c(
        "Identify the fixed trial count n and constant success probability p in the code.",
        "Confirm whether the event describes an exact count, at-most, strictly-below, at-least or above-threshold count.",
        "For an exact count use stats::dbinom(k, n, p); for cumulative counts use stats::pbinom() with the threshold adjusted for strict inequalities.",
        "For an at-least count, the complement excludes counts below k; for strictly above k, exclude counts at or below k.",
        "For requested moments, use the n * p and n * p * (1 - p) expressions in the preview.",
        "Read the requested verified A3 output rows; do not misinterpret a count mean as a probability."
      ),
      edit = c("n: number of independent trials, not the number of observed successes.",
        "p: the common success probability per trial, not a p-value from a hypothesis test.",
        "k: event threshold only when a count probability was requested. Change it together with the event inequality."),
      hints = list(
        H0 = "The random variable counts how many of n trials succeed.",
        H1 = "Decide whether the question asks for a probability at a count, a tail, or the distribution's moments.",
        H2 = "Use stats::dbinom(k,n,p) for an exact count or stats::pbinom() for a cumulative/tail event; moments use n*p and n*p*(1-p).",
        H3 = "Copy the validated n and p assignments, set k only if an event was requested, and select the dbinom/pbinom call shown in w4_values. Check the inequality boundary before reading the A3 probability."),
      transfer = "With a different fixed n or p, calculate both a strict-tail and inclusive-tail probability for a chosen count; explain the difference and test your R code.",
      links = c("ru_find('binomial')", "ru_find('probability distribution')")
    ),
    "distribution.poisson" = list(
      meaning = c(
        "A Poisson random variable models the number of events in a specified exposure interval using mean count lambda.",
        "The stated lambda applies only to its specified time, space or exposure; changing exposure requires a justified rate conversion.",
        "An exact count uses stats::dpois(); cumulative or upper-tail count events use stats::ppois() with careful integer boundaries.",
        "Under the Poisson model the expected count and population distribution variance both equal lambda; this is not an observed sample variance."
      ),
      steps = c(
        "Identify lambda, the expected count over the exact exposure interval in the question.",
        "Determine whether the request is an exact count, cumulative count, upper-tail count or model moment.",
        "Use stats::dpois(k, lambda) for an exact count or stats::ppois() for cumulative probabilities and strict/inclusive tails.",
        "For model expectation or variance, the preview uses lambda directly.",
        "Check the interpretation of the exposure and never substitute an exponential waiting-time model for a count event."
      ),
      edit = c("lambda: the mean count for the chosen exposure, not necessarily an unscaled rate per different period.",
        "k: the nonnegative integer event threshold when an event is requested.",
        "Update exposure assumptions before changing lambda; do not change the problem from counts to waiting time."),
      hints = list(
        H0 = "Start with the number of arrivals in a fixed interval, not the waiting time between arrivals.",
        H1 = "Match the supplied mean count to the requested exposure and identify the event boundary.",
        H2 = "Use stats::dpois() for a particular count, stats::ppois() for a cumulative/tail count, and lambda for model moments.",
        H3 = "Set lambda from the question, use k if an event was supplied, run the corresponding dpois/ppois expression in the preview, and explain why its probability refers to the stated exposure."),
      transfer = "Choose another exposure interval with a justified mean count and compute an inclusive upper-tail probability; show how you kept the units consistent.",
      links = c("ru_find('poisson')", "ru_find('rate and exposure')")
    ),
    "distribution.normal" = list(
      meaning = c(
        "The continuous normal model is specified by population/model mean mu and positive standard deviation sigma.",
        "A normal CDF is a probability at or below a threshold; an interval probability subtracts two CDF values.",
        "The preview uses stats::pnorm() for probabilities and stats::qnorm() for an inverse CDF quantile.",
        "The model variance is sigma^2. Sigma is the model SD, not automatically the standard error of a sample mean.",
        "Normal model probabilities are conditional on the stated model; they do not test normality or establish that observations follow it."
      ),
      steps = c(
        "Read mu as the stated normal model centre and sigma as its strictly positive model SD.",
        "Inspect the exact event: a threshold, an interval, or a cumulative quantile probability.",
        "For probability use stats::pnorm(); for an interval subtract the lower CDF from the upper CDF.",
        "For a quantile use stats::qnorm(quantile_p, mu, sigma), as shown in the preview.",
        "For moments the preview uses mu and sigma^2; interpret those as model-level quantities.",
        "Keep the probability model for individual values distinct from a sampling distribution for means."
      ),
      edit = c("mu: the model mean; sigma: the model standard deviation, not a sample standard error.",
        "k or lower/upper: an event threshold or interval bounds; quantile_p: a cumulative probability if an inverse quantile was requested.",
        "Rerun the selected pnorm() or qnorm() expression only after updating both parameters and the event."),
      hints = list(
        H0 = "Think of a continuous bell-shaped model, not separate equally likely integer outcomes.",
        H1 = "Locate the model centre mu and spread sigma, then decide whether you seek an area or a quantile.",
        H2 = "Use stats::pnorm() for cumulative/interval probability and stats::qnorm() for an inverse probability; moments use mu or sigma^2.",
        H3 = "Set mu and sigma in the preview, check whether the event supplies k, lower/upper or quantile_p, then run the fixed pnorm/qnorm expression and interpret a model probability rather than an observed fraction."),
      transfer = "Choose a different normal-model mean or SD and compare two cumulative probabilities using R. Explain why changing SD alters spread without proving a real population is normal.",
      links = c("ru_find('normal distribution')", "ru_find('normal between')")
    ),
    "distribution.uniform_continuous" = list(
      meaning = c(
        "A continuous uniform random variable has constant density on the interval from a to b, with b strictly greater than a.",
        "The model describes a continuum of values rather than equally likely integers.",
        "Interval probability is the difference of stats::punif() values at the two boundaries; an endpoint has zero point probability in the continuous model.",
        "Expectation is the midpoint (a + b) / 2; the model variance is (b - a)^2 / 12, not a sample variance.",
        "A strict inequality such as lower < X < upper is legitimate probability notation, not an instruction to evaluate code."
      ),
      steps = c(
        "Read a and b from the preview as the support bounds of the continuous model.",
        "Identify whether the request is an interval, a cumulative event, an upper tail or a model moment.",
        "For an interval, use stats::punif(upper, a, b) - stats::punif(lower, a, b).",
        "For a cumulative threshold use stats::punif(k, a, b); for a requested upper tail use its complement.",
        "For the model mean or variance use (a + b) / 2 or (b - a)^2 / 12 as shown in the preview.",
        "Interpret the output as an area probability or theoretical model moment, not a count of observations."
      ),
      edit = c("a and b: the ordered continuous support bounds, with b strictly greater than a.",
        "lower/upper or k: event boundaries, which can lie outside the support without implying a different model.",
        "Changing support endpoints alters the model; recalculate by running the preview locally."),
      hints = list(
        H0 = "A continuous uniform model assigns equal density, not positive mass, to each individual point.",
        H1 = "Sketch a to b and mark the event region, taking care to distinguish support bounds from event bounds.",
        H2 = "Use stats::punif() at the event boundaries and subtract cumulative probabilities for an interval.",
        H3 = "Set a and b, then lower and upper for an interval. Evaluate stats::punif(upper,a,b)-stats::punif(lower,a,b) and verify that it refers to the supplied support, not to a discrete number of points."),
      transfer = "Change the support bounds and choose an interval partly outside the new support; compute its probability using the CDF and explain why the answer stays between zero and one.",
      links = c("ru_find('uniform interval')", "ru_find('continuous probability')")
    ),
    "inference.one_sample_t" = list(
      meaning = c(
        "A one-sample Student t procedure estimates or tests a population mean using one numerical sample with unknown population SD.",
        "The test uses sample SD and standard error sd(values) / sqrt(length(values)); it does not use population variance as if it were known.",
        "A p-value measures how extreme a test statistic would be under the null model and its assumptions; it is not the probability that the null hypothesis is true.",
        "A confidence interval is a range generated by a repeated-sampling procedure with nominal coverage under assumptions; it does not assign a posterior probability to a fixed population mean.",
        "Declared independence and approximate normality are not externally verified; clustered/paired designs or strongly inappropriate distributions need different methods."
      ),
      steps = c(
        "Read the actual sample vector values, its independence/design declaration and approximate-normality assumption.",
        "If testing, identify the null population mean mu0 and the predeclared alternative direction.",
        "Use mean(values), stats::sd(values) and sqrt(length(values)) to obtain the standardized t-statistic.",
        "Under a t test, use the stated one-sided or two-sided stats::pt() tail with degrees of freedom length(values)-1.",
        "For a confidence interval, use the supplied confidence_level and stats::qt() critical value with the sample standard error.",
        "Interpret the actual A3 p_value or ci_lower/ci_upper without treating them as proof of an effect or a probability for the fixed mean."
      ),
      edit = c("values: the independent numeric observations from the question.",
        "mu0 and alternative: null mean and prespecified test direction, only for test mode.",
        "confidence_level: a nominal repeated-sampling coverage level, only for interval mode.",
        "Changing design or dependence requires reconsidering the method, not just editing the numeric values."),
      hints = list(
        H0 = "Start with the parameter: the unknown population mean, not each individual's outcome.",
        H1 = "Decide whether you are testing a null mean or constructing a confidence interval and identify the sample design.",
        H2 = "For a test use stats::sd(), length() and stats::pt(); for an interval use stats::sd() and stats::qt().",
        H3 = "Enter the supplied values in R. For a test, compute w4_t from mean(values), mu0 and stats::sd(values)/sqrt(length(values)), then use stats::pt() with the specified alternative. For an interval, use the qt() critical value times the same standard error. Compare with A3's checked quantities."),
      transfer = "Use a different independent sample and another prespecified null mean or confidence level. Explain the design assumptions, compute the test/interval in R and interpret the result without saying that a p-value is P(H0).",
      links = c("ru_find('one sample t')", "ru_find('confidence interval')")
    ),
    "regression.simple_ols" = list(
      meaning = c(
        "Simple ordinary least squares fits a straight line with an intercept to paired numerical predictor x and response y values.",
        "The slope describes the fitted change in response per one-unit predictor change; the intercept is the fitted response at x = 0, which may be outside the observed range.",
        "R-squared describes the proportion of observed response variation represented by the fitted line in this sample. It is not a causal measure or proof of a correct model.",
        "stats::lm(y ~ x) fits the coefficients; summary(fit)$r.squared reports in-sample fit; stats::predict() at prediction_x produces a fitted mean point, not an uncertainty or prediction interval.",
        "The checked coefficients and residual arithmetic do not verify independence, linearity, homoscedasticity, error normality or the sampling design."
      ),
      steps = c(
        "Pair each observed x value with the y from the same record; do not reorder one vector alone.",
        "Check that x varies and the model includes an intercept as specified.",
        "Use fit <- stats::lm(y ~ x) to estimate the least-squares straight line.",
        "Read stats::coef(fit) for the intercept and slope; use summary(fit)$r.squared only when requested.",
        "If prediction_x was supplied, use stats::predict(fit, newdata = data.frame(x = prediction_x)) for its fitted response.",
        "Interpret the fitted association in its observational context and inspect model/design assumptions before any inferential or causal claim."
      ),
      edit = c("x and y: replace both literal vectors with aligned observations, preserving record pairing.",
        "prediction_x: the predictor value for a fitted-mean point prediction when requested.",
        "Do not replace y ~ x with a different model without validating design, diagnostics and the intended estimand."),
      hints = list(
        H0 = "Regression relates a numerical predictor to a numerical response; the output is not a probability distribution.",
        H1 = "Keep each x/y pair together and identify whether you need slope, intercept, R-squared or a fitted value.",
        H2 = "Use stats::lm(y ~ x), stats::coef(fit), summary(fit)$r.squared or stats::predict() according to the requested outputs.",
        H3 = "Enter the validated paired x and y vectors, run fit <- stats::lm(y ~ x), and inspect stats::coef(fit). For R-squared use summary(fit)$r.squared; for a requested fitted value set prediction_x and use stats::predict(fit,newdata=data.frame(x=prediction_x)). Do not infer causation."),
      transfer = "Change one matched x/y observation in a new dataset, fit a new simple OLS line, and compare slope and R-squared. Explain why this cannot by itself identify a causal effect.",
      links = c("ru_find('linear regression')", "ru_find('regression diagnostics')")
    )
  )

  lesson$explanation_sections <- c(
    paste0("Requested verified output(s): ",
           paste(vapply(outs, quantity_name, character(1L)), collapse = ", "), "."),
    paste0("Selected deterministic method: ", shown(computed$method_id),
           "; candidate model: ", shown(computed$model_id),
           ". These names identify the computation, not independently verified data-generating assumptions."),
    item$meaning
  )
  inputs_used <- switch(family,
    "descriptive.numeric" = c("convention", "quantile_probability"),
    "probability.event_scalar" = c("p_a", "p_b", "p_intersection"),
    "distribution.binomial" = c("n", "p"),
    "distribution.poisson" = "lambda",
    "distribution.normal" = c("mu", "sigma"),
    "distribution.uniform_continuous" = c("a", "b"),
    "inference.one_sample_t" = c("mode", "mu0", "alternative", "confidence_level"),
    "regression.simple_ols" = "prediction_x"
  )
  inputs_summary <- named_inputs(inputs_used)
  if (length(inputs_summary))
    lesson$explanation_sections <- c(lesson$explanation_sections,
                                    paste("Stated input(s):", paste(inputs_summary, collapse = "; "), "."))
  if (family %in% c("distribution.binomial", "distribution.poisson",
                    "distribution.normal", "distribution.uniform_continuous")) {
    event <- event_description()
    if (nzchar(event)) lesson$explanation_sections <- c(lesson$explanation_sections, event)
  }
  if (identical(family, "descriptive.numeric")) {
    lesson$explanation_sections <- c(lesson$explanation_sections,
      "The preview's values vector contains the observations supplied in the question. No external dataset was read.")
  }
  if (identical(family, "inference.one_sample_t")) {
    lesson$explanation_sections <- c(lesson$explanation_sections,
      paste0("The question selects ", shown(inputs$mode),
             " mode. Its stated sampling assumptions must be assessed before generalizing to a population."))
  }
  if (identical(family, "regression.simple_ols"))
    lesson$explanation_sections <- c(lesson$explanation_sections,
      "The fitted response is conditional on the provided predictor values; model assumptions and causal identification were not empirically tested.")

  quantity_explanation <- function(id) switch(id,
    mean = "The mean is an arithmetic average of the supplied values.",
    median = "The median is the central ordered observation, or midpoint of the two central observations.",
    sample_variance = "Sample variance uses deviations squared with n - 1 in the denominator.",
    population_variance = "Population variance uses deviations squared with n in the denominator.",
    sample_sd = "Sample SD is the square root of sample variance, in the observation's original units.",
    population_sd = "Population SD is the square root of population variance, in the observation's original units.",
    quantile = "A quantile is a position on the model or sorted sample scale, not generally a probability.",
    complement = "A complement is the probability that event A does not occur.",
    union = "A union is the probability of A or B; account for the shared intersection.",
    conditional = "Conditioning divides the joint probability by the probability of the conditioning event.",
    probability = "The probability refers to the exact validated event and model, not to an empirical frequency from unprovided data.",
    expected_value = "Expectation is the theoretical mean of the stated random-variable model.",
    variance = "The model variance describes theoretical squared spread, not sample variance computed from observations.",
    t_statistic = "The signed t statistic compares the sample mean with the null mean in standard-error units.",
    degrees_freedom = "Degrees of freedom govern which Student t distribution the procedure uses.",
    p_value = "The p-value is a model-based tail probability conditional on the null hypothesis, not P(H0).",
    ci_lower = "The lower confidence endpoint belongs to a repeated-sampling confidence interval for the population mean.",
    ci_upper = "The upper confidence endpoint belongs to that same confidence interval; it is not a posterior bound.",
    intercept = "The intercept is the fitted response where x equals zero, possibly outside observed x.",
    slope = "The slope is the estimated response change per unit of x in the fitted line.",
    r_squared = "R-squared describes in-sample fit, not causation or independent predictive validity.",
    prediction = "A fitted predicted response is not a full prediction interval or a causal effect.",
    paste0("Output '", id, "' is reported exactly as computed by A3.")
  )
  lesson$explanation_sections <- c(
    lesson$explanation_sections,
    vapply(outs, quantity_explanation, character(1L), USE.NAMES = FALSE)
  )
  lesson$step_by_step <- item$steps
  lesson$runnable_code <- computed$code_preview
  # No calculated numbers are recreated by the pedagogy. A4 receives the
  # original typed A3 answer, including the optional verified result table.
  lesson$expected_output <- list(
    answer = computed$answer,
    requested_outputs = computed$requested_outputs,
    summary_lines = character()
  )
  lesson$checks <- c(
    check_sentences(computed$checks),
    "All numerical values displayed by the teaching layer originate in the A3 computed answer.",
    "The R code is a preview only; RU has not run it or inspected a student's RStudio workspace.",
    "Model and design assumptions must be checked with actual observations before real-world inference."
  )
  quantities <- computed$answer$quantities
  lesson$interpretations <- vapply(seq_len(nrow(quantities)), function(i) {
    units <- quantities$units[[i]]
    paste0("A3 verified ", quantity_name(quantities$output_id[[i]]),
           " = ", fmt(quantities$value[[i]]),
           if (nzchar(units)) paste0(" ", units) else " (unit not specified)",
           ". Interpret this only under the stated method and assumptions.")
  }, character(1L))
  if (identical(family, "inference.one_sample_t")) {
    lesson$interpretations <- c(lesson$interpretations,
      if ("p_value" %in% outs)
        "A p-value does not quantify the probability that the null hypothesis is true."
      else "Confidence limits concern the coverage of the interval-generating procedure, not a probability distribution over the fixed population mean.")
  }
  if (identical(family, "regression.simple_ols")) {
    lesson$interpretations <- c(lesson$interpretations,
      "An in-sample fitted association cannot establish causation, independent prediction quality or valid inferential standard errors.")
  }
  lesson$change_this <- item$edit
  lesson$hints <- item$hints
  lesson$transfer_question <- item$transfer
  lesson$links <- item$links
  lesson$assumptions <- c(lesson$assumptions,
    "A3's mathematical verification does not constitute observational evidence that the model or study design is correct.",
    "The provided code is an editable local R preview; its execution has not occurred within the teaching adapter.")
  lesson
}