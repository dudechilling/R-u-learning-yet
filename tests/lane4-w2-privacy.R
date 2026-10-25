# W2 authored reference privacy check. This complements, not replaces,
# the unchanged Field Atlas legacy 84-topic privacy regression.
options(rulearn.auto_home = FALSE)
library(rulearn)
root <- system.file(package = "rulearn")
stopifnot(nzchar(root), dir.exists(root))
ids <- c("rstudio_contexts", "vectors_indexing", "missing_values",
         "describe_numeric", "histogram_interpret")
folder <- system.file("references", "w2", package = "rulearn")
stopifnot(nzchar(folder), dir.exists(folder))
files <- sort(list.files(folder, pattern = "[.]md$", full.names = TRUE))
expected <- file.path(folder, paste0(ids, ".md"))
stopifnot(length(files) == 5L, setequal(files, expected),
          !any(file.exists(file.path(root, "lessons", paste0(ids, ".md")))))
figures <- file.path(root, "www", "figures",
                     c("observed-missing-flow.svg", "histogram-bins.svg"))
sources <- c(files, figures)
stopifnot(length(sources) == 7L, all(file.exists(sources)),
          !any(dir.exists(sources)))
pkg_root <- normalizePath(root, winslash = "/", mustWork = TRUE)
for (source in sources) {
  link <- Sys.readlink(source)
  stopifnot(length(link) == 1L, is.na(link) || !nzchar(link))
  resolved <- normalizePath(source, winslash = "/", mustWork = TRUE)
  stopifnot(startsWith(resolved, paste0(pkg_root, "/")))
}
# Original generic privacy markers; operator exact terms remain outside Git.
signals <- c("/home/", "/mnt/", "file:///", "C:\\Users\\")
private_file <- Sys.getenv("RULEARN_PRIVATE_TERMS_FILE", unset = "")
if (nzchar(private_file)) {
  stopifnot(file.exists(private_file), !dir.exists(private_file))
  signals <- unique(c(signals, readLines(private_file, warn = FALSE)))
  signals <- signals[nzchar(signals)]
} else {
  message("Restricted term list not supplied: generic path checks only.")
}
contents <- paste(unlist(lapply(sources, readLines, warn = FALSE)),
                  collapse = "\n")
exposed <- vapply(signals, function(term)
  grepl(tolower(term), tolower(contents), fixed = TRUE), logical(1L))
if (any(exposed))
  stop("Forbidden marker in installed W2 reference or figure.", call. = FALSE)
cat("W2 privacy: five authored Markdown pages and two figures scanned; ",
    "generic and supplied restricted terms absent. PASS\n", sep = "")
