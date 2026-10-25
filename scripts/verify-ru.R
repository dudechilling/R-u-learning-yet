#!/usr/bin/env Rscript
# L5 independent verification profiles. Do not alter scripts/ci-check.R.
# No automatic installation of external dependencies, no silent/skipped PASS.
options(warn = 1L)

args <- commandArgs(trailingOnly = TRUE)
known <- c("--profile", "--evidence", "--archive", "--expected-sha256")
usage <- "Usage: Rscript --vanilla scripts/verify-ru.R --profile core|ui|offline|artifact|all --evidence OUTSIDE_SOURCE [--archive EXACT.tar.gz --expected-sha256 SHA256]"
arg_error <- function(reason) {
  cat("VERIFY_RU_INVALID_ARGUMENT: ", reason, "\n", usage, "\n", sep = "", file = stderr())
  quit(save = "no", status = 3L)
}
if (length(args) %% 2L != 0L || !length(args)) arg_error("Expected named value pairs")
keys <- args[seq.int(1L, length(args), by = 2L)]
vals <- args[seq.int(2L, length(args), by = 2L)]
if (any(!keys %in% known) || anyDuplicated(keys) || anyNA(vals) || any(!nzchar(vals)))
  arg_error("Unknown, duplicate, or empty argument")
opts <- setNames(as.list(vals), keys)
if (is.null(opts[["--profile"]]) || !opts[["--profile"]] %in%
    c("core", "ui", "offline", "artifact", "all"))
  arg_error("Unknown or missing verification profile")
if (is.null(opts[["--evidence"]])) arg_error("--evidence is mandatory")
if (!is.null(opts[["--expected-sha256"]]) &&
    !grepl("^[a-fA-F0-9]{64}$", opts[["--expected-sha256"]]))
  arg_error("Expected archive SHA-256 must be 64 hexadecimal characters")

scripts <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(scripts) != 1L) arg_error("Could not identify this script source")
source_dir <- normalizePath(file.path(dirname(sub("^--file=", "", scripts)), ".."),
                            winslash = "/", mustWork = TRUE)
inside <- function(x, root) {
  if (.Platform$OS.type == "windows") {
    x <- tolower(x); root <- tolower(root)
  }
  identical(x, root) || startsWith(x, paste0(root, "/"))
}
requested <- opts[["--evidence"]]
if (!grepl("^(/|[A-Za-z]:[/\\\\])", requested))
  arg_error("--evidence must be an absolute path")
# Check the *existing* ancestor first, so symlinks into source do not create files there.
probe <- requested
while (!file.exists(probe) && !dir.exists(probe)) {
  parent <- dirname(probe)
  if (identical(parent, probe)) arg_error("Evidence path has no accessible ancestor")
  probe <- parent
}
real_ancestor <- normalizePath(probe, winslash = "/", mustWork = TRUE)
if (inside(real_ancestor, source_dir) ||
    inside(normalizePath(requested, winslash = "/", mustWork = FALSE), source_dir))
  arg_error("Evidence must be outside the package source (including symlinks)")
if (!dir.exists(requested)) dir.create(requested, recursive = TRUE, showWarnings = FALSE,
                                       mode = "0700")
if (!dir.exists(requested)) arg_error("Evidence directory cannot be created")
evidence <- normalizePath(requested, winslash = "/", mustWork = TRUE)
if (inside(evidence, source_dir)) arg_error("Resolved evidence path enters source")
if (!is.null(opts[["--archive"]])) {
  a <- opts[["--archive"]]
  if (!file.exists(a) || dir.exists(a)) arg_error("--archive is not a readable file")
  if (!grepl("[.]tar[.]gz$", a)) arg_error("--archive must be a source tar.gz")
}

checks <- list()
add <- function(profile, name, status, code, detail = "") {
  stopifnot(status %in% c("PASS", "FAIL", "BLOCKED", "NOT_TESTED"))
  checks[[length(checks) + 1L]] <<- list(
    profile = profile, check = name, status = status, code = code,
    detail = substr(as.character(detail), 1L, 420L))
  cat(sprintf("%-9s %-8s %-34s %s\n", toupper(profile), status, name, code))
  invisible(status == "PASS")
}
yes <- function(profile, name, condition, code_fail, details = "") {
  add(profile, name, if (isTRUE(condition)) "PASS" else "FAIL",
      if (isTRUE(condition)) "OK" else code_fail, details)
}
block <- function(profile, name, reason, detail = "") {
  add(profile, name, "BLOCKED", reason, detail)
}
exports <- function() {
  if (!requireNamespace("rulearn", quietly = TRUE)) return(NULL)
  getNamespaceExports("rulearn")
}
baseline <- c("ru", "ru_find", "ru_plan", "ru_run", "ru_code", "ru_topics",
              "ru_inputs", "ru_hist", "ru_bar", "ru_box", "ru_scatter",
              "ru_data", "ru_datasets", "ru_columns", "ru_apply", "ru_guide",
              "ru_edit", "ru_open", "ru_text", "ru_palette", "ru_home")
