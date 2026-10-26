# W4-R1 private method-family registry. Entries describe candidates, not solvers.
# All eight are disabled until independently qualified with A2/A3/A4 adapters.
# Neither question text nor data may name an executable callback.
.ru_w4_family_ids <- c(
  "descriptive.numeric", "probability.event_scalar",
  "distribution.binomial", "distribution.poisson",
  "distribution.normal", "distribution.uniform_continuous",
  "inference.one_sample_t", "regression.simple_ols"
)

.ru_w4_adapter_ids <- c(
  parse = ".ru_w4_parse", compute = ".ru_w4_compute",
  teach = ".ru_w4_teach", render = ".ru_w4_render"
)

.ru_w4_input_types <- c(
  "finite_scalar", "positive_scalar", "bounded_probability",
  "bounded_integer", "finite_vector", "operation_id",
  "side", "declared_model", "confidence_level"
)

.ru_w4_make_family <- function(id, method, model, operations, inputs,
                               assumptions, positive, negative, coverage,
                               curriculum = character()) {
  list(
    schema_version = "ru.family.v1",
    family_id = id,
    family_version = 1L,
    method_id = method,
    model_id = model,
    qa_status = "CANDIDATE",
    enabled = FALSE,
    execution_scope = "INLINE_LITERAL_ONLY",
    operations = operations,
    input_schema = inputs,
    required_model_assertions = assumptions,
    positive_evidence = positive,
    negative_guards = negative,
    adapter_ids = .ru_w4_adapter_ids,
    coverage_ids = coverage,
    curriculum_ids = curriculum,
    resource_caps = list(question_bytes = 4096L,
                         max_vector = 20000L, max_table_cells = 200000L)
  )
}

