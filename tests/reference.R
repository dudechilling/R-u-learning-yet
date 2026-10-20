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
# Representative generic introductory-language tasks. No student work is
# embedded in test fixtures; only the types of method sought are retained.
replay_topics <- list(
  "Describe descriptive and inferential statistics"="descriptive_inferential",
  "Why do we use samples in statistics?"="population_sample",
  "Which scale of measurement is better for ordered categories?"=
     "measurement_scales",
  "What is a statistical experiment?"="probability_events",
  "What is a sample space?"="probability_events",
  "Difference between independent and mutually exclusive events"=
     "conditional_independence",
  "What does conditional probability mean?"="conditional_independence",
  "What is the complement of an event?"="probability_events",
  "Stem and leaf plot for a numeric column"="r_stem",
  "How to import a csv file"="import_csv"
)
for (q in names(replay_topics)) {
  invisible(capture.output(found <- ru_find(q,n=3L)))
  stopifnot(nrow(found)>0L,
            identical(found$id[1L],replay_topics[[q]]))
}
# Composite application questions should open the complete worked topic,
# not an unrelated graph or only one of the named R functions.
invisible(capture.output(both <- ru_find(
  "How do I calculate mean and median?",n=3L)))
stopifnot(nrow(both)>0L,
          identical(both$id[1L],"mean_median"),
          identical(both$type[1L],"walkthrough"))

# Distinguish an ordinary R programming error from "standard error",
# which names the estimated variability of a sample statistic.
invisible(capture.output(se <- ru_find(
  "What is the difference between standard deviation and standard error?",
  n=1L)))
stopifnot(nrow(se)==1L,identical(se$id[1L],"sampling_distributions"))
invisible(capture.output(bg <- ru_find(
  "Compare measurements separated by category with a boxplot",n=1L)))
stopifnot(nrow(bg)==1L,identical(bg$id[1L],"grouped_boxplot"))
# Outside statistical-reference scope, return no match rather than a
# plausible but unrelated concept. Native IDE help covers document rendering.
invisible(capture.output(outside <- ru_find(
  "Create a Quarto document rendered as PDF",n=3L)))
stopifnot(nrow(outside)==0L)

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
stopifnot(nrow(concepts)>=20L,nrow(functions)>=10L)
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
# Native quick mode is a separate, runnable short script. Full mode keeps
# the earlier detailed example; both modes share one installed source.
quick_dir <- file.path(scratch,"quick")
dir.create(quick_dir)
for(id in c("histogram","grouped_boxplot","two_sample_t")) {
  q <- ru_edit(id,dir=quick_dir,open=FALSE,mode="quick")
  lines <- readLines(q,warn=FALSE)
  stopifnot(length(lines)>1L, !any(grepl("ru_apply(",lines,fixed=TRUE)),
            !any(grepl("## ---- worked-",lines,fixed=TRUE)))
  pdf(tempfile(fileext=".pdf"))
  out <- try(sys.source(q,envir=new.env(parent=.GlobalEnv)),silent=TRUE)
  dev.off()
  if(inherits(out,"try-error"))
    stop("Immediate native example failed: ",id," - ",out)
}
both <- ru_edit("histogram",dir=quick_dir,open=FALSE,mode="both")
both_lines <- readLines(both,warn=FALSE)
stopifnot(any(grepl("## ---- quick-",both_lines,fixed=TRUE)),
          any(grepl("## ---- worked-",both_lines,fixed=TRUE)))
stopifnot(inherits(try(ru_edit("relative_frequency",dir=quick_dir,
                              mode="quick",open=FALSE),
                       silent=TRUE),"try-error"))

