# How do I calculate quartiles, the five-number summary, and IQR?
# Independent illustrative observations; replace deliberately.
x <- c(2,4,6,8,10,12,14,16,18)
print(quantile(x,probs=c(0,.25,.5,.75,1)))
print(IQR(x))
print(fivenum(x))
