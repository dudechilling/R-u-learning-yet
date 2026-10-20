# How do I turn category counts into relative frequencies and percentages?
# Independent illustrative observations; replace deliberately.
travel <- c("bus","walk","bus","car","walk","bus")
counts <- table(travel)
print(counts)
print(prop.table(counts))
print(100*prop.table(counts))
