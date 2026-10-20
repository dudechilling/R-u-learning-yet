## ---- worked-histogram
# THE QUESTION: What is the distribution of eruption durations?
# Dataset: faithful, included with R. "eruptions" is measured in minutes.
# No rulearn helper is necessary: these are the actual base-R commands.

data("faithful", package="datasets")

# 1. SELECT: change faithful and "eruptions" for your own data frame/column.
values <- faithful$eruptions
units <- "Eruption duration (minutes)"

# 2. CHECK: NA/Inf are not measurements; state how many are excluded.
excluded <- sum(!is.finite(values))
values <- values[is.finite(values)]
cat("Usable observations:", length(values), "Excluded:", excluded, "\n")

# 3. CALCULATE: choose the edges of the histogram's intervals.
# Here each bar spans 0.5 minutes. Change by= to test other bin widths.
edges <- seq(floor(min(values)*2)/2, ceiling(max(values)*2)/2, by=0.5)
counts <- hist(values, breaks=edges, plot=FALSE)
average <- mean(values)
middle <- median(values)

# 4. GRAPH: col changes the bars; xlab and ylab explain the axes.
hist(values, breaks=edges, col="#CEE2F0", border="#254967",
     main="How long do eruptions last?", xlab=units,
     ylab="Number of eruptions", ylim=c(0, max(counts$counts)+6))

# 5. LABEL: text() puts the actual frequency above each bar.
text(counts$mids, counts$counts, labels=counts$counts, pos=3, cex=.8)

# 6. COMPARE: reference lines make the mean and median identifiable.
abline(v=average, col="#215E92", lty=1, lwd=2)
abline(v=middle, col="#A35E20", lty=2, lwd=2)
legend("topright", legend=c(paste("Mean:",round(average,2)),
                             paste("Median:",round(middle,2))),
       col=c("#215E92","#A35E20"),lty=c(1,2),lwd=2,bty="n")

# 7. READ: a bar is a number of eruptions within an interval, not a
# percentage or probability at one exact duration. Look for clusters.
stopifnot(sum(counts$counts)==length(values))
print(summary(values))

# ADAPT: replace the SELECT line with:
# your_data <- read.csv("measurements.csv")
# values <- your_data$your_numeric_column
# units <- "Your measurement (your units)"
