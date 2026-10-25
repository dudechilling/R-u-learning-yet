# L1-owned W2 integration contracts: truthful consumer activation, paths, and search.
library(rulearn)
catalogue <- getFromNamespace(".ru_content_catalogue", "rulearn")()
keys <- paste(catalogue$surface, catalogue$id, catalogue$representation, sep = "/")
stopifnot(nrow(catalogue) == 26L, !anyDuplicated(keys),
          all(c("learn", "analyze", "reference", "asset", "example",
                "native_help") %in% catalogue$surface))
# L4's six reviewed registry rows must appear once, including the
# replacement of existing missing_values compact, not a duplicate.
refs <- c("rstudio_contexts", "vectors_indexing", "missing_values",
          "describe_numeric", "histogram_interpret")
for (id in refs) {
  row <- catalogue[catalogue$surface == "reference" &
                   catalogue$id == id &
                   catalogue$representation == "compact_md", , drop = FALSE]
  stopifnot(nrow(row) == 1L, row$rights_status == "NOT_CLEARED")
  result <- ru_reference(id, open = FALSE)
  present <- nzchar(system.file(row$relative_path, package = "rulearn"))
  stopifnot(result$status == if (present) "SINGLE_MATCH" else "UNAVAILABLE")
  if (present) stopifnot(result$resolution$locator_status == "AVAILABLE")
}
stopifnot(ru_reference("hist", open = FALSE)$status == "MULTIPLE_MATCHES")
legacy <- ru_reference("missing_values", representation = "legacy_guide_qmd",
                       open = FALSE)
stopifnot(legacy$status == "SINGLE_MATCH",
          legacy$resolution$locator_status == "AVAILABLE")
stopifnot(!ru_reference("missing_values", open = TRUE)$opened)

# L2's three exact installed selectors and both CSV assets cannot be
# represented as available until the corresponding peer bytes are installed.
lesson_ids <- paste0("ru.learning.foundation.0", 1:3)
for (i in seq_along(lesson_ids)) {
  row <- catalogue[catalogue$surface == "learn" &
                   catalogue$id == lesson_ids[i] &
                   catalogue$representation == "tutorial", , drop = FALSE]
  stopifnot(nrow(row) == 1L, row$source_type == "learnr_tutorial")
  stopifnot(grepl(sprintf("ru-foundation-%02d", i), row$relative_path, fixed = TRUE))
}
assets <- c("sites-intro-v1.csv", "sites-transfer-v1.csv")
expect_sha <- c("3166dcb4137ce10342f5bed98004c71e28e3aace1a0c088c7fa7c33da8f3834a",
                "45879c7bc71dc297f5b862f090931637f9d0ddfb718c4107baed1ca7c773c26a")
for (i in seq_along(assets)) {
  path <- system.file("tutorials", "ru-learning-foundations", "data",
                      assets[i], package = "rulearn")
  id <- paste0("ru.learning.foundation.03.", sub("\\.csv$", "", assets[i]))
  row <- catalogue[catalogue$surface == "asset" & catalogue$id == id &
                   catalogue$representation == "csv", , drop = FALSE]
  stopifnot(nrow(row) == 1L, row$source_type == "authored_csv")
  resolution <- getFromNamespace(".ru_content_resolve", "rulearn")(
    id, "asset", representation = "csv")
  if (nzchar(path)) {
    stopifnot(resolution$locator_status == "AVAILABLE",
              identical(digest::digest(path, algo = "sha256", file = TRUE),
                        expect_sha[i]))
  } else {
    stopifnot(resolution$locator_status == "UNAVAILABLE",
              resolution$reason_code == "MISSING_ASSET")
  }
}
entries <- getNamespaceExports("rulearn")
w2 <- c("ru_learn", "ru_analyze", "ru_analyze_plan",
        "ru_analyze_code", "ru_analyze_execute", "ru_analyze_export")
if (all(w2 %in% entries)) stopifnot(length(entries) == 32L)
if ("ru_learn" %in% entries) {
  route <- ru_workspace("learn")
  stopifnot(route$status == "SELECTOR", route$mode == "learn",
            inherits(route$consumer, "ru_learning_route"),
            nrow(route$consumer$lessons) == 3L, !route$opened)
} else {
  stopifnot(ru_workspace("learn")$status == "UNAVAILABLE",
            ru_workspace("learn")$reason_code == "NOT_IMPLEMENTED")
}
if ("ru_analyze" %in% entries) {
  route <- ru_workspace("analyze")
  stopifnot(route$status == "READY_TO_LAUNCH",
            inherits(route$consumer, "shiny.appobj"),
            route$capability_status == "UNTESTED", !route$opened)
} else {
  stopifnot(ru_workspace("analyze")$status == "UNAVAILABLE",
            ru_workspace("analyze")$reason_code == "NOT_IMPLEMENTED")
}
stopifnot(ru_workspace("reference")$status == "CATALOGUE",
          identical(names(formals(ru_plan)), c("query", "have", "missing")))
cat("L1_W2_CONSUMER_AND_REGISTRY_CHECK_PASS\n")