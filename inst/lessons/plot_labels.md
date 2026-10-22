---
id: plot_labels
type: walkthrough
domain: Data visualization
aliases: main xlab ylab col legend;labels axes;graph title;plot colors;text;annotation
related: scatterplot;histogram;bar_chart;axes
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/graphics/html/title.html
status: VERIFIED
---
# How do I add labels and a legend to a graph?

## Immediate answer

For base R plots, `main` sets the title, `xlab` and `ylab` label the axes, and `col` controls colour. Use `legend()` to explain marks and lines.

## Use this in R

```r
data(mtcars)
plot(mtcars$wt, mtcars$mpg, pch=19,
     col="navy", main="Recorded vehicles",
     xlab="Weight (1000 lb)", ylab="Fuel economy (mpg)")
legend("topright",legend="Recorded vehicle",
       pch=19,col="navy",bty="n")
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$wt` | Horizontal measurements | Your numeric x variable |
| `mtcars$mpg` | Vertical measurements | Your numeric y variable |
| `xlab` and `ylab` | Axis labels | Actual variables and units |
| `legend()` | Explanation of marks | The meaning of the marks actually plotted |

## What to check

- Check units in the dataset help page.
- Text should remain readable without relying on colour alone.
- A legend should explain something, not repeat unnecessary decoration.

## Interpret your results

The plotted points pair weight and fuel economy from each recorded vehicle. Labels identify what is being compared, not whether an association is causal.

## Learn more

For line labels use `text()` sparingly; for reference lines use `abline()` with an explanation. Do not label an arbitrary graph limit as a measured extreme.
