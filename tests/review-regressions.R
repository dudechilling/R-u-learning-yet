library(rulearn)
# Guard the failure cases identified in the independent review.

must_fail <- function(expr, message_part) {
  err <- try(suppressMessages(suppressWarnings(expr)), silent=TRUE)
  if (!inherits(err,"try-error") ||
      !grepl(message_part,as.character(err),fixed=TRUE))
    stop("Expected error containing '",message_part,"'. Got: ",
         paste(as.character(err),collapse=" "))
}

# Aggregated rows represent frequency-weighted observations.
ship <- ru_data("Titanic")
correct <- sum(ship$Freq[ship$Survived=="Yes"])/sum(ship$Freq)
weighted <- ru_apply("event_probability",ship,
                     x="Survived",event="Yes",weight="Freq")
stopifnot(isTRUE(all.equal(unname(weighted["proportion"]),correct)))
unweighted <- ru_apply("event_probability",ship,x="Survived",event="Yes")
stopifnot(abs(weighted["proportion"]-unweighted["proportion"])>.01)

joint <- ru_apply("conditional_probability",ship,
                  x="Survived",y="Sex",event="Yes",given="Female",
                  weight="Freq")
baseline <- sum(ship$Freq[ship$Survived=="Yes" & ship$Sex=="Female"])/
            sum(ship$Freq[ship$Sex=="Female"])
stopifnot(isTRUE(all.equal(unname(joint["probability"]),baseline)))
union <- ru_apply("probability_union",ship,x="Survived",y="Sex",
                  event="Yes",given="Female",weight="Freq")
expected_union <- sum(ship$Freq[ship$Survived=="Yes" |
                                 ship$Sex=="Female"])/sum(ship$Freq)
stopifnot(isTRUE(all.equal(unname(union["either"]),expected_union)))
must_fail(ru_apply("event_probability",ship,x="Survived",event="Yes",
                   weight=rep(-1,nrow(ship))),"nonnegative")
must_fail(ru_apply("binomial_exact",n=10,k=2,prob=.3,weight=2),
          "does not use")
must_fail(ru_apply("predict_regression",ru_data("cars"),
                   x="speed",y="dist",new_x=15,confidence=.95,
                   show_plot=FALSE),"does not use")
must_fail(ru_apply("mean_median",ru_data("iris"),x="Sepal.Length",
                   alternative="greater"),"does not use")

plants <- subset(ru_data("PlantGrowth"),group %in% c("ctrl","trt1"))
x <- plants$weight[plants$group=="ctrl"]
y <- plants$weight[plants$group=="trt1"]
two <- ru_apply("two_sample_t",plants,x="weight",group="group",
                independent=TRUE,confidence=.95,alternative="greater")
expected <- t.test(x,y,alternative="greater")
stopifnot(identical(two$alternative,expected$alternative),
          isTRUE(all.equal(two$p.value,expected$p.value)))

sleep <- ru_data("sleep")
left <- subset(sleep,group==1,c(ID,extra))
right <- subset(sleep,group==2,c(ID,extra))
paired <- merge(left,right,by="ID",suffixes=c("_1","_2"))
tpaired <- ru_apply("paired_t",paired,x="extra_1",y="extra_2",
                    paired=TRUE,confidence=.95,alternative="less")
original <- t.test(paired$extra_2,paired$extra_1,
                   paired=TRUE,alternative="less")
stopifnot(isTRUE(all.equal(tpaired$p.value,original$p.value)))
cars <- ru_data("cars")
pearson <- ru_apply("correlation_test",cars,x="speed",y="dist",
                    confidence=.95,alternative="less")
expected <- cor.test(cars$speed,cars$dist,alternative="less")
stopifnot(isTRUE(all.equal(pearson$p.value,expected$p.value)))
spearman <- ru_apply("spearman_correlation",cars,x="speed",y="dist",
                     alternative="greater")
expected <- suppressWarnings(cor.test(cars$speed,cars$dist,
                           method="spearman",exact=FALSE,
                           alternative="greater"))
stopifnot(isTRUE(all.equal(spearman$p.value,expected$p.value)))
must_fail(ru_apply("one_sample_t",plants,x="weight",reference=5,
                   confidence=.95,alternative="invalid"),
          "alternative=")
must_fail(ru_apply("spearman_correlation",cars,x="speed",y="dist",
                   confidence=.95),"does not use")

# Never open a plotting device when show_plot=FALSE.
# Running without a pre-existing device detects accidental plot calls.
while (dev.cur()!=1L) dev.off()
before <- dev.cur()
flowers <- ru_data("iris")
ru_apply("histogram",flowers,x="Sepal.Length",show_plot=FALSE)
ru_apply("bar_chart",flowers,x="Species",show_plot=FALSE)
ru_apply("boxplot",flowers,x="Sepal.Length",show_plot=FALSE)
ru_apply("grouped_boxplot",flowers,x="Sepal.Length",group="Species",
         show_plot=FALSE)
ru_apply("scatterplot",flowers,x="Sepal.Length",y="Petal.Length",
         show_plot=FALSE)
ru_apply("zero_correlation",flowers,x="Sepal.Length",y="Petal.Length",
         show_plot=FALSE)
ru_apply("normal_shaded_area",mu=5,sigma=2,threshold=5,
         assume_normal=TRUE,show_plot=FALSE)
stopifnot(identical(before,dev.cur()))
must_fail(ru_apply("two_sample_t",plants,x="weight",group="group",
                   independent=TRUE,confidence=.95,show_plot=FALSE),
          "does not use")

# Irregular time points or deleted interior observations must not yield
# an ordinary ACF or a consecutive-observation moving average.
regular <- data.frame(t=seq_len(12),v=sin(seq_len(12)))
bad <- regular[-4,,drop=FALSE]
must_fail(ru_apply("autocorrelation",bad,x="v",time="t",
                   show_plot=FALSE),"Regularly spaced")
must_fail(ru_apply("moving_average",bad,x="v",time="t",
                   show_plot=FALSE),"Regularly spaced")
missing <- regular
missing$v[4] <- NA_real_
must_fail(ru_apply("autocorrelation",missing,x="v",time="t",
                   show_plot=FALSE),"Regularly spaced")
duplicate <- regular
duplicate$t[2] <- 1
must_fail(ru_apply("autocorrelation",duplicate,x="v",time="t",
                   show_plot=FALSE),"Duplicate timestamps")
okay <- ru_apply("autocorrelation",regular,x="v",time="t",show_plot=FALSE)
stopifnot(inherits(okay,"acf"))

# A route must be unambiguous, and every listed condition must be reachable.
routes <- getFromNamespace(".ru_db","rulearn")("routes.csv")
signature <- paste(routes$id,routes$have,routes$missing,sep="|")
stopifnot(!anyDuplicated(signature))
for (i in seq_len(nrow(routes))) {
  entry <- routes[i,]
  supplied <- getFromNamespace(".ru_list","rulearn")(entry$have)
  absent <- getFromNamespace(".ru_list","rulearn")(entry$missing)
  if (!length(supplied) && !length(absent)) next
  msg <- capture.output(ru_plan(entry$id,have=supplied,missing=absent))
  if (!any(grepl(paste0("Selected route: ",entry$route),
                 msg,fixed=TRUE)))
    stop("Unreachable route: ",entry$id," / ",entry$route)
}
cat("Review regressions passed.\n")