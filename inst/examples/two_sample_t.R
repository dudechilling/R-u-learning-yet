# How do I compare the means of two independent groups?
# Standalone illustrative data and R commands.
group_a <- c(8,9,11,10,12,9,13,11)
group_b <- c(13,15,12,16,14,15,17,14)
result <- t.test(group_a,group_b,var.equal=FALSE)
print(result$estimate)
print(result$conf.int)
print(result$p.value)
