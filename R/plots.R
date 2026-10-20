# Publication plots use readable axes, labels and distinct line types.
.ru_numeric <- function(x,label="x") {
  if (!is.numeric(x)) stop(label," must be numeric.",call.=FALSE)
  bad <- sum(!is.finite(x))
  if (bad) warning(bad," non-finite observations omitted.",call.=FALSE)
  y <- x[is.finite(x)]
  if (!length(y)) stop("No finite observations.",call.=FALSE)
  y
}
ru_hist <- function(x,units="Value",title="Distribution",breaks="Sturges",
                    col="#CEE2F0",show_mean=TRUE,show_median=TRUE) {
  z <- .ru_numeric(x)
  h <- hist(z,breaks=breaks,plot=FALSE)
  ymax <- max(h$counts)*1.27+0.5
  hist(z,breaks=h$breaks,col=col,border="#254967",
       main=title,xlab=units,ylab="Frequency",ylim=c(0,ymax))
  text(h$mids,h$counts,labels=h$counts,pos=3,cex=.8,xpd=TRUE)
  labs <- cols <- character()
  types <- integer()
  if (show_mean) {
    abline(v=mean(z),col="#215E92",lwd=2,lty=1)
    labs <- c(labs,paste0("Mean: ",signif(mean(z),4)))
    cols <- c(cols,"#215E92"); types <- c(types,1L)
  }
  if (show_median) {
    abline(v=median(z),col="#A35E20",lwd=2,lty=2)
    labs <- c(labs,paste0("Median: ",signif(median(z),4)))
    cols <- c(cols,"#A35E20"); types <- c(types,2L)
  }
  if (length(labs)) legend("topright",legend=labs,col=cols,
                           lty=types,lwd=2,bty="n",cex=.8)
  invisible(h)
}
ru_bar <- function(x,title="Category counts",xlab="Category",
                   col="#9DC6E2") {
  if (is.numeric(x) && !is.null(names(x))) {
    if (any(!is.finite(x)) || any(x<0)) stop("Counts must be finite and nonnegative.")
    counts <- x
  } else {
    counts <- table(x,useNA="no")
  }
  if (!length(counts)) stop("No categories to plot.")
  op <- par(mar=c(if (max(nchar(names(counts)))>12L) 9 else 6,4,4,2)+.1)
  on.exit(par(op),add=TRUE)
  pos <- barplot(counts,col=col,border="#254967",
                 ylim=c(0,max(counts)*1.25+0.5),
                 main=title,ylab="Count",las=2,cex.names=.88)
  text(pos,counts,labels=counts,pos=3,cex=.85,xpd=TRUE)
  mtext(xlab,side=1,line=par("mar")[1]-1)
  invisible(counts)
}
ru_box <- function(x,groups=NULL,units="Value",title="Spread and outliers") {
  if (is.null(groups)) {
    z <- .ru_numeric(x)
    s <- boxplot.stats(z)
    boxplot(z,col="#CEE2F0",border="#254967",ylab=units,main=title)
    abline(h=median(z),col="#A35E20",lty=2)
    legend("topright",legend=paste0("Median: ",signif(median(z),4)),
           col="#A35E20",lty=2,bty="n",cex=.8)
    return(invisible(s))
  }
  if (!is.numeric(x) || length(x)!=length(groups))
    stop("Numeric values and matching group labels are required.")
  good <- is.finite(x) & !is.na(groups)
  if (!any(good)) stop("No complete grouped observations.")
  f <- factor(groups[good])
  if (nlevels(f)<2) stop("At least two groups are required.")
  palette <- rep(c("#CEE2F0","#EAC89E","#B8D5C0","#D6CAE8"),length.out=nlevels(f))
  boxplot(x[good] ~ f,col=palette,border="#254967",
          main=title,ylab=units,xlab="Group")
  legend("topright",legend=levels(f),fill=palette,bty="n",cex=.78)
  invisible(tapply(x[good],f,median))
}
ru_scatter <- function(x,y,xlab="X",ylab="Y",title="Paired measurements",
                       show_fit=TRUE,labels=NULL,col="#3F78A8") {
  if (!is.numeric(x) || !is.numeric(y) || length(x)!=length(y))
    stop("x and y must be equally long numeric vectors.")
  good <- is.finite(x) & is.finite(y)
  if (sum(good)<3L) stop("At least three complete numeric pairs are required.")
  if (!is.null(labels) && length(labels)!=length(x))
    stop("Labels must align with the original paired measurements.")
  if (!is.null(labels)) labels <- as.character(labels[good])
  x <- x[good]; y <- y[good]
  plot(x,y,type="n",xlab=xlab,ylab=ylab,main=title)
  grid(col="gray85")
  points(x,y,pch=19,col=col)
  legends <- "Observed pairs"; legend_cols <- col
  line_types <- 0L; point_types <- 19L
  fit <- NULL
  if (show_fit && length(unique(x))>1L) {
    fit <- lm(y ~ x)
    abline(fit,col="#A35E20",lwd=2,lty=2)
    legends <- c(legends,"Straight-line fit")
    legend_cols <- c(legend_cols,"#A35E20")
    line_types <- c(line_types,2L); point_types <- c(point_types,NA_integer_)
  }
  if (!is.null(labels)) text(x,y,labels=labels,pos=3,cex=.7,col="#254967")
  legend("topleft",legend=legends,col=legend_cols,lty=line_types,
         pch=point_types,bty="n",cex=.77)
  invisible(fit)
}
