---
id: anova_oneway
type: walkthrough
domain: Applied analysis
aliases: Welch ANOVA;oneway.test;heteroscedastic one way;unequal group variances
related: two_sample_t;multiple_testing_holm;hypotheses
visual:
alt:
caption:
sources: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/oneway.test.html
status: VERIFIED
---
# How do I compare independent group means with Welch one-way ANOVA?

## Immediate answer

Use stats::oneway.test(value ~ group, var.equal=FALSE) for an omnibus comparison of independent normal-population means without assuming equal variances. Welch ANOVA extends the two-sample Welch comparison to several groups.

## What the question asks

How do I compare independent group means with Welch one-way ANOVA? The worked data are constructed, not supplied by a learner.

## Recognize the method

Each unit belongs to one independent group and supplies a quantitative response. This example compares three or more groups. It is not classical pooled-variance aov, repeated-measures, factorial, clustered or binomial-outcome analysis.

## Numbered solution steps

1. Define the groups and omnibus null that their population means are equal.
2. Inspect group counts, distributions, missingness and variance estimates.
3. Run the one-way Welch test with separate group variances.
4. Report group summaries and the omnibus result; plan any follow-up comparisons with multiplicity control.

## Original worked example

Three fictional processes have constructed response vectors of lengths five, six and seven. The demonstration deliberately uses unequal spread and unequal group sizes.

## Use this in R

```r
samples <- list(A = c(4.1,4.4,4.8,4.5,4.7),
  B = c(4.9,5.7,5.2,6.1,4.8,5.5), C = c(5.8,6.4,7.2,5.9,6.8,7.6,6.1))
if (!is.list(samples) || length(samples) < 3L || is.null(names(samples)) ||
    any(!nzchar(names(samples))) || anyDuplicated(names(samples)) ||
    !all(vapply(samples, function(x) is.numeric(x) && !is.complex(x) &&
      length(x) >= 2L && all(is.finite(x)) && stats::sd(x) > 0, logical(1L))))
  stop("Supply at least three named independent groups with finite values and nonzero spread.")
values <- unlist(samples, use.names = FALSE)
group <- factor(rep(names(samples), lengths(samples)), levels = names(samples))
fit <- stats::oneway.test(values ~ group, var.equal = FALSE, na.action = stats::na.fail)
group_summary <- data.frame(group = names(samples), n = lengths(samples),
  mean = vapply(samples, mean, numeric(1L)), sd = vapply(samples, stats::sd, numeric(1L)))
result <- c(F = unname(fit$statistic), df1 = unname(fit$parameter[1L]),
            df2 = unname(fit$parameter[2L]), p = fit$p.value)
group_summary
result
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| samples | Independent groups | A named list of at least three numeric vectors in comparable units |
| group order | Reported comparison labels | Names specified before interpretation |
| var.equal = FALSE | Welch rather than pooled ANOVA | Keep FALSE for this workflow |

## What to check

- Independence is a design requirement. Welch handles unequal variances, not dependence, nonrandom group assignment or strong small-sample nonnormality.

- Each variance estimate needs replication. A group with zero spread or insufficient observations is rejected here.

## Interpret your results

A small omnibus p-value is evidence against equality of all means under the model. It does not identify which pairs differ and does not prove that every mean differs from every other mean. Show group sizes, means, SDs and substantive differences.

## Frequent mistakes

A nonsignificant result does not prove equal means. Do not substitute this for repeated-measures ANOVA or a Kruskal-Wallis rank procedure.

## Learn more

Use the linked official R documentation for argument and return-value semantics. This explanation, constructed case and native R example were independently authored for this library; source links are not copied lessons.
