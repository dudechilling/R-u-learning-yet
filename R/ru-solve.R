# Public, deterministic question-to-guidance facade. No R code preview is executed.
.ru_w3_statuses <- c("SOLVED", "GUIDED_REFERENCE", "NEEDS_INPUT",
                     "UNSUPPORTED", "INVALID")

.ru_w3_valid_question <- function(question) {
  is.character(question) && length(question) == 1L && !is.na(question) &&
    nzchar(trimws(question)) && nchar(question, type = "bytes") <= 4096L
}

.ru_w3_invalid <- function(question, code = "INVALID_QUESTION") {
  q <- if (is.character(question) && length(question) == 1L &&
           !is.na(question) && nchar(question, type = "bytes") <= 4096L)
    question else ""
  list(schema_version = "ru.guided.v1", status = "INVALID",
       reason_code = code, original_question = q, family_id = NA_character_,
       inputs = list(), requested_outputs = character(), assumptions = list(),
       answer = list(), checks = list(), code_preview = "",
       executed = FALSE)
}

.ru_w3_as_solution <- function(computed, lesson, rendering, level) {
  allowed <- .ru_w3_statuses
  if (!is.list(computed) || !identical(computed$schema_version, "ru.guided.v1") ||
      !is.character(computed$status) || length(computed$status) != 1L ||
      is.na(computed$status) || !computed$status %in% allowed ||
      !is.character(computed$reason_code) ||
      length(computed$reason_code) != 1L || is.na(computed$reason_code) ||
      !identical(computed$executed, FALSE))
    stop("Invalid W3 computation contract.", call. = FALSE)
  if (!is.list(lesson) || !identical(lesson$schema_version, "ru.guided.v1") ||
      !identical(lesson$status, computed$status) ||
      !identical(lesson$reason_code, computed$reason_code))
    stop("Invalid W3 lesson contract.", call. = FALSE)
  if (!is.list(rendering) || !identical(rendering$status, computed$status) ||
      !is.logical(rendering$opened) || length(rendering$opened) != 1L ||
      is.na(rendering$opened) || !is.character(rendering$capability_status) ||
      length(rendering$capability_status) != 1L ||
      is.na(rendering$capability_status))
    stop("Invalid W3 viewer contract.", call. = FALSE)
  structure(list(schema_version = "ru.guided.v1",
                 status = computed$status, reason_code = computed$reason_code,
                 question = computed$original_question, family_id = computed$family_id,
                 inputs = computed$inputs,
                 requested_outputs = computed$requested_outputs,
                 assumptions = computed$assumptions,
                 answer = computed$answer, checks = computed$checks,
                 guide = lesson,
                 code_preview = computed$code_preview,
                 code_status = "NOT_EXECUTED", executed = FALSE,
                 opened = rendering$opened,
                 capability_status = rendering$capability_status,
                 level = level), class = "ru_solution")
}

.ru_w3_concise_guide <- function(lesson) {
  # Presentation-only reduction of A2 teaching content. Never change A3
  # mathematics, the structured answer, code, assumptions, checks, hints,
  # interpretations, edit instructions, or an unsupported/refusal status.
  if (!is.list(lesson))
    stop("Expected a structured W3 lesson.", call. = FALSE)
  explanation <- lesson$explanation_sections
  if (is.character(explanation) && length(explanation) > 3L)
    lesson$explanation_sections <- explanation[unique(c(1L, 2L, length(explanation)))]
  steps <- lesson$step_by_step
  if (is.character(steps) && length(steps) > 3L) {
    keep <- unique(c(1L, if (length(steps) >= 5L) 3L else 2L,
                     seq.int(max(1L, length(steps)-2L), length(steps))))
    # The renderer already numbers ordered steps; remove old embedded numbers
    # after selecting steps so the reduced sequence is not misleading.
    lesson$step_by_step <- sub("^[[:space:]]*[0-9]+[.)][[:space:]]*",
                               "", steps[keep], perl = TRUE)
  }
  lesson$presentation_level <- "concise"
  lesson
}

#' Solve or guide a statistical assignment question
#'
#' Interpret one quoted question using installed deterministic lessons. The
#' returned R code is a preview and is never executed on research data.
#' Viewers are optional; all guidance remains in the returned object.
#'
#' @param question One ordinary quoted natural-language question.
#' @param open Whether to try the local RStudio Viewer.
#' @param level One of "beginner" or "concise".
#' @return An inspectable `ru_solution` list, invisibility not required.
#' @export
ru_solve <- function(question, open = TRUE, level = c("beginner", "concise")) {
  level <- match.arg(level)
  if (!is.logical(open) || length(open) != 1L || is.na(open))
    stop("open must be TRUE or FALSE.", call. = FALSE)
  if (!.ru_w3_valid_question(question)) {
    parsed <- .ru_w3_invalid(question,
      if (is.character(question) && length(question) == 1L &&
          !is.na(question) && nchar(question, type = "bytes") > 4096L)
        "QUESTION_TOO_LONG" else "INVALID_QUESTION")
    # INVALID still follows the same teaching/rendering contract.
    computed <- parsed
  } else {
    # W4 is additive: without an A3-recognized W4 intent the complete W3
    # parser, computation, safeguards and output remain unchanged.
    w4 <- .ru_w4_dispatch(question)
    if (is.null(w4)) {
      parsed <- .ru_w3_parse(question)
      computed <- .ru_w3_compute(parsed)
    } else {
      computed <- w4
    }
  }
  # A qualified W4 numerical family requires its own approved teaching
  # and Viewer adapters. Candidate families return honest non-SOLVED
  # guidance through the still-supported W3 lesson/Viewer fallback.
  w4_solved <- inherits(computed, "ru_w4_computed") &&
    identical(computed$status, "SOLVED")
  lesson <- if (w4_solved)
    .ru_w4_peer_function("teach")(computed) else .ru_w3_teach(computed)
  if (identical(level, "concise"))
    lesson <- .ru_w3_concise_guide(lesson)
  else
    lesson$presentation_level <- "beginner"
  # Viewer truthfulness and code-preview-only behavior are unchanged.
  rendering <- if (w4_solved)
    .ru_w4_peer_function("render")(lesson, open = open) else
    .ru_w3_render(lesson, open = open)
  .ru_w3_as_solution(computed, lesson, rendering, level)
}

#' @export
print.ru_solution <- function(x, ...) {
  cat("RU guidance [", x$status, "]", sep = "")
  if (nzchar(x$reason_code)) cat(" (", x$reason_code, ")", sep = "")
  cat("\n", "Question: ", x$question, "\n", sep = "")
  if (length(x$guide$step_by_step))
    cat(paste(as.character(x$guide$step_by_step), collapse = "\n"), "\n")
  if (is.character(x$code_preview) && length(x$code_preview) == 1L &&
      nzchar(x$code_preview))
    cat("R code preview (NOT EXECUTED):\n", x$code_preview, "\n", sep = "")
  invisible(x)
}