w1 <- c("ru_workspace", "ru_reference", "ru_capabilities",
        "ru_progress", "ru_source_context")
required_w2 <- c("ru_learn", "ru_analyze", "ru_analyze_plan",
                 "ru_analyze_code", "ru_analyze_execute", "ru_analyze_export")

do_core <- function() {
  profile <- "core"
  x <- exports()
  if (is.null(x)) {
    block(profile, "installed_rulearn", "PACKAGE_NOT_INSTALLED")
    block(profile, "w2_three_lessons", "NO_INSTALLED_PACKAGE")
    block(profile, "describe_numeric", "NO_INSTALLED_PACKAGE")
    return(invisible(NULL))
  }
  yes(profile, "original_21_exports", all(baseline %in% x),
      "LEGACY_EXPORT_REMOVED", paste(setdiff(baseline, x), collapse = ","))
  yes(profile, "w1_five_exports", all(w1 %in% x),
      "W1_EXPORT_MISSING", paste(setdiff(w1, x), collapse = ","))
  if (all(w1 %in% x)) {
    v <- tryCatch({
      s <- rulearn::ru_workspace()
      r <- rulearn::ru_reference(open = FALSE)
      identical(s$status, "SELECTOR") && identical(r$status, "CATALOGUE")
    }, error = function(e) FALSE)
    yes(profile, "safe_no_argument_workspace", v, "NO_ARGUMENT_DEFAULT_INVALID")
  } else block(profile, "safe_no_argument_workspace", "W1_CAPABILITY_UNAVAILABLE")
  yes(profile, "w2_api_exports", all(required_w2 %in% x),
      "W2_APIS_MISSING", paste(setdiff(required_w2, x), collapse = ","))
  tutorials <- system.file("tutorials", package = "rulearn")
  lessons <- if (nzchar(tutorials) && dir.exists(tutorials))
    list.files(tutorials, pattern = "[.]Rmd$", recursive = TRUE, full.names = TRUE) else character()
  if (length(lessons) < 3L) {
    block(profile, "three_installed_lessons", "THREE_LESSONS_NOT_INSTALLED",
          paste("Installed .Rmd count:", length(lessons)))
  } else {
    yes(profile, "three_installed_lessons", length(unique(dirname(lessons))) >= 3L,
        "LESSON_IDENTITIES_NOT_DISTINCT")
  }
  # A real statistical result must be checked by a distinct L5 oracle, not a claimed route label.
  oracle <- file.path(source_dir, "tests", "production-w2-core.R")
  if (!file.exists(oracle)) {
    block(profile, "numeric_oracle_replay_export",
          "INDEPENDENT_W2_ORACLE_NOT_AVAILABLE")
  } else if (!all(required_w2 %in% x)) {
    block(profile, "numeric_oracle_replay_export", "W2_API_NOT_READY")
  } else {
    output <- tempfile(pattern = "ru-core-oracle-", tmpdir = evidence)
    code <- suppressWarnings(system2(
      file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
      c("--vanilla", shQuote(oracle)), stdout = output, stderr = output))
    details <- if (file.exists(output)) paste(tail(readLines(output, warn = FALSE), 6L), collapse = " | ") else ""
    yes(profile, "numeric_oracle_replay_export", identical(as.integer(code), 0L),
        "INDEPENDENT_W2_ORACLE_FAIL", details)
  }
}
do_ui <- function() {
  profile <- "ui"
  available <- requireNamespace("shinytest2", quietly = TRUE) &&
    requireNamespace("chromote", quietly = TRUE)
  if (!available) block(profile, "browser_harness", "RELEASED_BROWSER_HARNESS_MISSING")
  else add(profile, "browser_harness", "PASS", "RELEASED_BROWSER_HARNESS_AVAILABLE")
  x <- exports()
  if (is.null(x) || !all(c("ru_learn", "ru_analyze") %in% x))
    block(profile, "interactive_w2_consumers", "W2_UI_ENTRYPOINTS_MISSING")
  else add(profile, "interactive_w2_consumers", "PASS", "W2_UI_APIS_INSTALLED")
  pilot <- file.path(source_dir, "tests", "ui", "production-pilot.R")
  if (!available || is.null(x) || !all(c("ru_learn", "ru_analyze") %in% x) ||
      !file.exists(pilot)) {
    block(profile, "browser_actions_and_focus", "LIVE_BROWSER_JOURNEY_NOT_RUN")
  } else {
    output <- tempfile(pattern = "ru-ui-test-", tmpdir = evidence)
    status <- suppressWarnings(system2(
      file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
      c("--vanilla", shQuote(pilot)), stdout = output, stderr = output))
    yes(profile, "browser_actions_and_focus", identical(as.integer(status), 0L),
        "BROWSER_JOURNEY_FAILED",
        if (file.exists(output)) paste(tail(readLines(output, warn = FALSE), 4L), collapse = " | ") else "")
  }
  add(profile, "windows_rstudio_keyboard_at", "NOT_TESTED", "REAL_TARGET_HUMAN_GATE",
      "Browser checks never establish Windows RStudio, keyboard, screen reader or novice acceptance")
}
do_offline <- function() {
  profile <- "offline"
  x <- exports()
  if (is.null(x)) block(profile, "installed_package", "PACKAGE_NOT_INSTALLED")
  else add(profile, "installed_package", "PASS", "PACKAGE_RESOLVES_LOCALLY")
  # Network namespace isolation alone cannot prove that no attempted requests occurred.
  # Require a traceable, external observation of a network-disabled *run*.
  proof <- file.path(evidence, "network-isolation-receipt.txt")
  attempts <- file.path(evidence, "outbound-attempts.log")
  if (!file.exists(proof) || !file.exists(attempts)) {
    block(profile, "network_disabled_and_attempts_traced", "OFFLINE_RUNTIME_EVIDENCE_MISSING",
          "Need independently captured offline run and outbound attempt log")
  } else {
    a <- readLines(proof, warn = FALSE)
    b <- readLines(attempts, warn = FALSE)
    # These files are external observations for *human review*, not self-certifying proofs.
    yes(profile, "offline_receipt_syntactically_present",
        any(grepl("^ISOLATION_TOOL=", a)) && any(grepl("^CANDIDATE_SHA256=", a)) &&
          any(grepl("^NETWORK_BLOCKED=TRUE$", a)),
        "OFFLINE_RECEIPT_INCOMPLETE")
    block(profile, "network_disabled_and_attempts_traced",
          "NETWORK_EVIDENCE_REQUIRES_INDEPENDENT_REVIEW",
          sprintf("%d outbound-trace lines supplied; no automatic permission inference", length(b)))
  }
  block(profile, "cancel_resume_offline", "OFFLINE_RESTART_UNOBSERVED")
}
do_artifact <- function() {
  profile <- "artifact"
  archive <- opts[["--archive"]]
  if (is.null(archive)) {
    block(profile, "exact_source_archive", "ARCHIVE_ARGUMENT_MISSING")
    block(profile, "fresh_install_and_help", "NO_ARCHIVE")
    return(invisible(NULL))
  }
  if (!requireNamespace("digest", quietly = TRUE)) {
    block(profile, "sha256_codec", "DIGEST_DEPENDENCY_MISSING")
    return(invisible(NULL))
  }
  sha <- digest::digest(archive, algo = "sha256", serialize = FALSE, file = TRUE)
  cat("ARCHIVE_SHA256 ", sha, "\n", sep = "")
  expected <- opts[["--expected-sha256"]]
  if (is.null(expected)) {
    block(profile, "expected_exact_archive_identity", "EXPECTED_ARCHIVE_SHA256_MISSING", sha)
  } else {
    yes(profile, "expected_exact_archive_identity", identical(tolower(expected), tolower(sha)),
        "ARCHIVE_SHA256_MISMATCH", sha)
    if (!identical(tolower(expected), tolower(sha))) return(invisible(NULL))
  }
  files <- tryCatch(utils::untar(archive, list = TRUE),
                    error = function(e) NULL)
  if (is.null(files) || !length(files)) {
    yes(profile, "source_archive_structure", FALSE, "ARCHIVE_LISTING_FAILED")
    return(invisible(NULL))
  }
  entries <- sub("^[^/]+/", "", files)
  safe <- all(!grepl("^/", files)) &&
    !any(grepl("(^|/)\\.\\.(/|$)", files)) &&
    length(unique(files)) == length(files)
  yes(profile, "source_archive_safe_paths", safe, "UNSAFE_ARCHIVE_MEMBER")
  needed <- c("DESCRIPTION", "NAMESPACE", paste0("man/ru-", c("workspace","reference",
                  "capabilities","progress","source-context"), ".Rd"))
  present <- all(needed %in% entries)
  yes(profile, "all_five_help_pages_archived", present, "REQUIRED_RD_OR_METADATA_MISSING",
      paste(setdiff(needed, entries), collapse = ","))
  if (!safe || !present || is.null(expected)) {
    block(profile, "fresh_install_and_help", "ARCHIVE_NOT_QUALIFIED_FOR_INSTALL")
    return(invisible(NULL))
  }
  private <- file.path(evidence, "artifact-library")
  if (!dir.exists(private)) dir.create(private, mode = "0700")
  if (dir.exists(file.path(private, "rulearn"))) {
    block(profile, "fresh_install_and_help", "PRIVATE_LIBRARY_NOT_FRESH")
    return(invisible(NULL))
  }
  installed <- tryCatch({
    utils::install.packages(archive, lib = private, repos = NULL, type = "source",
                            quiet = TRUE)
    find.package("rulearn", lib.loc = private, quiet = TRUE)
  }, error = function(e) character())
  valid <- length(installed) == 1L && nzchar(installed[[1L]])
  if (!valid) {
    yes(profile, "fresh_install_and_help", FALSE, "FRESH_INSTALL_FAILED")
    return(invisible(NULL))
  }
  # Isolate the installed-package assertion in a fresh R process, because
  # an earlier profile in --profile all may already have loaded a different rulearn.
  probe <- paste0(
    ".libPaths(c(", deparse(private), ",.libPaths())); ",
    "library(rulearn,lib.loc=", deparse(private), "); ",
    "stopifnot(startsWith(normalizePath(find.package('rulearn'),winslash='/'),",
    "paste0(normalizePath(", deparse(private), ",winslash='/'),'/'))); ",
    "required<-c('ru_workspace','ru_reference','ru_capabilities','ru_progress','ru_source_context'); ",
    "stopifnot(all(required %in% getNamespaceExports('rulearn'))); ",
    "stopifnot(all(vapply(required,function(x) length(utils::help(x,package='rulearn'))>0L,logical(1L)))); ",
    "cat('FRESH_SESSION_ARCHIVE_HELP_AND_EXPORT_PASS\\n')"
  )
  output <- tempfile("ru-artifact-fresh-", tmpdir = evidence)
  code <- tryCatch(suppressWarnings(system2(
    file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
    c("--vanilla","-e",shQuote(probe)), stdout = output, stderr = output)),
    error = function(e) 127L)
  log <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  good <- identical(as.integer(code), 0L) &&
          any(grepl("FRESH_SESSION_ARCHIVE_HELP_AND_EXPORT_PASS",log,fixed=TRUE))
  yes(profile, "fresh_install_help_and_exports", good,
      "ARCHIVE_FRESH_SESSION_CHECK_FAILED", paste(tail(log,6L),collapse=" | "))

}
profiles <- if (opts[["--profile"]] == "all") c("core", "ui", "offline", "artifact") else opts[["--profile"]]
for (name in profiles) switch(name, core = do_core(), ui = do_ui(),
                             offline = do_offline(), artifact = do_artifact())
