---
id: ci_method_selection
type: concept
domain: Sampling and inference
aliases: z or t for confidence interval;choose confidence interval method;confidence interval method selection;known versus unknown sigma;which interval should I use;z versus t for mean estimate
related: mean_ci_z;mean_confidence_interval;confidence_intervals;proportion_interval;independent_paired
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/stats/html/t.test.html;https://search.r-project.org/R/refmans/stats/html/Normal.html
status: VERIFIED
---
# Should I use a z interval, t interval, or another confidence-interval method?

## Immediate answer

Choose the parameter and study design before choosing a critical value. For a single numeric population mean with independently known population SD sigma, use mean_ci_z under its model assumptions. For one mean with unknown sigma estimated by sample SD s, use mean_confidence_interval (a t interval). For a yes/no population proportion, inspect proportion_interval for the two-sided Wilson score interval and its binomial sampling conditions. If the question asks for a hypothesis test rather than interval estimation, do not substitute a confidence interval.

## What the question asks

Select a defensible method, not compute bounds without observations, a parameter, confidence level and sampling structure. The number of observations alone does not determine z versus t.

## Recognize the method

1. Identify the target parameter: numeric mean, binary proportion or another quantity. If unspecified, ask what is being estimated rather than guessing.
2. Determine whether the data represent one population, two independent groups, or paired/repeated measurements. A one-sample interval cannot silently stand in for a two-group difference; dependence and clustering affect the standard error.
3. For one mean, ask whether population sigma is genuinely known independently, or whether only sample s is available. Known sigma points to mean_ci_z; estimated s points to mean_confidence_interval. Known variance needs a square root before entering a known-SD formula.
4. Confirm the sampling assumptions, sample size, confidence level and whether the request is two-sided. Large n may improve an approximation but does not convert estimated sigma into known sigma.
5. For a proportion, use the verified proportion_interval Wilson reference only after checking binomial sampling and its method-specific conditions. A proportion test, variance test or unsupported hypothesis direction needs a different, separately reviewed method; do not recommend a descriptive calculation in their place.

## Exam answer pattern

State the parameter, number of populations, sampling structure, known-versus-estimated SD, confidence level and inference goal. Then name the matching method and at least one assumption; if any decisive fact is absent or contradictory, request clarification rather than generating confident numeric results.

## What to check

- A 95% confidence level describes repeated-procedure coverage under assumptions; it does not assign a 95% chance to a fixed population mean after one interval is observed.
- One mean with known sigma is not interchangeable with a t interval for unknown sigma. Known population variance is in squared units, so sigma = sqrt(variance).
- 'Paired observations', 'two independent samples' and 'one numeric sample' are different designs; select the appropriate checked procedure or abstain until design details are known.
- Asking for H0, a p-value, significance, an increase/decrease alternative, or a test of population variance is not a mean confidence-interval calculation.

## Interpret your results

Method selection is a conditional decision, not a calculated answer. Once the target parameter and design are established, open a computational reference with actual numeric inputs. No confidence limits should be inferred from the question's wording alone.

## Frequent mistakes

Do not choose z only because n is large, switch to t because n is small when a genuine population sigma is known, use sample SD as known sigma, apply a one-sample guide to grouped data, or confuse a proportion confidence interval with a proportion hypothesis test.

## Learn more

Verified computational pages: mean_ci_z and mean_confidence_interval. The confidence_intervals page explains long-run coverage. The compact proportion_interval page now provides an independently checked Wilson score interval; its older full walkthrough remains compatibility material. R's official t.test and Normal documentation distinguishes t intervals and normal quantiles; these words are independently authored.