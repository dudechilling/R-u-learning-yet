# Visual problem recipes, using the existing annotated graph helpers.
.ru_apply_graph <- function(id,a) {
  if (id=="histogram") {
    z <- .ru_numeric_values(a)
    return(ru_hist(z,units=if (is.character(a$x)&&length(a$x)==1L)
                 a$x else "Measured value",
                 title="Distribution of observed measurements"))
  }
  if (id=="bar_chart") {
    z <- if (is.null(a$weight)) .ru_column(a,"x") else .ru_counts(a)
    return(ru_bar(z,title="Observed category counts",
                  xlab=if (is.character(a$x)&&length(a$x)==1L)
                  a$x else "Category"))
  }
  if (id %in% c("boxplot","grouped_boxplot")) {
    z <- .ru_column(a,"x",numeric=TRUE)
    g <- if (id=="grouped_boxplot" || !is.null(a$group))
      .ru_column(a,"group") else NULL
    return(ru_box(z,groups=g,
                  units=if(is.character(a$x)&&length(a$x)==1L) a$x else "Measurement",
                  title=if(is.null(g)) "Distribution and flagged values" else
                    "Measurements by group"))
  }
  if (id %in% c("scatterplot","zero_correlation")) {
    d <- .ru_pairs(a)
    labs <- c(if(is.character(a$x)&&length(a$x)==1L) a$x else "X",
              if(is.character(a$y)&&length(a$y)==1L) a$y else "Y")
    if (id=="scatterplot")
      return(ru_scatter(d$x,d$y,xlab=labs[1],ylab=labs[2],
                        title="Paired measurements and fitted line"))
    if (stats::sd(d$x)==0 || stats::sd(d$y)==0)
      stop("Pearson correlation needs variation in both variables.")
    r <- stats::cor(d$x,d$y)
    ru_scatter(d$x,d$y,xlab=labs[1],ylab=labs[2],
               title="Inspect shape before interpreting correlation",
               show_fit=FALSE)
    graphics::lines(stats::lowess(d$x,d$y),col="#A35E20",lty=2,lwd=2)
    graphics::legend("topright",
                     legend=c(paste0("Pearson r = ",round(r,3)),
                              "Smoothed pattern"),
                     lty=c(NA,2),col=c("#3F78A8","#A35E20"),bty="n")
    cat("A small Pearson r does not rule out nonlinear dependence.\n")
    return(r)
  }
  if (id=="normal_shaded_area") {
    if (!isTRUE(a$assume_normal))
      stop("For a normal model set assume_normal=TRUE after checking the assumption.")
    mu <- .ru_required(a$mu,"mu"); s <- .ru_positive(a$sigma,"sigma")
    cut <- .ru_required(a$threshold,"threshold")
    low <- min(mu-4*s,cut-2*s); high <- max(mu+4*s,cut+2*s)
    xx <- seq(low,high,length.out=500)
    yy <- stats::dnorm(xx,mu,s)
    graphics::plot(xx,yy,type="l",lwd=2,col="#3F78A8",
                   main="Assumed normal model, left-tail probability",
                   xlab="Value",ylab="Probability density")
    sel <- xx<=cut
    if (sum(sel)>1L) graphics::polygon(
      c(xx[sel][1L],xx[sel],tail(xx[sel],1L)),
      c(0,yy[sel],0),col="#CDE1EF",border=NA)
    graphics::abline(v=cut,col="#A35E20",lty=2,lwd=2)
    p <- stats::pnorm(cut,mu,s)
    graphics::legend("topright",
      legend=paste0("P(X <= ",signif(cut,4),") = ",signif(p,4)),
      fill="#CDE1EF",bty="n")
    print(p); return(p)
  }
  stop("Unknown graph problem.")
}
