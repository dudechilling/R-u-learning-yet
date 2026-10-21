# The single palette token definition is inst/www/field-atlas.css.
# Shared with local Viewer; no global RStudio styling changes.
source("R/field-atlas.R",local=TRUE)
pal <- .ru_palette_from_css("inst/www/field-atlas.css")
stopifnot(length(pal)==9L)
# Intentional, reproducible offline teaching diagrams.
# Illustrative model curves are not observations. Histogram panels use iris.
# Run from the repository root: Rscript scripts/generate-figures.R
dir.create("inst/www/figures",recursive=TRUE,showWarnings=FALSE)

open_fig <- function(name,height,width=5,pointsize=12) {
  grDevices::svg(file.path("inst/www/figures",name),
                 width=width,height=height,pointsize=pointsize,bg=unname(pal["warm-paper"]))
  graphics::par(family="sans",fg=unname(pal["deep-ink"]),col.axis=unname(pal["deep-ink"]),
                col.lab=unname(pal["deep-ink"]),col.main=unname(pal["deep-ink"]))
}
curve_panel <- function(x,y,caption,xlab) {
  plot(x,y,type="l",lwd=2.7,col=unname(pal["ocean"]),bty="l",
       xlab=xlab,ylab="Model density",main=caption,
       xaxt="s",yaxt="n",cex.main=1.1)
  abline(h=0,col=unname(pal["slate"]))
}
x <- seq(-4,4,length.out=500)
# Same lognormal shape reflected around zero to distinguish tail direction.
logx <- seq(0.06,7,length.out=500)
y <- dlnorm(logx,meanlog=0,sdlog=.65)
open_fig("skew-shapes.svg",9.0,width=3.8,pointsize=15)
par(mfrow=c(3,1),mar=c(3.6,4.2,2.2,.9),oma=c(0,0,0,0))
curve_panel(-rev(logx),rev(y),"Negative skew: longer left tail","Illustrative value")
curve_panel(x,dnorm(x),"Symmetric: similar tails","Illustrative value")
curve_panel(logx,y,"Positive skew: longer right tail","Illustrative value")
grDevices::dev.off()

open_fig("modes.svg",4.35)
par(mfrow=c(2,1),mar=c(3.5,4,2.2,.7))
curve_panel(x,dnorm(x),"Unimodal: one main peak","Illustrative value")
mixture <- .48*dnorm(x,-1.55,.6)+.52*dnorm(x,1.55,.7)
curve_panel(x,mixture,"Bimodal: two peaks","Illustrative value")
grDevices::dev.off()

data("iris",package="datasets")
open_fig("histogram-bins.svg",5.0)
par(mfrow=c(2,1),mar=c(4,4.1,2.1,.8))
hist(iris$Sepal.Length,breaks=8,col=grDevices::adjustcolor(unname(pal["ocean"]),alpha.f=.28),border=unname(pal["warm-paper"]),
     main="Broader intervals",xlab="Sepal length (cm)",ylab="Flower count",
     cex.main=1.1)
hist(iris$Sepal.Length,breaks=seq(4,8,by=.25),col=grDevices::adjustcolor(unname(pal["ocean"]),alpha.f=.28),border=unname(pal["warm-paper"]),
     main="Narrower intervals",xlab="Sepal length (cm)",ylab="Flower count",
     cex.main=1.1)
grDevices::dev.off()

# A clearly labeled schematic, not fabricated empirical observations.
open_fig("boxplot-explained.svg",2.65)
par(mar=c(2.6,1,1.9,1),xpd=NA)
plot.new();plot.window(xlim=c(0,10),ylim=c(-.12,1.2))
segments(1.3,.58,8.6,.58,lwd=2,col=unname(pal["deep-ink"]))
segments(c(1.3,8.6),.42,c(1.3,8.6),.74,lwd=2,col=unname(pal["deep-ink"]))
rect(3.2,.34,6.7,.82,col=grDevices::adjustcolor(unname(pal["ocean"]),alpha.f=.28),border=unname(pal["ocean"]),lwd=2)
segments(5,.34,5,.82,lwd=2.3,col=unname(pal["deep-ink"]))
points(9.4,.58,pch=16,col=unname(pal["clay"]))
text(3.2,.15,"Q1",cex=.9)
text(5,.15,"Median",cex=.9)
text(6.7,.15,"Q3",cex=.9)
text(9.1,1,"Flagged point",cex=.84,col=unname(pal["clay"]))
text(5,1.13,"Schematic boxplot: not observed measurements",cex=.94,font=2)
grDevices::dev.off()

# Recorded vehicles, not a schematic or an inferred population.
data("mtcars",package="datasets")
open_fig("scatter-correlation.svg",3.4)
par(mar=c(4.0,4.3,2.3,1))
plot(mtcars$wt,mtcars$mpg,pch=19,col=unname(pal["ocean"]),
     xlab="Vehicle weight (1,000 lb)",ylab="Fuel economy (mpg)",
     main="Recorded mtcars vehicles",cex.main=1.12)
abline(stats::lm(mpg~wt,data=mtcars),col=unname(pal["clay"]),lwd=2)
legend("topright",
       legend=c("Recorded vehicle","Linear fit"),
       pch=c(19,NA),lty=c(0,1),col=c(unname(pal["ocean"]),unname(pal["clay"])),
       bty="n",cex=.8)
grDevices::dev.off()

stopifnot(all(file.exists(file.path("inst/www/figures",
      c("skew-shapes.svg","modes.svg","histogram-bins.svg",
        "boxplot-explained.svg","scatter-correlation.svg")))))
cat("Five instructional SVG assets built.\n")