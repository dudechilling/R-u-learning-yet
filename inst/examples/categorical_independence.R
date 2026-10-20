# How do I test whether two categories are associated?
# Standalone illustrative data and R commands.
counts <- matrix(c(24,15,18,27),nrow=2,byrow=TRUE,
                 dimnames=list(setting=c("A","B"),outcome=c("Yes","No")))
result <- chisq.test(counts,correct=FALSE)
print(counts)
print(result$expected)
print(result$p.value)
if (any(result$expected<5)) print(fisher.test(counts)$p.value)