.ru_w4_registry <- local({
  entries <- list(
    "descriptive.numeric" = .ru_w4_make_family(
      "descriptive.numeric", "describe.numeric", "observed_numeric_list",
      c("mean", "median", "sample_variance", "population_variance",
        "sample_sd", "population_sd", "quantile"),
      c(values = "finite_vector", statistic = "operation_id",
        quantile_probability = "bounded_probability"),
      c("sample_or_population_convention"),
      c("explicit_inline_numeric_values", "named_descriptive_statistic"),
      c("unknown_variance_denominator", "unprovided_dataset",
        "categorical_response", "nonfinite_observations"),
      c("mean", "variance", "sample_sd", "quartiles"),
      c("EXP-01")),
    "probability.event_scalar" = .ru_w4_make_family(
      "probability.event_scalar", "event_probability",
      "finite_scalar_event_probabilities",
      c("complement", "union", "conditional_probability"),
      c(p_a = "bounded_probability", p_b = "bounded_probability",
        p_intersection = "bounded_probability", operation = "operation_id"),
      c("probability_axioms", "valid_joint_probabilities"),
      c("named_events", "explicit_scalar_probabilities"),
      c("unknown_joint_probability", "mutually_exclusive_conflict",
        "impossible_probability", "conditional_denominator_zero"),
      c("probability_events", "probability_union", "conditional_independence"),
      c("PRO-01")),
    "distribution.binomial" = .ru_w4_make_family(
      "distribution.binomial", "binomial_exact",
      "iid_bernoulli_fixed_n_p",
      c("pmf", "cdf", "upper_strict", "upper_inclusive",
        "expected_value", "variance"),
      c(n = "bounded_integer", p = "bounded_probability",
        k = "bounded_integer", operation = "operation_id"),
      c("fixed_trials", "independent_trials",
        "identical_success_probability", "count_response"),
      c("binomial_named", "independent_success_count"),
      c("waiting_time", "sampling_without_replacement",
        "varying_trial_probability", "missing_n_or_p"),
      c("binomial", "binomial_more_than"), c("PRO-02")),
    "distribution.poisson" = .ru_w4_make_family(
      "distribution.poisson", "poisson_exact", "poisson_count_fixed_exposure",
      c("pmf", "cdf", "upper_strict", "upper_inclusive",
        "expected_value", "variance"),
      c(lambda = "positive_scalar", k = "bounded_integer",
        operation = "operation_id"),
      c("count_response", "rate_applies_to_requested_exposure"),
      c("poisson_named", "specified_mean_count"),
      c("continuous_waiting_time", "unscaled_exposure",
        "binomial_model_conflict"),
      c("poisson_exact", "poisson_cdf", "poisson_upper_tail"), c("PRO-02")),
    "distribution.normal" = .ru_w4_make_family(
      "distribution.normal", "normal_between",
      "normal_continuous_measurement",
      c("cdf", "upper_tail", "interval_probability", "quantile"),
      c(mu = "finite_scalar", sigma = "positive_scalar",
        lower = "finite_scalar", upper = "finite_scalar",
        threshold = "finite_scalar", p = "bounded_probability",
        operation = "operation_id"),
      c("normal_model_declared", "sigma_is_model_sd"),
      c("normal_named", "normal_probability_or_quantile"),
      c("normality_test", "known_sigma_hypothesis_test",
        "nonpositive_sd", "missing_model_parameters"),
      c("normal_between", "inverse_cdf"), c("PRO-02")),
    "distribution.uniform_continuous" = .ru_w4_make_family(
      "distribution.uniform_continuous", "uniform_interval",
      "continuous_uniform_bounded_interval",
      c("cdf", "interval_probability", "upper_tail"),
      c(a = "finite_scalar", b = "finite_scalar",
        lower = "finite_scalar", upper = "finite_scalar",
        threshold = "finite_scalar", operation = "operation_id"),
      c("continuous_uniform_model", "upper_bound_strictly_greater"),
      c("uniform_named", "explicit_interval_endpoints"),
      c("discrete_uniform", "unknown_support", "reversed_support"),
      c("uniform_cdf", "uniform_interval"), c("PRO-02")),
    "inference.one_sample_t" = .ru_w4_make_family(
      "inference.one_sample_t", "one_sample_t",
      "iid_unknown_sigma_one_sample_mean",
      c("t_statistic", "p_value", "confidence_interval"),
      c(values = "finite_vector", null_mean = "finite_scalar",
        confidence = "confidence_level", alternative = "side",
        operation = "operation_id"),
      c("one_numeric_sample", "population_sd_unknown",
        "independent_observations", "valid_sampling_design"),
      c("one_sample_t_named", "one_mean_unknown_sigma"),
      c("known_population_sigma", "paired_design",
        "clustered_or_repeated_data", "population_variance_test"),
      c("one_sample_t", "mean_confidence_interval"), c("INF-02")),
    "regression.simple_ols" = .ru_w4_make_family(
      "regression.simple_ols", "linear_regression",
      "simple_gaussian_ols_with_intercept",
      c("intercept", "slope", "r_squared", "fitted_values"),
      c(x = "finite_vector", y = "finite_vector",
        operation = "operation_id"),
      c("single_numeric_predictor", "numeric_response",
        "aligned_pairs", "intercept_included", "design_sufficient"),
      c("simple_linear_regression", "paired_inline_xy"),
      c("multivariable_regression", "nonlinear_or_logistic_model",
        "unpaired_vectors", "causal_proof_claim"),
      c("linear_regression", "regression_diagnostics"), c("MOD-02"))
  )
  # Copy-on-return, so mutations to a caller's snapshot cannot promote a
  # candidate or replace its fixed adapter identifiers.
  function() unserialize(serialize(entries, NULL, version = 3L))
})

.ru_w4_scalar <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    nzchar(x) && validUTF8(x) && nchar(x, type = "bytes") <= 256L
}

.ru_w4_output_id <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    grepl("^[a-z][a-z0-9_]{0,63}$", x)
}

