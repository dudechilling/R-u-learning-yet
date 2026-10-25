# Local content registry; separate source existence from review and Viewer capability.
.ru_content_surfaces <- c("learn", "analyze", "reference", "example", "asset", "native_help")
.ru_content_representations <- list(
  learn = c("tutorial", "exercise"), analyze = "analysis_method",
  reference = c("compact_md", "legacy_guide_qmd"),
  example = "r_script", asset = c("svg", "csv"), native_help = "rd_alias"
)

.ru_content_catalogue <- function() {
  file <- system.file("extdata", "ru-content.csv", package = "rulearn")
  if (!nzchar(file))
    .ru_error("ru_unavailable_content", "Installed content registry is missing.")
  data <- utils::read.csv(file, stringsAsFactors = FALSE, na.strings = character(),
                          check.names = FALSE, fileEncoding = "UTF-8")
  expected <- c("surface", "id", "representation", "title", "relative_path",
                "content_version", "source_type", "rights_status", "review_status")
  if (!identical(names(data), expected) || !nrow(data) ||
      anyDuplicated(paste(data$surface, data$id, data$representation, sep = "/")) ||
      any(!data$surface %in% .ru_content_surfaces) ||
      any(!nzchar(data$id)) || any(!nzchar(data$title)) ||
      any(!nzchar(data$content_version)) ||
      any(vapply(seq_len(nrow(data)), function(i)
        !data$representation[i] %in% .ru_content_representations[[data$surface[i]]],
        logical(1L))))
    .ru_error("ru_unavailable_content", "Installed content registry failed validation.")
  data
}

.ru_content_safe_id <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl("^[a-z][a-z0-9._-]*$", value) &&
    !grepl("..", value, fixed = TRUE) && !startsWith(value, ".")
}

.ru_content_locator <- function(relative_path, root) {
  if (!is.character(relative_path) || length(relative_path) != 1L ||
      is.na(relative_path) || !grepl("^[a-zA-Z0-9._/-]+$", relative_path) ||
      startsWith(relative_path, "/") || grepl("..", relative_path, fixed = TRUE) ||
      grepl("//", relative_path, fixed = TRUE) ||
      grepl("\\\\", relative_path) || grepl(":", relative_path, fixed = TRUE))
    .ru_error("ru_unavailable_content", "Content registry has an unsafe locator.")
  if (!nzchar(root))
    return(NULL)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  path <- file.path(root, relative_path)
  if (!file.exists(path) || dir.exists(path))
    return(NULL)
  real <- normalizePath(path, winslash = "/", mustWork = TRUE)
  if (!startsWith(real, paste0(root, "/")))
    .ru_error("ru_unavailable_content", "Content locator escapes the installed package.")
  real
}

.ru_content_default_representation <- function(surface, data) {
  if (surface == "reference") return("compact_md")
  if (surface %in% c("learn", "analyze", "example", "asset", "native_help")) {
    opts <- unique(data$representation)
    if (length(opts) == 1L) return(opts)
    if (surface == "asset") return(NULL)
  }
  .ru_content_representations[[surface]][1L]
}

