# What proportion of responses belongs to each category?
travel <- c("bus", "walk", "bus", "car", "walk", "bus")
counts <- table(travel)
shares <- prop.table(counts)
print(counts)
print(shares)
print(100 * shares)
stopifnot(sum(counts) == 6, isTRUE(all.equal(sum(shares), 1)))
