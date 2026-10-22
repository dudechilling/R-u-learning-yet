---
id: relative_frequency
type: walkthrough
domain: Data visualization
aliases: relative frequency;category proportion;percent counts;calculate percentages;table proportion
related: frequency_table;cumulative_frequency;bar_chart
visual:
alt:
caption:
sources:
status: VERIFIED
---
# How do I calculate relative frequency and percentage?

## Immediate answer

Relative frequency is a category count divided by the total number of included observations. Multiply by 100 to express it as a percentage; the denominator and any excluded values must be stated.

## Exam answer pattern

Identify what one row represents and the relevant denominator. If the question supplies a grouped count table, divide those counts directly rather than counting the count rows again.

## Use this in R

```r
data(iris)
counts <- table(iris$Species)
relative <- counts / sum(counts)
data.frame(category=names(counts),
           count=as.integer(counts),
           proportion=as.numeric(relative),
           percent=round(100*as.numeric(relative),1))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `iris$Species` | Recorded category column | Your observed category or counted groups |
| `sum(counts)` | Total usable observations | Do not replace with number of categories |
| `round(...,1)` | Display rounding | Requested decimal places or precision |

## What to check

- The frequencies must sum to the number of usable observations.
- Relative frequencies usually sum to one, apart from rounding.
- Missing category labels must be handled explicitly.

## Interpret your results

The result describes proportions within the recorded sample. It does not establish proportions in a wider population without sampling assumptions.

## Learn more

For numeric bins, the frequency is associated with each interval. For category labels, use a bar plot; do not confuse percentages with density heights.
