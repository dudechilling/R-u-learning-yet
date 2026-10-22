---
id: normal_between
type: walkthrough
domain: Probability and random variables
aliases: normal between;normal interval probability;pnorm difference;between two normal values;normal distribution two bounds
related: normal_left_tail;normal_right_tail;normal_percentile;uniform_interval
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Normal.html
status: VERIFIED
---
# How do I calculate the probability between two values in a normal model?

## Immediate answer

For X ~ Normal(mu,sigma) with sigma > 0, P(lower < X < upper) equals stats::pnorm(upper,mean=mu,sd=sigma) minus stats::pnorm(lower,mean=mu,sd=sigma). A stable right-tail equivalent subtracts two upper tails when both limits lie to the right of the mean. The following worked example is original and does not supply an answer to an assessment.

## What the question asks

Calculate the fraction of an assumed normal distribution between two observed-value limits, not a test, confidence interval or a normal quantile.

## Recognize the method

Choose normal_between only when the model is normal and the event has two ordered bounds. Standard normal means mu=0, sigma=1; other parameters can be passed to pnorm directly, because R standardizes internally. Single bounds need a normal tail guide; qnorm finds a cutoff, and a confidence interval/test is a separate inference task.

## Numbered solution steps

1. State the normal assumption; enter the model mean and strictly positive standard deviation in consistent units.
2. Identify lower and upper observed-value cutoffs, with lower < upper.
3. Find each cumulative normal probability using pnorm and subtract lower from upper.
4. When both limits are right of the mean, subtract upper-tail probabilities instead to prevent cancellation near cumulative probability 1.
5. Check the probability is nonnegative and at most 1, then give a contextual model-based interpretation.

## Original worked example

Suppose a hypothetical automated timer has a normally modelled reading X with mean 28 seconds and standard deviation 4 seconds. What proportion of readings falls strictly between 25 and 34 seconds? The standardized limits are -0.75 and 1.5; the model probability is Phi(1.5) - Phi(-0.75).

## Use this in R

```r
mu_seconds <- 28
sigma_seconds <- 4
lower_seconds <- 25
upper_seconds <- 34
inputs <- c(mu_seconds, sigma_seconds, lower_seconds, upper_seconds)
stopifnot(all(is.numeric(inputs)), all(is.finite(inputs)),
          sigma_seconds > 0, lower_seconds < upper_seconds)
# Two CDF calls on either path; upper tails avoid cancellation on the right.
probability_between <- if (lower_seconds >= mu_seconds) {
  stats::pnorm(lower_seconds, mean = mu_seconds, sd = sigma_seconds,
               lower.tail = FALSE) -
    stats::pnorm(upper_seconds, mean = mu_seconds, sd = sigma_seconds,
                 lower.tail = FALSE)
} else {
  stats::pnorm(upper_seconds, mean = mu_seconds, sd = sigma_seconds) -
    stats::pnorm(lower_seconds, mean = mu_seconds, sd = sigma_seconds)
}
stopifnot(is.finite(probability_between), probability_between >= 0,
          probability_between <= 1)
probability_between
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mu_seconds` | Normal mean, seconds | Finite real model mean; 0 for standard normal |
| `sigma_seconds` | Normal standard deviation, seconds | Finite strictly positive model SD; 1 for standard normal |
| `lower_seconds` | Lower observed-value limit, seconds | Finite real lower limit |
| `upper_seconds` | Upper observed-value limit, seconds | Finite real value above lower_seconds |
| `lower.tail` | Numerically stable right-tail branch | Leave FALSE only in the right-tail calculation; code selects the branch automatically |

## What to check

- Normality is an assumption to justify separately; R cannot establish it from a mean and SD alone. The SD must be positive, bounds must be finite and ordered, and all values must use compatible units.
- At far-right limits, subtracting pnorm(upper)-pnorm(lower) can round both near-one CDFs to 1 and falsely return zero. The upper-tail branch avoids that cancellation where probabilities remain representable; all finite-precision methods eventually underflow for sufficiently tiny probabilities.

## Interpret your results

For the invented timer, the probability is the normal area between 25 and 34 seconds, not the probability that a particular reading has precisely one of the endpoint values. Normal continuous point probabilities are zero, so inclusive endpoints give the same interval probability.

## Frequent mistakes

Do not use one pnorm call to answer a two-bound question, use qnorm for an event probability, or interpret this as a confidence interval for mu. Avoid subtracting nearly equal CDFs near 1; the right-tail difference is more stable.

## Learn more

Official R documentation (API facts, not copied text): https://search.r-project.org/R/refmans/stats/html/Normal.html. All examples, wording and synthetic data are independently authored.