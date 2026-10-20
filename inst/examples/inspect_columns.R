# How do I find what columns and data types are in my dataset?
# Independent illustrative observations; replace deliberately.
d <- data.frame(site=c("A","B","C"), depth_cm=c(12,19,NA))
print(names(d))
str(d)
print(head(d))
print(summary(d))
