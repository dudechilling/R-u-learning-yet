## ---- quick-mean-median
data(faithful)
mean(faithful$waiting)       # arithmetic average, minutes
median(faithful$waiting)     # middle ordered value, minutes

## ---- worked-mean-median
# QUESTION: How do the mean and median describe recorded measurements?
# The built-in faithful dataset records eruption waiting times in minutes.
data(faithful)

# 1. SELECT: replace faithful$waiting with a suitable numeric column.
values <- faithful$waiting
units <- "minutes"

# 2. CHECK: missing or non-finite values cannot be summarized directly.
if (!is.numeric(values)) stop("Select a numerical measurement column.")
omitted <- sum(!is.finite(values))
values <- values[is.finite(values)]
if (!length(values)) stop("No finite measurements remain.")
cat("Used:", length(values), "Excluded:", omitted, "\n")

# 3. CALCULATE: the median and trimmed mean resist extremes differently.
average <- mean(values)
middle <- median(values)
trimmed10 <- mean(values, trim=0.10)
quartiles <- quantile(values, probs=c(.25,.75))
print(c(mean=average,median=middle,trimmed_mean_10pct=trimmed10))
print(quartiles)

# 4. GRAPH: inspect whether one center hides different clusters.
hist(values,breaks=10,col="lightblue",
     main="Waiting times between eruptions",
     xlab=paste("Waiting time (",units,")",sep=""),
     ylab="Number of recorded intervals")
abline(v=average,col="blue",lwd=2)
abline(v=middle,col="brown",lty=2,lwd=2)
legend("topright",legend=c("Mean","Median"),
       col=c("blue","brown"),lty=c(1,2),bty="n")

# 5. READ: every result describes the selected records; it does not
# prove a population average, a causal effect or representative sampling.