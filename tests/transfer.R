# Transfer regression: fresh, publicly available R datasets and fair-outcome models.
# No course files, submitted answers or private data are included here.
library(rulearn)

# Histograms apply to numeric observations, not just the demonstration data.
data(airquality)
x <- airquality$Ozone
discarded <- sum(!is.finite(x))
valid <- x[is.finite(x)]
stopifnot(is.numeric(x),discarded==37L,length(valid)==116L)
grDevices::pdf(tempfile(fileext=".pdf"))
h <- hist(valid,breaks=10,main="Observed ozone",xlab="Ozone (ppb)")
stopifnot(sum(h$counts)==length(valid))
stopifnot(isTRUE(all.equal(range(valid),c(1,168))))

# A categorical number can still label groups rather than a continuous scale.
data(mtcars)
count <- table(factor(mtcars$cyl))
fraction <- prop.table(count)
stopifnot(sum(count)==nrow(mtcars),length(count)==3L,
          isTRUE(all.equal(sum(fraction),1)))
barplot(count,ylab="Cars recorded",main="Engine cylinder categories")
stopifnot(identical(unname(as.integer(count)),c(11L,7L,14L)))

# Different group count, variable names and unit semantics.
data(ToothGrowth)
stopifnot(all(c("len","supp") %in% names(ToothGrowth)),
          is.numeric(ToothGrowth$len),
          length(unique(ToothGrowth$supp))==2L)
g <- boxplot(len ~ supp,data=ToothGrowth,
             xlab="Supplement",ylab="Tooth length (reported units)")
size <- table(ToothGrowth$supp)
medians <- tapply(ToothGrowth$len,ToothGrowth$supp,median)
stopifnot(sum(size)==nrow(ToothGrowth),ncol(g$stats)==2L,
          all(size==30L),length(medians)==2L)

# Trimmed mean and quartiles use native R arguments on alternate data.
stats <- c(mean=mean(ToothGrowth$len),median=median(ToothGrowth$len),
           trimmed=mean(ToothGrowth$len,trim=.1),
           q1=unname(quantile(ToothGrowth$len,probs=.25)),
           q3=unname(quantile(ToothGrowth$len,probs=.75)),
           variance=var(ToothGrowth$len),sd=sd(ToothGrowth$len))
stopifnot(all(is.finite(stats)),stats["q1"]<stats["median"],
          stats["median"]<stats["q3"])
# A stem-and-leaf displays numeric measurements in the Console.
st <- capture.output(stem(ToothGrowth$len))
stopifnot(length(st)>2L,any(grepl("decimal point",st,fixed=TRUE)))

# Finite uniform sample space: a fair six-sided die plus an independent
# fair coin. This is a CONSTRUCTED mathematical model, not recorded data.
outcomes <- expand.grid(die=1:6, coin=c("H","T"))
stopifnot(nrow(outcomes)==12L)
A <- outcomes$die%%2L==0L
B <- outcomes$coin=="H"
p_A <- mean(A)
p_B <- mean(B)
p_both <- mean(A&B)
p_either <- mean(A|B)
p_given_B <- mean(A&B)/mean(B)
stopifnot(isTRUE(all.equal(p_A,.5)),isTRUE(all.equal(p_B,.5)),
          isTRUE(all.equal(p_both,.25)),isTRUE(all.equal(p_either,.75)),
          isTRUE(all.equal(p_given_B,.5)),
          isTRUE(all.equal(mean(!A),.5)))

# A changed experiment: two marked cards drawn without replacement.
# Model: ordinary 52-card deck with exactly four queens.
# The second conditional denominator must decrease after the first draw.
p_2_queens <- (4/52)*(3/51)
p_with_replacement <- (4/52)^2
stopifnot(isTRUE(all.equal(p_2_queens,1/221)),
          p_2_queens < p_with_replacement)

# R's native data inspection is the alternative to asking the Help pane
# for a help topic named after an arbitrary imported CSV variable.
d <- mtcars
stopifnot(nrow(d)==32L,identical(names(d),names(mtcars)),
          is.numeric(d$mpg))
# The R help pages are definitions, not hidden calculation wrappers.
for (topic in c("measurement_scales","probability_events",
                "conditional_independence","descriptive_inferential","r_stem")) {
  stopifnot(length(help(topic,package="rulearn"))==1L)
}

grDevices::dev.off()

# Search from general questions; do not train on or retain coursework.
lookup <- c(
 "What is the sample space?"="sample_space",
 "Are independent events the same as mutually exclusive?"="mutually_exclusive",
 "How do I make a stem and leaf plot?"="r_stem",
 "Define descriptive and inferential statistics"="descriptive_inferential",
 "How do I make a histogram?"="histogram",
 "What does a p-value mean?"="hypothesis_tests_pvalues",
 "What is the population of a sample?"="population_sample")
for (q in names(lookup)) {
  invisible(capture.output(hit <- ru_find(q,n=5L)))
  if (!nrow(hit) || hit$id[1L]!=lookup[[q]])
    stop("Local lookup returned unsuitable first result for: ",q)
}
cat("Generic transferable native-R methods and lookup: PASS\n")