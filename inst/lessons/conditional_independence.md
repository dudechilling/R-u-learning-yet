---
id: conditional_independence
type: walkthrough
domain: Probability and random variables
aliases: conditional probability;P(A given B);independence;P(A|B);without replacement
related: mutually_exclusive;probability_complement
visual:
alt:
caption:
sources:
status: VERIFIED
---
# How do conditional probability and independence differ?

## Immediate answer

If P(B)>0, P(A given B)=P(A and B)/P(B). Independence means P(A given B)=P(A), equivalently P(A and B)=P(A)P(B).

## Exam answer pattern

Identify B as the conditioning information and compute the overlap. Check independence mathematically instead of assuming it.

## Use this in R

```r
pA <- .4; pB <- .5; pBoth <- .2  # Constructed event model
pConditional <- pBoth / pB
c(conditional=pConditional,
  independent=as.numeric(isTRUE(all.equal(pBoth,pA*pB))))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `pBoth` | Intersection probability | Chance of both A and B |
| `pB` | Conditioning event chance | Must be greater than zero |
| `pA` | Original event chance | Probability before learning B |

## What to check

- Never divide by P(B)=0.
- Without-replacement sampling typically changes later probabilities.
- Mutual exclusivity is not independence.

## Interpret your results

Conditioning restricts attention to cases where B occurred; independence means that restriction does not change A's probability.

## Learn more

Probabilistic association alone cannot establish a causal relationship.
