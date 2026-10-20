# How do I calculate an average separately for each group?
# Independent illustrative observations; replace deliberately.
group <- c("north","north","south","south","south")
temperature_c <- c(7,9,11,15,13)
print(table(group))
print(tapply(temperature_c,group,mean))
