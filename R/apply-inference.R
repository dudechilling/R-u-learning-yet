# Estimation, hypothesis tests, and numerical relationships.
.ru_apply_inference <- function(id,a) {
  if (id %in% c("standard_error","mean_confidence_interval","one_sample_t")) {
    z <- .ru_numeric_values(a,min_n=3L)
    if (stats::sd(z)==0) stop("The sample has no variation.")
    .ru_warn_inference()
    if (id=="standard_error") {
      out <- c(n=length(z),sample_sd=stats::sd(z),
               estimated_se=stats::sd(z)/sqrt(length(z)))
      print(out); return(out)
    }
    confidence <- .ru_level(a)
    if (id=="mean_confidence_interval") {
      fit <- stats::t.test(z,conf.level=confidence)
    } else {
      reference <- .ru_required(a$reference,"reference")
      fit <- stats::t.test(z,mu=reference,conf.level=confidence,
                           alternative=a$alternative)
    }
    print(fit)
    return(fit)
  }
  if (id=="two_sample_t") {
    if (!isTRUE(a$independent))
      stop("Confirm independent=TRUE only after checking the study design.")
    d <- .ru_groups(a,two=TRUE)
    if (any(table(d$group)<2L)) stop("Each group needs at least two observations.")
    .ru_warn_inference()
    out <- stats::t.test(value~group,data=d,conf.level=.ru_level(a))
    print(out); return(out)
  }
  if (id=="paired_t") {
    if (!isTRUE(a$paired))
      stop("Confirm paired=TRUE only after matching both columns by subject.")
    d <- .ru_pairs(a,min_n=3L)
    differences <- d$y-d$x
    if (stats::sd(differences)==0)
      stop("No variation in paired differences; this t test is undefined.")
    .ru_warn_inference()
    out <- stats::t.test(d$y,d$x,paired=TRUE,conf.level=.ru_level(a))
    cat("Mean second minus first: ",mean(differences),"\n",sep="")
    print(out); return(out)
  }
  if (id %in% c("correlation_test","spearman_correlation")) {
    d <- .ru_pairs(a,min_n=4L)
    if (stats::sd(d$x)==0 || stats::sd(d$y)==0)
      stop("Both variables must vary.")
    .ru_warn_inference()
    out <- if (id=="correlation_test")
      stats::cor.test(d$x,d$y,method="pearson",
                      conf.level=.ru_level(a)) else
      stats::cor.test(d$x,d$y,method="spearman",exact=FALSE)
    print(out); return(out)
  }
  if (id %in% c("linear_regression","predict_regression")) {
    d <- .ru_pairs(a,min_n=4L)
    if (length(unique(d$x))<3L)
      stop("Predictor needs at least three distinct values.")
    fit <- stats::lm(y~x,data=d)
    .ru_warn_inference()
    if (id=="linear_regression") {
      print(summary(fit))
      if (isTRUE(a$show_plot))
        ru_scatter(d$x,d$y,xlab="Predictor",ylab="Response",
                   title="Linear regression: observed and fitted")
      return(fit)
    }
    nx <- .ru_required(a$new_x,"new_x")
    if (!isTRUE(a$allow_extrapolate) &&
        (nx<min(d$x) || nx>max(d$x)))
      stop("Prediction is outside the observed predictor range. ",
           "Set allow_extrapolate=TRUE only if justified.")
    out <- stats::predict(fit,newdata=data.frame(x=nx),
                          interval="prediction",level=.ru_level(a))
    print(out); return(out)
  }
  if (id=="interpolation") {
    d <- .ru_pairs(a,min_n=2L)
    if (anyDuplicated(d$x))
      stop("Repeated x positions need resolving before interpolation.")
    target <- .ru_required(a$threshold,"threshold")
    if (target<min(d$x) || target>max(d$x))
      stop("The target is outside the observed range: extrapolation is not interpolation.")
    out <- stats::approx(d$x,d$y,xout=target)
    if (isTRUE(a$show_plot)) {
      graphics::plot(d$x,d$y,type="b",pch=19,col="#3F78A8",
                     xlab="Known X",ylab="Measured Y",
                     main="Linear interpolation within observed range")
      graphics::points(out$x,out$y,pch=19,cex=1.5,col="#A35E20")
      graphics::legend("topleft",
        legend=c("Observations","Interpolated value"),
        col=c("#3F78A8","#A35E20"),pch=19,bty="n")
    }
    print(out); return(out)
  }
  if (id=="categorical_independence") {
    x <- .ru_column(a,"x"); y <- .ru_column(a,"y")
    if (length(x)!=length(y)) stop("Category columns must align.")
    weights <- if (is.null(a$weight)) rep(1,length(x)) else
      .ru_column(a,"weight",numeric=TRUE)
    ok <- !is.na(x)&!is.na(y)&is.finite(weights)
    if (!all(ok)) message("Omitted ",sum(!ok)," incomplete category pairs.")
    if (any(weights[ok]<0) || any(weights[ok]!=floor(weights[ok])))
      stop("Frequency weights must be nonnegative whole counts.")
    d <- data.frame(a=factor(x[ok]),b=factor(y[ok]),count=weights[ok])
    tab <- stats::xtabs(count~a+b,data=d)
    if (any(dim(tab)<2L)) stop("Two or more categories per variable required.")
    test <- suppressWarnings(stats::chisq.test(tab,correct=FALSE))
    if (any(test$expected<5)) {
      if (all(dim(tab)==2L)) {
        message("Small expected counts: using Fisher exact test.")
        out <- stats::fisher.test(tab)
      } else {
        message("Small expected cells: chi-square approximation may be unreliable. ",
                "Review a suitable exact or simulation-based test.")
        return(list(observed=tab,expected=test$expected,
                    test_not_selected=TRUE))
      }
    } else out <- test
    print(tab);print(out);return(out)
  }
  if (id=="proportion_interval") {
    successes <- .ru_integer(a$successes,"successes")
    n <- .ru_integer(a$n,"n",min=1L)
    if (successes>n) stop("Successes exceed trials.")
    .ru_warn_inference()
    out <- stats::prop.test(successes,n,conf.level=.ru_level(a),
                            correct=FALSE)
    print(out);return(out)
  }
  stop("Unknown inference problem.")
}
