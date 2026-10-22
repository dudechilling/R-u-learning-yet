# Development changes

## 0.4.2.9001 - student-first offline tutorials

The home now links to two offline, step-by-step exercises: a built-in-data histogram and a synthetic one-sample t confidence interval. Both provide Copy controls, expected observations, interpretation, and links to the verified references. Tutorials are linked from the home, usage help, Start here, and the shared Viewer navigation. Method routing is unchanged.

## 0.4.2.9000 - GitHub main lab release

Added a local home, `ru_home()`, guarded interactive RStudio attachment, a pre-attach opt-out, local help and ordered learning paths. Noninteractive package use remains separate from the Viewer.

Added ten original compact workflows: three t-test designs, a Wilson proportion interval, simple linear regression, Welch one-way ANOVA, OLS diagnostics, grouped binomial logistic regression, iid mean percentile bootstrap and Holm adjustment. The bootstrap restores the caller's RNG state. Method guards reject unsupported estimators and conflicting designs rather than substituting another method.

Added independent numerical, input-boundary and frozen routing checks. The original regression scenarios remain; catalogue membership and development-version assertions were updated to match verified additions. The catalogue now has 174 rows and 84 compact lessons, with unfinished topics labelled separately.

Prepared pinned multi-platform CI and scoped licences for newly authored material. Package-wide inherited-content review, historical distribution disposition, actual Windows RStudio acceptance and authentic IDE screenshots remain release gates. The prior source was published to GitHub main. Windows Viewer, clipboard, historical rights review and authentic GUI screenshots require their own acceptance evidence.
