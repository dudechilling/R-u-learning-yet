# How do I compare two measurements matched by the same subject?
# Reference dataset: datasets::sleep (bundled with R).
library(rulearn)
d <- ru_data("sleep")
first <- subset(d, group==1, select=c(ID, extra))
second <- subset(d, group==2, select=c(ID, extra))
matched <- merge(first, second, by="ID", suffixes=c("_1","_2"))
fit <- ru_apply("paired_t", matched,
                x="extra_1", y="extra_2", paired=TRUE, confidence=.95)
stopifnot(is.finite(fit$p.value))
