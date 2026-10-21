---
id: probability_union
type: walkthrough
domain: Probability and random variables
aliases: union;A or B;addition rule;at least one;inclusion exclusion
related: probability_events;mutually_exclusive
visual:
alt:
caption:
sources:
status: VERIFIED
---
# How do I find the probability of A or B?

## Immediate answer

The general addition rule is P(A or B)=P(A)+P(B)-P(A and B). Subtract the overlap because it was counted twice.

## Exam answer pattern

Identify events and their intersection. Set the intersection to zero only when A and B are mutually exclusive.

## Use this in R

```r
pA <- .4; pB <- .3; pBoth <- .1  # Constructed model
pUnion <- pA + pB - pBoth
stopifnot(pUnion >= max(pA,pB), pUnion <= 1)
pUnion
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `pA, pB` | Individual event chances | Probabilities from the defined model |
| `pBoth` | Chance of both | Justified event intersection |

## What to check

- Probability 'or' includes both events occurring.
- Independent is not the same as mutually exclusive.

## Interpret your results

The union means at least one event happened and cannot be less probable than either individual event.

## Learn more

For at least one event, a complement may simplify the calculation if independence is justified.
