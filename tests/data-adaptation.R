library(rulearn)

fails <- function(expr) inherits(try(suppressWarnings(suppressMessages(expr)),
                                     silent=TRUE),"try-error")
iris <- ru_data("iris")
stopifnot(nrow(iris)==150L,all(c("Sepal.Length","Species")%in%names(iris)))
stopifnot(nrow(ru_data("AirPassengers"))==144L)
stopifnot(nrow(ru_data("Nile"))==100L)
stopifnot(fails(ru_data("not_a_dataset")))
stopifnot(fails(ru_apply("mean_median",iris,x="NotAColumn")))
stopifnot(fails(ru_apply("mean_median",iris,x="Species")))
stopifnot(fails(ru_apply("normal_left_tail",mu=1,sigma=2,threshold=1)))
stopifnot(fails(ru_apply("normal_left_tail",mu=1,sigma=0,
                        threshold=1,assume_normal=TRUE)))
stopifnot(fails(ru_apply("mean_confidence_interval",iris,x="Sepal.Length")))
stopifnot(fails(ru_apply("two_sample_t",iris,x="Sepal.Length",
                        group="Species",independent=TRUE,confidence=.95)))
stopifnot(fails(ru_apply("predict_regression",ru_data("cars"),x="speed",
                        y="dist",new_x=999,confidence=.95,show_plot=FALSE)))
stopifnot(fails(ru_apply("categorical_mode",ru_data("Titanic"),
                        x="Sex",weight=rep(NA_real_,nrow(ru_data("Titanic"))))))
x <- ru_apply("mean_median",iris,x="Sepal.Length")
stopifnot(abs(unname(x["mean"])-mean(iris$Sepal.Length))<1e-12)
g <- ru_apply("group_means",iris,x="Sepal.Length",group="Species")
stopifnot(nrow(g)==3L,all(g$n==50L))
aq <- ru_data("airquality")
m <- ru_apply("missing_values",aq,x="Ozone")
stopifnot(m["missing"]==sum(is.na(aq$Ozone)))
titanic <- ru_data("Titanic")
stopifnot(sum(titanic$Freq)==2201L)
p <- ru_apply("relative_frequency",titanic,x="Survived",weight="Freq")
stopifnot(sum(p$n)==2201L,isTRUE(all.equal(sum(p$proportion),1)))
mode <- ru_apply("categorical_mode",titanic,x="Survived",weight="Freq")
stopifnot(identical(mode,"No"))
stopifnot(fails(ru_apply("relative_frequency",titanic,
                        x="Survived",weight=rep(-1,nrow(titanic)))))
png <- tempfile(fileext=".pdf")
grDevices::pdf(png)
counts <- ru_apply("bar_chart",titanic,x="Survived",weight="Freq")
grDevices::dev.off()
unlink(png)
stopifnot(sum(counts)==2201L)
set.seed(829)
original <- .Random.seed
s <- ru_apply("sample_random",iris,n=10,seed=40)
stopifnot(nrow(s)==10L,identical(original,.Random.seed))
b <- ru_apply("sampling_distribution",iris,x="Sepal.Length",
              n=15,reps=60,seed=40,show_plot=FALSE)
stopifnot(length(b)==60L,identical(original,.Random.seed))
stopifnot(fails(ru_apply("sample_random",iris,n=500,seed=2)))
d <- ru_data("cars")
fit <- ru_apply("linear_regression",d,x="speed",y="dist",show_plot=FALSE)
stopifnot(inherits(fit,"lm"))
pred <- ru_apply("predict_regression",d,x="speed",y="dist",
                 new_x=15.5,confidence=.95,show_plot=FALSE)
stopifnot(nrow(pred)==1L)
temporal <- ru_apply("moving_average",ru_data("Nile"),x="flow",time="year",
                     window=7,show_plot=FALSE)
stopifnot(nrow(temporal)==100L,anyNA(temporal$smoothed))
if (requireNamespace("palmerpenguins",quietly=TRUE)) {
  birds <- ru_data("penguins")
  stopifnot(nrow(birds)>300L,"body_mass_g"%in%names(birds))
  groups <- ru_apply("group_means",birds,x="body_mass_g",group="species")
  stopifnot(nrow(groups)==3L)
}
hits <- ru_find("penguins", n=20)
stopifnot("grouped_boxplot" %in% hits$id,
          "linear_regression" %in% hits$id)
stopifnot("group_means" %in% ru_find("iris", n=30)$id)
cat("Dataset-adaptation tests passed.\\n")
