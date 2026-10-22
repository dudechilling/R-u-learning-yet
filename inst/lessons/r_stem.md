---
id: r_stem
type: walkthrough
domain: Data visualization
aliases: stem leaf plot;stem-and-leaf;create stem and leaf;stem plot;stem scale;leaves
related: histogram;histogram_breaks;distribution_shape
visual:
alt:
caption:
sources: https://search.r-project.org/R/refmans/graphics/html/stem.html
status: VERIFIED
---
# How do I make and read a stem-and-leaf plot?

## Immediate answer

Use `stem(x)` to arrange numerical values by leading digits (stems) and final digits (leaves). It shows the original digits rather than drawing solid histogram bars.

## Use this in R

```r
data(mtcars)
stem(mtcars$hp, scale=1)
```

## What to edit

| Element | What it controls | What to replace it with |
| --- | --- | --- |
| `mtcars$hp` | Horsepower observations | Your numerical measurements |
| `scale=1` | How many stems and leaves appear | Try `scale=2` for more detail |

## What to check

- Use numerical values; a category label does not have a meaningful numerical stem.
- Read the key printed by R before interpreting a leaf.
- Check whether `scale` makes the display too sparse or too crowded.

## Interpret your results

Each leaf is a recorded value represented by the stem plus leaf according to the printed key. Several leaves on one stem mean several observations in that numerical band.

## Learn more

Compare `stem(mtcars$hp, scale=1)` and `stem(mtcars$hp, scale=2)`. Increasing scale often produces a longer display but does not create new observations.
