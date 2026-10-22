---
id: discrete_pmf
type: walkthrough
domain: Probability and random variables
aliases: discrete PMF;dice sum;probability mass;independent outcomes
related: binomial;probability_events;probability_complement
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/base/html/outer.html
status: VERIFIED
---
# How do I make a PMF for a sum of fair dice?

## Immediate answer

For a finite discrete random variable, the PMF assigns P(X=k) to each distinct support value k. For equally likely independent dice, enumerate ordered pairs and divide the count for each sum by all possible pairs. The synthetic worked example is not an assignment-specific answer.

## What the question asks

Identify the random variable, support or event-rate model, and event boundary.

## Recognize the method

Use the named method only with its prerequisites. outer, table and prop.table count duplicate sums; never fit a binomial model to a sum of dice.

## Numbered solution steps

1. Identify the model and its units. 2. Verify inputs and assumptions. 3. Translate the exact event operation. 4. Run the native R code and interpret the probability.

## Original worked example

For an invented fair four-faced and six-faced die, the sum five has probability 4/24 = 1/6.

## Use this in R

```r
x <- as.vector(outer(1:4, 1:6, '+'))
p <- prop.table(table(x))
stopifnot(all(p >= 0), abs(sum(p) - 1) < 1e-12)
data.frame(sum = as.integer(names(p)), mass = as.numeric(p))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| a and b | Faces of independent dice | Substitute explicit equiprobable outcome sets |
| x | Sum of ordered pairs | Replace operation if variable changes |

## What to check

Check finite and valid model inputs; no private datasets or observed measurements are supplied. Where a probability vector is used, require nonnegative entries and total mass one.

## Interpret your results

Each ordered pair is equally likely. Frequencies from a random sample are estimates, not the theoretical PMF. For a validated discrete PMF, sum the mass of all outcomes giving k.

## Frequent mistakes

outer, table and prop.table count duplicate sums; never fit a binomial model to a sum of dice.

## Learn more

Official R documentation: https://search.r-project.org/R/refmans/base/html/outer.html. Explanation and examples are original.