.ru_w4_validate_family <- function(x) {
  required <- c(
    "schema_version", "family_id", "family_version",
    "method_id", "model_id", "qa_status", "enabled",
    "execution_scope", "operations", "input_schema",
    "required_model_assertions", "positive_evidence",
    "negative_guards", "adapter_ids", "coverage_ids",
    "curriculum_ids", "resource_caps"
  )
  if (!is.list(x) || !identical(class(x), "list") ||
      !setequal(names(x), required) || anyDuplicated(names(x)) ||
      !identical(x$schema_version, "ru.family.v1") ||
      !.ru_w4_scalar(x$family_id) ||
      !(x$family_id %in% .ru_w4_family_ids) ||
      !identical(x$family_version, 1L) ||
      !.ru_w4_scalar(x$method_id) || !.ru_w4_scalar(x$model_id) ||
      !is.character(x$qa_status) || length(x$qa_status) != 1L ||
      is.na(x$qa_status) ||
      !(x$qa_status %in%
          c("CANDIDATE", "ORACLE_QUALIFIED", "INDEPENDENT_QA_ACCEPTED")) ||
      !is.logical(x$enabled) || length(x$enabled) != 1L ||
      is.na(x$enabled) || !identical(x$execution_scope, "INLINE_LITERAL_ONLY") ||
      !is.character(x$operations) || !length(x$operations) ||
      anyNA(x$operations) || anyDuplicated(x$operations) ||
      !all(vapply(x$operations, .ru_w4_output_id, logical(1L))) ||
      !is.character(x$input_schema) || !length(x$input_schema) ||
      is.null(names(x$input_schema)) ||
      anyDuplicated(names(x$input_schema)) ||
      !all(vapply(names(x$input_schema), .ru_w4_output_id, logical(1L))) ||
      !all(x$input_schema %in% .ru_w4_input_types))
    return(FALSE)
  strings <- c("required_model_assertions", "positive_evidence",
               "negative_guards", "coverage_ids", "curriculum_ids")
  if (!all(vapply(x[strings], function(y)
      is.character(y) && !anyNA(y) && length(y) <= 48L &&
        all(nzchar(y)) && !anyDuplicated(y), logical(1L))))
    return(FALSE)
  if (!is.character(x$adapter_ids) ||
      !identical(x$adapter_ids, .ru_w4_adapter_ids))
    return(FALSE)
  limits <- x$resource_caps
  if (!is.list(limits) || !identical(class(limits), "list") ||
      !setequal(names(limits),
                c("question_bytes", "max_vector", "max_table_cells")) ||
      !all(vapply(limits, function(n)
        is.integer(n) && length(n) == 1L &&
        !is.na(n) && n >= 1L && n <= 1000000L, logical(1L))))
    return(FALSE)
  if (isTRUE(x$enabled) &&
      !identical(x$qa_status, "INDEPENDENT_QA_ACCEPTED"))
    return(FALSE)
  TRUE
}

.ru_w4_validate_registry <- function(registry = .ru_w4_registry()) {
  is.list(registry) && identical(class(registry), "list") &&
    identical(registry, .ru_w4_registry()) &&
    identical(names(registry), .ru_w4_family_ids) &&
    all(vapply(seq_along(registry), function(i)
      .ru_w4_validate_family(registry[[i]]) &&
        identical(registry[[i]]$family_id, names(registry)[i]),
      logical(1L)))
}

.ru_w4_family <- function(id) {
  if (!.ru_w4_scalar(id) || !id %in% .ru_w4_family_ids)
    return(NULL)
  .ru_w4_registry()[[id]]
}

.ru_w4_family_enabled <- function(id) {
  item <- .ru_w4_family(id)
  !is.null(item) && isTRUE(item$enabled) &&
    identical(item$qa_status, "INDEPENDENT_QA_ACCEPTED") &&
    .ru_w4_validate_family(item)
}