---
id: random_variance
type: walkthrough
domain: Probability and random variables
aliases: random variable variance;theoretical spread;weighted squared deviation
related: expected_value;pmf;variance
visual:
alt:
caption:
sources:
status: VERIFIED
---
# What is variance of a random variable?

## Immediate answer

For a discrete PMF, Var(X)=Σ(x−μ)^2 P(X=x), where μ=E(X). This differs from R's sample `var()`, which uses an n−1 denominator.

## Exam answer pattern

Compute the model mean first, then weight squared deviations by their probabilities.

## Use this in R

```r
x <- c(0,1,4); p <- c(.2,.5,.3)
mu <- sum(x*p)
c(mean=mu,variance=sum((x-mu)^2*p),sd=sqrt(sum((x-mu)^2*p)))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x` | Discrete outcomes | Your model support |
| `p` | Event mass | Probabilities aligned to x |

## What to check

- Probability masses must sum to one.
- Variance has squared outcome units.

## Interpret your results

The square root of variance is a theoretical standard deviation in the original units.

## Learn more

An equivalent identity is E(X²)-[E(X)]².
