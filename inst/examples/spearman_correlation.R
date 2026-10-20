# How do I measure a monotonic relationship when linear correlation is unsuitable?
# Standalone illustrative data and R commands.
x <- c(1,2,3,4,5,6,7,8)
y <- c(1,4,9,16,25,36,49,64)
print(c(pearson=cor(x,y,method="pearson"),
        spearman=cor(x,y,method="spearman")))
print(cor.test(x,y,method="spearman")$estimate)
