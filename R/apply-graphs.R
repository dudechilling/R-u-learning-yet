# Visual methods separate computation from rendering. show_plot=FALSE never opens a device.
.ru_apply_graph <- function(id,a) {
  if (id=="histogram") {
    z <- .ru_numeric_values(a)
    if (!isTRUE(a$show_plot))
      return(graphics::hist(z,plot=FALSE))
    return(ru_hist(z,
      units=.ru_text(a$units,.ru_axis(a,"x","Measured value")),
      title=.ru_text(a$title,"Distribution of observed measurements"),
      col=.ru_text(a$col,"#CEE2F0")))
  }
  if (id=="bar_chart") {
    counts <- .ru_counts(a)
    if (!isTRUE(a$show_plot)) return(counts)
    return(ru_bar(counts,
       title=.ru_text(a$title,"Observed category counts"),
       xlab=.ru_text(a$xlab,.ru_axis(a,"x","Category")),
       col=.ru_text(a$col,"#9DC6E2")))
  }
  if (id %in% c("boxplot","grouped_boxplot")) {
    if (id=="boxplot") {
      z <- .ru_numeric_values(a)
      if (!isTRUE(a$show_plot)) return(grDevices::boxplot.stats(z))
      return(ru_box(z,
        units=.ru_text(a$units,.ru_axis(a,"x","Measurement")),
        title=.ru_text(a$title,"Distribution and flagged values"),
        col=.ru_text(a$col,"#CEE2F0")))
    }
    grouped <- .ru_groups(a)
    grouped_medians <- tapply(grouped$value,grouped$group,stats::median)
    if (!isTRUE(a$show_plot)) return(grouped_medians)
    return(ru_box(grouped$value,groups=grouped$group,
      units=.ru_text(a$units,.ru_axis(a,"x","Measurement")),
      title=.ru_text(a$title,"Measurements by group"),
      col=a$col))
  }
  if (id %in% c("scatterplot","zero_correlation")) {
    d <- .ru_pairs(a)
    xlab <- .ru_axis(a,"x","X")
    ylab <- .ru_axis(a,"y","Y")
    col <- .ru_text(a$col,"#3F78A8")
    if (id=="scatterplot") {
      if (!isTRUE(a$show_plot)) {
        if (length(unique(d$x))<=1L) return(invisible(NULL))
        return(stats::lm(y~x,data=d))
      }
      return(ru_scatter(d$x,d$y,xlab=xlab,ylab=ylab,
                        col=col,title=.ru_text(a$title,
                        "Paired measurements and fitted line")))
    }
    if (stats::sd(d$x)==0 || stats::sd(d$y)==0)
      stop("Pearson correlation needs variation in both variables.")
    r <- stats::cor(d$x,d$y)
    if (isTRUE(a$show_plot)) {
      ru_scatter(d$x,d$y,xlab=xlab,ylab=ylab,
                 title=.ru_text(a$title,"Inspect shape before interpreting correlation"),
                 col=col,show_fit=FALSE)
      graphics::lines(stats::lowess(d$x,d$y),col="#A35E20",lty=2,lwd=2)
      graphics::legend("topright",
           legend=c(paste0("Pearson r = ",round(r,3)), "Smoothed pattern"),
           lty=c(NA,2),col=c(col,"#A35E20"),bty="n")
    }
    cat("A small Pearson r does not rule out nonlinear dependence.\n")
    return(r)
  }
  if (id=="normal_shaded_area") {
    if (!isTRUE(a$assume_normal))
      stop("For a normal model set assume_normal=TRUE after checking the assumption.")
    mu <- .ru_required(a$mu,"mu"); s <- .ru_positive(a$sigma,"sigma")
    cut <- .ru_required(a$threshold,"threshold")
    p <- stats::pnorm(cut,mu,s)
    if (!isTRUE(a$show_plot)) return(p)
    low <- min(mu-4*s,cut-2*s); high <- max(mu+4*s,cut+2*s)
    xx <- seq(low,high,length.out=500)
    yy <- stats::dnorm(xx,mu,s)
    graphics::plot(xx,yy,type="l",lwd=2,
       col=.ru_text(a$col,"#3F78A8"),
       main=.ru_text(a$title,"Assumed normal model, left-tail probability"),
       xlab=.ru_text(a$xlab,"Value"),ylab="Probability density")
    sel <- xx<=cut
    if (sum(sel)>1L) graphics::polygon(
      c(xx[sel][1L],xx[sel],tail(xx[sel],1L)),
      c(0,yy[sel],0),col="#CDE1EF",border=NA)
    graphics::abline(v=cut,col="#A35E20",lty=2,lwd=2)
    graphics::legend("topright",
      legend=paste0("P(X <= ",signif(cut,4),") = ",signif(p,4)),
      fill="#CDE1EF",bty="n")
    print(p); return(p)
  }
  stop("Unknown graph problem.")
}