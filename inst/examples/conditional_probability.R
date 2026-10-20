# How do I calculate the probability of A given that B occurred?
# Independent illustrative data.
rain <- c(TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,TRUE,TRUE)
wind <- c(TRUE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE)
denom <- sum(rain)
if (denom==0L) stop("No observations satisfy the given event.")
p <- sum(wind & rain)/denom
print(c(joint=sum(wind & rain),given=denom,conditional=p))
