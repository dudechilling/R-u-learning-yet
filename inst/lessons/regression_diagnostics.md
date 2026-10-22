---
id: regression_diagnostics
type: walkthrough
domain: Applied analysis
aliases: lm diagnostics;residual fitted;leverage;Cook distance;standardized residuals;Q-Q
related: linear_regression;confounding;sampling_design
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/influence.measures.html
status: VERIFIED
---
# How do I inspect residuals and influence after simple linear regression?

## Immediate answer

Inspect residual patterns, a normal Q-Q plot, leverage and Cook's distance after fitting an ordinary least-squares model. These diagnostics reveal possible model problems; they do not prove independence, normality, causality or correct measurement.

## What the question asks

How do I inspect residuals and influence after simple linear regression? The worked data are constructed, not supplied by a learner.

## Recognize the method

This page uses an unweighted simple linear model. Logistic, nonlinear, mixed, dependent-time-series and survey-weighted models need diagnostics appropriate to their model and design.

## Numbered solution steps

1. Fit the prespecified simple linear model to complete finite observations.
2. Compare residuals with fitted values for curvature or changing spread.
3. Inspect the residual Q-Q plot, leverage and Cook's distance.
4. Investigate flagged units against measurement and design records; do not delete them solely to improve a test.

## Original worked example

Use the same explicitly constructed twelve-row x/y case as the simple regression page. The row index is an identifier, not evidence of chronological order.

## Use this in R

```r
study <- data.frame(x = seq_len(12L),
  y = 2 + 0.7*seq_len(12L) + c(-.3,.7,-.4,.5,-.6,.1,.4,-.2,.6,-.5,.2,-.1))
confidence <- 0.95
if (!is.data.frame(study) || !all(c("x","y") %in% names(study)) || nrow(study) < 3L ||
    !is.numeric(study$x) || !is.numeric(study$y) || is.complex(study$x) ||
    is.complex(study$y) || any(!is.finite(study$x)) || any(!is.finite(study$y)) ||
    length(unique(study$x)) < 2L)
  stop("Supply at least three finite numeric x/y rows and a varying predictor.")
if (!is.numeric(confidence) || length(confidence) != 1L ||
    !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Set confidence strictly between zero and one.")
fit <- stats::lm(y ~ x, data = study, na.action = stats::na.fail)
if (fit$rank != 2L || sum(stats::residuals(fit)^2) <= .Machine$double.eps)
  stop("Check rank and residual variation before interpreting regression uncertainty.")
interval <- stats::confint(fit, level = confidence)
result <- c(intercept = unname(stats::coef(fit)[1L]), slope = unname(stats::coef(fit)[2L]),
            lower = interval[2L,1L], upper = interval[2L,2L],
            residual_sd = summary(fit)$sigma, r_squared = summary(fit)$r.squared)
leverage <- stats::hatvalues(fit)
standardized <- stats::rstandard(fit)
cooks <- stats::cooks.distance(fit)
diagnostics <- data.frame(row = seq_len(nrow(study)), fitted = stats::fitted(fit),
  residual = stats::residuals(fit), standardized = standardized,
  leverage = leverage, cooks_distance = cooks)
draw_diagnostics <- function(model) {
  old <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old))
  graphics::par(mfrow = c(2L,2L))
  plot(stats::fitted(model), stats::residuals(model),
       xlab = "Fitted response", ylab = "Residual", main = "Residual pattern")
  graphics::abline(h = 0, lty = 2)
  stats::qqnorm(stats::rstandard(model), main = "Residual normal Q-Q")
  stats::qqline(stats::rstandard(model), lty = 2)
  plot(stats::hatvalues(model), ylab = "Leverage", xlab = "Row", main = "Predictor influence")
  plot(stats::cooks.distance(model), ylab = "Cook's distance", xlab = "Row", main = "Fit sensitivity")
}
draw_diagnostics(fit)
diagnostics
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| study | Model rows and units | Your paired quantitative predictor and response |
| fit | The model being diagnosed | The same prespecified simple least-squares model |
| diagnostics$row | Link to observations | Retain a stable record identifier during investigation |

## What to check

- Residual patterns may reflect mean-model misspecification, unequal variance or omitted structure. Independence must also be assessed from the sampling process.

- High leverage concerns unusual predictor values. Cook's distance combines leverage with residual influence. Numerical thresholds are screening aids, not permission to erase data.

## Interpret your results

Explain the observed pattern and its plausible consequences for the intended inference. A sensitivity analysis should state which observation or model assumption changed and why. A clean-looking plot cannot certify the design.

## Frequent mistakes

Do not use ordinary lm diagnostics for a logistic or mixed model. Do not claim that residual plots prove independence or that automatic deletion makes an analysis valid.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
