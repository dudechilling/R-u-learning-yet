---
id: describe_numeric
type: walkthrough
collection: w2.reference.v1
domain: Descriptive statistics
aliases: describe numeric;numeric summary;AN-01;describe.numeric;mean median range missing
related: mean;missing_values;inspect_columns;histogram_interpret;histogram
visual: observed-missing-flow.svg
alt: Constructed example with four source readings, one NA and three usable values. After a documented complete-case decision, the three observed values 13, 18 and 20 have mean 17 degrees Celsius.
caption: Numeric description of a constructed example: raw n=4, observed n=3, missing n=1. A valid plan must separately confirm the source, units, missing-data choice and live data snapshot.
sources: https://search.r-project.org/R/refmans/base/html/mean.html;https://search.r-project.org/R/refmans/stats/html/sd.html
status: AUTHORED
---
# How do I describe a numeric outcome safely?

## Immediate answer

Identify the actual numeric column, source, declared measurement units and raw sample size. Count missing values, decide whether complete-case omission is justified, then report the observed sample size, center and spread. This reference does not run `AN-01 / describe.numeric` or certify its plan as ready.

## Use this in R

```r
# Constructed teaching data; declared units: degrees Celsius.
x <- c(13, NA_real_, 18, 20)
n_raw <- length(x)
n_missing <- sum(is.na(x))
# Run only after recording an appropriate exclusion decision:
observed <- x[!is.na(x)]
c(raw=n_raw, missing=n_missing, observed=length(observed))
c(mean=mean(observed), median=median(observed),
  sample_sd=sd(observed), minimum=min(observed), maximum=max(observed))
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `x` | The example numeric observations | A verified imported numeric column |
| `observed` | Selected nonmissing entries | An explicitly recorded missingness rule |
| `sd(observed)` | Sample standard deviation | Report NA or insufficient size when appropriate |

## What to check

- Distinguish the constructed `temp_c` demonstration from L2's guided CSV `reading`; the latter has its own source ID, file digest and Celsius declaration.
- Missingness can change the denominator. Never silently infer units, observational independence or sampling method.
- The sample standard deviation needs at least two observed values.
- A real Analysis action requires current data binding, explicit attestations and a confirmed plan; a static reference cannot execute or export results.

## Interpret your results

For the constructed four values, raw n is 4, missing n is 1 and observed n is 3. With justified omission the observed mean is 17, median 18 and sample standard deviation is approximately 3.606 degrees Celsius. These are not inferential estimates of unobserved values.

## Learn more

Inspect `?mean`, `?median` and `?sd` for native behavior. Open `histogram_interpret` for interval-based visual interpretation using a completely different built-in iris dataset.
