# Time-series questions: descriptive checks, not formal stationarity claims.
.ru_apply_time <- function(id,a) {
  d <- .ru_time(a,minimum=if(id=="line_chart") 2L else 8L)
  v <- d$value; t <- d$time
  nm <- if(is.character(a$x)&&length(a$x)==1L) a$x else "Measurement"
  if (id=="line_chart") {
    if (isTRUE(a$show_plot))
      graphics::plot(t,v,type=if(length(v)<=32L) "b" else "l",
                     pch=19,col="#3F78A8",
                     main="Measurements over time",xlab="Time",ylab=nm)
    return(d)
  }
  if (id=="moving_average") {
    window <- .ru_integer(a$window,"window",min=2L)
    if (window>length(v)) stop("Window exceeds number of observations.")
    if (window%%2L==0L)
      message("Even centered windows are not symmetric about one point.")
    smoothed <- as.numeric(stats::filter(v,rep(1/window,window),sides=2))
    if (isTRUE(a$show_plot)) {
      graphics::plot(t,v,type="l",col="#3F78A8",
                     main=paste(window,"observation moving average"),
                     xlab="Time",ylab=nm)
      graphics::lines(t,smoothed,col="#A35E20",lwd=2,lty=2)
      graphics::legend("topleft",legend=c("Original","Moving average"),
                       col=c("#3F78A8","#A35E20"),
                       lty=c(1,2),lwd=c(1,2),bty="n")
    }
    message("The window counts observations, not elapsed time. ",
            "Verify regular sampling intervals.")
    return(data.frame(time=t,raw=v,smoothed=smoothed))
  }
  if (id=="autocorrelation") {
    if (isTRUE(a$show_plot))
      stats::acf(v,main="Autocorrelation by observation lag",
                 col="#3F78A8")
    out <- stats::acf(v,plot=FALSE)
    message("Trend, seasonality and irregular spacing can distort interpretation.")
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
      graphics::plot(t,v,type="l",col="#3F78A8",
                     main="Exploratory stability check",
                     xlab="Time",ylab=nm)
      graphics::segments(t[1],mean(first),t[middle],mean(first),
                         lwd=2,lty=2,col="#A35E20")
      graphics::segments(t[length(v)-middle+1],mean(last),
                         t[length(v)],mean(last),
                         lwd=2,lty=3,col="#51775B")
      graphics::legend("topleft",legend=c("Observed","Early mean","Late mean"),
        col=c("#3F78A8","#A35E20","#51775B"),
        lty=c(1,2,3),bty="n",cex=.8)
    }
    print(summary,row.names=FALSE)
    message("Similar window statistics cannot prove stationarity. ",
            "Consider dependence, seasonality, changing variance and trends.")
    return(summary)
  }
  stop("Unknown temporal problem.")
}
