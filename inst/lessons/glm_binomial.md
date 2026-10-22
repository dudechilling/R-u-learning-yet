---
id: glm_binomial
type: walkthrough
domain: Research workflows
aliases: binomial GLM;logistic regression;logit;grouped successes failures;glm binomial;odds ratio
related: linear_regression;binomial;confounding
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/glm.html
status: VERIFIED
---
# How do I fit a grouped binomial logistic regression?

## Immediate answer

Use stats::glm(cbind(successes, failures) ~ x, family=binomial(link="logit")) to model a binomial success probability through a linear log-odds predictor. Exponentiating the slope gives the fitted odds ratio for a one-unit predictor increase.

## What the question asks

How do I fit a grouped binomial logistic regression? The worked data are constructed, not supplied by a learner.

## Recognize the method

This worked workflow uses one quantitative predictor, independent grouped binomial counts and a logit link. It does not fit Poisson, quasibinomial, probit, multinomial, random-effects or causal models.

## Numbered solution steps

1. Define independent trial groups, success, predictor units and the binomial sampling model.
2. Check integer counts, positive trial totals, predictor variation and data completeness.
3. Fit the logit model and inspect convergence, coefficients and a dispersion diagnostic.
4. Report an odds ratio with an explicitly approximate Wald interval and fitted probabilities inside the observed predictor range.

## Original worked example

Six invented trial groups use predictor values -2 through 3, with 30 trials each and 4, 7, 11, 17, 22 and 26 successes. Every group in this teaching case contains both outcomes. The example is synthetic, not evidence from an experiment.

## Use this in R

```r
trial_data <- data.frame(x = -2:3, total = rep(30L,6L), successes = c(4L,7L,11L,17L,22L,26L))
confidence <- 0.95
if (!is.data.frame(trial_data) || !all(c("x","total","successes") %in% names(trial_data)) ||
    nrow(trial_data) < 3L || !all(vapply(trial_data[c("x","total","successes")],
    function(x) is.numeric(x) && !is.complex(x) && all(is.finite(x)), logical(1L))))
  stop("Supply complete finite numeric predictor, total and success columns.")
if (any(trial_data$total < 1 | trial_data$total != floor(trial_data$total)) ||
    any(trial_data$successes != floor(trial_data$successes) | trial_data$successes < 0 |
        trial_data$successes > trial_data$total) || length(unique(trial_data$x)) < 2L)
  stop("Use positive integer totals, valid integer successes and a varying predictor.")
if (any(trial_data$successes == 0 | trial_data$successes == trial_data$total))
  stop("This grouped teaching workflow requires both outcomes in every group; review sparse or separated data separately.")
if (!is.numeric(confidence) || length(confidence) != 1L ||
    !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Set confidence strictly between zero and one.")
trial_data$failures <- trial_data$total - trial_data$successes
fit <- stats::glm(cbind(successes, failures) ~ x, data = trial_data,
  family = stats::binomial(link = "logit"), na.action = stats::na.fail)
if (!isTRUE(fit$converged) || fit$rank != 2L || any(!is.finite(stats::coef(fit))))
  stop("Model fitting did not produce a finite full-rank converged solution.")
beta <- stats::coef(fit)
se <- sqrt(diag(stats::vcov(fit)))
z <- stats::qnorm((1+confidence)/2)
odds_interval <- exp(beta[2L] + c(-1,1)*z*se[2L])
pearson_ratio <- sum(stats::residuals(fit, type = "pearson")^2)/fit$df.residual
probability_at_zero <- unname(stats::predict(fit, newdata = data.frame(x=0), type = "response"))
result <- c(log_odds_slope = unname(beta[2L]), odds_ratio = unname(exp(beta[2L])),
            lower = odds_interval[1L], upper = odds_interval[2L],
            probability_at_zero = probability_at_zero, pearson_ratio = pearson_ratio)
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| trial_data | Grouped binomial counts | Independent group counts with both outcomes for this bounded workflow |
| x | One quantitative predictor and unit | A prespecified predictor with observed variation |
| confidence | Approximate Wald odds-ratio interval | Prespecified number strictly between zero and one |

## What to check

- Binomial variance assumes independent trials with a common probability within a group. Extra variation, clustering and missingness need substantive investigation. A Pearson ratio is a diagnostic, not an automatic choice of another model.

- Check the linear log-odds relationship. Sparse or separated data can defeat ordinary maximum likelihood and Wald intervals; this bounded example rejects groups containing only one outcome.

- Convergence is necessary but not a guarantee of scientific validity. The displayed interval is a model-based normal approximation, not a profile-likelihood or exact interval.

## Interpret your results

The odds ratio multiplies fitted odds, not probability, for a one-unit increase in x. A probability prediction must state the predictor value. Neither the coefficient nor a small p-value establishes a causal intervention effect from observational data.

## Frequent mistakes

Do not interpret exp(beta) as a risk ratio. Do not silently replace a requested Poisson, probit, mixed or quasibinomial model with this workflow.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
