# P2-A1 independent mathematical oracles and installed Viewer contract.
# All data are invented; no course assignments or external service calls.
library(rulearn)
get <- getFromNamespace(".ru_lesson_read","rulearn")
make <- getFromNamespace(".ru_page_html","rulearn")
prepare <- getFromNamespace(".ru_viewer_prepare","rulearn")
index <- getFromNamespace(".ru_lesson_index","rulearn")()
cov <- getFromNamespace(".ru_coverage","rulearn")()
ids <- c("central_limit_theorem","mean_confidence_interval",
         "mean_ci_z","ci_method_selection")
stopifnot(nrow(index)==84L,nrow(cov)==174L,
          !anyDuplicated(index$id),!anyDuplicated(cov$reference_id),
          all(ids %in% index$id),
          identical(unname(cov$content_status[match(ids,cov$id)]),
                    rep("VERIFIED",length(ids))),
          identical(cov$content_status[cov$id=="proportion_interval"],"VERIFIED"),
          identical(get("proportion_interval")$meta$status,"VERIFIED"),
          nzchar(get("proportion_interval")$code))
required <- c("immediate answer","what the question asks","recognize the method",
              "what to check","interpret your results","frequent mistakes","learn more")
for(id in ids) {
  page<-get(id); html<-make(page)
  stopifnot(all(required %in% names(page$sections)),
            identical(page$meta$status,"VERIFIED"),
            startsWith(page$meta$sources,"https://"),
            grepl(paste0("data-lesson='",id,"'"),html,fixed=TRUE),
            !grepl("ru_apply(",page$code,fixed=TRUE))
  if(id %in% c("mean_ci_z","mean_confidence_interval")) {
    stopifnot(all(c("numbered solution steps","original worked example",
                    "use this in r","what to edit") %in% names(page$sections)),
              nzchar(page$code),length(page$edit)>=6L,
              grepl("<ol>",html,fixed=TRUE),
              grepl("class='copy'",html,fixed=TRUE),
              grepl("class='edit'",html,fixed=TRUE),
              grepl(paste0("data-target='code-",id,"'"),html,fixed=TRUE))
    eval(parse(text=page$code),envir=new.env(parent=.GlobalEnv))
  } else {
    stopifnot("exam answer pattern" %in% names(page$sections),
              !nzchar(page$code),!length(page$edit),
              !grepl("class='copy'",html,fixed=TRUE),
              !grepl("class='edit'",html,fixed=TRUE),
              grepl("Answer pattern for study",html,fixed=TRUE))
  }
}
folder <- prepare(hits=ru_find("ci_method_selection"),query="ci_method_selection")
for(id in ids) {
 path<-file.path(folder,paste0(id,".html"))
 stopifnot(file.exists(path),file.info(path)$size>200)
}
selector<-paste(readLines(file.path(folder,"ci_method_selection.html")),collapse="\n")
stopifnot(grepl("mean_ci_z.html",selector,fixed=TRUE),
          grepl("mean_confidence_interval.html",selector,fixed=TRUE),
          grepl("proportion_interval",selector,fixed=TRUE),
          !grepl("class='copy'",selector,fixed=TRUE))
js<-paste(readLines(file.path(folder,"reference.js")),collapse="\n")
stopifnot(grepl("clipboard",js,ignore.case=TRUE),
          grepl("Clipboard access unavailable",js,fixed=TRUE),
          !grepl("fetch(",js,fixed=TRUE))
cat("P2-A1 compact catalogue, Viewer navigation, code copy and concept-only: PASS\n")

