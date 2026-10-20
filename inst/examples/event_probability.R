# How do I estimate the probability of an event from observed trials?
# Independent illustrative data.
events <- c(TRUE,FALSE,TRUE,TRUE,FALSE,TRUE,FALSE,TRUE)
successes <- sum(events)
trials <- length(events)
p <- successes/trials
print(c(successes=successes,trials=trials,rate=p))
