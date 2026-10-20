library(rulearn)

# REF-001/002: a concept or definition query should not require its exact title.
wanted <- list(
  "What is stationarity?"=c("stationarity","concept"),
  "Define standard deviation"=c("variance_sd","concept"),
  "What does a p-value mean?"=c("hypothesis_tests_pvalues","concept"),
  "How do I make a histogram?"=c("histogram","walkthrough"),
  "What is the difference between a sample and a population?"=
      c("population_sample","concept"),
  "How do I calculate an average by group?"=c("group_means","walkthrough"),
  "How does the sd function work?"=c("r_sd","function")
)
for (query in names(wanted)) {
  hits <- suppressMessages(ru_find(query,n=5L))
  stopifnot(nrow(hits)>0L,identical(hits$id[1L],wanted[[query]][1L]),
            identical(hits$type[1L],wanted[[query]][2L]),
            nzchar(hits$path[1L]))
}
stopifnot(identical(ru_find("histogram",n=1L)$id,"histogram"))

# Search familiarity, spelling, novice-language and recovery checks.
extra <- list(
  "stasionarity"=c("stationarity","concept"),
  "histgram"=c("histogram","walkthrough"),
  "standrad deviation"=c("variance_sd","concept"),
  "How does sd work?"=c("r_sd","function"),
  "When is a paired test appropriate?"=c("independent_paired","concept"),
  "Can I use a paired t test?"=c("independent_paired","concept"),
  "Object not found"=c("r_errors","concept"),
  "numeric data imported as text"=c("r_errors","concept"),
  "function not found"=c("r_errors","concept"),
  "Create and customize a histogram"=c("histogram","walkthrough")
)
for (q in names(extra)) {
  invisible(capture.output(got <- ru_find(q,n=3L)))
  stopifnot(nrow(got)>0L, identical(got$id[1L],extra[[q]][1L]),
            identical(got$type[1L],extra[[q]][2L]))
}
invisible(capture.output(no_match <- ru_find("xyzzymn",n=2L)))
stopifnot(nrow(no_match)==0L)
invisible(capture.output(corrected <- ru_find("histgram",n=3L)))
stopifnot(length(attr(corrected,"corrected_terms"))>0L)



# REF-003/004/007: official R help format is the installed source of truth.
idx <- utils::read.csv(system.file("extdata","reference.csv",
                                    package="rulearn"),
                       stringsAsFactors=FALSE)
concepts <- idx[idx$type=="concept",,drop=FALSE]
functions <- idx[idx$type=="function",,drop=FALSE]
stopifnot(nrow(concepts)>=12L,nrow(functions)>=8L)
for (topic in idx$topic) {
  page <- utils::help(topic,package="rulearn")
  if (length(page)!=1L) stop("Unresolvable native reference: ",topic)
}
stationarity_page <- utils::help("stationarity",package="rulearn")
stopifnot(length(stationarity_page)==1L,
          length(utils::help("standard deviation",package="rulearn"))==1L,
          length(utils::help("sd",package="stats"))==1L)
body <- paste(capture.output(tools::Rd2txt(
  utils:::.getHelpFile(stationarity_page))),collapse=" ")
for (word in c("Weak stationarity","variance","autocovariance","lag",
               "Nile","exploratory")) {
  if (!grepl(word,body,fixed=TRUE))
    stop("Stationarity help is missing: ",word)
}
stopifnot(length(ru_open("stationarity",type="concept"))==1L,
          length(ru_open("sd",type="function"))==1L)

# REF-005/006/012: edit and run ordinary native code, without a wrapper.
scratch <- tempfile(pattern="rulearn-reference-")
dir.create(scratch)
for (id in c("histogram","grouped_boxplot","two_sample_t")) {
  path <- ru_edit(id,dir=scratch,open=FALSE)
  lines <- readLines(path,warn=FALSE)
  if (!any(grepl("data(",lines,fixed=TRUE)) ||
      any(grepl("ru_apply(",lines,fixed=TRUE)))
    stop("The editable example depends on a custom calculation: ",id)
  device <- tempfile(fileext=".pdf")
  grDevices::pdf(device)
  err <- try(suppressMessages(sys.source(path,envir=new.env(parent=.GlobalEnv))),
             silent=TRUE)
  grDevices::dev.off()
  if (file.exists(device)) unlink(device)
  if (inherits(err,"try-error"))
    stop("Editable native code did not run: ",id," - ",err)
}
data(iris)
x <- iris$Sepal.Length
native <- c(mean=mean(x),median=median(x),sd=sd(x))
stopifnot(all(is.finite(native)),length(native)==3L)
# Replace the numeric variable, not the calculation helper.
y <- iris$Petal.Length
stopifnot(is.finite(mean(y)),!isTRUE(all.equal(mean(x),mean(y))))

