# W2 L4 reference source, interval semantics and structural UX checks.
options(rulearn.auto_home = FALSE)
library(rulearn)
ns <- function(id) getFromNamespace(id, "rulearn")
ids <- c("rstudio_contexts", "vectors_indexing", "missing_values",
         "describe_numeric", "histogram_interpret")
read_topic <- ns(".ru_lesson_read")
page_html <- ns(".ru_page_html")
root <- system.file(package = "rulearn")
legacy <- file.path(root, "lessons")
folder <- system.file("references", "w2", package = "rulearn")
stopifnot(nzchar(root), nzchar(folder), dir.exists(folder),
          length(list.files(legacy,pattern = "[.]md$")) == 84L,
          nrow(ns(".ru_lesson_index")()) == 84L,
          all(ns(".ru_lesson_index")()$status == "VERIFIED"),
          length(list.files(folder, pattern = "[.]md$")) == 5L,
          setequal(list.files(folder,pattern="[.]md$"),
                   paste0(ids,".md")),
          file.exists(file.path(root,"extdata","coverage.csv")))
for (unsafe in list(NULL, NA_character_, "", "../missing_values",
                    "/etc/passwd", "%2e%2e", "missing_values/../../",
                    c("mean","missing_values"), ".hidden")) {
  stopifnot(is.null(read_topic(unsafe)))
}
for (id in ids) {
  path <- file.path(folder,paste0(id,".md"))
  stopifnot(file.exists(path),
            !file.exists(file.path(legacy,paste0(id,".md"))))
  page <- read_topic(id)
  stopifnot(identical(normalizePath(page$source,winslash="/"),
                      normalizePath(path,winslash="/")),
            identical(page$meta$collection,"w2.reference.v1"),
            identical(page$id, id), identical(page$meta$status, "AUTHORED"),
            nzchar(page$title), nzchar(page$code),
            all(c("immediate answer","use this in r","what to edit","what to check",
                  "interpret your results","learn more") %in% names(page$sections)),
            length(parse(text=page$code)) > 0L)
  html <- page_html(page)
  stopifnot(grepl("w2-ref-grid", html, fixed=TRUE),
            grepl("w2-ref-aside", html, fixed=TRUE),
            grepl("review-status", html, fixed=TRUE),
            grepl("Quick answer", html, fixed=TRUE))
  if (id %in% c("missing_values","describe_numeric")) {
    stopifnot(grepl("observed-missing-flow.svg", html, fixed=TRUE),
              grepl("alt='", html, fixed=TRUE) && nzchar(page$meta$alt))
  }
  if (id == "histogram_interpret")
    stopifnot(grepl("histogram-bins.svg", html, fixed=TRUE),
              grepl("150 recorded iris", html, fixed=TRUE))
}
shell <- ns(".ru_shell")("Test local reference", "<h1>Test</h1>")
stopifnot(grepl("w2-mode-nav", shell, fixed=TRUE),
          grepl("Learning materials",shell,fixed=TRUE),
          grepl("Analyzing: launch separately",shell,fixed=TRUE),
          grepl("Reference catalogue",shell,fixed=TRUE),
          grepl("w2-return-context",shell,fixed=TRUE),
          grepl("tabindex='-1'",shell,fixed=TRUE))
css <- readLines(system.file("www","reference.css",package="rulearn"),warn=FALSE)
css <- paste(css, collapse="\n")
for (check in c("@media(min-width:960px)","@media(max-width:400px)",
                "@media(max-width:320px)",".w2-ref-grid",
                "a:focus-visible","--atlas-ocean","prefers-reduced-motion"))
  stopifnot(grepl(check,css,fixed=TRUE))
js <- paste(readLines(system.file("www","reference.js",package="rulearn"),warn=FALSE),collapse="\n")
stopifnot(grepl("ru-w2-focus-v1",js,fixed=TRUE),
          grepl("sessionStorage.removeItem(key)",js,fixed=TRUE),
          grepl("results.html",js,fixed=TRUE))
fig <- readLines(system.file("www","figures","observed-missing-flow.svg",package="rulearn"),
                 warn=FALSE)
stopifnot(any(grepl("<title",fig,fixed=TRUE)),
          any(grepl("<desc",fig,fixed=TRUE)))
scope <- utils::read.csv(system.file("licensing","scope.csv",package="rulearn"),
                        stringsAsFactors=FALSE)
for (path in c(paste0("inst/references/w2/",ids,".md"),
               "inst/www/figures/observed-missing-flow.svg",
               "tests/lane4-w2.R"))
  stopifnot(sum(scope$source_path==path)==1L)
# Standalone numerical oracle: distinct constructed temperatures and iris.
temps <- c(13,NA_real_,18,20)
stopifnot(length(temps)==4L,sum(is.na(temps))==1L,
          sum(!is.na(temps))==3L,mean(temps,na.rm=TRUE)==17,
          median(temps,na.rm=TRUE)==18,
          abs(sd(temps,na.rm=TRUE)-sqrt(13))<1e-12)
x <- datasets::iris$Sepal.Length
right <- hist(x,breaks=seq(4,8,by=1),right=TRUE,include.lowest=TRUE,plot=FALSE)
left <- hist(x,breaks=seq(4,8,by=1),right=FALSE,include.lowest=TRUE,plot=FALSE)
right_narrow <- hist(x,breaks=seq(4,8,by=.25),right=TRUE,
                     include.lowest=TRUE,plot=FALSE)
left_narrow <- hist(x,breaks=seq(4,8,by=.25),right=FALSE,
                    include.lowest=TRUE,plot=FALSE)
stopifnot(length(x)==150L,nrow(datasets::faithful)==272L,
          right$counts[2L]==57L,left$counts[2L]==61L,
          right_narrow$counts[5L]==13L,left_narrow$counts[5L]==23L,
          sum(right$counts)==150L,sum(left$counts)==150L)
cat("L4 W2 source/semantic/static UX tests PASS; rendered keyboard, screen-reader and Windows are NOT_TESTED.\n")