.ru_content_resolve <- function(id, surface, locale = "en",
                                representation = NULL, content_version = NULL) {
  surface <- .ru_exact_choice(surface, "surface", .ru_content_surfaces)
  id <- .ru_scalar_string(id, "id")
  if (!.ru_content_safe_id(id))
    .ru_error("ru_invalid_argument", "id must be a registered safe content identifier.", "id")
  locale <- .ru_scalar_string(locale, "locale")
  if (!is.null(content_version))
    content_version <- .ru_scalar_string(content_version, "content_version")
  if (!is.null(representation))
    representation <- .ru_exact_choice(representation, "representation",
                                      .ru_content_representations[[surface]])
  catalogue <- .ru_content_catalogue()
  data <- catalogue[catalogue$surface == surface & catalogue$id == id, , drop = FALSE]
  requested <- if (is.null(representation))
    .ru_content_default_representation(surface, data) else representation
  result <- .ru_result(
    "ru_content_resolution", schema_version = 1L, id = id, surface = surface,
    representation_requested = representation,
    representation_resolved = requested, locale = locale,
    content_version = content_version, locator_status = "UNAVAILABLE",
    source_status = "NOT_INSPECTED", source_evidence_scope = "INSTALLED_PACKAGE",
    review_states = "NOT_REVIEWED", rights_status = "NOT_CLEARED",
    capability_status = "UNTESTED", reason_code = "NOT_FOUND",
    validated_locator = NULL, provenance = NULL, alternatives = list()
  )
  if (!nrow(data)) return(result)
  result$content_version <- if (is.null(content_version)) data$content_version[1L] else content_version
  if (!identical(locale, "en")) {
    result$reason_code <- "UNSUPPORTED_LOCALE"
    return(result)
  }
  if (!is.null(content_version) && !content_version %in% data$content_version) {
    result$reason_code <- "INCOMPATIBLE_CONTENT_VERSION"
    return(result)
  }
  result$alternatives <- lapply(seq_len(nrow(data)), function(i) {
    item <- data[i, , drop = FALSE]
    available <- FALSE
    if (item$source_type[1L] == "base_help") {
      aliases <- list(r_mean = c("base", "mean"),
                      r_hist = c("graphics", "hist"), r_cor = c("stats", "cor"))
      route <- aliases[[id]]
      available <- !is.null(route) && tryCatch(
        length(utils::help(route[2L], package = route[1L])) > 0L,
        error = function(e) FALSE)
    } else if (item$source_type[1L] != "not_implemented") {
      available <- !is.null(.ru_content_locator(item$relative_path[1L],
                                                system.file(package = "rulearn")))
    }
    list(representation = item$representation[1L],
         source_type = item$source_type[1L],
         source_status = if (available) "INSTALLED_VALIDATED"
                         else "ABSENT_FOR_REQUESTED_REPRESENTATION",
         locator_status = if (available) "AVAILABLE" else "UNAVAILABLE",
         reason_code = if (available) NULL
                       else if (item$source_type[1L] == "not_implemented")
                         "NOT_IMPLEMENTED" else "MISSING_ASSET",
         review_status = item$review_status[1L],
         rights_status = item$rights_status[1L],
         capability_status = "UNTESTED")
  })
  if (is.null(requested)) {
    result$reason_code <- "SOURCE_AMBIGUOUS"
    return(result)
  }
  selected <- data[data$representation == requested, , drop = FALSE]
  if (!nrow(selected)) {
    result$reason_code <- "MISSING_ASSET"
    result$source_status <- "ABSENT_FOR_REQUESTED_REPRESENTATION"
    return(result)
  }
  row <- selected[1L, , drop = FALSE]
  result$review_states <- row$review_status[[1L]]
  result$rights_status <- row$rights_status[[1L]]
  result$provenance <- list(source_type = row$source_type[[1L]],
                            content_version = row$content_version[[1L]],
                            registry_id = row$id[[1L]])
  if (row$source_type[[1L]] == "not_implemented") {
    result$reason_code <- "NOT_IMPLEMENTED"
    result$source_status <- "ABSENT_FOR_REQUESTED_REPRESENTATION"
    return(result)
  }
  if (row$source_type[[1L]] == "base_help") {
    aliases <- list(r_mean = c("base", "mean"),
                    r_hist = c("graphics", "hist"),
                    r_cor = c("stats", "cor"))
    where <- aliases[[id]]
    if (is.null(where)) return(result)
    found <- tryCatch(length(utils::help(where[2L], package = where[1L])) > 0L,
                      error = function(e) FALSE)
    if (!found) {
      result$reason_code <- "MISSING_ASSET"
      return(result)
    }
    result$validated_locator <- list(package = where[1L], topic = where[2L])
  } else {
    root <- system.file(package = "rulearn")
    loc <- .ru_content_locator(row$relative_path[[1L]], root)
    if (is.null(loc)) {
      result$reason_code <- "MISSING_ASSET"
      result$source_status <- "ABSENT_FOR_REQUESTED_REPRESENTATION"
      return(result)
    }
    result$validated_locator <- loc
  }
  result$locator_status <- "AVAILABLE"
  result$source_status <- "INSTALLED_VALIDATED"
  result$reason_code <- NULL
  result
}

