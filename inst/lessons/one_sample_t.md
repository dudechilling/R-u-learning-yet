---
id: one_sample_t
type: walkthrough
domain: Core inference
aliases: one sample t;Student t;benchmark mean;unknown sigma;t.test
related: hypotheses;p_value;mean_confidence_interval
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html
status: VERIFIED
---
# How do I test one mean against a benchmark with a two-sided t test?

## Immediate answer

Use stats::t.test(x, mu=target, alternative="two.sided") for one quantitative sample when population SD is unknown. The statistic is (sample mean - target)/(sample SD/sqrt(n)), with n-1 degrees of freedom under the normal independent-sample model.

## What the question asks

How do I test one mean against a benchmark with a two-sided t test? The worked data are constructed, not supplied by a learner.

## Recognize the method

The parameter is one population mean. The benchmark must be selected independently of the observed result. This workflow is not a known-sigma z test, a proportion test, a variance test, or a paired/two-population comparison. A one-sided alternative needs a separately justified analysis plan.

## Numbered solution steps

1. Define the target population, sampling unit, benchmark and two-sided alternative before examining significance.
2. Check finite quantitative observations, at least two units, nonzero sample SD and adequate independence.
3. Compute the native t test with the chosen confidence level.
4. Report the mean difference, interval, t statistic, degrees of freedom and p-value together.

## Original worked example

Eight invented calibration readings are 10.2, 10.7, 9.8, 11.1, 10.4, 9.9, 10.8 and 10.1 units. In this constructed illustration, compare the hypothetical population mean with 10 units. The numbers do not establish that any real sampling was random.

## Use this in R

```r
sample_values <- c(10.2, 10.7, 9.8, 11.1, 10.4, 9.9, 10.8, 10.1)
target <- 10
confidence <- 0.95
if (!is.numeric(sample_values) || is.complex(sample_values) ||
    length(sample_values) < 2L || any(!is.finite(sample_values)) ||
    stats::sd(sample_values) <= 0)
  stop("Supply at least two finite numeric observations with nonzero spread.")
if (!is.numeric(target) || length(target) != 1L || !is.finite(target))
  stop("Supply one finite, prespecified benchmark mean.")
if (!is.numeric(confidence) || length(confidence) != 1L ||
    !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Set confidence strictly between zero and one.")
fit <- stats::t.test(sample_values, mu = target,
                     alternative = "two.sided", conf.level = confidence)
result <- c(mean = mean(sample_values), difference = mean(sample_values)-target,
            lower = fit$conf.int[1L], upper = fit$conf.int[2L],
            t = unname(fit$statistic), df = unname(fit$parameter), p = fit$p.value)
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| sample_values | One quantitative sample | Your finite observations in one stated unit |
| target | Null population mean | A benchmark selected before inspecting the test result |
| confidence | Two-sided mean interval coverage level | A number strictly between zero and one |

## What to check

- Exact small-sample t inference assumes independent observations from a normal population. With other distributions, approximation depends on sample size and shape; a universal sample-size cutoff is not a guarantee.

- Inspect unusual observations and missingness. This example rejects nonfinite values rather than silently dropping them. Sampling independence and representativeness require design evidence, not a successful function call.

## Interpret your results

The interval estimates the population mean; subtract the benchmark from its endpoints for an interval for the mean difference. The p-value describes incompatibility with the specified null model. It is not the probability that the null is true. A small p-value does not establish practical importance or causation.

## Frequent mistakes

Do not use the sample SD as an independently known population sigma. Do not change the benchmark or alternative after seeing the p-value. A failure to reject is not proof of equality.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
