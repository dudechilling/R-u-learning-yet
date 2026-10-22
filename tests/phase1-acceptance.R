# Exact Phase 1 lesson manifest acceptance gate.
# No class identifiers, assessment originals, private slides or student work.
library(rulearn)
accepted <- c(
"bar_chart",
 "bernoulli",
 "bimodal",
 "binomial",
 "boxplot",
 "choose_center",
 "choose_spread",
 "cluster_stratified",
 "conditional_independence",
 "confidence_intervals",
 "confounding",
 "density_plot",
 "derived_column",
 "descriptive_inferential",
 "direction_strength",
 "distribution_interpret",
 "distribution_shape",
 "expected_value",
 "experiment_design",
 "five_number",
 "grouped_boxplot",
 "histogram",
 "histogram_breaks",
 "hypotheses",
 "import_csv",
 "inspect_columns",
 "maximum",
 "mean",
 "measurement_scales",
 "minimum",
 "mutually_exclusive",
 "p_value",
 "pearson",
 "percentile_rank",
 "plot_labels",
 "population_sample",
 "probability_complement",
 "probability_events",
 "probability_union",
 "quartiles",
 "r_objects_columns",
 "r_stem",
 "random_variance",
 "range",
 "relative_frequency",
 "sample_sd",
 "sample_space",
 "sampling_design",
 "sampling_distribution",
 "significant_figures",
 "skewness",
 "sort_values",
 "spearman",
 "standard_error",
 "stationarity",
 "symmetry",
 "type_errors_power",
 "unimodal",
 "variance",
 "variance_sd",
 "zero_correlation"
)
accepted <- c(accepted,"discrete_pmf","discrete_cdf","poisson_exact","poisson_cdf","poisson_upper_tail")
accepted <- c(accepted,"uniform_cdf","uniform_interval",
              "normal_between","binomial_more_than")
accepted <- c(accepted,"central_limit_theorem","mean_confidence_interval",
              "mean_ci_z","ci_method_selection")
# Ten independently validated additions extend, not replace, the original set.
accepted <- c(accepted,"one_sample_t","two_sample_t","paired_t","proportion_interval","linear_regression","anova_oneway","regression_diagnostics","glm_binomial","bootstrap_mean","multiple_testing_holm")
stopifnot(length(accepted)==84L,!anyDuplicated(accepted))
idx <- getFromNamespace(".ru_lesson_index","rulearn")()
cov <- getFromNamespace(".ru_coverage","rulearn")()
readlesson <- getFromNamespace(".ru_lesson_read","rulearn")
prepare <- getFromNamespace(".ru_viewer_prepare","rulearn")
stopifnot(setequal(idx$id,accepted), nrow(idx)==84L,
          all(idx$status=="VERIFIED"), nrow(cov)==174L,
          sum(cov$content_status=="VERIFIED")==84L,
          sum(cov$content_status=="AUTHORED")==48L,
          sum(cov$content_status=="NEEDS_REVIEW")==6L,
          sum(cov$content_status=="DISCOVERED")==36L,
          setequal(cov$reference_id[cov$content_status=="VERIFIED"],accepted))
stopifnot(!anyDuplicated(cov$reference_id))
# Authentic study intents rewritten in original wording; old calculation-bank
# guides may be found on secondary results but accepted compact page is top.
q <- c(
 "How do I count significant figures in 0.0030?"="significant_figures",
 "Which measurement scale is an ordered rating?"="measurement_scales",
 "How can I calculate relative frequency?"="relative_frequency",
 "What does the 38th percentile rank mean?"="percentile_rank",
 "What is positive skew?"="skewness",
 "When should I report mean or median?"="choose_center",
 "Which spread measure handles outliers better?"="choose_spread",
 "What is a five number summary?"="five_number",
 "Can Pearson r be zero for nonlinear data?"="zero_correlation",
 "What does weak stationarity mean?"="stationarity",
 "How do I import a CSV?"="import_csv",
 "How do I create variables from a data frame?"="r_objects_columns",
 "How do I calculate quartiles?"="quartiles",
 "How do I calculate the mean?"="mean",
 "How do I calculate sample variance?"="variance",
 "How do I calculate sample standard deviation?"="variance_sd",
 "How do I calculate Pearson correlation?"="pearson",
 "When do I use Spearman correlation?"="spearman",
 "What is a sample versus population?"="population_sample",
 "What is descriptive versus inferential statistics?"="descriptive_inferential",
 "What is probability sampling?"="sampling_design",
 "What is cluster versus stratified sampling?"="cluster_stratified",
 "How does an observational study differ from experiment?"="experiment_design",
 "What is a confounding variable?"="confounding",
 "What is a probability event?"="probability_events",
 "How do I calculate the probability of A or B?"="probability_union",
 "What does mutually exclusive mean?"="mutually_exclusive",
 "What is conditional probability and independence?"="conditional_independence",
 "What is a Bernoulli trial?"="bernoulli",
 "When should I use a binomial distribution?"="binomial",
 "How is expected value calculated?"="expected_value",
 "What is variance of a random variable?"="random_variance",
 "What is a sampling distribution?"="sampling_distribution",
 "How do I calculate standard error of a mean?"="standard_error",
 "How do I interpret a confidence interval?"="confidence_intervals",
 "What are null and alternative hypotheses?"="hypotheses",
 "What does a p-value mean?"="hypothesis_tests_pvalues",
 "What is a type I and type II error?"="type_errors_power")
