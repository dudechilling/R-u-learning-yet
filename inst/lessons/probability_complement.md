---
id: probability_complement
type: walkthrough
domain: Probability and random variables
aliases: complement;not A;one minus;none;at least one
related: probability_union;conditional_independence
visual:
alt:
caption:
sources:
status: VERIFIED
---
# What is the complement of an event?

## Immediate answer

Not A contains every sample-space outcome outside A. Its probability is 1-P(A).

## Exam answer pattern

Say precisely which outcomes count as A and which are excluded, and verify they partition the space.

## Use this in R

```r
pA <- 0.3  # Constructed model
c(A=pA,not_A=1-pA)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `pA` | Chance of A | A justified probability between 0 and 1 |

## What to check

- A complement is not automatically independent of A.
- Endpoint equality matters when defining numerical intervals.

## Interpret your results

If P(A)=0.3, P(not A)=0.7 under that model.

## Learn more

For at least one independent success across n trials, consider 1 minus the chance of no successes.
