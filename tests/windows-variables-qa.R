# Regression for the first supervised user QA failure.
# The user's own CSV, observations and academic materials are not copied here.
library(rulearn)

cases <- list(
  "How do I create variables?"=c("r_objects_columns","function"),
  "How do I create a variable from a CSV column?"=c("r_objects_columns","function"),
  "What does <- mean in R?"=c("r_objects_columns","function"),
  "What does df$mpg mean?"=c("r_objects_columns","function"),
  "How do I add a new column to a data frame?"=c("r_objects_columns","function"),
  "How do I plot two numeric variables?"=c("scatterplot","walkthrough"),
  "What is a statistical variable?"=c("statistical_variable","concept"),
  "How do I create varibles?"=c("r_objects_columns","function")
)
for(q in names(cases)){
  printed <- capture.output(hits<-ru_find(q,n=5L))
  stopifnot(nrow(hits)>=1L,
            identical(hits$id[1L],cases[[q]][1L]),
            identical(hits$type[1L],cases[[q]][2L]),
            length(printed)<=5L,
            !any(grepl("correlation_test",printed,fixed=TRUE)))
}

# Truly unseen phrasings: assignment, extraction, statistical vs R terms,
# paired numeric visualization, and unsupported out-of-domain requests.
paraphrases <- c(
  "How can I store a data-frame column in a separate R object?"="r_objects_columns",
  "What is the R assignment arrow?"="r_objects_columns",
  "How do I select a field from a data frame?"="r_objects_columns",
  "Save my mpg column as an object"="r_objects_columns",
  "How do I extract values from a CSV column?"="r_objects_columns",
  "Make a new column in a data frame"="r_objects_columns",
  "Explain the meaning of a statistical variable in an experiment"="statistical_variable",
  "What does variable mean in statistics?"="statistical_variable",
  "Compare two numeric columns on a scatterplot"="scatterplot",
  "Draw a scatter diagram for paired numerical measurements"="scatterplot",
  "Plot the relationship between two columns"="scatterplot")
for(q in names(paraphrases)){
  invisible(capture.output(h<-ru_find(q,n=2L)))
  stopifnot(nrow(h)>0L,identical(h$id[1L],paraphrases[[q]]))
}
no_match <- c(
  "How do I do something this library does not cover?",
  "Can you book flights and buy plane tickets for me?",
  "Tell me whether my car's engine is broken",
  "How do I make a cup of tea?",
  "What causes temperatures to change?")
for(q in no_match){
  txt <- capture.output(h<-ru_find(q,n=4L))
  stopifnot(nrow(h)==0L,length(txt)==0L)
}

# Genuine offline help, including R's native help topics for <- and $.
stopifnot(length(help("r_objects_columns",package="rulearn"))==1L,
          length(help("statistical_variable",package="rulearn"))==1L,
          length(help("assignOps",package="base"))==1L,
          length(help("Extract",package="base"))==1L)
stopifnot(nrow(ru_open("r_objects_columns"))==1L)
installed_rd <- utils:::.getHelpFile(
  help("r_objects_columns",package="rulearn"))
article <- getFromNamespace(".ru_console_rd","rulearn")(installed_rd)
stopifnot(any(grepl("mpg <- df$mpg",article,fixed=TRUE)),
          any(grepl("weight <- df$weight",article,fixed=TRUE)),
          any(grepl("What to change",article,fixed=TRUE)),
          any(grepl("What to check",article,fixed=TRUE)),
          !any(grepl(intToUtf8(8L),article,fixed=TRUE)))

# Does the promised R operation really create an object containing the
# matching column? We use recorded built-in mtcars rather than lab data.
df <- mtcars
df$weight <- df$wt
mpg <- df$mpg
weight <- df$weight
stopifnot(is.data.frame(df),nrow(df)==32L,
          identical(mpg,df$mpg),identical(weight,df$weight),
          length(mpg)==nrow(df),length(weight)==nrow(df))
df$mpg_per_weight <- df$mpg / df$weight
stopifnot(all(is.finite(df$mpg_per_weight)),
          identical(names(df)[ncol(df)],"mpg_per_weight"))

# One conversion from each canonical Quarto guide (no second doc system).
catalog <- getFromNamespace(".ru_db","rulearn")("problems.csv")
ids <- unique(catalog$id)
stopifnot(length(ids)==46L)
for(id in ids){
  console <- capture.output(ru_guide(id))
  stopifnot(length(console)==0L)
  tmp <- getFromNamespace(".ru_quarto_guide_to_rd","rulearn")(id)
  stopifnot(file.exists(tmp),inherits(tools::parse_Rd(tmp),"Rd"))
}
legacy <- getFromNamespace(".ru_short_fallback","rulearn")(
  getFromNamespace(".ru_catalog","rulearn")()[
    getFromNamespace(".ru_catalog","rulearn")()$id=="correlation_test",][1L,])
stopifnot(grepl("compatibility wrapper",legacy,fixed=TRUE))
native <- getFromNamespace(".ru_page_html","rulearn")(
  getFromNamespace(".ru_lesson_read","rulearn")("histogram"))
stopifnot(grepl("Quick answer",native,fixed=TRUE),
          grepl("Use this in R",native,fixed=TRUE),
          grepl("hist(",native,fixed=TRUE),
          !grepl("#| eval:",native,fixed=TRUE))

# The quick R script must remain editable and contain no package solver call.
folder <- tempfile("ruly-qa-");dir.create(folder)
path <- ru_edit("histogram",dir=folder,open=FALSE,mode="quick")
stopifnot(file.exists(path),!any(grepl("ru_apply(",readLines(path),fixed=TRUE)))
grDevices::pdf(tempfile(fileext=".pdf"))
e <- new.env(parent=.GlobalEnv)
result <- try(sys.source(path,envir=e),silent=TRUE)
grDevices::dev.off()
stopifnot(!inherits(result,"try-error"))
unlink(folder,recursive=TRUE)

cat("RLY-QA-001..010 and unseen paraphrase, fallback, help,",
    "46-guide Rd rendering, edit and no-match checks: PASS\n")