# Categorical lab tasks also use native table(), prop.table() and barplot().
for (mode in c("quick","full")) {
  path <- ru_edit("bar_chart",dir=quick_dir,open=FALSE,mode=mode)
  script <- readLines(path,warn=FALSE)
  stopifnot(any(grepl("barplot(",script,fixed=TRUE)),
            !any(grepl("ru_apply(",script,fixed=TRUE)))
  grDevices::pdf(tempfile(fileext=".pdf"))
  env <- new.env(parent=.GlobalEnv)
  error <- try(sys.source(path,envir=env),silent=TRUE)
  grDevices::dev.off()
  if(inherits(error,"try-error")) stop("Native bar-chart script failed: ",error)
  if(mode=="full") stopifnot(sum(env$counts)==150L,
                            isTRUE(all.equal(sum(env$proportions),1)))
}
# Frequently needed data-import, central-tendency and spread lessons
# must demonstrate ordinary R first. Full examples and Quick mode run.
for (id in c("import_csv","mean_median","sample_sd")) {
  content <- paste(readLines(file.path(
    system.file("guides",package="rulearn"),paste0(id,".qmd")),
    warn=FALSE),collapse="\n")
  stopifnot(grepl("## Immediate answer",content,fixed=TRUE),
            grepl("## What to change",content,fixed=TRUE),
            grepl("## What to check",content,fixed=TRUE),
            grepl("## Complete walkthrough",content,fixed=TRUE),
            grepl("## Retention practice (optional)",content,fixed=TRUE),
            !grepl("ru_apply(",content,fixed=TRUE))
  script <- readLines(file.path(system.file("examples",package="rulearn"),
                                paste0(id,".R")),warn=FALSE)
  stopifnot(grepl("## ---- quick-",script[1L],fixed=TRUE),
            any(grepl("## ---- worked-",script,fixed=TRUE)),
            !any(grepl("ru_apply(",script,fixed=TRUE)))
  note <- capture.output(ru_guide(id))
  stopifnot(which(grepl("## Immediate answer",note,fixed=TRUE))[1L] <
            which(grepl("## Complete walkthrough",note,fixed=TRUE))[1L])
  for (mode in c("quick","full")) {
    folder <- tempfile(paste0(id,"-"))
    dir.create(folder)
    path <- ru_edit(id,dir=folder,mode=mode,open=FALSE)
    grDevices::pdf(tempfile(fileext=".pdf"))
    outcome <- try(sys.source(path,envir=new.env(parent=.GlobalEnv)),
                   silent=TRUE)
    grDevices::dev.off()
    if (inherits(outcome,"try-error"))
      stop("Native lesson could not run: ",id, " ",mode," ",outcome)
    unlink(folder,recursive=TRUE)
  }
}

# Independent transfer: categorical numeric labels, different dataset.
dir.create(file.path(quick_dir,"transfer"))
path <- ru_edit("bar_chart",dir=file.path(quick_dir,"transfer"),
                mode="full",open=FALSE)
script <- readLines(path,warn=FALSE)
script <- gsub('data("iris", package="datasets")',
               'data("mtcars", package="datasets")',script,fixed=TRUE)
script <- gsub("iris$Species","factor(mtcars$cyl)",script,fixed=TRUE)
writeLines(script,path)
grDevices::pdf(tempfile(fileext=".pdf"))
env <- new.env(parent=.GlobalEnv)
error <- try(sys.source(path,envir=env),silent=TRUE)
grDevices::dev.off()
if(inherits(error,"try-error")) stop("Categorical transfer failed: ",error)
stopifnot(sum(env$counts)==nrow(mtcars),length(env$counts)==3L)

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
            grepl("Retention practice (optional)",code,fixed=TRUE),
            grepl("## Immediate answer",code,fixed=TRUE),
            grepl("## What to change",code,fixed=TRUE),
            grepl("## What to check",code,fixed=TRUE),
            grepl("## Complete walkthrough (optional)",code,fixed=TRUE),
            !grepl('ru_apply("',code,fixed=TRUE))
  script <- file.path(system.file("examples",package="rulearn"),
                      paste0(id,".R"))
  lines <- readLines(script,warn=FALSE)
  stopifnot(grepl("## ---- quick-",lines[1L],fixed=TRUE),
            any(grepl("## ---- worked-",lines,fixed=TRUE)),
            any(grepl("hist(",lines,fixed=TRUE) |
                grepl("boxplot(",lines,fixed=TRUE) |
                grepl("t.test(",lines,fixed=TRUE)))
  # The quick code must come before the detailed worked section.
  idx1 <- which(grepl("## ---- quick-",lines,fixed=TRUE))[1L]
  idx2 <- which(grepl("## ---- worked-",lines,fixed=TRUE))[1L]
  stopifnot(idx1 < idx2)
  guide_out <- capture.output(ru_guide(id))
  quick_heading <- grep("## Immediate answer",guide_out,fixed=TRUE)[1L]
  detailed_heading <- grep("## Complete walkthrough",guide_out,fixed=TRUE)[1L]
  stopifnot(is.finite(quick_heading),is.finite(detailed_heading),
            quick_heading<detailed_heading,
            any(grepl("```r",guide_out,fixed=TRUE)))
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
    original <- gsub("data(faithful)", "data(airquality)", original,
                     fixed=TRUE)
    original <- gsub('data("faithful", package="datasets")',
      'data("airquality", package="datasets")',original,fixed=TRUE)
    original <- gsub("faithful$eruptions","airquality$Wind",
                     original,fixed=TRUE)
    original <- gsub("Eruption duration (minutes)","Wind speed (mph)",
                     original,fixed=TRUE)
    original <- gsub("bin_width <- 0.5","bin_width <- 5",
                     original,fixed=TRUE)
  } else if (id=="grouped_boxplot") {
    original <- gsub("data(iris)", "data(ToothGrowth)", original,
                     fixed=TRUE)
    original <- gsub("Sepal.Length ~ Species, data=iris",
                     "len ~ supp, data=ToothGrowth",original,fixed=TRUE)
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
    original <- gsub('measurement_units <- "cm"',
                     'measurement_units <- "units"',original,fixed=TRUE)
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