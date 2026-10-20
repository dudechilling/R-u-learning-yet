# How do I find the probability that A or B occurs without double-counting?
# Independent illustrative data.
rain <- c(TRUE,TRUE,FALSE,TRUE,FALSE,FALSE,TRUE,TRUE)
wind <- c(TRUE,FALSE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE)
p_a <- mean(rain); p_b <- mean(wind); overlap <- mean(rain & wind)
p_union <- p_a+p_b-overlap
print(c(P_A=p_a,P_B=p_b,P_both=overlap,P_either=p_union))
stopifnot(isTRUE(all.equal(p_union,mean(rain | wind))))
