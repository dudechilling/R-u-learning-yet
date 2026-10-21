---
id: binomial
type: walkthrough
domain: Probability and random variables
aliases: binomial;dbinom;exact successes;at least successes;at most successes
related: bernoulli;poisson;probability_complement
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Binomial.html
status: VERIFIED
---
# When can I use a binomial model?

## Immediate answer

A binomial model counts successes in a fixed number n of independent two-outcome trials, with the same probability p each time. Mean=np and variance=np(1-p).

## Exam answer pattern

Check fixed n, two outcomes, independence and constant p. Distinguish exactly k, at most k and at least k.

## Use this in R

```r
n <- 10; p <- .3; k <- 3 # Constructed model
c(exact=dbinom(k,size=n,prob=p),
  at_most=pbinom(k,size=n,prob=p),
  at_least=1-pbinom(k-1,size=n,prob=p))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `n` | Fixed independent trials | Your trial count |
| `p` | Chance of success | Same for each trial |
| `k` | Requested count | Nonnegative integer |

## What to check

- Sampling without replacement can violate independence.
- At least k requires 1-P(X≤k−1), not 1-P(X≤k).

## Interpret your results

The calculated probability belongs to a specified count under the assumed trial model.

## Learn more

`dbinom()` returns exact mass, while `pbinom()` returns cumulative probability.
