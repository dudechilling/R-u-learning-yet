---
id: multiple_testing_holm
type: walkthrough
domain: Research workflows
aliases: Holm;p.adjust;familywise error;Holm Bonferroni;step down;multiple testing
related: hypotheses;p_value;anova_oneway
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/p.adjust.html
status: VERIFIED
---
# How do I control familywise error with Holm-adjusted p-values?

## Immediate answer

Use stats::p.adjust(raw_p, method="holm") on the entire prespecified family of valid p-values. Holm controls the probability of at least one false rejection under the global familywise criterion without requiring independent p-values.

## What the question asks

How do I control familywise error with Holm-adjusted p-values? The worked data are constructed, not supplied by a learner.

## Recognize the method

The inputs are p-values already computed by defensible individual tests. Holm is not a method for generating raw p-values and is not a false-discovery-rate procedure. The family must not be selected by keeping only significant results.

## Numbered solution steps

1. Define the hypothesis family and error-control objective before screening results.
2. Check that each p-value is finite, lies between zero and one, and corresponds to a valid test.
3. Adjust the full vector with method="holm" and retain original labels.
4. Report raw and adjusted values, the family size and the prespecified alpha.

## Original worked example

A fictional six-test family has raw p-values 0.002, 0.014, 0.031, 0.20, 0.42 and 0.06. The values illustrate multiplicity calculations; they are not claims about six real studies.

## Use this in R

```r
raw_p <- c(test_a=.002, test_b=.014, test_c=.031, test_d=.20, test_e=.42, test_f=.06)
alpha <- 0.05
if (!is.numeric(raw_p) || is.complex(raw_p) || length(raw_p)<1L ||
    any(!is.finite(raw_p)) || any(raw_p<0 | raw_p>1))
  stop("Supply the full prespecified vector of finite p-values between zero and one.")
if (!is.numeric(alpha) || length(alpha)!=1L || !is.finite(alpha) || alpha<=0 || alpha>=1)
  stop("Set the familywise alpha strictly between zero and one.")
adjusted <- stats::p.adjust(raw_p, method="holm")
result <- data.frame(hypothesis=if (is.null(names(raw_p))) seq_along(raw_p) else names(raw_p),
  raw_p=unname(raw_p), holm_p=unname(adjusted), reject=unname(adjusted)<=alpha)
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| raw_p | Entire prespecified hypothesis family | Valid individual-test p-values, retaining all planned tests |
| alpha | Familywise rejection threshold | A threshold selected before examining results |
| method="holm" | Step-down familywise correction | Keep Holm; FDR methods answer a different error-control question |

## What to check

- The guarantee depends on valid raw p-values for true nulls and an appropriate fixed family. Holm cannot repair invalid models, selective reporting or data-dependent hypothesis generation.

- Dependence of valid p-values does not by itself invalidate Holm. Familywise error and false discovery rate are different quantities.

## Interpret your results

Compare each Holm-adjusted p-value with the familywise alpha. An adjusted p-value is not the probability that its hypothesis is false or an effect size. Keep effect estimates and uncertainty beside multiplicity reporting.

## Frequent mistakes

Do not apply Holm only to the raw p-values that were already significant. Do not substitute Benjamini-Hochberg or Hochberg while retaining a Holm label.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
