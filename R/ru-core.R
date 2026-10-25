# W1 platform primitives. These validate inputs without evaluating user code.
.ru_error <- function(class, message, field = NULL) {
  condition <- structure(
    list(message = message, call = NULL, field = field),
    class = c(class, "ru_error", "error", "condition")
  )
  stop(condition)
}

.ru_scalar_string <- function(value, field) {
  if (!is.character(value) || length(value) != 1L ||
      is.na(value) || !nzchar(trimws(value)))
    .ru_error("ru_invalid_argument", paste0(field, " must be one nonempty string."), field)
  value
}

.ru_exact_choice <- function(value, field, allowed) {
  value <- .ru_scalar_string(value, field)
  if (!value %in% allowed)
    .ru_error("ru_invalid_argument",
              paste0(field, " must equal one of: ", paste(allowed, collapse = ", "), "."),
              field)
  value
}

.ru_scalar_flag <- function(value, field) {
  if (!is.logical(value) || length(value) != 1L || is.na(value))
    .ru_error("ru_invalid_argument", paste0(field, " must be TRUE or FALSE."), field)
  value
}

.ru_digest_string <- function(value, field, nullable = FALSE) {
  if (nullable && is.null(value)) return(NULL)
  value <- .ru_scalar_string(value, field)
  if (!grepl("^[a-f0-9]{64}$", value))
    .ru_error("ru_invalid_argument", paste0(field, " must be a lowercase SHA-256 digest."), field)
  value
}

.ru_named_fields <- function(x, required, field, optional = character()) {
  if (!is.list(x) || is.null(names(x)) || anyNA(names(x)) ||
      anyDuplicated(names(x)) ||
      !setequal(names(x), c(required, intersect(names(x), optional))))
    .ru_error("ru_invalid_argument",
              paste0(field, " has missing, duplicate, or unknown fields."), field)
  invisible(TRUE)
}

.ru_scalar_count <- function(x, field, minimum = 0) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x != trunc(x) || x < minimum)
    .ru_error("ru_invalid_argument", paste0(field, " must be a finite integer-like count."), field)
  as.integer(x)
}

.ru_result <- function(class, ...) structure(list(...), class = c(class, "ru_result"))