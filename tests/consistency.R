library(rulearn)

# The installed guides are the same source used by the website.
root <- system.file(package="rulearn")
guides <- file.path(root,"guides")
examples <- file.path(root,"examples")
index <- getFromNamespace(".ru_db","rulearn")("problems.csv")

stopifnot(dir.exists(guides),dir.exists(examples))
stopifnot(!anyDuplicated(index$id))
guide_names <- sub("[.]qmd$","",list.files(guides,pattern="[.]qmd$"))
guide_names <- setdiff(guide_names,"index")
example_names <- sub("[.]R$","",list.files(examples,pattern="[.]R$"))
stopifnot(setequal(index$id,guide_names),
          setequal(index$id,example_names))

for (id in index$id) {
  page <- file.path(guides,paste0(id,".qmd"))
  link <- paste0("../examples/",id,".R")
  contents <- readLines(page,warn=FALSE)
  if (!any(grepl(link,contents,fixed=TRUE)))
    stop("Missing or invalid example link for ",id)
  if (!any(grepl("ru_plan(",contents,fixed=TRUE)))
    stop("Missing decision advice in guide for ",id)
  if (!file.exists(file.path(examples,paste0(id,".R"))))
    stop("Missing script for ",id)
}

for (id in c("histogram","grouped_boxplot","two_sample_t")) {
  guide <- paste(readLines(file.path(guides,paste0(id,".qmd"))),collapse="\n")
  script <- paste(readLines(file.path(examples,paste0(id,".R"))),collapse="\n")
  if (!grepl("#| eval: true",guide,fixed=TRUE))
    stop("Reference example does not render its real output: ",id)
  if (grepl("ru_apply(",script,fixed=TRUE))
    stop("Reference example must teach base R directly: ",id)
  if (!grepl("THE QUESTION",script,fixed=TRUE))
    stop("Reference script missing its learning question: ",id)
}

guide <- capture.output(ru_guide("histogram"))
stopifnot(length(guide)==0L)
lesson <- getFromNamespace(".ru_lesson_read","rulearn")("histogram")
stopifnot(!is.null(lesson),grepl("hist(",lesson$code,fixed=TRUE))
scratch <- tempfile(pattern="rulearn-edit-")
dir.create(scratch)
created <- ru_edit("histogram",dir=scratch,open=FALSE)
stopifnot(file.exists(created),
          inherits(try(ru_edit("histogram",dir=scratch,open=FALSE),
                       silent=TRUE),"try-error"))
unlink(scratch,recursive=TRUE)

cat("Guide, script, and installed-resource checks passed: ",
    length(index$id)," problems.\n",sep="")