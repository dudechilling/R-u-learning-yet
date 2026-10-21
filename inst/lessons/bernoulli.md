---
id: bernoulli
type: walkthrough
domain: Probability and random variables
aliases: Bernoulli;one binary trial;binary random variable
related: binomial;pmf
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/Binomial.html
status: VERIFIED
---
# What is a Bernoulli trial?

## Immediate answer

A Bernoulli variable takes 0 or 1 on one trial, with P(X=1)=p. Its mean is p and variance is p(1-p).

## Exam answer pattern

Define success and failure explicitly. Check that the experiment really has two outcomes under the model.

## Use this in R

```r
p <- .3  # Constructed success chance
data.frame(outcome=0:1,mass=dbinom(0:1,size=1,prob=p))
c(mean=p,variance=p*(1-p))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `p` | Success chance | Value from 0 to 1 |
| `size=1` | One trial | Keep for Bernoulli |

## What to check

- A binomial count describes multiple Bernoulli trials.
- The label success need not imply a desirable real-world result.

## Interpret your results

The theoretical expectation p need not be an outcome seen on one trial.

## Learn more

`dbinom(x,size=1,prob=p)` gives the Bernoulli PMF in base R.