# REF-008: source package includes all articles, examples and index files.
stopifnot(nrow(ru_find("sample",n=20,type="concept"))>0L,
          nrow(ru_find("sd",n=20,type="function"))>0L,
          nrow(ru_find("histogram",n=20,type="walkthrough"))>0L)
stopifnot(all(file.exists(file.path(system.file("guides",
                                                package="rulearn"),
                                    paste0(c("histogram","two_sample_t",
                                             "stationarity"),".qmd")))))
# Each flagship guide sources its one canonical native R script. A rendered
# figure must have a textual description and practice must remain optional.
for (id in c("histogram","grouped_boxplot","two_sample_t")) {
  guide <- file.path(system.file("guides",package="rulearn"),
                     paste0(id,".qmd"))
  code <- paste(readLines(guide,warn=FALSE),collapse="\n")
  stopifnot(grepl("knitr::read_chunk",code,fixed=TRUE),
            grepl("#| fig-alt:",code,fixed=TRUE),
            grepl("Remember it (optional)",code,fixed=TRUE),
            grepl("## Quick answer",code,fixed=TRUE),
            !grepl('ru_apply("',code,fixed=TRUE))
  script <- file.path(system.file("examples",package="rulearn"),
                      paste0(id,".R"))
  lines <- readLines(script,warn=FALSE)
  stopifnot(grepl("## ---- worked-",lines[1L],fixed=TRUE))
}
stopifnot(length(help("r_errors",package="rulearn"))==1L)

# Transfer check: change dataset and columns, run the SAME native script.
# This is not a human comprehension test, but it prevents hard-coded
# three-group/example-variable assumptions from creeping back in.
transfer_dir <- file.path(scratch,"transfer")
dir.create(transfer_dir)
for (id in c("histogram","grouped_boxplot","two_sample_t")) {
  path <- ru_edit(id,dir=transfer_dir,open=FALSE)
  original <- readLines(path,warn=FALSE)
  if (id=="histogram") {
    original <- gsub('data("faithful", package="datasets")',
      'data("airquality", package="datasets")',original,fixed=TRUE)
    original <- gsub("faithful$eruptions","airquality$Wind",
                     original,fixed=TRUE)
    original <- gsub("Eruption duration (minutes)","Wind speed (mph)",
                     original,fixed=TRUE)
  } else if (id=="grouped_boxplot") {
    original <- gsub('data("iris", package="datasets")',
      'data("ToothGrowth", package="datasets")',original,fixed=TRUE)
    original <- gsub("iris$Sepal.Length","ToothGrowth$len",original,fixed=TRUE)
    original <- gsub("iris$Species","ToothGrowth$supp",original,fixed=TRUE)
    original <- gsub("Sepal length by species","Tooth length by supplement",
                     original,fixed=TRUE)
    original <- gsub("Flower species","Supplement",original,fixed=TRUE)
    original <- gsub("Sepal length (cm)","Recorded tooth length",
                     original,fixed=TRUE)
    original <- gsub('" cm"','" units"',original,fixed=TRUE)
  } else original <- gsub("trt1","trt2",original,fixed=TRUE)
  writeLines(original,path)
  grDevices::pdf(tempfile(fileext=".pdf"))
  copied <- new.env(parent=.GlobalEnv)
  error <- try(suppressMessages(sys.source(path,envir=copied)),silent=TRUE)
  grDevices::dev.off()
  if(inherits(error,"try-error"))
    stop("Native script failed adaptation: ",id," ",error)
  if(id=="histogram")
    stopifnot(length(copied$values)==nrow(airquality),
              sum(copied$counts$counts)==nrow(airquality))
  if(id=="grouped_boxplot")
    stopifnot(length(copied$medians)==2L)
  if(id=="two_sample_t")
    stopifnot(identical(levels(copied$d$group),c("ctrl","trt2")),
              is.finite(copied$test$p.value))
}
unlink(scratch,recursive=TRUE)
cat("Reference acceptance tests passed: ",
    nrow(concepts)," concepts, ",nrow(functions),
    " function references, all core queries and native examples.\n",sep="")