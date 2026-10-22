---
id: mean_ci_z
type: walkthrough
domain: Sampling and inference
aliases: known population standard deviation mean confidence interval;known sigma z confidence interval;population variance known z interval;z interval one mean;normal critical mean CI;mean interval known population SD
related: ci_method_selection;mean_confidence_interval;standard_error;central_limit_theorem
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Normal.html
status: VERIFIED
---
# How do I calculate a two-sided confidence interval for a mean with known population SD?

## Immediate answer

When population standard deviation sigma > 0 is genuinely known from outside this sample, a two-sided normal-critical-value confidence interval for one population mean is sample_mean +/- qnorm(1 - alpha/2) * sigma/sqrt(n), where alpha = 1 - confidence_level. Do not replace sigma with the sample SD. If population variance is supplied as sigma squared, first take its positive square root to obtain sigma in the measurement's units.

## What the question asks

Estimate one population mean from numeric measurements when the population SD has been independently established, under a justified normal-population or appropriate large-sample model and a defensible sampling design. The target is a mean, not a proportion, normal observation tail probability, or hypothesis test.

## Recognize the method

Use this known-sigma z interval when one numeric population mean, a valid independent sample and known positive sigma are identified. The resulting standard error is sigma/sqrt(n). If sigma must be estimated from these measurements, use mean_confidence_interval instead. Merely saying n is large or saying 'normal' is not evidence that population sigma is known.

## Numbered solution steps

1. Verify that sigma is a strictly positive population standard deviation, not the sample s. Convert a known population variance to sigma using sqrt(variance) and check its units.
2. Verify one appropriately sampled numeric population, n >= 1 finite nonmissing observation(s), independent sampling units, and the model assumptions for using a normal critical value.
3. Choose confidence_level in (0,1), alpha = 1 - confidence_level and z critical = stats::qnorm(1 - alpha/2).
4. Compute standard error sigma/sqrt(n) and both bounds sample_mean +/- z critical * standard error.
5. State the mean's units, conditional coverage interpretation, and why the known-sigma and sample design assumptions are credible. At fixed sigma and confidence, doubling n divides the margin by sqrt(2).

## Original worked example

A fictional reference instrument is stipulated to have a previously validated population SD of 1.6 millimetres; this is an assumption for teaching, not an estimate from the measurements below. Eight imaginary independent readings form a sample. Construct a two-sided 95% interval for the mean under a normal-population model. A real investigation would have to substantiate the known-SD claim and sample design.

## Use this in R

```r
measurements <- data.frame(length_mm = c(30.2, 31.0, 29.7, 30.5, 30.8, 29.9, 30.4, 30.1))
column <- "length_mm"
sigma_population_mm <- 1.6  # Independently KNOWN population SD, not sd(x)
confidence_level <- 0.95
stopifnot(is.data.frame(measurements), column %in% names(measurements),
          is.numeric(sigma_population_mm), length(sigma_population_mm) == 1L,
          is.finite(sigma_population_mm), sigma_population_mm > 0,
          is.numeric(confidence_level), length(confidence_level) == 1L,
          is.finite(confidence_level), confidence_level > 0,
          confidence_level < 1)
x <- measurements[[column]]
stopifnot(is.numeric(x), !is.complex(x), length(x) >= 1L,
          all(is.finite(x)))
n <- length(x)
standard_error <- sigma_population_mm / sqrt(n)
critical <- stats::qnorm(1 - (1 - confidence_level) / 2)
stopifnot(is.finite(critical))
margin <- critical * standard_error
stopifnot(is.finite(margin))
interval <- c(lower = mean(x) - margin, upper = mean(x) + margin)
stopifnot(all(is.finite(interval)))
c(n = n, sample_mean = mean(x), standard_error = standard_error, interval)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `measurements` | Original synthetic length dataset | Your numeric one-population dataset |
| `column` | Numeric measurement column in millimetres | Your exact column name |
| `sigma_population_mm` | Known population SD (millimetres); not sample s | Independently justified positive population SD; if given population variance, use sqrt(variance) |
| `n` | Number of independent units | Leave length(x); verify the sampling units and any missing data |
| `confidence_level` | Two-sided confidence level | Chosen number between 0 and 1, such as 0.90, 0.95 or 0.99 |
| Units / missingness | Consistency and completeness | Match sigma, mean and interval units; reject NA/Inf rather than silently drop data |

## What to check

- With independent normal-population observations and genuinely known sigma, the normal mean model is exact even for n=1; with nonnormal observations at small n, normal-approximation coverage may be poor.
- A large n cannot fix biased sampling, dependence or clustered observations. Verify known sigma externally; a computed sample sd(x) does not make this a known-SD problem.
- Replacing sigma with known variance without its square root gives incorrect units and margin. This example rejects zero/negative sigma, invalid confidence, missing/nonfinite values and nonfinite endpoints.
- stats::t.test estimates sigma and uses t critical values. It must not be presented as the implementation of this known-sigma z interval.

## Interpret your results

The interval estimates a fixed mean length in millimetres; 95% is the procedure's intended long-run coverage under the assumed model and repeated study design, not a probability statement about the fixed mean in this realised interval. For fixed sigma, confidence and model, changing n from 8 to 32 halves the margin, but cannot establish sampling validity.

## Frequent mistakes

Do not use the sample SD in a z interval, confuse variance (squared units) with SD (original units), assume n >= 30 guarantees normality, or treat stats::qnorm as a normal-area calculation rather than a critical quantile.

## Learn more

The R stats::qnorm documentation supplies normal quantiles; the remaining code uses base mean() and sqrt(). The example and teaching text are original. Read mean_confidence_interval for estimated-SD t intervals.