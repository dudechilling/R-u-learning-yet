# Time-series questions: lags require regular observation spacing.
.ru_apply_time <- function(id,a) {
  d <- .ru_time(a,minimum=if (id=="line_chart") 2L else 8L)
  v <- d$value; t <- d$time
  spacing <- attr(d,"time_spacing")
  xlab <- .ru_text(a$xlab,"Time")
  ylab <- .ru_axis(a,"x","Measurement")
  title <- .ru_text(a$title, switch(id,
    line_chart="Measurements over time",
    moving_average="Original measurements and moving average",
    autocorrelation="Autocorrelation by equal-spaced observation lag",
    stationarity="Exploratory stability check"))
  col <- .ru_text(a$col,"#3F78A8")
  if (id=="line_chart") {
    if (isTRUE(a$show_plot)) {
      graphics::plot(t,v,type=if (length(v)<=32L) "b" else "l",
                     pch=19,col=col,main=title,xlab=xlab,ylab=ylab)
    }
    return(d)
  }
  if (id %in% c("moving_average","autocorrelation") && !spacing$regular) {
    stop("Regularly spaced observations are required for ",id,
         ". A lag counts observations, not equal elapsed-time intervals. ",
         "Resample onto a justified time grid or choose a method for ",
         "unevenly spaced observations.",call.=FALSE)
  }
  if (id=="moving_average") {
    window <- .ru_integer(a$window,"window",min=2L)
    if (window>length(v)) stop("Window exceeds number of observations.")
    if (window%%2L==0L)
      message("Even centered windows are not symmetric about one point.")
    smoothed <- as.numeric(stats::filter(v,rep(1/window,window),sides=2))
    if (isTRUE(a$show_plot)) {
      graphics::plot(t,v,type="l",col=col,
                     main=title,xlab=xlab,ylab=ylab)
      graphics::lines(t,smoothed,col="#A35E20",lwd=3,lty=2)
      graphics::legend("topleft",legend=c("Original","Moving average"),
                       col=c(col,"#A35E20"),
                       lty=c(1,2),lwd=c(1,3),bty="n")
    }
    message("The window is ",window," regularly spaced observations (",
            spacing$label, "), not a new set of measured values.")
    return(data.frame(time=t,raw=v,smoothed=smoothed))
  }
  if (id=="autocorrelation") {
    out <- stats::acf(v,plot=isTRUE(a$show_plot),main=title,col=col)
    message("Lags count equal-spaced observations (",spacing$label,
            "). Trend and seasonality can affect the ACF.")
    return(out)
  }
  if (id=="stationarity") {
    middle <- floor(length(v)/2)
    first <- v[seq_len(middle)]
    last <- tail(v,middle)
    summary <- data.frame(
      period=c("first half","last half"),
      n=c(length(first),length(last)),
      mean=c(mean(first),mean(last)),
      sample_sd=c(stats::sd(first),stats::sd(last)))
    if (isTRUE(a$show_plot)) {
      graphics::plot(t,v,type="l",col=col,
                     main=title,xlab=xlab,ylab=ylab)
      graphics::segments(t[1],mean(first),t[middle],mean(first),
                         lwd=2,lty=2,col="#A35E20")
      graphics::segments(t[length(v)-middle+1L],mean(last),
                         t[length(v)],mean(last),
                         lwd=2,lty=3,col="#51775B")
      graphics::legend("topleft",legend=c("Observed","Early mean","Late mean"),
        col=c(col,"#A35E20","#51775B"),
        lty=c(1,2,3),bty="n",cex=.8)
    }
    print(summary,row.names=FALSE)
    message("Exploratory only: similar means and sample deviations cannot ",
            "prove stationarity. Inspect trends, variance, seasonality, ",
            "dependence and sampling intervals.")
    return(summary)
  }
  stop("Unknown temporal problem.")
}