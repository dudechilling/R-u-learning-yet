---
id: expected_value
type: walkthrough
domain: Probability and random variables
aliases: expected value;expectation;weighted probability mean;E(X)
related: pmf;random_variance
visual:
alt:
caption:
sources:
status: VERIFIED
---
# How do I find expected value from a PMF?

## Immediate answer

Multiply each possible value by its probability and add: E(X)=ΣxP(X=x). Expected value is a theoretical long-run average, not necessarily a possible outcome.

## Exam answer pattern

List outcomes with their probabilities, confirm the masses sum to one, then calculate the weighted sum.

## Use this in R

```r
x <- c(0,1,4); p <- c(.2,.5,.3) # Constructed model
stopifnot(isTRUE(all.equal(sum(p),1)))
sum(x*p)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x` | Discrete values | All supported numerical outcomes |
| `p` | Masses | Aligned probabilities totaling one |

## What to check

- Do not average values without their probability weights.
- Check that values and masses stay aligned.

## Interpret your results

A large value with low probability may still affect the expectation.

## Learn more

E(aX+b)=aE(X)+b for constants a,b.