# An advertised available representation must have a verified local locator.
.ru_reference_candidate <- function(row) {
  resolution <- .ru_content_resolve(row$id[1L], row$surface[1L])
  options <- resolution$alternatives
  good <- Filter(function(x) identical(x$locator_status, "AVAILABLE"), options)
  list(id = row$id[1L], surface = row$surface[1L], title = row$title[1L],
       available_representations = lapply(good, function(x) x$representation),
       source_status = resolution$source_status,
       review_status = resolution$review_states,
       rights_status = resolution$rights_status,
       capability_status = resolution$capability_status)
}

# Reference index does not select a first search hit or substitute a legacy guide.
ru_reference <- function(query = NULL, view = c("summary", "detail"), open = TRUE,
                         representation = NULL) {
  if (missing(view)) view <- "summary"
  view <- .ru_exact_choice(view, "view", c("summary", "detail"))
  open <- .ru_scalar_flag(open, "open")
  if (!is.null(representation))
    representation <- .ru_scalar_string(representation, "representation")
  if (is.null(query) && !is.null(representation))
    .ru_error("ru_invalid_argument", "A representation requires an explicit query.", "representation")
  catalogue <- .ru_content_catalogue()
  searchable <- catalogue[catalogue$surface %in% c("reference", "native_help"), , drop = FALSE]
  result <- .ru_result("ru_reference_result",
    schema_version = 1L, status = "CATALOGUE", reason_code = NULL,
    query = query, view = view, open_requested = open, opened = FALSE,
    selected_id = NULL, requested_representation = representation,
    selected_representation = NULL, available_representations = list(),
    matches = list(), resolution = NULL, capability_status = "UNTESTED",
    origin_return = NULL
  )
  if (is.null(query)) {
    chosen <- !duplicated(paste(searchable$surface, searchable$id))
    result$matches <- lapply(which(chosen), function(i)
      .ru_reference_candidate(searchable[i, , drop = FALSE]))
    return(result)
  }
  query <- .ru_scalar_string(query, "query")
  # Unsafe path-like text is rejected, not used as a file lookup.
  if (grepl("[/\\\\]", query) || grepl("..", query, fixed = TRUE) ||
      grepl("%", query, fixed = TRUE))
    .ru_error("ru_invalid_argument", "query must not contain a path or encoded separator.", "query")
  q <- tolower(trimws(query))
  exact <- searchable[searchable$id == query, , drop = FALSE]
  hits <- if (nrow(exact)) exact else searchable[
    grepl(q, tolower(searchable$id), fixed = TRUE) |
    grepl(q, tolower(searchable$title), fixed = TRUE), , drop = FALSE]
  if (!nrow(hits)) {
    result$status <- "NOT_FOUND"; result$reason_code <- "NOT_FOUND"
    return(result)
  }
  unique_keys <- paste(hits$surface, hits$id, sep = ":")
  first <- which(!duplicated(unique_keys))
  result$matches <- lapply(first, function(i)
    .ru_reference_candidate(hits[i, , drop = FALSE]))
  if (length(first) > 1L) {
    result$status <- "MULTIPLE_MATCHES"
    return(result)
  }
  selected <- hits[first[1L], , drop = FALSE]
  result$selected_id <- selected$id[1L]
  result$available_representations <- result$matches[[1L]]$available_representations
  resolution <- .ru_content_resolve(selected$id[1L], selected$surface[1L],
                                    representation = representation)
  result$resolution <- resolution
  result$selected_representation <- resolution$representation_resolved
  result$capability_status <- resolution$capability_status
  if (resolution$locator_status != "AVAILABLE") {
    result$status <- "UNAVAILABLE"
    result$reason_code <- resolution$reason_code
    return(result)
  }
  result$status <- "SINGLE_MATCH"
  if (open) {
    # The W1 route cannot claim an untested Viewer/Help session opened.
    result$status <- "UNAVAILABLE"
    result$reason_code <- "UNAVAILABLE_CAPABILITY"
    result$capability_status <- "UNAVAILABLE"
  }
  result
}

print.ru_reference_result <- function(x, ...) {
  cat("RU Reference: ", x$status, if (!is.null(x$reason_code))
      paste0(" (", x$reason_code, ")") else "", "\n", sep = "")
  if (x$status %in% c("CATALOGUE", "MULTIPLE_MATCHES")) {
    for (item in x$matches)
      cat(" - ", item$id, " [", item$surface, "]: ", item$title, "\n", sep = "")
  }
  invisible(x)
}