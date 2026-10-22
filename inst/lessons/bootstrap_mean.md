---
id: bootstrap_mean
type: walkthrough
domain: Research workflows
aliases: iid bootstrap mean;percentile bootstrap;resample with replacement;nonparametric mean bootstrap;sample.int
related: sampling_distribution;standard_error;confidence_intervals
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/base/html/sample.html;https://stat.ethz.ch/R-manual/R-devel/library/stats/html/quantile.html;https://stat.ethz.ch/R-manual/R-devel/library/boot/html/boot.html
status: VERIFIED
---
# How do I bootstrap an iid mean and a percentile interval?

## Immediate answer

Resample n observations with replacement from the observed sample, calculate the mean for each resample, and inspect the resulting bootstrap distribution. Percentile endpoints are quantiles of that distribution. This is an approximation based on the empirical distribution, not a guarantee of coverage.

## What the question asks

How do I bootstrap an iid mean and a percentile interval? The worked data are constructed, not supplied by a learner.

## Recognize the method

This page estimates one arithmetic mean from iid quantitative observations. It does not implement block, cluster, parametric, BCa, studentized, median or survey bootstrap procedures. Resampling cannot repair biased sampling.

## Numbered solution steps

1. Justify the independent identically distributed sampling unit and define the target mean.
2. Select a resample count, confidence level and reproducible seed.
3. Generate same-size resamples with replacement and retain each mean.
4. Report the sample mean, bootstrap standard error, percentile endpoints and sensitivity to resample count and sampling assumptions.

## Original worked example

Twelve invented measurements are 4.2, 5.1, 4.8, 6.0, 5.6, 4.9, 5.4, 6.2, 5.8, 4.6, 5.3 and 5.7 units. The example uses 4,999 iid resamples and preserves the caller's random-number generator settings and state.

## Use this in R

```r
measurements <- c(4.2,5.1,4.8,6.0,5.6,4.9,5.4,6.2,5.8,4.6,5.3,5.7)
B <- 4999L
confidence <- 0.95
seed <- 841L
bootstrap_mean <- function(x, B, confidence, seed) {
  if (!is.numeric(x) || is.complex(x) || length(x) < 2L || any(!is.finite(x)) || stats::sd(x) <= 0)
    stop("Supply at least two finite iid measurements with nonzero spread.")
  if (!is.numeric(B) || length(B)!=1L || !is.finite(B) || B!=floor(B) || B<1000 || B>1000000)
    stop("Use an integer resample count from 1000 to 1000000.")
  if (!is.numeric(confidence) || length(confidence)!=1L || !is.finite(confidence) || confidence<=0 || confidence>=1)
    stop("Set confidence strictly between zero and one.")
  if (!is.numeric(seed) || length(seed)!=1L || !is.finite(seed) || seed!=floor(seed) || seed<0 || seed>.Machine$integer.max)
    stop("Use a nonnegative integer seed within the R integer range.")
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir=.GlobalEnv, inherits=FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir=.GlobalEnv, inherits=FALSE)
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) assign(".Random.seed", old_seed, envir=.GlobalEnv)
    else if (exists(".Random.seed", envir=.GlobalEnv, inherits=FALSE)) rm(".Random.seed", envir=.GlobalEnv)
  })
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  means <- replicate(B, mean(x[sample.int(length(x), length(x), replace=TRUE)]))
  limits <- stats::quantile(means, c((1-confidence)/2,(1+confidence)/2), type=6, names=FALSE)
  list(estimate=mean(x), standard_error=stats::sd(means), interval=limits, means=means)
}
result <- bootstrap_mean(measurements, B, confidence, seed)
c(mean=result$estimate, bootstrap_se=result$standard_error,
  lower=result$interval[1L], upper=result$interval[2L])
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| measurements | Empirical iid sampling units | Your finite quantitative sample with a justified sampling design |
| B | Monte Carlo precision | At least 1000 resamples; inspect stability with a larger count |
| confidence / seed | Percentile coverage target and repeatability | Prespecified confidence and a recorded integer seed |

## What to check

- The iid bootstrap resamples individual units. Dependence or cluster sampling requires a different resampling scheme.

- Percentile intervals can have poor coverage for small, biased, highly skewed or otherwise difficult samples. Monte Carlo stability is not proof of inferential coverage.

- Record the R version, RNG kind, seed, resample count and quantile type. The helper restores RNG state even when its calculation raises an error.

## Interpret your results

The bootstrap standard error estimates uncertainty of the sample mean under empirical resampling. It is not the SD of individual measurements. The endpoints are approximate percentile confidence limits, not a prediction interval for a new observation.

## Frequent mistakes

Do not resample without replacement and call it the ordinary bootstrap. More resamples reduce Monte Carlo error but cannot remove selection bias or make dependent observations iid.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
