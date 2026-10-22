---
id: paired_t
type: walkthrough
domain: Core inference
aliases: paired t;matched pairs;before after;within person difference;paired=TRUE
related: two_sample_t;hypotheses;p_value
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html
status: VERIFIED
---
# How do I test a mean change in matched pairs?

## Immediate answer

A paired t test is a one-sample t test on within-pair differences. Use aligned pairs and state the subtraction direction. This example tests the mean after-minus-before change against zero with a two-sided alternative.

## What the question asks

How do I test a mean change in matched pairs? The worked data are constructed, not supplied by a learner.

## Recognize the method

Each row is one subject or matched unit observed twice. Different rows must supply independent differences. Unrelated samples, binary changes, three or more measurement times and multilevel dependence need another method.

## Numbered solution steps

1. Match rows by stable unit identifier before computing differences.
2. Define after minus before and check that every pair is complete.
3. Inspect the difference distribution, not only the two marginal distributions.
4. Run the paired test and report the mean change, interval and p-value.

## Original worked example

Eight fictional devices are measured before and after one adjustment. The paired readings are deliberately constructed, and this example supplies no evidence of a causal treatment effect.

## Use this in R

```r
paired_data <- data.frame(id = seq_len(8L),
  before = c(18,21,20,17,23,19,22,20), after = c(17,19,20,16,20,18,20,19))
confidence <- 0.95
if (!is.data.frame(paired_data) ||
    !all(c("id","before","after") %in% names(paired_data)) ||
    nrow(paired_data) < 2L || anyNA(paired_data$id) || anyDuplicated(paired_data$id))
  stop("Supply at least two uniquely identified complete pairs.")
if (!is.numeric(paired_data$before) || !is.numeric(paired_data$after) ||
    is.complex(paired_data$before) || is.complex(paired_data$after) ||
    any(!is.finite(paired_data$before)) || any(!is.finite(paired_data$after)))
  stop("Both measurements must be finite numeric values in compatible units.")
difference <- paired_data$after - paired_data$before
if (stats::sd(difference) <= 0) stop("Paired differences need nonzero spread.")
if (!is.numeric(confidence) || length(confidence) != 1L ||
    !is.finite(confidence) || confidence <= 0 || confidence >= 1)
  stop("Set confidence strictly between zero and one.")
fit <- stats::t.test(paired_data$after, paired_data$before, paired = TRUE,
                     mu = 0, alternative = "two.sided", conf.level = confidence)
result <- c(change = mean(difference), lower = fit$conf.int[1L],
            upper = fit$conf.int[2L], t = unname(fit$statistic),
            df = unname(fit$parameter), p = fit$p.value)
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| paired_data | Rows that must remain matched | Your data with a unique ID and two measurements per unit |
| after - before | Meaning and sign of change | A prespecified subtraction order |
| confidence | Two-sided change interval level | A number strictly between zero and one |

## What to check

- The differences must be independent across units. Small-sample exact t inference assumes normally distributed differences.

- Do not sort the before and after columns separately. Missing pairs require an explicit missing-data decision; this example rejects them.

## Interpret your results

A negative mean change means the after measurement is lower in the chosen units. The interval describes a population mean change under the design and model. Pairing reduces some between-unit variation but does not by itself control confounding.

## Frequent mistakes

Do not compare two separate unpaired tests or their significance labels to infer change. A paired analysis is not appropriate merely because vectors have the same length.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
