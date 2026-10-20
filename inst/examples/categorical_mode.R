# Which category occurs most often, including ties?
# Independent illustrative observations; replace deliberately.
choice <- c("A","B","A","B","C","A","B")
counts <- table(choice)
print(counts)
print(names(counts)[counts==max(counts)])
