---
id: two_sample_t
type: walkthrough
domain: Core inference
aliases: Welch t;independent samples;unpaired t test;unequal variances;two sample means
related: paired_t;p_value;sampling_design
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html
status: VERIFIED
---
# How do I compare two independent means with a Welch t test?

## Immediate answer

Use stats::t.test(group_a, group_b, var.equal=FALSE) for a two-sided comparison of two independent quantitative samples. Welch inference estimates each variance separately and uses approximate degrees of freedom.

## What the question asks

How do I compare two independent means with a Welch t test? The worked data are constructed, not supplied by a learner.

## Recognize the method

The target is mean A minus mean B. The groups must be independent, not matched measurements on the same units. This page does not implement pooled equal-variance, one-sided, survey-weighted, clustered, or three-group testing.

## Numbered solution steps

1. Prespecify the two populations and the direction A minus B.
2. Inspect each group, its sample size, missingness and possible dependence.
3. Run the two-sided Welch test without pooling variances.
4. Report group summaries, the difference interval, degrees of freedom and p-value.

## Original worked example

Two invented batches have readings A = 12.1, 11.4, 13.0, 12.7, 11.9, 12.4 and B = 10.8, 11.2, 9.7, 12.0, 10.1, 11.6, 9.9, 10.5 units. Treat the batches as independent only for this constructed example.

## Use this in R

```r
group_a <- c(12.1, 11.4, 13.0, 12.7, 11.9, 12.4)
group_b <- c(10.8, 11.2, 9.7, 12.0, 10.1, 11.6, 9.9, 10.5)
confidence <- 0.95
valid_sample <- function(x) is.numeric(x) && !is.complex(x) &&
  length(x) >= 2L && all(is.finite(x)) && stats::sd(x) > 0
if (!valid_sample(group_a) || !valid_sample(group_b))
  stop("Each independent group needs at least two finite values and nonzero spread.")
if (!is.numeric(confidence) || length(confidence) != 1L ||
    !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Set confidence strictly between zero and one.")
fit <- stats::t.test(group_a, group_b, var.equal = FALSE,
                     alternative = "two.sided", conf.level = confidence)
result <- c(mean_a = mean(group_a), mean_b = mean(group_b),
            difference = mean(group_a)-mean(group_b),
            lower = fit$conf.int[1L], upper = fit$conf.int[2L],
            t = unname(fit$statistic), df = unname(fit$parameter), p = fit$p.value)
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| group_a / group_b | Independent populations and difference order | Two numeric samples in compatible units |
| confidence | Two-sided interval level | Prespecified number strictly between zero and one |
| var.equal = FALSE | Separate variance estimates | Keep FALSE for this Welch workflow |

## What to check

- Independence is required within and between groups. Repeated measurements from the same person are not independent groups.

- Welch addresses unequal variances, not biased sampling, severe small-sample nonnormality or dependence. Check outliers and distributions.

## Interpret your results

The estimated difference and interval are in the original measurement units. Welch degrees of freedom need not be an integer. Report the size and uncertainty of the difference, not only whether a threshold was crossed.

## Frequent mistakes

Equal group sizes do not establish equal variances. Do not switch to a pooled test because one variance comparison was nonsignificant. For matched data use the paired design.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
