# Bounded method compatibility for independently checked product workflows.
# Return NULL to preserve earlier routing; character() requires clarification.
# Explicit model/design/operation conflicts are rejected before lexical ranking.
.ru_product_compatible_ids <- function(q) {
  ids <- c("one_sample_t","two_sample_t","paired_t","proportion_interval",
           "linear_regression","anova_oneway","regression_diagnostics",
           "glm_binomial","bootstrap_mean","multiple_testing_holm")
  if(q %in% ids) return(q)
  has <- function(pattern) grepl(pattern,q,perl=TRUE)
  dependent <- has("\\b(mixed|multilevel|hierarchical|clustered|clustering|complex survey|survey weighted|survey weights)\\b|random[ -](intercept|effects?)|spatial autoregress")
  causal_proof <- has("\\b(prove|establish|guarantee)\\b") && has("\\b(causal|causation|causality)\\b")
  one_sided <- has("\\bone[ -]?(sided|tailed)\\b") ||
    has("alternative\\s*=\\s*['\"]?(less|greater)\\b")
  unsupported_estimator <- has("\\b(bayesian|credible|posterior|firth|penalized|ridge|lasso|huber|weighted|multivariable|multivariate|noninferiority|equivalence|tost|ranks)\\b|non-inferiority|generalized least squares|generalized estimating equations|\\bgee\\b")

  multiplicity <- has("\\bholm\\b|\\bp[.]adjust\\b|\\b(multiple[ -]testing|family[ -]?wise|false discovery|benjamini|hochberg)\\b")
  if(multiplicity) {
    if(unsupported_estimator || has("online|sequential|alpha spending|confidence interval|only to selected|only selected")) return(character())
    if(has("\\b(fdr|false discovery|benjamini|hochberg|bhochberg|bonferroni correction)\\b|method\\s*=\\s*['\"]?(bh|by)\\b|\\bby method\\b"))
      return(character())
    if(has("\\bonly to significant\\b|after dropping|\\bdropping\\b.*\\b(planned|other)\\b") ||
       (has("\\b(calculate|compute|generate)\\b") && has("\\braw p[ -]?values?\\b") && has("\\bdataset\\b")))
      return(character())
    if(has("\\bholm\\b")) return("multiple_testing_holm")
    return(character())
  }

  boot <- has("\\bbootstrap\\b") ||
    (has("\\bresampl\\w*\\b") && has("\\bmean\\b") && has("\\breplacement\\b"))
  if(boot) {
    if(unsupported_estimator || has("\\b(basic|wild|reversed|paired)\\b|difference between")) return(character())
    if(dependent || has("\\b(time series|dependent|cluster|block|bca|studentized|parametric|median|convenience|biased)\\b|without replacement") ||
       !has("\\b(mean|average|arithmetic)\\b")) return(character())
    return("bootstrap_mean")
  }

  logistic <- has("\\blogistic\\b|\\blogit\\b|\\bglm\\b|generalized linear model")
  diagnostic <- has("diagnostic|influence|\\bresiduals?\\b|\\bleverage\\b|cook['s]* distance|cook['s]*s? distance|\\bq-q\\b|standardized residual")
  linear <- has("linear (regression|model)|least[ -]squares|\\bols\\b|\\blm\\b|straight[ -]line regression")
  if(logistic) {
    if(unsupported_estimator || has("repeated|\\b(two|multiple)\\s+predictors\\b")) return(character())
    if(dependent || causal_proof || has("\\b(poisson|gaussian|quasibinomial|quasi-binomial|probit|multinomial|growth|differential equation)\\b"))
      return(character())
    if(diagnostic && (has("\\blm\\b|ordinary least squares|ordinary.*residual"))) return(character())
    if(linear && has("least[ -]squares|\\bols\\b|simple linear regression")) return(character())
    if(has("\\b(logistic|logit|binomial)\\b")) return("glm_binomial")
    return(character())
  }
  if(diagnostic && (linear || has("cook|\\bresiduals?\\b"))) {
    if(unsupported_estimator || (has("\\bprove\\b") && has("\\b(normality|independence)\\b"))) return(character())
    if(dependent || has("\\b(arima|nonlinear|logistic)\\b") ||
       (has("automatically|automatic") && has("delete|remove") &&
        !has("rather than|instead of|do not|not automatically")) ||
       (has("\\bprove\\b") && has("\\bindependence\\b"))) return(character())
    if(linear) return("regression_diagnostics")
    return(NULL)
  }
  if(linear) {
    if(unsupported_estimator || has("without an? intercept|no intercept|through the origin|time.correlated|autocorrelated|dependent errors")) return(character())
    if(dependent || causal_proof || has("\\b(binary|ridge|lasso|penalized|nonlinear|polynomial)\\b") ||
       has("\\b(two|multiple|several|many)\\s+(numeric\\s+)?predictors\\b")) return(character())
    return("linear_regression")
  }
  if(has("nonlinear.*regression|\\bkruskal[ -]?wallis\\b")) return(character())

  anova <- has("\\banova\\b|oneway[.]test|analysis of variance|\\bwelch\\b.*\\bf statistic\\b")
  if(anova) {
    if(unsupported_estimator || has("games.howell|post hoc|post-hoc|pairwise|tukey")) return(character())
    if(dependent || has("repeated|same subjects|two[ -]way|factorial|interaction|\\baov\\b|classical|pooled|binomial|proportion|\\bbinary\\b") ||
       (has("\\bprove\\b") && has("\\bequal\\b"))) return(character())
    if(has("\\bwelch\\b|oneway[.]test") && !has("var[.]equal\\s*=\\s*true")) return("anova_oneway")
    return(character())
  }

  prop_ci <- has("\\bwilson\\b") ||
    (has("proportion|\\bscore\\b|binomial") && has("confidence|\\bci\\b"))
  if(prop_ci) {
    if(unsupported_estimator || has("paired|matched|risk ratio|odds ratio|relative risk|\\bprior\\b|with continuity correction|correct\\s*=\\s*true|yates")) return(character())
    if(dependent || one_sided || has("\\b(wald|clopper|pearson exact|mean|continuous)\\b|difference between|two proportions|test whether|null value|hypothesis test"))
      return(character())
    if(has("\\bproportion\\b|\\bwilson\\b|\\bsuccess\\b")) return("proportion_interval")
    return(character())
  }

  t_method <- has("\\bt[ .-]?test(?:ing)?\\b|\\bt statistic\\b|student['s]* t|\\bwelch\\b")
  t_method <- t_method || (has("\\bt\\b") && has("\\b(test|testing|statistic)\\b"))
  if(t_method) {
    if(unsupported_estimator || has("\\bmedian\\b")) return(character())
    if(has("confidence interval|confidence bounds|confidence limits|\\bt interval\\b")) return(NULL)
    if(dependent || one_sided || has("\\b(binary|proportion|proportions|success probability)\\b|compare variances|population variance"))
      return(character())
    paired <- has("\\b(paired|matched|within-person|within person)\\b|before[ -]after|paired\\s*=\\s*true")
    independent <- has("independent (samples|groups|populations)|unrelated|unpaired|two[ -]sample|two sample")
    single <- has("one[ -]sample|single sample|one population mean|one mean|one numeric sample")
    if((paired && independent) || (single && (paired || independent))) return(character())
    if(has("\\b(three|four|five|[3-9])\\b.*\\b(groups|samples|times)\\b")) return(character())
    if(has("pooled|equal[ -]variance") && !has("without a pooled|unequal[ -]variance|unequal variances")) return(character())
    if(has("\\bknown population (sigma|sd|standard deviation)\\b|population (sigma|sd|standard deviation) is known"))
      return(character())
    if(paired) {
      if(has("^\\s*(can i use|when is|when should|should i use)\\b") ||
         has("\\b(appropriate|suitable)\\b")) return(NULL)
      return("paired_t")
    }
    if(independent || has("\\bwelch\\b")) return("two_sample_t")
    if(single) return("one_sample_t")
    return(NULL)
  }
  # Explicit independent mean comparisons also name the Welch target without t.
  if(has("two independent populations|two independent groups|two unrelated sample means") &&
     has("\\b(mean|means)\\b") && has("\\b(test|compare|comparison)\\b")) {
    if(dependent || one_sided || has("paired|matched|confidence interval|known sigma")) return(character())
    return("two_sample_t")
  }
  NULL
}