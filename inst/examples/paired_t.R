# How do I compare before-and-after measurements from the same subjects?
# Standalone illustrative data and R commands.
before <- c(12,14,13,11,15,16,14,12)
after <- c(14,15,15,11,16,17,16,13)
change <- after-before
print(change)
print(mean(change))
print(t.test(after,before,paired=TRUE)$p.value)