stopifnot(length(q)==38L,!anyDuplicated(names(q)))
for(query in names(q)) {
 out <- capture.output(hit <- ru_find(query,n=5))
 stopifnot(length(out)==0L,nrow(hit)>0L,identical(hit$id[[1]],unname(q[[query]])))
 if(q[[query]]!="hypothesis_tests_pvalues")
   stopifnot(hit$id[[1]] %in% accepted)
}
# Held-out paraphrases differ from the explicit page titles and acceptance
# examples. False positives are preferable to recognize as failed checks.
heldout <- c(
 "Does the last zero matter in 0.0030?"="significant_figures",
 "Can I treat a ranked opinion as a measured difference?"="measurement_scales",
 "What fraction of categories were recorded?"="relative_frequency",
 "Can zero Pearson correlation hide a U shaped pattern?"="zero_correlation",
 "When do extremes call for a resistant measure of spread?"="choose_spread",
 "Why are groups selected under cluster sampling?"="cluster_stratified",
 "How do I tell whether treatment was randomly assigned?"="experiment_design",
 "What is the union rule for two overlapping events?"="probability_union",
 "What is the meaning of independent and mutually exclusive?"="mutually_exclusive",
 "How do I find probability conditioned on another event?"="conditional_independence",
 "What distribution describes independent success counts?"="binomial",
 "How do I find a probability weighted expectation?"="expected_value",
 "What does the variation across sample means represent?"="sampling_distribution",
 "Can I confuse a confidence interval with a range of observations?"="confidence_intervals",
 "What does falsely rejecting the null mean?"="type_errors_power")
for(query in names(heldout)) {
  capture.output(hit <- ru_find(query,n=5))
  stopifnot(nrow(hit)>0L,identical(hit$id[1L],unname(heldout[[query]])))
}
for(query in c("How do I fix a broken car engine?",
                "How can I brew coffee for guests?",
                "How should I solve a chemistry reaction?")) {
 out<-capture.output(x<-ru_find(query))
 stopifnot(length(out)==0L,nrow(x)==0L)
}
# Every accepted code lesson is actually runnable; conceptual-only cards
# never acquire a fake Copy button. Check the full markup and local SVG links.
grDevices::pdf(tempfile(fileext=".pdf"))
ran<-0L;study<-0L
for(id in accepted) {
 item<-readlesson(id)
 stopifnot(!is.null(item),identical(item$meta$status,"VERIFIED"),
  all(c("immediate answer","what to check","interpret your results","learn more")
   %in% names(item$sections)))
 body<-getFromNamespace(".ru_page_html","rulearn")(item)
 if(nzchar(item$code)) {
  stopifnot(grepl("class='copy'",body,fixed=TRUE),
           grepl("<table class='edit'>",body,fixed=TRUE),
           grepl("aria-label='Copy this R code",body,fixed=TRUE))
  env<-new.env(parent=.GlobalEnv)
  invisible(capture.output(tryCatch(eval(parse(text=item$code),envir=env),
             error=function(e)stop(id,": ",conditionMessage(e),call.=FALSE))))
  ran<-ran+1L
 } else {
  stopifnot("exam answer pattern" %in% names(item$sections),
            !grepl("class='copy'",body,fixed=TRUE))
  study<-study+1L
 }
 if(nzchar(item$meta$visual)) {
  stopifnot(grepl("Open full-size illustration (local)",body,fixed=TRUE),
            nzchar(item$meta$alt),nzchar(item$meta$caption))
 }
}
grDevices::dev.off()
stopifnot(ran==68L,study==16L)
folder<-prepare(hits=ru_find("significant figures"),query="significant figures")
stopifnot(file.exists(file.path(folder,"catalog.html")),
          file.exists(file.path(folder,"figures","skew-shapes.svg")),
          file.exists(file.path(folder,"field-atlas.css")))
catalog<-paste(readLines(file.path(folder,"catalog.html")),collapse="\n")
stopifnot(grepl("84 verified",catalog,fixed=TRUE),
          grepl("48 authored drafts",catalog,fixed=TRUE))
cat("Phase1 exact candidate PASS: 84 verified lesson IDs, 38 source-derived queries,",
    length(heldout),"held-out queries, 68 runnable code lessons, 16 study-only cards.\n")
