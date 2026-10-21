---
id: significant_figures
type: concept
domain: Data and measurement
aliases: significant digits;sig figs;0.0030;trailing zeros;precision of measurement;scientific notation
related: measurement_scales;accuracy_precision;percentile_rank
visual:
alt:
caption:
sources: https://www.nist.gov/pml/special-publication-811/nist-guide-si-chapter-7-rules-and-style-conventions-expressing-values
status: VERIFIED
---
# How do I count significant figures?

## Immediate answer

Leading zeros locate the decimal place but do not count. Nonzero digits and zeros after a decimal that follow significant digits count; 0.0030 has two significant figures: 3 and the final 0.

## Exam answer pattern

State which digits convey recorded precision. For 0.0030, identify the leading zero placeholders, then the 3 and the final 0. Explain why changing the unit does not change the original measurement precision.

## What to check

- Do not mistake decimal places for significant figures.
- An exact count, such as 50 participants, is not a rounded measurement.
- Report the chosen rounding rule and avoid claiming measured precision that was not recorded.

## Interpret your results

The final zero in 0.0030 signals a precision to the ten-thousandth place. Scientific notation expresses this as 3.0 × 10^-3 without losing the two significant figures.

## Learn more

In scientific notation, writing 3 × 10^-3 would express one significant digit. Computing in R uses stored numeric values; its default printing does not preserve how many trailing zeros were originally measured.
