# Three-mode selector. A resolved local consumer is not a GUI launch.
.ru_workspace_has_consumer <- function(name) {
  exists(name, envir = environment(ru_workspace), mode = "function",
         inherits = FALSE)
}

ru_workspace <- function(mode = c("learn", "analyze", "reference")) {
  choices <- c("learn", "analyze", "reference")
  if (missing(mode))
    return(.ru_result("ru_workspace_result", schema_version = 1L,
                      status = "SELECTOR", mode = NULL, choices = choices,
                      opened = FALSE, capability_status = "SUPPORTED",
                      reason_code = "CHOICE_REQUIRED", consumer = NULL))
  mode <- .ru_exact_choice(mode, "mode", choices)
  if (mode == "reference") {
    catalogue <- ru_reference(query = NULL, open = FALSE)
    return(.ru_result("ru_workspace_result", schema_version = 1L,
                      status = "CATALOGUE", mode = mode, choices = choices,
                      opened = FALSE, capability_status = "SUPPORTED",
                      reason_code = NULL, consumer = catalogue))
  }
  unavailable <- function(reason = "NOT_IMPLEMENTED") {
    .ru_result("ru_workspace_result", schema_version = 1L,
               status = "UNAVAILABLE", mode = mode, choices = choices,
               opened = FALSE, capability_status = "UNAVAILABLE",
               reason_code = reason, consumer = NULL)
  }
  if (mode == "learn") {
    if (!.ru_workspace_has_consumer("ru_learn")) return(unavailable())
    # ru_learn() provides the real local selector, without an invented
    # launch or a claim of independent assessment credit.
    select <- get("ru_learn", envir = environment(ru_workspace),
                  inherits = FALSE)()
    if (!inherits(select, "ru_learning_route") ||
        !identical(select$status, "SELECTOR") || !identical(select$opened, FALSE))
      return(unavailable("INVALID_CONSUMER"))
    return(.ru_result("ru_workspace_result", schema_version = 1L,
                      status = "SELECTOR", mode = mode, choices = choices,
                      opened = FALSE, capability_status = "UNTESTED",
                      reason_code = "CHOICE_REQUIRED", consumer = select))
  }
  if (!.ru_workspace_has_consumer("ru_analyze")) return(unavailable())
  if (!requireNamespace("shiny", quietly = TRUE))
    return(unavailable("UNAVAILABLE_DEPENDENCY"))
  # Construct only an actual L3 question-first Shiny consumer. Never
  # report a launch, a computation, or current-data validation.
  app <- get("ru_analyze", envir = environment(ru_workspace),
             inherits = FALSE)(data = NULL, spec = NULL)
  if (!inherits(app, "shiny.appobj"))
    return(unavailable("INVALID_CONSUMER"))
  .ru_result("ru_workspace_result", schema_version = 1L,
             status = "READY_TO_LAUNCH", mode = mode, choices = choices,
             opened = FALSE, capability_status = "UNTESTED",
             reason_code = "GUI_NOT_TESTED", consumer = app)
}

print.ru_workspace_result <- function(x, ...) {
  if (identical(x$status, "SELECTOR") && is.null(x$mode)) {
    cat("RU workspace: choose learn, analyze, or reference.\n",
        "Use ru_workspace('reference') for the offline catalogue.\n", sep = "")
  } else if (identical(x$status, "SELECTOR") &&
             identical(x$mode, "learn")) {
    cat("RU learning: choose one of the registered foundation tutorials.\n")
  } else if (identical(x$status, "READY_TO_LAUNCH")) {
    cat("RU analysis app constructed but not launched; runtime not tested.\n")
  } else if (identical(x$status, "UNAVAILABLE")) {
    cat("RU ", x$mode, ": unavailable (", x$reason_code, ").\n", sep = "")
  } else {
    cat("RU reference catalogue: inspect the structured result with ",
        "ru_reference(open=FALSE).\n", sep = "")
  }
  invisible(x)
}
