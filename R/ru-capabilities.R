# Detect namespaces without loading the corresponding UI or creating state.
ru_capabilities <- function() {
  names <- c("shiny", "bslib", "learnr", "filelock", "digest", "rstudioapi")
  found <- vapply(names, requireNamespace, logical(1L), quietly = TRUE)
  versions <- vapply(seq_along(names), function(i)
    if (found[i]) as.character(utils::packageVersion(names[i])) else NA_character_,
    character(1L))
  packages <- data.frame(package = names, installed = unname(found),
                         version = unname(versions), stringsAsFactors = FALSE)
  ide <- FALSE
  if (found[["rstudioapi"]])
    ide <- tryCatch(isTRUE(rstudioapi::isAvailable()), error = function(e) FALSE)
  modes <- data.frame(
    mode = c("selector", "learn", "analyze", "reference_catalogue",
             "reference_viewer", "progress_write"),
    status = c("SUPPORTED", "UNAVAILABLE", "UNAVAILABLE", "SUPPORTED",
               if (ide) "UNTESTED" else "UNAVAILABLE",
               if (found[["filelock"]]) "UNTESTED" else "UNAVAILABLE"),
    reason = c("STRUCTURED_SELECTOR", "NOT_IMPLEMENTED", "NOT_IMPLEMENTED",
               "LOCAL_CATALOGUE", if (ide) "GUI_NOT_TESTED" else "RSTUDIO_NOT_AVAILABLE",
               if (found[["filelock"]]) "WRITE_NOT_TESTED" else "FILELOCK_NOT_INSTALLED"),
    stringsAsFactors = FALSE
  )
  structure(list(schema_version = 1L, R = as.character(getRversion()),
                 platform = R.version$platform, rstudio_detected = ide,
                 packages = packages, routes = modes),
            class = "ru_capabilities")
}