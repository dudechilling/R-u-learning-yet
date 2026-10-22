# Regression for one-letter apostrophe suffixes and irrelevant search hits.
# These examples test retrieval, not an assignment-solving calculation.
library(rulearn)
stopifnot(as.character(packageVersion("rulearn"))=="0.4.2.9001")

tokens <- getFromNamespace(".ru_words","rulearn")
for(term in c("car's","car’s","bike's","bike’s","driver's","driver’s")) {
  part <- tokens(term)
  stopifnot(length(part)==1L,!identical(part,"s"),
            !("s" %in% part))
}
stopifnot(identical(tokens("Spearman's rho"),c("spearman","rho")),
          identical(tokens("Spearman’s rho"),c("spearman","rho")),
          identical(tokens("r_s"),c("r","s")),
          identical(tokens("r"),"r"),
          identical(tokens("s"),"s"),
          identical(tokens("t"),"t"),
          identical(tokens("x"),"x"),
          identical(tokens("y"),"y"),
          !("s" %in% tokens("How do I repair my car's starter?")),
          !("s" %in% tokens("How do I repair my car’s starter?")))

# Generic question framing ("why", "change", "compare") is not in
# itself a statistical concept. Actual named methods and data terms remain.
for(term in c("why","change","compare"))
  stopifnot(length(tokens(term))==0L)

negatives <- c(
  "How do I repair my car's starter?",
  "How do I change my car's oil?",
  "Why is my bike's chain falling off?",
  "How do I fix a broken car engine?",
  "How do I repair my car’s starter?",
  "How do I change my car’s oil?",
  "Why is my bike’s chain falling off?"
)
for(query in negatives) {
  console <- capture.output(hits <- ru_find(query,n=10L))
  stopifnot(length(console)==0L,nrow(hits)==0L)
  stopifnot(is.null(ru_open(query)))
}
# A no-match must generate the installed offline Viewer no-match page,
# not render an unrelated article as the default suggestion.
first <- negatives[[1L]]
hits <- ru_find(first)
folder <- getFromNamespace(".ru_viewer_prepare","rulearn")(
  hits=hits,query=first)
results <- paste(readLines(file.path(folder,"results.html"),warn=FALSE),
                 collapse="\n")
stopifnot(grepl("No matching local reference",results,fixed=TRUE),
          grepl("Do not use an unrelated statistical procedure.",
                results,fixed=TRUE),
          !grepl("href='spearman.html'",results,fixed=TRUE),
          !grepl("<ol class='results'>",results,fixed=TRUE))
stopifnot(identical(capture.output(ru_text(first)),
                    "No local reference found."))

# Named methods and appropriate programming errors remain discoverable.
positives <- c(
  "When should I use Spearman correlation?"="spearman",
  "How do I calculate Spearman's rho?"="spearman",
  "How do I calculate Spearman’s rho?"="spearman",
  "How do I calculate Pearson correlation?"="pearson",
  "How do I compare car weight and fuel economy using Spearman?"="spearman",
  "How do I fix an object not found error in R?"="r_errors",
  "How do I plot x and y?"="scatterplot",
  "How do I run a t test?"="one_sample_t",
  "Compare measurements separated by category with a boxplot"="grouped_boxplot",
  "How do I compare independent groups?"="two_sample_t",
  "Why is stationarity important?"="stationarity"
)
for(query in names(positives)) {
  hits <- ru_find(query,n=5L)
  if(nrow(hits)==0L || !identical(hits$id[[1L]],unname(positives[[query]])))
    stop("Wrong leading method for ",encodeString(query,quote='"'),
         ": ",if(nrow(hits))hits$id[[1L]] else "no match",
         " (expected ",positives[[query]],")",call.=FALSE)
}
# Short statistical symbols are still searchable even when the same
# letters occur as clitics in ordinary English.
r <- ru_find("Does r measure correlation?",n=5L)
rs <- ru_find("What is r_s in a Spearman correlation?",n=5L)
t <- ru_find("How do I run a t test?",n=5L)
xy <- ru_find("How do I plot x and y?",n=5L)
stopifnot(any(r$id %in% c("correlation","r_cor","spearman_correlation")),
          any(rs$id %in% c("spearman","spearman_correlation")),
          any(t$id %in% c("one_sample_t","two_sample_t","paired_t","r_t_test")),
          identical(xy$id[[1L]],"scatterplot"))

cat("Apostrophe tokenization, seven no-match controls, eleven positive",
    "statistical searches, short notation and Viewer fallback: PASS\n")