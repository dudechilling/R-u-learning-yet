# Full-public-install dependency contract: use installed package, no IDE or network.
suppressPackageStartupMessages(library(rulearn))
required <- c("bslib","digest","filelock","learnr",
              "palmerpenguins","rstudioapi","shiny")
imports <- trimws(strsplit(
  utils::packageDescription("rulearn")$Imports, ",", fixed = TRUE
)[[1L]])
stopifnot(all(required %in% imports))
present <- vapply(required,requireNamespace,logical(1L),quietly=TRUE)
stopifnot(all(present))
caps <- ru_capabilities()
stopifnot(is.list(caps),all(caps$packages$installed))
stopifnot(!identical(caps$routes$status[caps$routes$mode=="analyze"],
                     "UNAVAILABLE_DEPENDENCY"))
stopifnot(!identical(caps$routes$status[caps$routes$mode=="progress_write"],
                     "UNAVAILABLE"))
selector <- ru_learn()
stopifnot(is.list(selector),identical(selector$status,"SELECTOR"),
          nrow(selector$lessons)==3L,!selector$opened)
stopifnot(is.data.frame(ru_data("penguins")))
cat("Windows-ready complete hard-dependency install PASS: ",
    length(required)," runtime dependencies, full foundation selector, ",
    "optional dataset and nonexecuting routes.\n",sep="")