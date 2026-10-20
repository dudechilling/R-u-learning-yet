## ---- quick-bar-chart
data(iris)
barplot(table(iris$Species), col="lightblue",
        main="Recorded flowers by species", ylab="Number of flowers")

## ---- worked-bar-chart
# THE QUESTION: How many recorded observations belong to each category?
# Built-in R dataset: iris. Species is categorical; bars show counts.
data("iris", package="datasets")

# 1. SELECT: replace iris$Species with your category column.
category <- iris$Species
category_label <- "Flower species"

# 2. CHECK: counts are observations, not measurements along a numeric axis.
omitted <- sum(is.na(category))
counts <- table(category)
if (!length(counts)) stop("No nonmissing categories to count.")
cat("Omitted missing category labels:", omitted, "\n")

# 3. CALCULATE: a proportion is a count divided by the total usable count.
proportions <- prop.table(counts)
print(data.frame(category=names(counts), count=as.integer(counts),
                 percent=round(100*as.numeric(proportions),1)))

# 4. GRAPH: the bars start at zero and show observation counts.
midpoints <- barplot(counts,col="#CEE2F0",border="#254967",
                     main="Recorded flowers by species",
                     xlab=category_label,ylab="Number of flowers",
                     ylim=c(0,1.2*max(counts)))
text(midpoints,counts,
     labels=paste0(counts," (",round(100*proportions,1),"%)"),
     pos=3,cex=.85)

# 5. READ: a category bar is not a histogram interval.
# These are sample proportions, not universal species probabilities.
stopifnot(sum(counts)==sum(!is.na(category)))

# ADAPT: if the column holds numeric category codes, treat as categories:
# category <- factor(your_data$category_code)
# If each row stores an already aggregated Freq, use those frequencies
# directly with barplot(); table() would incorrectly count summary rows.