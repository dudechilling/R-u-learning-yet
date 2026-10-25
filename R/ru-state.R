# Progress is metadata only. Generation files are immutable; no silent rollback.
.ru_progress_empty <- function() data.frame(
  competency_id = character(), content_version = character(),
  status = character(), evidence_kind = character(),
  last_attempt = character(), review_recommended = logical(),
  stringsAsFactors = FALSE
)

.ru_progress_validate <- function(rows) {
  target <- names(.ru_progress_empty())
  if (!is.data.frame(rows) || !identical(names(rows), target) ||
      !identical(vapply(rows, typeof, character(1L)),
                 c(competency_id = "character", content_version = "character",
                   status = "character", evidence_kind = "character",
                   last_attempt = "character", review_recommended = "logical")) ||
      anyNA(rows))
    .ru_error("ru_invalid_argument", "Progress rows have an invalid schema.")
  if (nrow(rows)) {
    valid <- c(introduced = "exposure", practised = "guided_attempt",
               performed_independently = "independent_transfer")
    if (any(!rows$status %in% names(valid)) ||
        any(rows$evidence_kind != unname(valid[rows$status])) ||
        any(!grepl("^[a-z][a-z0-9._-]+$", rows$competency_id)) ||
        any(!nzchar(rows$content_version)) || any(!nzchar(rows$last_attempt)) ||
        anyDuplicated(rows$competency_id))
      .ru_error("ru_invalid_argument", "Progress evidence must match an explicit status and unique competency.")
  }
  invisible(TRUE)
}

.ru_state_dir <- function() tools::R_user_dir("rulearn", "data")
.ru_state_files <- function(dir) {
  if (!dir.exists(dir)) return(character())
  sort(list.files(dir, "^progress-[0-9]{8}[.]rds$", full.names = TRUE))
}

.ru_state_load <- function(file) {
  x <- tryCatch(readRDS(file), error = function(e)
    .ru_error("ru_state_corrupt", "Progress generation cannot be read; manual recovery required."))
  if (!is.list(x) || !identical(names(x), c("schema_version", "revision", "rows")))
    .ru_error("ru_state_corrupt", "Progress generation has an invalid envelope.")
  if (!identical(x$schema_version, "ru.progress.v1"))
    .ru_error("ru_state_unknown_schema", "Progress storage schema needs explicit migration.")
  .ru_scalar_count(x$revision, "revision", minimum = 1L)
  .ru_progress_validate(x$rows)
  filename_revision <- suppressWarnings(as.integer(sub("^progress-([0-9]{8})[.]rds$",
                            "\\1", basename(file))))
  if (!identical(as.integer(x$revision), filename_revision))
    .ru_error("ru_state_corrupt", "Progress generation revision does not match its filename.")
  x
}

.ru_state_read <- function(dir = .ru_state_dir()) {
  files <- .ru_state_files(dir)
  if (!length(files))
    return(list(schema_version = "ru.progress.v1", revision = 0L,
                rows = .ru_progress_empty()))
  .ru_state_load(tail(files, 1L))
}

ru_progress <- function() {
  state <- .ru_state_read()
  rows <- state$rows
  attr(rows, "storage_schema_version") <- state$schema_version
  attr(rows, "revision") <- state$revision
  rows
}

.ru_state_lock <- function(dir, timeout_ms = 3000L) {
  if (!requireNamespace("filelock", quietly = TRUE))
    .ru_error("ru_unavailable_dependency",
              "Progress writing requires filelock; no unlocked fallback is permitted.")
  dir.create(dir, recursive = TRUE, showWarnings = FALSE, mode = "0700")
  lock <- filelock::lock(file.path(dir, "progress.lock"), timeout = timeout_ms)
  if (is.null(lock))
    .ru_error("ru_state_busy", "Progress storage is already locked.")
  lock
}

.ru_state_write <- function(rows, expected_revision, dir = .ru_state_dir()) {
  .ru_progress_validate(rows)
  expected_revision <- .ru_scalar_count(expected_revision, "expected_revision")
  if (expected_revision >= 99999999L)
    .ru_error("ru_invalid_argument", "Progress revision limit reached.")
  lock <- .ru_state_lock(dir)
  on.exit(filelock::unlock(lock), add = TRUE)
  previous <- .ru_state_read(dir)
  if (!identical(as.integer(previous$revision), expected_revision))
    .ru_error("ru_state_stale_revision", "Progress changed since the last read.")
  revision <- expected_revision + 1L
  target <- file.path(dir, sprintf("progress-%08d.rds", revision))
  if (file.exists(target))
    .ru_error("ru_state_stale_revision", "Progress generation already exists.")
  temp <- tempfile(pattern = "progress-staging-", tmpdir = dir)
  on.exit(if (file.exists(temp)) unlink(temp), add = TRUE)
  saveRDS(list(schema_version = "ru.progress.v1", revision = revision,
               rows = rows), temp, version = 3L)
  if (!file.rename(temp, target))
    .ru_error("ru_state_write_failed", "Atomic generation installation failed; previous generation remains.")
  revision
}

# Explicit operator recovery: quarantine only the corrupt newest generation.
# Never silently advance or repair a corrupt/currently unknown state.
.ru_state_recover <- function(dir = .ru_state_dir()) {
  lock <- .ru_state_lock(dir)
  on.exit(filelock::unlock(lock), add = TRUE)
  files <- .ru_state_files(dir)
  if (length(files) < 2L)
    .ru_error("ru_state_recovery_required", "No prior generation exists for recovery.")
  latest <- tail(files, 1L)
  if (!inherits(try(.ru_state_load(latest), silent = TRUE), "try-error"))
    .ru_error("ru_invalid_argument", "Latest progress generation is valid; recovery refused.")
  previous <- .ru_state_load(files[length(files) - 1L])
  quarantine <- file.path(dir, paste0("quarantine-", basename(latest), "-",
                                     format(Sys.time(), "%Y%m%d%H%M%S")))
  if (file.exists(quarantine) || !file.rename(latest, quarantine))
    .ru_error("ru_state_recovery_required", "Could not quarantine corrupt generation.")
  invisible(list(recovered_revision = previous$revision, quarantine = quarantine))
}