## ---- worked-two-sample-t
# THE QUESTION: Do two independent groups have different mean weights?
# Dataset: PlantGrowth, included with R. Weight is the response.
# Use Welch's t-test by default; it does not assume equal variances.

data("PlantGrowth", package="datasets")

# 1. SELECT: control and one treatment. Three groups would require
# another question; do not quietly include a third.
d <- subset(PlantGrowth,group %in% c("ctrl","trt1"))
d$group <- droplevels(d$group)

# 2. CHECK: are there exactly two groups and at least two measurements
# per group? Are the observations from different independent units?
sizes <- table(d$group)
print(sizes)
stopifnot(length(sizes)==2L,all(sizes>=2L))
# Independence is a fact to establish from the study design.
# The function cannot detect repeated measurements of the same unit.

# 3. DESCRIBE: what do these observations show before testing?
means <- tapply(d$weight,d$group,mean)
print(means)
boxplot(weight ~ group, data=d, col=c("#CEE2F0","#EAC89E"),
        border="#254967",
        names=paste0(names(sizes)," (n=",as.integer(sizes),")"),
        main="Control and treatment weights",xlab="Group",ylab="Weight")

# 4. TEST: the left side of ~ is the numerical response.
# var.equal=FALSE requests Welch's test.
# alternative="two.sided" asks whether either mean could differ.
test <- t.test(weight ~ group,data=d,
               alternative="two.sided",var.equal=FALSE,conf.level=.95)
print(test)

# 5. READ: the estimate gives two observed group means.
# The confidence interval estimates mean(ctrl) - mean(trt1) because
# the factor levels are ctrl, then trt1. Check levels(d$group).
print(levels(d$group))
print(test$conf.int)
print(test$p.value)

# 6. INTERPRET: the p-value measures compatibility with the null under
# the model. It is NOT the probability that the null is true.
# A statistically detectable difference is not automatically important.
# The interval and study design are essential to interpretation.

# ADAPT:
# d <- subset(your_data, group %in% c("A","B"))
# t.test(measurement ~ group, data=d, var.equal=FALSE)
# If the same subjects were measured twice, use a PAIRED test instead.
# For a one-sided test, the direction follows factor level ordering.
