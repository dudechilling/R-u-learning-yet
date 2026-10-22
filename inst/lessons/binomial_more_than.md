---
id: binomial_more_than
type: walkthrough
domain: Probability and random variables
aliases: binomial more than;binomial greater than;binomial exceeds;strictly more than;pbinom upper tail;X>k successes
related: binomial;probability_complement;poisson_upper_tail
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Binomial.html
status: VERIFIED
---
# How do I compute strictly more than k successes in a binomial model?

## Immediate answer

For X ~ Binomial(n,p), P(X > k) is stats::pbinom(k,size=n,prob=p,lower.tail=FALSE). At least k includes k, so P(X >= k) uses k-1 as the upper-tail cutoff. Exactly k instead uses stats::dbinom(k,size=n,prob=p). The following worked example is original and does not supply an answer to an assessment.

## What the question asks

Find the chance of a strictly greater number of successes than a stated whole-number threshold across fixed independent binary trials with one shared success probability.

## Recognize the method

Use the binomial model only when n is a fixed nonnegative whole number of independent Bernoulli trials, each trial is success/failure, and the same probability p applies. A Poisson event rate per interval is different. Named binomial hypothesis tests and binomial CDF lower tails are not this question.

## Numbered solution steps

1. Identify n independent binary trials and a common success probability p.
2. Confirm that the question asks for strictly more than k rather than at least k or exactly k.
3. Validate finite integer n >= 0, p in [0,1], and an integer threshold k (which may lie outside 0..n).
4. Call pbinom(k,n,p,lower.tail=FALSE) to obtain the direct upper tail.
5. For comparison, evaluate pbinom(k-1,n,p,lower.tail=FALSE) and dbinom(k,n,p); their difference confirms the k boundary.

## Original worked example

In a fictional quality check, 9 independently inspected units each have a modelled 0.35 probability of meeting a yes/no criterion. Find the probability of strictly more than 3 positive outcomes. Independently, sum binomial masses for counts 4 through 9; at least 3 also includes the count 3.

## Use this in R

```r
size_trials <- 9L
success_probability <- 0.35
cutoff_successes <- 3L
stopifnot(is.numeric(size_trials), length(size_trials) == 1L,
          is.finite(size_trials), size_trials >= 0,
          size_trials == floor(size_trials),
          is.numeric(success_probability), length(success_probability) == 1L,
          is.finite(success_probability), success_probability >= 0,
          success_probability <= 1,
          is.numeric(cutoff_successes), length(cutoff_successes) == 1L,
          is.finite(cutoff_successes),
          cutoff_successes == floor(cutoff_successes))
more_than <- stats::pbinom(cutoff_successes, size = size_trials,
                            prob = success_probability, lower.tail = FALSE)
at_least <- stats::pbinom(cutoff_successes - 1, size = size_trials,
                           prob = success_probability, lower.tail = FALSE)
exactly <- stats::dbinom(cutoff_successes, size = size_trials,
                          prob = success_probability)
c(strictly_more = more_than, inclusive_at_least = at_least,
  exactly_cutoff = exactly)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `size_trials` | Fixed number of Bernoulli trials, trials | Finite nonnegative whole number, including n=0 |
| `success_probability` | Common probability per independent trial | Finite number from 0 through 1 inclusive |
| `cutoff_successes` | Strict/inclusive event boundary, successes | Finite whole-number cutoff k; outside 0..n is meaningful |
| `lower.tail` | Whether pbinom gives upper-tail probabilities | Keep FALSE for more than or at least; changing it changes the event |

## What to check

- A fixed sample size, independent success/failure trials, and constant p are assumptions, not facts established by the formula. These computations are probabilities, not binom.test hypothesis tests.
- When n=0, X=0 always. For k>=n, P(X>k)=0; for k<0, P(X>k)=1. With p=0 all mass is at 0; with p=1 all mass is at n. The k-1 shift is essential for inclusive at least.

## Interpret your results

Under this made-up model, strictly more than 3 means 4 to 9 successes. At least 3 includes the count 3. The amount by which these probabilities differ is exactly P(X=3), calculated by dbinom.

## Frequent mistakes

Never call at least 3 the same event as more than 3. Do not silently replace a Poisson rate with p, subtract 1-pbinom near one if a direct upper-tail calculation is available, or use binom.test when the question only asks a model probability.

## Learn more

Official R documentation (API facts, not copied text): https://search.r-project.org/R/refmans/stats/html/Binomial.html. All examples, wording and synthetic data are independently authored.