# New three-mode selector. Legacy ru_home()/ru_plan() are separate APIs.
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
  .ru_result("ru_workspace_result", schema_version = 1L,
             status = "UNAVAILABLE", mode = mode, choices = choices,
             opened = FALSE, capability_status = "UNAVAILABLE",
             reason_code = "NOT_IMPLEMENTED", consumer = NULL)
}

print.ru_workspace_result <- function(x, ...) {
  if (identical(x$status, "SELECTOR")) {
    cat("RU workspace: choose learn, analyze, or reference.\n",
        "Use ru_workspace('reference') for the offline catalogue.\n",
        "Learning and analysis consumers are not implemented in W1.\n", sep = "")
  } else if (identical(x$status, "UNAVAILABLE")) {
    cat("RU ", x$mode, ": unavailable (", x$reason_code, ").\n", sep = "")
  } else {
    cat("RU reference catalogue: inspect the structured result with ",
        "ru_reference(open=FALSE).\n", sep = "")
  }
  invisible(x)
}