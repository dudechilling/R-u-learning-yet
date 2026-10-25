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
  expected_path <- paste0("references/w2/", id, ".md")
  stopifnot(nrow(row) == 1L,
            identical(row$relative_path, expected_path),
            identical(row$content_version, "ru-w2-reference-v1"),
            identical(row$source_type, "authored_md"),
            identical(row$rights_status, "NOT_CLEARED"),
            identical(row$review_status, "NOT_REVIEWED"))
  root <- system.file(package = "rulearn")
  stopifnot(!file.exists(file.path(root, "lessons", paste0(id, ".md"))))
  installed <- system.file("references", "w2", paste0(id, ".md"),
                           package = "rulearn")
  stopifnot(nzchar(installed), file.exists(installed))
  result <- ru_reference(id, open = FALSE)
  stopifnot(identical(result$status, "SINGLE_MATCH"),
            identical(result$resolution$locator_status, "AVAILABLE"),
            identical(result$resolution$validated_locator,
                      normalizePath(installed, winslash = "/", mustWork = TRUE)))
  page <- getFromNamespace(".ru_lesson_read", "rulearn")(id)
  stopifnot(identical(page$meta$status, "AUTHORED"),
            identical(page$meta$collection, "w2.reference.v1"))
}
# The original physical Viewer directory is an immutable 84-page contract.
root <- system.file(package = "rulearn")
stopifnot(length(list.files(file.path(root, "lessons"),
                             pattern = "[.]md$")) == 84L,
          length(list.files(file.path(root, "references", "w2"),
                             pattern = "[.]md$")) == 5L)
old_index <- getFromNamespace(".ru_lesson_index", "rulearn")()
stopifnot(nrow(old_index) == 84L, all(old_index$status == "VERIFIED"))

# A stale legacy locator must not resolve; unsafe locators must remain typed.
locator <- getFromNamespace(".ru_content_locator", "rulearn")
for (id in refs)
  stopifnot(is.null(locator(paste0("lessons/", id, ".md"), root)))
unsafe <- c("../lessons/mean.md", "/etc/passwd",
            "references//w2/missing_values.md",
            "references/w2/../lessons/mean.md",
            "references\\\\w2\\\\missing_values.md",
            "references/w2/%2e%2e/mean.md")
for (path in unsafe) {
  error <- tryCatch(locator(path, root), error = identity)
  stopifnot(inherits(error, "ru_unavailable_content"))
}
mismatch <- getFromNamespace(".ru_content_resolve", "rulearn")(
  "missing_values", "reference", representation = "compact_md",
  content_version = "unsupported-reference-version")
stopifnot(identical(mismatch$locator_status, "UNAVAILABLE"),
          identical(mismatch$reason_code, "INCOMPATIBLE_CONTENT_VERSION"))

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
stopifnot(length(entries) == 32L, setequal(entries,
         c("ru","ru_find","ru_plan","ru_run","ru_code","ru_topics",
           "ru_inputs","ru_hist","ru_bar","ru_box","ru_scatter",
           "ru_data","ru_datasets","ru_columns","ru_apply",
           "ru_guide","ru_edit","ru_open","ru_text","ru_palette","ru_home",
           "ru_workspace","ru_reference","ru_capabilities","ru_progress",
           "ru_source_context",w2)),
           all(w2 %in% entries))
stopifnot(identical(names(formals(ru_learn)),
                    c("path","lesson","resume")),
          identical(names(formals(ru_analyze)),c("data","spec")),
          identical(names(formals(ru_analyze_plan)),
                    c("spec","data","source_context")),
          identical(names(formals(ru_analyze_code)),c("plan")),
          identical(names(formals(ru_analyze_execute)),
                    c("plan","data","confirm")),
          identical(names(formals(ru_analyze_export)),
                    c("plan","result","path","include_data","data")))
route <- ru_workspace("learn")
stopifnot(route$status == "SELECTOR", route$mode == "learn",
          inherits(route$consumer, "ru_learning_route"),
          nrow(route$consumer$lessons) == 3L, !route$opened)
analysis <- ru_workspace("analyze")
if (requireNamespace("shiny", quietly = TRUE)) {
  stopifnot(analysis$status == "READY_TO_LAUNCH",
            inherits(analysis$consumer, "shiny.appobj"),
            analysis$capability_status == "UNTESTED", !analysis$opened)
} else {
  stopifnot(analysis$status == "UNAVAILABLE",
            analysis$reason_code == "UNAVAILABLE_DEPENDENCY", !analysis$opened)
}
stopifnot(ru_workspace("reference")$status == "CATALOGUE",
          identical(names(formals(ru_plan)), c("query", "have", "missing")))
cat("L1_W2_CONSUMER_AND_REGISTRY_CHECK_PASS\n")