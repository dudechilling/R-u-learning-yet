## ---- quick-grouped-boxplot
data(iris)
boxplot(Sepal.Length ~ Species, data=iris,
        main="Sepal length by species",
        xlab="Species", ylab="Sepal length (cm)")

## ---- worked-grouped-boxplot
# THE QUESTION: How do sepal lengths compare across flower species?
# Dataset: iris, included with R. Sepal.Length is in centimetres.
# No custom plotting helper is required.

data("iris", package="datasets")

# 1. SELECT: change x and group to columns in your own table.
x <- iris$Sepal.Length
group <- iris$Species
measurement_units <- "cm"
measurement_label <- "Sepal length (cm)"
group_label <- "Flower species"
plot_title <- "Sepal length by species"

# 2. CHECK: a group label must belong to the same observation as x.
keep <- is.finite(x) & !is.na(group)
cat("Removed incomplete rows:",sum(!keep),"\n")
x <- x[keep]
group <- droplevels(factor(group[keep]))

# 3. CALCULATE: group sizes and medians before drawing anything.
counts <- table(group)
medians <- tapply(x,group,median)
print(data.frame(group=names(counts),n=as.integer(counts),
                 median_value=as.numeric(medians)))

# 4. GRAPH: each box uses the same centimetre scale; the x-axis
# includes n so small groups cannot look equally reliable as large ones.
palette <- c("#CEE2F0","#EAC89E","#B8D5C0")
labels <- paste0(names(counts)," (n=",as.integer(counts),")")
boxplot(x ~ group, names=labels, col=palette,border="#254967",
        main=plot_title, xlab=group_label, ylab=measurement_label)

# 5. LABEL: the line inside each box is its median, not its mean.
text(seq_along(medians),medians,
     labels=paste0("Median ",round(medians,2)," ",measurement_units),
     pos=3,cex=.7,col="#254967")

# 6. INTERPRET: boxes show center, spread, and flagged points.
# An isolated point is not automatically a measurement error.
# The figure alone does not establish statistical significance.
stopifnot(sum(counts)==length(x),length(medians)==nlevels(group))

# ADAPT:
# x <- your_data$your_measurement_column
# group <- your_data$your_category_column
# Update plot title, y-axis units and palette for your groups.
