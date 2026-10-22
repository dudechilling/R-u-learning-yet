---
id: linear_regression
type: walkthrough
domain: Applied analysis
aliases: simple linear regression;ordinary least squares;OLS;lm;regression slope
related: regression_diagnostics;pearson;confounding
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html
status: VERIFIED
---
# How do I fit and interpret a simple least-squares regression?

## Immediate answer

Fit stats::lm(y ~ x, data=study) to estimate an intercept and a slope. Least squares minimizes the sum of squared residuals. The slope describes the fitted mean change in y for a one-unit change in x; it is not automatically a causal effect.

## What the question asks

How do I fit and interpret a simple least-squares regression? The worked data are constructed, not supplied by a learner.

## Recognize the method

This workflow has one quantitative response, one quantitative predictor and an intercept. It does not fit binary-response, mixed, penalized, nonlinear, spatial or multiple-predictor models.

## Numbered solution steps

1. State the observational unit, units of x and y and the intended association.
2. Plot the data and assess whether a straight-line conditional mean is plausible.
3. Fit the model and inspect residual and influence diagnostics.
4. Report the slope and its interval with units, uncertainty and design limits.

## Original worked example

Twelve invented observations follow y = 2 + 0.7*x plus a fixed list of deviations. The data are a constructed teaching case, not observations from a real study.

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
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| study | Paired quantitative rows | Your x/y data frame with rows that describe the same units |
| y ~ x | Response and one predictor | Use the intended response and predictor with their units |
| confidence | Slope/intercept interval level | A number strictly between zero and one |

## What to check

- Conventional t intervals require the linear mean model, independent errors, constant variance and normally distributed errors for exact small-sample inference. Least-squares coefficients alone do not establish those conditions.

- Check influential points, residual spread, the observed predictor range and missingness. A large R-squared is not proof of model adequacy or sampling validity.

## Interpret your results

The slope is measured in y-units per x-unit. The intercept concerns x=0 and may have little substantive meaning outside the observed range. R-squared describes the fitted sample variance fraction, not causal strength. Avoid unsupported extrapolation.

## Frequent mistakes

Do not equate association with an intervention effect. Do not use a Gaussian least-squares reference as a logistic-model substitute.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