near <- function(a,b,tol=1e-10) {
 isTRUE(all.equal(unname(as.numeric(a)),unname(as.numeric(b)),
                  tolerance=tol,check.attributes=FALSE))
}
x <- c(4.2,4.8,5.1,4.5,5.3,4.9,5.0)
n <- length(x)
s <- stats::sd(x)
xbar <- mean(x)
known_sigma <- 1.6
known_variance <- known_sigma^2
for(level in c(0.90,0.95,0.99)) {
 alpha <- 1-level
 tcrit <- stats::qt(1-alpha/2,df=n-1L)
 manual_t <- c(xbar-tcrit*s/sqrt(n),xbar+tcrit*s/sqrt(n))
 api_t <- stats::t.test(x,conf.level=level)$conf.int
 stopifnot(near(manual_t,api_t),near(mean(manual_t),xbar),
           near(diff(manual_t),2*tcrit*s/sqrt(n)))
 zcrit <- stats::qnorm(1-alpha/2)
 manual_z <- c(xbar-zcrit*sqrt(known_variance)/sqrt(n),
               xbar+zcrit*sqrt(known_variance)/sqrt(n))
 stopifnot(near(sqrt(known_variance),known_sigma),
           near(mean(manual_z),xbar),
           near(diff(manual_z),2*zcrit*known_sigma/sqrt(n)))
}
stopifnot(stats::qt(.975,6L) > stats::qnorm(.975))
w8 <- 2*stats::qnorm(.975)*known_sigma/sqrt(8)
w32 <- 2*stats::qnorm(.975)*known_sigma/sqrt(32)
stopifnot(near(w8/w32,2))
cat("P2-A1 independent 90/95/99 percent z/Student t critical oracles: PASS\n")

zcode <- get("mean_ci_z")$code
tcode <- get("mean_confidence_interval")$code
run_code <- function(code,from=NULL,to=NULL) {
 if(!is.null(from)) {
   stopifnot(grepl(from,code,fixed=TRUE))
   code <- sub(from,to,code,fixed=TRUE)
 }
 eval(parse(text=code),envir=new.env(parent=.GlobalEnv))
}
rejects <- function(code,from,to)
 inherits(try(suppressMessages(run_code(code,from,to)),
              silent=TRUE),"try-error")
stopifnot(rejects(zcode,"sigma_population_mm <- 1.6","sigma_population_mm <- 0"),
          rejects(zcode,"sigma_population_mm <- 1.6","sigma_population_mm <- -1"),
          rejects(zcode,"sigma_population_mm <- 1.6","sigma_population_mm <- Inf"),
          rejects(zcode,"sigma_population_mm <- 1.6","sigma_population_mm <- NA_real_"),
          rejects(zcode,"confidence_level <- 0.95","confidence_level <- 0"),
          rejects(zcode,"confidence_level <- 0.95","confidence_level <- 1"),
          rejects(zcode,"confidence_level <- 0.95","confidence_level <- NA_real_"),
          rejects(zcode,'column <- "length_mm"','column <- "does_not_exist"'),
          rejects(zcode,"30.2, 31.0, 29.7","NA_real_, 31.0, 29.7"),
          rejects(zcode,"30.2, 31.0, 29.7","Inf, 31.0, 29.7"),
          rejects(tcode,"confidence_level <- 0.95","confidence_level <- -0.5"),
          rejects(tcode,"confidence_level <- 0.95","confidence_level <- 1"),
          rejects(tcode,"4.2, 4.8, 5.1, 4.5, 5.3, 4.9, 5.0","4.2"),
          rejects(tcode,"4.2, 4.8, 5.1, 4.5, 5.3, 4.9, 5.0","rep(4.2,7)"),
          rejects(tcode,"4.2, 4.8, 5.1","NA_real_, 4.8, 5.1"),
          rejects(tcode,"4.2, 4.8, 5.1","Inf, 4.8, 5.1"))
z1 <- run_code(zcode,
  "30.2, 31.0, 29.7, 30.5, 30.8, 29.9, 30.4, 30.1",
  "30.2")
stopifnot(z1["n"]==1L,is.finite(z1["lower"]),is.finite(z1["upper"]))
t2 <- run_code(tcode,
  "4.2, 4.8, 5.1, 4.5, 5.3, 4.9, 5.0",
  "c(4.2,4.8)")
stopifnot(t2["n"]==2L,is.finite(t2["lower"]),is.finite(t2["upper"]))
for(id in c("central_limit_theorem","mean_confidence_interval","mean_ci_z")) {
 text <- tolower(paste(unlist(get(id)$sections),collapse=" "))
 stopifnot(grepl("normal",text,fixed=TRUE),
           grepl("sampling",text,fixed=TRUE),
           grepl("independen",text,fixed=TRUE))
}
clt <- tolower(paste(unlist(get("central_limit_theorem")$sections),collapse=" "))
stopifnot(grepl("heavy tails",clt,fixed=TRUE),
          grepl("30",clt,fixed=TRUE),
          grepl("finite",clt,fixed=TRUE),
          !grepl("n >= 30 is enough",clt,fixed=TRUE))
cat("P2-A1 native code boundary rejection 16/16, z n=1 and t n=2: PASS\n")