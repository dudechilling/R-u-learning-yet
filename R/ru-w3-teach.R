# Question-specific teaching from an already validated ru.guided.v1 result.
# No parsing, simulation, statistical solving or automatic execution takes place here.
.ru_w3_teach <- function(computed) {
  statuses <- c("SOLVED", "GUIDED_REFERENCE", "NEEDS_INPUT",
                "UNSUPPORTED", "INVALID")
  scalar <- function(x) is.character(x) && length(x) == 1L && !is.na(x)
  if (!is.list(computed) ||
      !identical(computed$schema_version, "ru.guided.v1") ||
      !scalar(computed$status) || !computed$status %in% statuses) {
    stop("Expected a validated ru.guided.v1 computation", call. = FALSE)
  }
  if (!is.null(computed$executed) && !identical(computed$executed, FALSE))
    stop("The teaching layer accepts code previews, not executed code", call. = FALSE)

  question <- if (scalar(computed$original_question)) computed$original_question else ""
  family <- if (scalar(computed$family_id)) computed$family_id else ""
  reason <- if (scalar(computed$reason_code)) computed$reason_code else ""
  requested <- if (is.character(computed$requested_outputs))
    computed$requested_outputs else character()
  fmt <- function(x) format(x, digits = 12L, trim = TRUE, scientific = FALSE)

  assumptions_as_sentences <- function(x) {
    if (!is.list(x) || !length(x))
      return("No calculation-specific model assumptions have been verified.")
    statements <- character()
    if ("fair" %in% names(x)) {
      statements <- c(statements, if (identical(x$fair, TRUE))
        "The theoretical model assumes that each die is fair: each face is equally likely. Fairness has not been measured."
        else "Equal face probabilities have not been established; do not assume fair dice without evidence.")
    }
    if ("independent" %in% names(x)) {
      statements <- c(statements, if (identical(x$independent, TRUE))
        "The theoretical model assumes the rolls are independent: the result of one die does not change the probabilities for the other."
        else "Independence has not been established; a dependent model needs an explicit joint probability rule.")
    }
    for (key in setdiff(names(x), c("fair", "independent"))) {
      value <- x[[key]]
      if (is.logical(value) && length(value) == 1L && !is.na(value)) {
        statements <- c(statements, paste0("Model condition '", key, "' is ",
          if (isTRUE(value)) "asserted" else "not established", "."))
      } else if (is.character(value) && length(value) == 1L &&
                 !is.na(value)) {
        statements <- c(statements, paste0("Model condition '", key,
                                          "': ", value, "."))
      }
    }
    if (!length(statements))
      statements <- "No named statistical assumptions were supplied with this computation."
    statements
  }

  checks_as_sentences <- function(x) {
    if (!is.list(x) || !length(x)) return(character())
    lines <- character()
    for (key in names(x)) {
      val <- x[[key]]
      if (is.logical(val) && length(val) == 1L && !is.na(val)) {
        lines <- c(lines, paste0("A3 verification '", key, "' ",
           if (val) "passed." else "did not pass."))
      } else if (is.numeric(val) && length(val) == 1L && is.finite(val)) {
        lines <- c(lines, paste0("A3 reported '", key, "': ", fmt(val), "."))
      }
    }
    lines
  }

  lesson <- list(
    schema_version = "ru.guided.v1",
    status = computed$status, reason_code = reason,
    title = "Guided statistical reasoning", question = question,
    requested_outputs = requested,
    explanation_sections = character(), step_by_step = character(),
    runnable_code = "", expected_output = character(),
    checks = character(), interpretations = character(),
    change_this = character(),
    hints = list(H0 = "", H1 = "", H2 = "", H3 = ""),
    transfer_question = "", links = character(),
    assumptions = assumptions_as_sentences(computed$assumptions)
  )

  if (identical(computed$status, "GUIDED_REFERENCE")) {
    if (identical(family, "discrete_cdf") || "cdf" %in% requested) {
      lesson$title <- "Understanding the cumulative distribution function (CDF)"
      lesson$explanation_sections <- c(
        "A random variable assigns a numerical value to each possible outcome of an experiment.",
        "A cumulative distribution function (CDF), written F(k), is the probability that the random variable is less than or equal to k: F(k) = P(X <= k).",
        "For a discrete random variable, the CDF adds the probability mass for every possible value at or below the chosen threshold. It increases in steps and never decreases.",
        "The PMF describes a particular outcome, whereas the CDF accumulates all outcomes up to and including a threshold. An exact boundary matters: X <= k includes k, but X < k excludes k.",
        "To calculate a CDF you need the experiment's valid PMF or probability model and the requested threshold. No distribution or die sizes were supplied here."
      )
      lesson$step_by_step <- c(
        "Identify the discrete random variable and what its values mean.",
        "Obtain a verified PMF or specify the probability model.",
        "Sort the possible values from smallest to largest.",
        "For each threshold, use cumsum() on the sorted probabilities, including probability at the threshold."
      )
      lesson$change_this <- "Specify the probability model or valid PMF, and which CDF threshold or complete curve you want."
      lesson$hints <- list(
        H0 = "Cumulative means 'at or below,' not just 'equal to.'",
        H1 = "Arrange the possible values in increasing order and keep all outcomes at or below the threshold.",
        H2 = "When a valid ordered PMF is available, cumsum() accumulates its probability column; for a particular k use P(X <= k).",
        H3 = "Write a table with the values, their PMF probabilities, and a running-total column. At each row add that row's probability to the preceding cumulative total. Check that the final total is one."
      )
      lesson$transfer_question <- "For a separately supplied PMF, explain the difference between F(k), P(X=k), and P(X<k); show how you would obtain F(k) from cumulative probability entries."
      lesson$links <- c("ru_reference('discrete_cdf')", "ru_reference('discrete_pmf')")
    } else if (identical(family, "discrete_pmf") || "pmf" %in% requested) {
      lesson$title <- "Understanding the probability mass function (PMF)"
      lesson$explanation_sections <- c(
        "A random variable assigns a number to each outcome of a random experiment.",
        "A probability mass function (PMF) lists each possible value of a discrete random variable together with the probability of that exact value.",
        "A valid PMF has nonnegative probabilities, each no larger than one, whose total is one.",
        "If all elementary outcomes are equally likely, the probability of a value is the count of outcomes giving that value divided by the total number of outcomes. Never assume equal probabilities for a loaded die.",
        "A CDF is a different object: it adds PMF probabilities at or below a chosen value. To calculate numerical probabilities, identify an experiment and its probability model first."
      )
      lesson$step_by_step <- c(
        "Name the discrete random variable and identify its possible values.",
        "Determine which elementary outcomes are allowed and whether their probabilities are known.",
        "Count or combine the outcome probabilities to obtain each PMF entry.",
        "Check nonnegativity and total probability one before interpreting results."
      )
      lesson$change_this <- "Specify an actual random experiment, its possible outcomes and probabilities, and the requested PMF calculation."
      lesson$hints <- list(
        H0 = "A PMF answers how likely one exact value is.",
        H1 = "List the possible values and which elementary outcomes lead to each.",
        H2 = "Under a verified equal-outcome model, probability equals count divided by total; otherwise add the actual outcome probabilities.",
        H3 = "Make columns for possible value, supporting outcomes, and probability. Populate them using your model, then verify that the probability column sums to one."
      )
      lesson$transfer_question <- "Describe a different discrete experiment and explain what would be needed to build its PMF, without assuming uniform probabilities."
      lesson$links <- c("ru_reference('discrete_pmf')", "ru_reference('discrete_cdf')")
    } else {
      lesson$title <- "Conceptual guidance for the requested method"
      lesson$explanation_sections <- c(
        "This question received a conceptual reference rather than a numerical solution.",
        "Identify the method, the needed data or parameters, and the assumptions before calculating anything."
      )
      lesson$step_by_step <- c("Name the quantity of interest.",
        "Identify the necessary inputs and model assumptions.",
        "Use an applicable installed RU reference for the next step.")
      lesson$change_this <- "Supply the actual method, data or numerical model for a specific solution."
      lesson$hints <- list(H0 = "Identify the key term.",
        H1 = "Explain it in your own words.",
        H2 = "Find a relevant method reference with ru_find().",
        H3 = "Make a short list of the required inputs, assumptions and intended interpretation.")
      lesson$transfer_question <- "Explain how to select the same concept in a different problem."
      lesson$links <- "ru_find('method selection')"
    }
    return(lesson)
  }

  if (!identical(computed$status, "SOLVED")) {
    lesson$title <- "More information or a supported method is required"
    lesson$explanation_sections <- c(
      "No verified numerical solution is available for this question.",
      paste0("Reason: ", if (nzchar(reason)) reason else computed$status, ".")
    )
    missing <- if (is.character(computed$missing_inputs))
      computed$missing_inputs else character()
    if (identical(family, "data_workflow")) {
      is_missingness <- grepl("missing\\s+(?:value|data)|\\bNA\\b", question,
                             ignore.case = TRUE, perl = TRUE)
      lesson$title <- if (is_missingness) "Inspect missing values in a data frame" else "Import a CSV file into R"
      lesson$explanation_sections <- c(
        "This is a data-dependent R workflow, not a theoretical probability calculation.",
        if (is_missingness)
          "Missingness means an observation is not recorded. In R, missing entries are usually NA, not the text 'NA' or zero."
        else
          "A CSV is a plain-text table of rows and columns. Import it into a data frame to inspect column names, data types and values.",
        "The source data has not been provided or opened by RU. No row count, statistics, or file contents can be inferred."
      )
      lesson$step_by_step <- if (is_missingness) c(
        "Obtain the actual data frame and identify the columns of interest.",
        "Use is.na(data) or colSums(is.na(data)) to locate or count missing entries, with data replaced by your R object name.",
        "Decide explicitly whether to omit, investigate or retain missing values before calculating statistics."
      ) else c(
        "Locate an authorized local CSV file and review its provenance and expected column types.",
        "In the RStudio Console, run data <- read.csv(file.choose(), stringsAsFactors = FALSE) to select your file; no file is read by RU automatically.",
        "Run names(data), str(data) and head(data) to check column types, missing values and whether the import matched the source."
      )
      lesson$change_this <- c(
        if (is_missingness) "Replace data with your actual data-frame object, and identify which columns and missing-value rules apply."
        else "Choose your own CSV; after import, change the example object name data to match your R script.",
        paste0("Missing input: ", if (length(missing)) paste(missing, collapse = ", ") else "the observed dataset", ".")
      )
      lesson$hints <- if (is_missingness) list(
        H0 = "An NA means an entry is absent; it is not automatically a zero.",
        H1 = "Decide which columns require a missingness check.",
        H2 = "Use is.na(data) for a logical missingness map and colSums(is.na(data)) for per-column counts.",
        H3 = "After assigning your data frame to data, run str(data), colSums(is.na(data)), and inspect the affected rows; document your treatment decision before calling mean(..., na.rm = TRUE)."
      ) else list(
        H0 = "Importing creates a data-frame object from an actual local file.",
        H1 = "Find the source CSV and identify its header row and intended columns.",
        H2 = "Use read.csv(file.choose(), stringsAsFactors = FALSE), then inspect names() and str().",
        H3 = "In the Console run data <- read.csv(file.choose(), stringsAsFactors = FALSE), then names(data), str(data), head(data), and colSums(is.na(data)). Recheck the chosen file and delimiters if columns look wrong."
      )
      lesson$transfer_question <- if (is_missingness)
        "For a different dataset, identify which variables contain missing values and explain whether deleting those rows could bias the analysis."
        else "Import a different CSV, check its column types, and explain how you would detect a misread header or missing values."
      lesson$links <- if (is_missingness)
        c("ru_reference('missing_values')", "ru_reference('import_csv')",
          "ru_reference('describe_numeric')")
      else c("ru_reference('import_csv')", "ru_reference('missing_values')",
             "ru_reference('rstudio_contexts')")
    } else if (identical(family, "histogram")) {
      lesson$title <- "Build and interpret a histogram"
      lesson$explanation_sections <- c(
        "A histogram groups numerical observations into intervals called bins and displays their frequencies or densities.",
        "The bin boundaries, widths, interval closure and missing-value handling affect interpretation. A histogram is not itself a probability mass function for discrete dice sums.",
        "The observed numeric variable and a justified histogram specification have not been supplied; RU cannot claim a plot, distribution shape or computed frequencies."
      )
      lesson$step_by_step <- c(
        "Identify the actual numeric column, its unit of measurement and missing observations.",
        "Specify bin boundaries or breaks, whether the right endpoint is included, and whether frequency or density is required.",
        "Inspect the specified numeric column and, once parameters are justified, use hist(x, breaks = ..., right = TRUE) with x replaced by the actual observations.",
        "Interpret the heights, units, spread and possible outliers without asserting a distribution that has not been observed."
      )
      lesson$change_this <- c("Replace x with your actual numerical observations.",
        "Choose breaks and interval closure from the assignment and data; do not treat example bin boundaries as observed facts.",
        paste0("Missing input: ", if (length(missing)) paste(missing, collapse = ", ") else "the numeric data and bin specification", "."))
      lesson$hints <- list(
        H0 = "A histogram describes observed numerical values grouped into intervals.",
        H1 = "Choose the measured variable and clarify bin boundaries, units and how to handle NA values.",
        H2 = "Use hist(x, breaks = ..., right = TRUE) only after supplying the real x vector and justified breaks.",
        H3 = "Check is.numeric(x) and missingness first; record the bin rules, call hist() with the specified breaks, and compare each bar's height and boundary with the underlying observations before interpreting shape."
      )
      lesson$transfer_question <- "With a different numerical variable, explain how changing bin width can alter the impression of its distribution without changing the data."
      lesson$links <- c("ru_reference('histogram')",
                        "ru_reference('histogram_breaks')",
                        "ru_reference('histogram_interpret')")
    } else if (identical(family, "inference")) {
      lesson$title <- "Identify a valid hypothesis-test method"
      lesson$explanation_sections <- c(
        "A hypothesis test evaluates how compatible observed data are with a specified null hypothesis under a statistical model.",
        "A test requires the research question, response and explanatory variables, sample design, independence conditions and a justified method.",
        "This question is outside the current full W3 deterministic solver. No p-value, confidence interval or conclusion has been computed."
      )
      lesson$step_by_step <- c(
        "State the null hypothesis and an appropriate alternative.",
        "Identify the observed variables, sampling design and measurement scale.",
        "Check method-specific requirements and inspect the data before selecting an R test.",
        "Interpret an actual calculated result only after a supported verified method has run.")
      lesson$change_this <- "Supply the observed data, study design and hypothesis; consult a relevant existing RU reference rather than inventing a test statistic."
      lesson$hints <- list(H0 = "Start with the population claim under investigation.",
        H1 = "Distinguish a population parameter from its sample estimate.",
        H2 = "Identify the response, groups, sample design and test assumptions before choosing a method.",
        H3 = "Write H0/H1, data sources, outcome type and possible confounders; inspect data and choose an appropriate validated test before calculating or interpreting a p-value.")
      lesson$transfer_question <- "Compare two hypothetical studies with different sampling designs; explain why the same hypothesis need not justify the same test."
      lesson$links <- c("ru_find('hypothesis test')", "ru_find('method selection')")
    } else {
      lesson$explanation_sections <- c(lesson$explanation_sections,
        "Specify the probability model, its required parameters and the requested event or quantity. The solver does not fill gaps by assuming a fair or independent process.")
      lesson$step_by_step <- c(
        "Identify the random variable or statistical operation in the question.",
        "List which numerical inputs and assumptions the question actually supplies.",
        "Check the missing information before using a numerical formula.")
      lesson$change_this <- if (length(missing))
        paste("Clarify:", paste(missing, collapse = ", "))
        else "Specify a supported model and the numerical inputs needed for it."
      lesson$hints <- list(
        H0 = "First identify the mathematical model and requested quantity.",
        H1 = "Separate values given in the question from information that has not been supplied.",
        H2 = "Use ru_find('PMF') to review discrete probability models, but do not silently treat a loaded die as fair.",
        H3 = "Write down the random variable, all possible outcomes and their probabilities; if any are unknown, obtain them or state why the problem cannot be solved with this method."
      )
      lesson$transfer_question <- "For a related problem, identify the missing parameter that would be necessary before any calculation."
      lesson$links <- c("ru_reference('discrete_pmf')", "ru_find('method selection')")
    }
    lesson$checks <- "No numerical computation was accepted as solved."
    return(lesson)
  }

  # Only the two-fair-independent-dice family has a validated W3 computation.
  if (!identical(family, "dice_sum_independent_fair"))
    stop("SOLVED computation has no supported W3 teaching adapter", call. = FALSE)

  inp <- computed$inputs
  ans <- computed$answer
  valid_face_count <- function(x) {
    is.numeric(x) && length(x) == 1L && is.finite(x) &&
      x >= 1 && x == floor(x)
  }
  valid_face <- function(x) is.integer(x) && length(x) == 1L &&
    !is.na(x) && x >= 2L && x <= 10000L
  valid_number <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  if (!is.list(inp) || !valid_face(inp$die1_faces) ||
      !valid_face(inp$die2_faces) || !is.list(ans) ||
      !is.data.frame(ans$pmf) || !nrow(ans$pmf) ||
      !identical(names(ans$pmf), c("sum", "count", "probability", "cdf")) ||
      !is.integer(ans$pmf$sum) || !is.integer(ans$pmf$count) ||
      !is.numeric(ans$pmf$probability) || !is.numeric(ans$pmf$cdf) ||
      anyNA(ans$pmf) || !valid_face_count(ans$total_outcomes) ||
      !valid_number(ans$expected_value) || !valid_number(ans$variance) ||
      !is.data.frame(ans$events) ||
      !all(c("label", "probability") %in% names(ans$events)) ||
      !scalar(computed$code_preview) ||
      !all(vapply(c("die1_faces", "die2_faces", "seq_len(", "outer(",
                    "roll_sums", "support", "tabulate(", "counts / length(roll_sums)",
                    "cumsum(", "expected_value", "variance"),
                  grepl, logical(1L), x = computed$code_preview, fixed = TRUE))) {
    stop("SOLVED dice teaching requires a validated A3 answer and code preview",
         call. = FALSE)
  }
  a <- inp$die1_faces
  b <- inp$die2_faces
  n <- ans$total_outcomes
  pmf <- ans$pmf
  events <- ans$events

  lesson$title <- paste0("Sum of a ", fmt(a), "-sided and a ",
                         fmt(b), "-sided die")
  lesson$explanation_sections <- c(
    paste0("A discrete random variable X maps each possible ordered outcome to a number. Here X is the sum of the first die (",
           fmt(a), " faces) and the second die (", fmt(b), " faces)."),
    paste0("The verified PMF lists every sum from ", fmt(pmf$sum[1L]),
           " through ", fmt(tail(pmf$sum, 1L)),
           ". Some sums have more ordered face pairs than others, so their probabilities differ."),
    paste0("The supplied A3 result contains ", fmt(n),
           " ordered outcomes. Under the fair and independent assumptions, each ordered face pair has equal probability. An individual sum's probability is its count divided by ",
           fmt(n), "."),
    "The actual R preview uses seq_len(die1_faces) and seq_len(die2_faces) to form the faces of each die. outer(..., '+') adds every pair; as.vector() collects the sums in roll_sums.",
    "support <- seq.int(2L, die1_faces + die2_faces) constructs the ordered possible sums. counts <- tabulate(roll_sums - 1L, nbins = die1_faces + die2_faces)[support - 1L] counts each sum; subtracting 1L maps a sum of two to the first R bin.",
    "The code divides counts by length(roll_sums) for the probability column of pmf. The optional alternative table(roll_sums) followed by prop.table() can produce equivalent frequencies and proportions, but those functions are not used in the displayed preview.",
    "The code makes pmf$cdf using cumsum(pmf$probability). The CDF at k, F(k), means P(X <= k), so the row at k includes its own probability.",
    "The weighted expected value is sum(pmf$sum * pmf$probability). Distribution variance is sum((pmf$sum - expected_value)^2 * pmf$probability). This differs from stats::var(), which estimates sample variance with an n-1 divisor.",
    "For a requested event, select the PMF entries meeting its condition and add their probabilities. The code creates events with labels and event_probabilities when needed."
  )
  lesson$step_by_step <- c(
    paste0("Set die1_faces <- ", fmt(a), "L and die2_faces <- ",
           fmt(b), "L to describe the parsed dice."),
    "Call seq_len() for each die's face values and outer() with '+' to form all ordered pairs, then as.vector() into roll_sums.",
    "Create support with seq.int(2L, die1_faces + die2_faces), which orders the possible sums.",
    "Use tabulate(roll_sums - 1L, nbins = die1_faces + die2_faces)[support - 1L] to obtain counts aligned with support.",
    "Build pmf with sum = support, count = counts, probability = counts / length(roll_sums).",
    "Create pmf$cdf <- cumsum(pmf$probability) for cumulative probability at or below each possible sum.",
    "Compute expected_value <- sum(pmf$sum * pmf$probability).",
    "Compute variance <- sum((pmf$sum - expected_value)^2 * pmf$probability); do not substitute stats::var(pmf$sum).",
    "For an event, add only matching pmf$probability entries. Check the A3 verification outcomes before interpreting the result."
  )
  lesson$runnable_code <- computed$code_preview
  summaries <- c(
    paste0("Ordered outcomes: ", fmt(n)),
    "sum : count / total = probability; CDF",
    sprintf("%s : count %s / %s = %s; CDF %s",
            fmt(pmf$sum), fmt(pmf$count), fmt(n),
            fmt(pmf$probability), fmt(pmf$cdf)),
    paste0("E(X): ", fmt(ans$expected_value)),
    paste0("Var(X): ", fmt(ans$variance))
  )
  if (nrow(events)) {
    summaries <- c(summaries,
      paste0(as.character(events$label), ": ",
             vapply(events$probability, fmt, character(1L))))
  }
  # A4 consumes answer$pmf to render the actual table and graph.
  # The exact A3 answer is carried through without another statistical engine.
  lesson$expected_output <- list(
    answer = computed$answer,
    requested_outputs = computed$requested_outputs,
    summary_lines = summaries
  )
  lesson$checks <- c(
    "Review A3's independent mathematical verification checks below; the teaching layer does not recalculate statistics.",
    checks_as_sentences(computed$checks),
    "The total PMF mass must equal one, and a CDF must not decrease.",
    "For an integer threshold k, P(X <= k) includes k; P(X < k) does not.",
    "Use probability-weighted distribution variance, not sample variance of unique totals."
  )
  lesson$interpretations <- c(
    paste0("The theoretical expected sum is ", fmt(ans$expected_value),
           " under the stated fair and independent assumptions."),
    paste0("The theoretical distribution variance is ", fmt(ans$variance),
           " in squared face-value units."),
    "The PMF is for an exact sum; the CDF includes all sums at or below a boundary."
  )
  if ("pmf" %in% requested)
    lesson$interpretations <- c(lesson$interpretations,
      "Each PMF row gives an exact sum, its ordered-outcome count and its probability.")
  if ("cdf" %in% requested)
    lesson$interpretations <- c(lesson$interpretations,
      "Use the CDF column at the relevant threshold; it already includes the PMF at that threshold.")
  if ("events" %in% requested && nrow(events)) {
    lesson$interpretations <- c(lesson$interpretations,
      paste0(as.character(events$label), " has theoretical probability ",
             vapply(events$probability, fmt, character(1L)), "."))
  }
  lesson$change_this <- c(
    paste0("die1_faces: the first die currently has ", fmt(a),
           " faces. Edit this variable in the code to change the first die."),
    paste0("die2_faces: the second die currently has ", fmt(b),
           " faces. Edit this variable in the code to change the second die."),
    "After either edit, re-run the entire code locally so support, counts, pmf, cdf, expected_value and variance update together.",
    "For a different event, change the conditional expression selecting pmf$sum and update its event label; do not change die sizes to alter an event."
  )
  lesson$hints <- list(
    H0 = "First treat the sum as a discrete random variable, not a count of all possible outcomes.",
    H1 = paste0("Track the first and second die separately. The validated model has ",
                fmt(n), " ordered face pairs; different totals can have different counts."),
    H2 = "Use seq_len() and outer() to enumerate pairs. tabulate() counts the values of roll_sums; divide counts by length(roll_sums), then use cumsum() and probability-weighted sums.",
    H3 = paste0("Set die1_faces <- ", fmt(a), "L; die2_faces <- ", fmt(b),
      "L. Build roll_sums <- as.vector(outer(seq_len(die1_faces), seq_len(die2_faces), '+')); ",
      "support <- seq.int(2L, die1_faces + die2_faces); ",
      "counts <- tabulate(roll_sums - 1L, nbins = die1_faces + die2_faces)[support - 1L]; ",
      "pmf <- data.frame(sum = support, count = counts, probability = counts / length(roll_sums)); ",
      "then use cumsum(pmf$probability) and probability-weighted sums. Check the A3 invariants.")
  )
  other_a <- if (a < 10L) a + 1L else a - 1L
  lesson$transfer_question <- paste0(
    "Try a ", fmt(other_a), "-sided first die with a ", fmt(b),
    "-sided second die. Assuming both are fair and independent, construct the PMF and CDF, then calculate E(X), Var(X), and explain what changed. Show the R output and an independent probability-mass check; do not copy the original numerical answer."
  )
  lesson$links <- c(
    "ru_reference('discrete_pmf')", "ru_reference('discrete_cdf')",
    "ru_reference('vectors_indexing')", "ru_find('variance')"
  )
  lesson$assumptions <- c(
    lesson$assumptions,
    "The calculations are theoretical; the question does not establish that physical dice were tested for fairness or independence.",
    "The displayed R code is an unexecuted preview to run on the student's computer."
  )
  lesson
}