statuses <- vapply(checks, function(x) x$status, character(1L))
stopifnot(length(checks) >= length(profiles))
overall <- if (any(statuses == "FAIL")) "FAIL" else
           if (any(statuses == "BLOCKED")) "BLOCKED" else "PASS"
# Human acceptance is always a separate gate; it cannot be inferred from headless profiles.
report <- list(schema = "ru.qa.profile.v1", profile = opts[["--profile"]],
               status = overall, checked_at_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
               platform = R.version$platform, R_version = as.character(getRversion()),
               source_path = source_dir, source_git_head = {
                 x <- tryCatch(system2("git", c("-C", shQuote(source_dir), "rev-parse", "HEAD"),
                                      stdout = TRUE, stderr = FALSE), error = function(e) character())
                 if (length(x) == 1L && grepl("^[a-f0-9]{40}$", x)) x else NA_character_
               },
               archive = if (!is.null(opts[["--archive"]])) normalizePath(opts[["--archive"]],
                                                                          winslash = "/", mustWork = TRUE) else NULL,
               checks = checks, human_acceptance = "NOT_TESTED",
               rights_clearance = "NOT_CLEARED")
dest <- file.path(evidence, paste0("verify-ru-", opts[["--profile"]], ".R"))
temp <- tempfile("verify-ru-stage-", tmpdir = evidence)
dput(report, file = temp)
if (!file.rename(temp, dest)) {
  unlink(temp)
  cat("VERIFY_RU_EVIDENCE_WRITE_FAILED\n", file = stderr())
  quit(save = "no", status = 3L)
}
cat("VERIFY_RU_PROFILE ", opts[["--profile"]], " ", overall,
    " | checks=", length(checks), " | evidence=", dest, "\n", sep = "")
quit(save = "no", status = if (overall == "PASS") 0L else
     if (overall == "FAIL") 1L else 2L)