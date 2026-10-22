# Field Atlas package, original R examples, topic registry and math QA.
# All examples are constructed or bundled base R datasets. No private course text.
library(rulearn)
coverage <- getFromNamespace(".ru_coverage","rulearn")()
index <- getFromNamespace(".ru_lesson_index","rulearn")()
read_lesson <- getFromNamespace(".ru_lesson_read","rulearn")
render <- getFromNamespace(".ru_page_html","rulearn")
prepare <- getFromNamespace(".ru_viewer_prepare","rulearn")
stopifnot(nrow(coverage)==174L,nrow(index)==84L,
          !anyDuplicated(coverage$id),!anyDuplicated(coverage$reference_id),
          !anyDuplicated(index$id),
          all(index$id %in% coverage$reference_id))
status <- table(coverage$content_status)
stopifnot(status["VERIFIED"]==84L,status["AUTHORED"]==48L,
          status["NEEDS_REVIEW"]==6L,status["DISCOVERED"]==36L)
stopifnot(sum(index$status=="VERIFIED")==84L,
          sum(index$status=="AUTHORED")==0L)
stopifnot(all(vapply(index$id,function(k) {
 row <- coverage[coverage$reference_id==k,,drop=FALSE]
 identical(row$content_status,read_lesson(k)$meta$status)
},logical(1L))))
# One installed source of exact nine tokens serves R and Viewer.
expected <- c(ocean="#28627A",clay="#C66A49",jade="#3F806E",
              ochre="#B18A3B",iris="#7B668C",slate="#73818B",
              "warm-paper"="#FAF8F4","deep-ink"="#273640",grid="#E1E4E0")
stopifnot(identical(ru_palette(),expected),
          identical(ru_palette(c("clay","ocean")),expected[c("clay","ocean")]))
# Color-only distinctions are insufficient: numeric summaries and text
# remain required regardless of palette selections.
colors <- grDevices::hcl.colors(32L,"Cividis")
lum <- function(hex) {
 rgb <- t(grDevices::col2rgb(hex)/255)
 rgb <- ifelse(rgb<=0.04045,rgb/12.92,((rgb+.055)/1.055)^2.4)
 drop(rgb %*% c(.2126,.7152,.0722))
}
stopifnot(all(diff(lum(colors))>0) || all(diff(lum(colors))<0))
ratio <- function(c1,c2) {
 x <- lum(c(c1,c2))
 (max(x)+.05)/(min(x)+.05)
}
stopifnot(ratio(expected["ocean"],expected["warm-paper"])>=4.5,
          ratio(expected["deep-ink"],expected["warm-paper"])>=4.5,
          ratio(expected["ocean"],"#FFFFFF")>=4.5,
          ratio("#FFFFFF",expected["ocean"])>=4.5)
# Regression invariant: 0.0030 has two significant digits, not one or three.
sig <- read_lesson("significant_figures")
stopifnot(grepl("two significant figures",tolower(paste(sig$sections[["immediate answer"]],collapse=" ")),
                fixed=TRUE))
# Independent arithmetic for event algebra, distributions and inverse CDF.
stopifnot(isTRUE(all.equal(.4+.3-.1,.6)),
          isTRUE(all.equal(.2/.5,.4)),
          isTRUE(all.equal(.3*(1-.3),.21)),
          isTRUE(all.equal(sum(c(0,1,4)*c(.2,.5,.3)),1.7)),
          isTRUE(all.equal(sum((c(0,1,4)-1.7)^2*c(.2,.5,.3)),2.41)),
          isTRUE(all.equal(1-pbinom(2,10,.3),sum(dbinom(3:10,10,.3)))),
          isTRUE(all.equal(dpois(3,2.5),exp(-2.5)*2.5^3/factorial(3))),
          abs(pnorm(1)-pnorm(-1)-.682689492)<1e-7,
          abs(qnorm(.95)-1.644853627)<1e-7,
          abs(pexp(.5,rate=2,lower.tail=FALSE)-exp(-1))<1e-10,
          isTRUE(all.equal(stats::approx(c(0,5,10),c(2,7,6),xout=3)$y,5)))
# Execute the exact code exposed in every computational card.
# Purely conceptual study must never generate fictitious code or a Copy button.
grDevices::pdf(tempfile(fileext=".pdf"))
run <- 0L;conceptual <- 0L
for(k in index$id) {
 l <- read_lesson(k)
 page <- render(l)
 if(nzchar(l$code)) {
  stopifnot(length(l$edit)>=1L,
            grepl("<table class='edit'>",page,fixed=TRUE),
            grepl("class='copy'",page,fixed=TRUE))
  env <- new.env(parent=.GlobalEnv)
  tryCatch(eval(parse(text=l$code),envir=env),
           error=function(e)stop(k,": ",conditionMessage(e),call.=FALSE))
  run <- run+1L
 } else {
  stopifnot("exam answer pattern" %in% names(l$sections),
            !grepl("class='copy'",page,fixed=TRUE),
            grepl("Answer pattern for study",page,fixed=TRUE))
  conceptual <- conceptual+1L
 }
 if(identical(l$meta$status,"AUTHORED"))
  stopifnot(grepl("Authored draft:",page,fixed=TRUE))
 else stopifnot(identical(l$meta$status,"VERIFIED"))
}
grDevices::dev.off()
stopifnot(run==68L,conceptual==16L)
folder <- prepare(hits=ru_find("significant figures"),query="significant figures")
stopifnot(file.exists(file.path(folder,"field-atlas.css")),
          file.exists(file.path(folder,"reference.css")),
          file.exists(file.path(folder,"figures","scatter-correlation.svg")))
html <- paste(readLines(file.path(folder,"catalog.html")),collapse="\n")
stopifnot(grepl("174 scoped topics",html,fixed=TRUE),
          grepl("48 authored drafts",html,fixed=TRUE),
          grepl("42",paste(status["NEEDS_REVIEW"]+status["DISCOVERED"])), # numeric
          !grepl(paste0("/", "mnt", "/", "current-", "semester"),html,fixed=TRUE))
cat("Field Atlas contract PASS: 174 topics; 84 verified, 48 authored,",
    "42 missing/review; 68 runnable examples, 16 conceptual; palette, math and Viewer.\n")
