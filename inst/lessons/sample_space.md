---
id: sample_space
type: concept
domain: Probability and random variables
aliases: sample space;all possible outcomes;dice outcomes;die outcomes;events;experiment;possible results
related: probability_events;conditional_independence
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/sample.html
status: VERIFIED
---
# What is a sample space in probability?

## Immediate answer

A sample space lists every possible result of a chance experiment. For one fair six-sided die, the possible outcomes are 1, 2, 3, 4, 5 and 6.

## Use this in R

```r
# A theoretical chance model, not recorded throws
outcomes <- 1:6
event <- outcomes[outcomes > 4]
outcomes
event
length(event) / length(outcomes)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `outcomes <- 1:6` | All possible die results | The possible results of your chance experiment |
| `outcomes > 4` | Event of interest | The event described in your question |

## What to check

- Check that possible outcomes are mutually distinguishable and exhaustive.
- Equal counting probabilities require equally likely outcomes.
- Do not confuse modeled possibilities with recorded observations.

## Interpret your results

For a fair die, two of six equally likely outcomes are greater than four, so the modeled probability is 2/6, or 1/3. An observed sequence of throws is not the sample space.

## Learn more

For unequal outcome probabilities, counting equally many possibilities does not give the event probability. R `sample()` can simulate, but simulation does not establish the true model.
