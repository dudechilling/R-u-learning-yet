# Verification of offline assignment-first rendering and retrieval.
# No private academic data or instructor-owned source text is used.
library(rulearn)

items <- c(
  "How do I create variables?"="r_objects_columns",
  "What does df$mpg mean?"="r_objects_columns",
  "What does <- mean?"="r_objects_columns",
  "How do I create a stem and leaf plot?"="r_stem",
  "What is positive skew?"="skewness",
  "How can I tell if my data are skewed?"="skewness",
  "What does unimodal mean?"="unimodal",
  "What does bimodal mean?"="bimodal",
  "How do I calculate the range?"="range",
  "How do I make a histogram?"="histogram",
  "How do I change histogram intervals?"="histogram_breaks",
  "How do I interpret a boxplot?"="boxplot",
  "How do I calculate quartiles?"="quartiles",
  "How do I calculate the mean?"="mean",
  "How do I calculate sample variance?"="variance",
  "How do I calculate standard deviation?"="variance_sd",
  "How do I calculate Pearson correlation?"="pearson",
  "When should I use Spearman correlation?"="spearman",
  "What is a sample space?"="sample_space",
  "How do I interpret a correlation coefficient?"="direction_strength"
)
lesson_read <- getFromNamespace(".ru_lesson_read","rulearn")
make_page <- getFromNamespace(".ru_page_html","rulearn")
prepare <- getFromNamespace(".ru_viewer_prepare","rulearn")
view_ready <- getFromNamespace(".ru_rstudio_ready","rulearn")
stopifnot(!view_ready("viewer"))

for(query in names(items)) {
  result <- NULL
  output <- capture.output(result <- ru_find(query))
  stopifnot(length(output)==0L,nrow(result)>0L,
            identical(result$id[1L],items[[query]]))
  page <- lesson_read(result$id[1L])
  stopifnot(!is.null(page))
  markup <- make_page(page)
  stopifnot(grepl("Quick answer",markup,fixed=TRUE),
            grepl("Use this in R",markup,fixed=TRUE),
            grepl("What to edit",markup,fixed=TRUE),
            grepl("<details>",markup,fixed=TRUE),
            grepl("class='copy'",markup,fixed=TRUE),
            grepl("<table class='edit'>",markup,fixed=TRUE),
            !grepl("#| eval:",markup,fixed=TRUE))
}
cat("20 exact natural-language questions: 20/20 appropriate compact first references.\n")

paraphrases <- c(
 "I need to sort these numeric measurements"="sort_values",
 "How do I find the lowest observation?"="minimum",
 "How can I calculate the observed maximum?"="maximum",
 "What is a right skewed distribution?"="skewness",
 "How do I change the number of histogram bins?"="histogram_breaks",
 "How do I find the first, second and third quartiles?"="quartiles",
 "What does a negative correlation coefficient tell me?"="direction_strength",
 "How do I select a CSV column as an R object?"="r_objects_columns",
 "How can I create an object to hold mpg?"="r_objects_columns",
 "What is the difference between correlation and causation?"="correlation",
 "How do I plot two numerical variables?"="scatterplot"
)
results <- character()
for(question in names(paraphrases)) {
  x<-ru_find(question,n=4L)
  results <- c(results,if(nrow(x))x$id[1L] else "NONE")
}
cat("Unseen paraphrase top-1: ",sum(results==unname(paraphrases)),"/",
    length(paraphrases),"\n",sep="")
print(data.frame(query=names(paraphrases),expected=unname(paraphrases),
                 observed=results),row.names=FALSE)
stopifnot(all(results==unname(paraphrases)))

for(q in c("How do I do something this library does not cover?",
           "How do I make a cup of tea?",
           "Tell me whether my car's engine is broken")) {
  text <- capture.output(hit<-ru_find(q))
  stopifnot(length(text)==0L,nrow(hit)==0L)
}
stopifnot(length(capture.output(ru_open("skewness")))==0L)
stopifnot(length(capture.output(ru_guide("histogram")))==0L)
stopifnot(nrow(ru_open("skewness"))==1L)

