# How do I test for a linear association between two numerical variables?
# Standalone illustrative data and R commands.
x <- c(2,4,5,7,8,10,11,13)
y <- c(3,5,6,9,8,12,11,15)
plot(x,y,pch=19,col="#3F78A8",xlab="X",ylab="Y")
result <- cor.test(x,y,method="pearson")
print(result$estimate)
print(result$conf.int)
print(result$p.value)
