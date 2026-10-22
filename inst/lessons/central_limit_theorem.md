---
id: central_limit_theorem
type: concept
domain: Sampling and inference
aliases: central limit theorem;CLT;sample mean approaches normal;distribution of averages;why sample means become bell shaped;large sample normal approximation
related: sampling_distribution;standard_error;mean_confidence_interval;mean_ci_z
visual:
alt:
caption:
sources: https://online.stat.psu.edu/stat414/Lesson27
status: VERIFIED
---
# Why can a distribution of sample means become approximately normal?

## Immediate answer

For independent, identically distributed observations with population mean mu and a finite, positive population variance sigma squared, the standardized sample mean (sample_mean - mu)/(sigma/sqrt(n)) approaches a standard normal distribution as n grows. The population need not be normal, but the theorem concerns repeated-sample means, not a claim that the original measurements turn normal.

## What the question asks

Decide whether a normal approximation for a sampling distribution is justified. Separate the population distribution of individual observations, one observed sample, and the hypothetical distribution of sample means from repeated samples of the same size.

## Recognize the method

Use the central limit theorem when the question asks why averages or sums approach a normal sampling distribution under increasing sample size. Use sampling_distribution to describe repeated sampling without a normal-approximation claim, and standard_error to compare the variability of observations with the variability of the mean.

## Exam answer pattern

1. Identify independent, appropriately sampled observational units, the target population mean mu, and finite population variance sigma squared.
2. For iid samples of size n, the mean has expectation mu and standard error sigma/sqrt(n); the latter is the SD of repeated-sample means, not the population SD of individual observations.
3. The standardized mean converges in distribution to N(0,1) as n increases. Approximation quality depends on the population's tails, skewness and sampling mechanism; n >= 30 is not a theorem guaranteeing accuracy.
4. If observations are drawn independently from a normal population, the mean is exactly normal for every n, with variance sigma squared/n. Without a normal population, finite n does not ensure an exact normal distribution.
5. Check dependence, unequal selection probabilities, clustering, sampling without replacement, influential outliers and heavy tails before using an iid standard error or a normal-based interval. Some designs need weighted, cluster-aware or finite-population corrections.

## What to check

- Repeated observations of the same person or clustered measurements are not automatically independent. A large nominal n cannot cure unmodelled dependence.
- Infinite population variance invalidates this classical iid finite-variance CLT; unusually heavy tails may require much larger n even when the variance is finite.
- A small independent normal sample can have an exactly normal mean; its raw observations are not made normal by averaging.
- When sigma is unknown, the estimated standard error uses s/sqrt(n). This alone does not make a z confidence interval legitimate.

## Interpret your results

The CLT supports a model-based approximation for repeated sample means and corresponding inference under its assumptions. It does not verify that the actual study was representative, that individual data are normal, or that an interval has nominal coverage under a flawed design.

## Frequent mistakes

Do not treat 30 as a universal threshold, confuse individual SD with standard error, apply a naive iid formula to clustered measurements, or use the CLT alone to declare a small skewed sample normal.

## Learn more

The companion sampling_distribution page contains an original simulation of repeated samples. Public teaching reference: Penn State STAT 414, Lesson 27 (central limit theorem); text here is independently authored. The links below are optional and the lesson works offline.