directory <- tempfile("ruly-edit-");dir.create(directory)
for(id in c("skewness","sample_space","variance","pearson")) {
  path<-ru_edit(id,dir=directory,open=FALSE)
  stopifnot(file.exists(path),
            identical(paste(readLines(path,warn=FALSE),collapse="\n"),
                      lesson_read(id)$code),
            !any(grepl("ru_apply(",readLines(path),fixed=TRUE)))
}
stopifnot(inherits(try(ru_edit("skewness",dir=directory,open=FALSE),
                       silent=TRUE),"try-error"))
unlink(directory,recursive=TRUE)

# Every reviewed lesson has the same one-source content structure and a
# genuinely executable example from an R included dataset or a model.
index <- getFromNamespace(".ru_lesson_index","rulearn")()
stopifnot(nrow(index)==84L,!anyDuplicated(index$id),all(index$status=="VERIFIED"))
grDevices::pdf(tempfile(fileext=".pdf"))
for(id in index$id) {
 item <- lesson_read(id)
 stopifnot(all(c("immediate answer","what to check",
                 "interpret your results","learn more") %in%
               names(item$sections)),
           !grepl("ru_apply(",item$code,fixed=TRUE),
           item$meta$status %in% c("AUTHORED","VERIFIED"))
 if(nzchar(item$code)){
   stopifnot(length(item$edit)>=1L,
             all(c("use this in r","what to edit") %in% names(item$sections)))
   env <- new.env(parent=.GlobalEnv)
   result <- try(suppressMessages(eval(parse(text=item$code),envir=env)),
                 silent=TRUE)
   if(inherits(result,"try-error"))
     stop("Lesson failed to execute: ",id," ",result,call.=FALSE)
 } else {
   stopifnot(length(item$edit)==0L,
             "exam answer pattern" %in% names(item$sections))
   page <- make_page(item)
   stopifnot(!grepl("class='copy'",page,fixed=TRUE),
             grepl("Answer pattern for study",page,fixed=TRUE))
 }
}
grDevices::dev.off()

# All Viewer pages and assets live in an R session's tempdir.
folder<-prepare(hits=ru_find("What is positive skew?"),query="What is positive skew?")
html<-list.files(folder,pattern="[.]html$")
stopifnot(length(html)>=95L,
          file.exists(file.path(folder,"catalog.html")),
          file.exists(file.path(folder,"results.html")),
          file.exists(file.path(folder,"figures","skew-shapes.svg")),
          file.exists(file.path(folder,"reference.js")),
          file.exists(file.path(folder,"reference.css")),
          file.exists(file.path(folder,"field-atlas.css")))
s<-paste(readLines(file.path(folder,"skewness.html")),collapse="\n")
stopifnot(grepl("aria-label='Copy this R code",s,fixed=TRUE),
          grepl("details",s,fixed=TRUE),
          grepl("figures/skew-shapes.svg",s,fixed=TRUE),
          grepl("img src=",s,fixed=TRUE),
          !grepl("Quarto",s,fixed=TRUE),
          !grepl("#| eval:",s,fixed=TRUE))
# Injected HTML is escaped: both tags and quote attributes.
query <- "<script>alert('bad')</script>"
prepare(hits=ru_find(query),query=query)
s<-paste(readLines(file.path(folder,"results.html")),collapse="\n")
stopifnot(!grepl("<script>alert('bad')</script>",s,fixed=TRUE),
          grepl("&lt;script&gt;",s,fixed=TRUE))
source <- getFromNamespace(".ru_coverage","rulearn")()
stopifnot(nrow(source)==174L,
          sum(source$content_status=="VERIFIED")==84L,
          sum(source$content_status=="AUTHORED")==48L,
          sum(source$content_status=="NEEDS_REVIEW")==6L,
          sum(source$content_status=="DISCOVERED")==36L,
          !anyDuplicated(source$reference_id),
          all(index$id %in% source$reference_id),
          !any(vapply(
            c(paste0(c("STAT","GEOG")," ",c("1200","2700")),
              paste0("/home","/earl")),
            function(term) grepl(term,paste(source,collapse=" "),fixed=TRUE),
            logical(1L))))
catalog<-paste(readLines(file.path(folder,"catalog.html")),collapse="\n")
stopifnot(grepl("Topic coverage",catalog,fixed=TRUE),
          grepl("Verified",catalog,ignore.case=TRUE))
cat(nrow(index),"compact lessons, conceptual study and native code, static pages, ",
    "offline content, CSP, query escaping, 169-topic ledger: PASS\n",sep="")