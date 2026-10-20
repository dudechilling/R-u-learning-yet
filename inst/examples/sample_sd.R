## ---- quick-sample-sd
data(iris)
range(iris$Petal.Length)  # recorded minimum and maximum (cm)
var(iris$Petal.Length)    # sample variance, cm squared
sd(iris$Petal.Length)     # sample standard deviation, cm

## ---- worked-sample-sd
# QUESTION: How widely do numeric observations vary?
# iris$Petal.Length contains recorded flower measurements in cm.
data(iris)

# 1. SELECT: use a numerical column with known measurement units.
values <- iris$Petal.Length
units <- "cm"

# 2. CHECK: report exclusions and require two usable measurements.
if (!is.numeric(values)) stop("Select a numerical measurement column.")
omitted <- sum(!is.finite(values))
values <- values[is.finite(values)]
if (length(values)<2L) stop("At least two usable observations are needed.")
cat("Used:",length(values),"Excluded:",omitted,"\n")

# 3. CALCULATE: range() returns the endpoints, not their difference.
endpoints <- range(values)
range_width <- diff(endpoints)
sample_variance <- var(values)         # n-1 denominator, units squared
sample_sd <- sd(values)               # square root, original units
cat("Recorded minimum and maximum:",endpoints,units,"\n")
cat("Distance across recorded range:",range_width,units,"\n")
cat("Sample variance:",sample_variance,paste0(units,"^2"),"\n")
cat("Sample standard deviation:",sample_sd,units,"\n")

# 4. READ: an SD is the spread of observed measurements around their
# average, not a standard error or a statement about causation.
stopifnot(isTRUE(all.equal(sample_sd^2,sample_variance)))