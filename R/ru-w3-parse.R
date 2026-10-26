# W3 question interpretation: deterministic, local, and side-effect free.
# These internal routines do not access research data, files, the network, or R evaluation.
.ru_w3_parsed <- function(status, reason_code, original_question = "",
                          family_id = NA_character_, inputs = list(),
                          requested_outputs = character(), assumptions = list(),
                          missing_inputs = character(), parser_rule_id = "none") {
  structure(list(
    schema_version = "ru.guided.v1",
    status = status, reason_code = reason_code,
    original_question = original_question, family_id = family_id,
    inputs = inputs, requested_outputs = requested_outputs,
    assumptions = assumptions, missing_inputs = missing_inputs,
    parser_rule_id = parser_rule_id
  ), class = c("ru_w3_parsed", "list"))
}

.ru_w3_normalize <- function(text) {
  # Canonicalize punctuation for recognition; original_question is never changed.
  text <- gsub("[\u2010-\u2015\u2212\uFE63\uFF0D]", "-", text, perl = TRUE)
  text <- gsub("\u2264", "<=", text, fixed = TRUE)
  text <- gsub("\u2265", ">=", text, fixed = TRUE)
  text <- gsub("[\u2018\u2019]", "'", text, perl = TRUE)
  text <- gsub("[\u201C\u201D]", '"', text, perl = TRUE)
  text <- tolower(text)
  words <- c(zero = 0L, one = 1L, two = 2L, three = 3L, four = 4L,
             five = 5L, six = 6L, seven = 7L, eight = 8L,
             nine = 9L, ten = 10L, eleven = 11L, twelve = 12L,
             thirteen = 13L, fourteen = 14L, fifteen = 15L,
             sixteen = 16L, seventeen = 17L, eighteen = 18L,
             nineteen = 19L, twenty = 20L)
  for (name in names(words))
    text <- gsub(paste0("\\b", name, "\\b"), as.character(words[[name]]),
                 text, perl = TRUE)
  gsub("\\s+", " ", trimws(text), perl = TRUE)
}

.ru_w3_capture <- function(pattern, text) {
  match <- regexec(pattern, text, perl = TRUE)
  groups <- regmatches(text, match)[[1L]]
  if (!length(groups)) character() else groups[-1L]
}

.ru_w3_die_literals <- function(text, detailed = FALSE) {
  # Inventory face-qualified dice in their textual order. Quantity precedes
  # the individual face description: "2 six-sided dice and 1 four-sided die"
  # is THREE dice, even though it contains only two face specifications.
  side <- "(?<![[:alnum:]])[+-]?[0-9]+(?:\\.[0-9]+)?\\s*[- ]\\s*(?:sided|faced)\\b(?:\\s+(?:dice|die)\\b)?"
  dice <- "(?<![[:alpha:]])d\\s*[+-]?[0-9]+(?:\\.[0-9]+)?\\b"
  suff <- "\\bdie\\s+(?:with\\s+)?[+-]?[0-9]+(?:\\.[0-9]+)?\\s+(?:faces|sides)\\b"
  parts <- character()
  positions <- integer()
  widths <- integer()
  for (pattern in c(side, dice, suff)) {
    locations <- gregexpr(pattern, text, perl = TRUE)[[1L]]
    if (locations[[1L]] == -1L) next
    parts <- c(parts, regmatches(text, list(locations))[[1L]])
    positions <- c(positions, as.integer(locations))
    widths <- c(widths, as.integer(attr(locations, "match.length")))
  }
  if (!length(parts)) {
    if (!detailed) return(character())
    return(list(literals = character(), quantities = integer(),
                invalid_quantity = FALSE, ambiguous_quantity = FALSE,
                aggregate_excess = FALSE, extra_die = FALSE))
  }
  order_found <- order(positions)
  parts <- parts[order_found]
  positions <- positions[order_found]
  widths <- widths[order_found]
  literals <- vapply(parts, function(part) {
    face <- regmatches(part, gregexpr("[+-]?[0-9]+(?:\\.[0-9]+)?",
                                      part, perl = TRUE))[[1L]]
    if (!length(face)) return(NA_character_)
    face[[1L]]
  }, character(1L), USE.NAMES = FALSE)
  if (!detailed) return(literals)

  quantities <- rep.int(1L, length(parts))
  invalid <- FALSE
  ambiguous <- FALSE
  for (i in seq_along(parts)) {
    # Limited lookback: quantifiers must immediately modify the face token,
    # optionally through a small set of die adjectives.
    start <- positions[[i]]
    prefix <- if (start > 1L)
      substr(text, max(1L, start - 85L), start - 1L) else ""
    count <- .ru_w3_capture(
      "(?<![[:alpha:]])([+-]?[0-9]+(?:\\.[0-9]+)?)\\s*(?:(?:fair|ordinary|independent|standard|identical|unbiased)\\s+)*$",
      prefix)
    if (length(count) == 1L) {
      # Decimal, negative, zero, and astronomically large multiplicities
      # cannot be interpreted as valid numbers of dice.
      n <- .ru_w3_int_literal(count[[1L]], 1L, 1000000000)
      if (is.null(n)) invalid <- TRUE else quantities[[i]] <- n
    } else if (grepl("\\bdice\\b", parts[[i]], perl = TRUE)) {
      # "Six-sided dice" without a count is not silently "one die".
      ambiguous <- TRUE
    }
  }
  # Mask the face-qualified mentions so that a trailing "and another die"
  # or "plus one die" cannot vanish from the parsed model.
  remainder <- text
  for (i in rev(seq_along(parts))) {
    start <- positions[[i]]
    end <- start + widths[[i]]
    remainder <- paste0(substr(remainder, 1L, start - 1L),
                        strrep(" ", widths[[i]]),
                        substr(remainder, end, nchar(remainder)))
  }
  aggregate_pattern <- "\\b([0-9]+)\\s+(?:(?:ordinary|fair|independent|standard|identical|other|extra)\\s+)*dice\\b"
  summary_count <- .ru_w3_capture(aggregate_pattern, remainder)
  aggregate_excess <- FALSE
  if (length(summary_count)) {
    n <- .ru_w3_int_literal(summary_count[[1L]], 1L, 1000000000)
    if (is.null(n)) invalid <- TRUE
    else if (n > 2L) aggregate_excess <- TRUE
    else if (n != sum(as.double(quantities))) ambiguous <- TRUE
    remainder <- sub(aggregate_pattern, "", remainder, perl = TRUE)
  }
  # Every other surviving "die"/"dice" is an extra unsized operand (not
  # a decorative word); do not solve merely because two sides were found.
  extra <- grepl(
    "\\b(?:and|plus|with|along\\s+with)\\s+(?:(?:a|an|another|extra|additional|third|fourth|[0-9]+)\\s+)?(?:(?:fair|ordinary|independent|unknown)\\s+)?(?:die|dice)\\b|\\b(?:another|extra|additional|third|fourth)\\s+(?:die|dice)\\b|\\b(?:and|plus|with)\\b.{0,35}\\b(?:another|third|fourth|extra|additional)\\b.{0,20}\\b(?:die|dice)\\b",
    remainder, perl = TRUE)
  list(literals = literals, quantities = quantities,
       invalid_quantity = invalid, ambiguous_quantity = ambiguous,
       aggregate_excess = aggregate_excess, extra_die = extra)
}

# Recognize unsupported method families separately from the dice family.
# Adding a family here identifies intent; it does NOT license calculation.
# A future supported family needs its own validated parser and math oracle.
.ru_w3_other_family <- function(text) {
  routes <- list(
    poisson = "\\bpoisson\\b",
    normal = "\\b(?:normal|gaussian)\\b",
    binomial = "\\bbinomial\\b",
    exponential = "\\bexponential\\b",
    hypergeometric = "\\bhypergeometric\\b",
    geometric = "\\bgeometric\\s+distribution\\b",
    continuous_uniform = "\\b(?:continuous|rectangular)\\s+uniform\\b",
    t_distribution = "\\bstudent'?s?\\s+t\\s+distribution\\b",
    geospatial = "\\b(?:geog(?:raphy|raphic|raphical)?|gis|geospatial|spatial\\s+(?:autocorrelation|analysis|interpolation|statistics)|moran'?s\\s+i|map\\s+projection|latitude|longitude|geodesic|kriging|coordinate\\s+reference\\s+system)\\b"
  )
  for (family in names(routes))
    if (grepl(routes[[family]], text, perl = TRUE)) return(family)
  NULL
}

# A positive family match is insufficient when other random variables,
# model modifications, conditions, or statistical outputs were also asked.
.ru_w3_model_boundary <- function(text) {
  if (grepl("\\b(?:coin|coins|coinflip|coin[- ]?toss|spinner|spinners|deck|cards?|roulette|bernoulli|random\\s+(?:variable|number|integer|term|component|draw|outcome|value|error|noise|quantity)|stochastic\\s+(?:noise|term|component|variable)|noise|lottery|marbles?|drawing\\s+balls?)\\b",
            text, perl = TRUE))
    return("ADDITIONAL_RANDOM_COMPONENT_UNSUPPORTED")
  if (grepl("\\b(?:conditioned\\s+on|conditional\\s+on|given\\s+that\\s+(?:the\\s+)?(?:first|second|one)\\s+die|given\\s+(?:first|second|one)\\s+die|provided\\s+that|(?:if|when|where)\\s+(?:the\\s+)?(?:first|second|one)\\s+die|if\\s+(?:the\\s+)?die|except|exclude|excluding|unless|discard\\s+rolls|re[- ]?roll|reroll|drop\\s+(?:the\\s+)?(?:highest|lowest)|keep\\s+(?:the\\s+)?(?:highest|lowest))\\b",
            text, perl = TRUE))
    return("CONDITIONAL_DICE_MODEL_UNSUPPORTED")
  # Reject shifts, scaling, and other transformations of the sum. Guard
  # against matching a legitimate operand such as "plus 1 four-sided die".
  scaled <- grepl(
    "\\b(?:minus|subtract(?:ing|ed)?|plus|add(?:ing|ed)?|times)\\s+(?![0-9]+\\s+[0-9]+\\s*[- ]\\s*(?:sided|faced)\\b)[+-]?[0-9]+\\b(?!\\s*[- ]\\s*(?:sided|faced)\\b)|(?<![[:alnum:]])[+\\-]\\s*(?![0-9]+\\s+[0-9]+\\s*[- ]\\s*(?:sided|faced)\\b)[0-9]+\\b(?!\\s*[- ]\\s*(?:sided|faced)\\b)|\\b(?:subtract|add)\\s+[0-9]+\\s+(?:from|to)\\s+(?:the\\s+)?sum\\b",
    text, perl = TRUE)
  shifted_words <- grepl(
    "\\b(?:plus|minus|add|subtract|added|subtracting)\\s+(?:(?:a|an|the)\\s+)?(?:(?:fixed|integer|arbitrary|known)\\s+)*(?:bonus|constant|offset|number|value|term)\\b|\\b(?:with|by)\\s+(?:(?:a|an)\\s+)?(?:(?:fixed|integer)\\s+)*(?:bonus|offset|constant\\s+shift)\\b",
    text, perl = TRUE)
  if (scaled || shifted_words || grepl(
    "\\b(?:twice|double|triple|halved?|scaled|shifted|squared|cubed|absolute\\s+value|multiply|multiplied|divide|divided)\\b",
    text, perl = TRUE))
    return("DICE_TRANSFORMATION_UNSUPPORTED")
  if (grepl(
    "\\b(?:standard\\s+deviation|median|mode|skewness|kurtosis|entropy|moment\\s+generating|quantile|quartile|percentile|correlation|covariance|sample\\s+variance|simulate|simulation|monte\\s+carlo|plot|graph|density\\s+function|probability\\s+generating\\s+function)\\b",
    text, perl = TRUE))
    return("ADDITIONAL_STATISTICAL_OUTPUT_UNSUPPORTED")
  NULL
}

.ru_w3_int_literal <- function(value, minimum = -1000000000,
                               maximum = 1000000000) {
  if (!is.character(value) || length(value) != 1L ||
      is.na(value) || !grepl("^[+-]?[0-9]+$", value))
    return(NULL)
  number <- suppressWarnings(as.numeric(value))
  if (!is.finite(number) || number < minimum || number > maximum ||
      number != floor(number))
    return(NULL)
  as.integer(number)
}

.ru_w3_event <- function(type, values = integer()) {
  label <- switch(type,
    equal = sprintf("P(X=%d)", values[[1L]]),
    at_most = sprintf("P(X<=%d)", values[[1L]]),
    even = "P(X is even)",
    one_of = sprintf("P(X=%d or X=%d)", values[[1L]], values[[2L]]))
  list(type = type, values = as.integer(values), label = label)
}

.ru_w3_event_from_expression <- function(expression) {
  inner <- trimws(sub("\\)$", "", sub("^p\\s*\\(", "", expression, perl = TRUE),
                      perl = TRUE))
  variable <- "(?:x|s|sum)"
  pair <- .ru_w3_capture(paste0("^", variable,
    "\\s*(?:=|==)\\s*([+-]?[0-9]+)\\s+or\\s+(?:",
    variable, "\\s*(?:=|==)\\s*)?([+-]?[0-9]+)$"), inner)
  if (length(pair) == 2L) {
    values <- lapply(pair, .ru_w3_int_literal)
    if (any(vapply(values, is.null, logical(1L))))
      return(list(error = "INVALID_EVENT_THRESHOLD", status = "INVALID"))
    return(.ru_w3_event("one_of", unlist(values, use.names = FALSE)))
  }
  equal <- .ru_w3_capture(paste0("^", variable,
                                 "\\s*(?:=|==)\\s*([+-]?[0-9]+)$"), inner)
  if (length(equal) == 1L) {
    value <- .ru_w3_int_literal(equal)
    if (is.null(value))
      return(list(error = "INVALID_EVENT_THRESHOLD", status = "INVALID"))
    return(.ru_w3_event("equal", value))
  }
  at_most <- .ru_w3_capture(paste0("^", variable,
                                   "\\s*(?:<=|=<)\\s*([+-]?[0-9]+)$"), inner)
  if (length(at_most) == 1L) {
    value <- .ru_w3_int_literal(at_most)
    if (is.null(value))
      return(list(error = "INVALID_EVENT_THRESHOLD", status = "INVALID"))
    return(.ru_w3_event("at_most", value))
  }
  if (grepl(paste0("^", variable, "\\s+(?:is\\s+)?even$"), inner,
            perl = TRUE))
    return(.ru_w3_event("even"))
  if (grepl(paste0("^", variable,
                   "\\s*(?:=|==|<=|=<)\\s*(?:k|n|\\?|value|threshold)?$"),
            inner, perl = TRUE))
    return(list(error = "EVENT_THRESHOLD_REQUIRED", status = "NEEDS_INPUT"))
  if (grepl(paste0("^", variable, "\\s*(?:=|==|<=|=<)\\s*[+-]?[0-9]*\\.[0-9]+$"),
            inner, perl = TRUE))
    return(list(error = "INVALID_EVENT_THRESHOLD", status = "INVALID"))
  list(error = "EVENT_EXPRESSION_UNSUPPORTED", status = "UNSUPPORTED")
}

.ru_w3_events <- function(text) {
  result <- list()
  expression_pattern <- "\\bp\\s*\\([^()]*\\)"
  expressions <- regmatches(text, gregexpr(expression_pattern, text,
                                            perl = TRUE))[[1L]]
  if (length(expressions) > 12L)
    return(list(error = "EVENT_LIMIT_EXCEEDED", status = "UNSUPPORTED"))
  for (expression in expressions) {
    one <- .ru_w3_event_from_expression(expression)
    if (!is.null(one$error)) return(one)
    result[[length(result) + 1L]] <- one
  }
  # If a P(X...) expression starts but was not wholly consumed, do not guess.
  all_starts <- gregexpr("\\bp\\s*\\(\\s*(?:x|s|sum)\\b",
                         text, perl = TRUE)[[1L]]
  if (all_starts[[1L]] != -1L && length(all_starts) != length(expressions))
    return(list(error = "MALFORMED_EVENT_EXPRESSION", status = "INVALID"))

  # Equivalent ordinary-language events; do not confuse generic PMF with an event.
  if (grepl("\\b(?:probability|chance|likelihood)\\b.{0,75}\\b(?:sum|total|x)\\s+(?:is\\s+)?even\\b",
            text, perl = TRUE))
    result[[length(result) + 1L]] <- .ru_w3_event("even")
  natural <- .ru_w3_capture(
    "\\b(?:probability|chance)\\b.{0,75}\\b(?:sum|total|x)\\s+(?:is\\s+|equals\\s+|=\\s*)([+-]?[0-9]+)\\s+or\\s+([+-]?[0-9]+)\\b",
    text)
  if (length(natural) == 2L) {
    values <- lapply(natural, .ru_w3_int_literal)
    if (any(vapply(values, is.null, logical(1L))))
      return(list(error = "INVALID_EVENT_THRESHOLD", status = "INVALID"))
    result[[length(result) + 1L]] <- .ru_w3_event(
      "one_of", unlist(values, use.names = FALSE))
  } else {
    natural <- .ru_w3_capture(
      "\\b(?:probability|chance)\\b.{0,75}\\b(?:sum|total|x)\\s+(?:is\\s+|equals\\s+|=\\s*)([+-]?[0-9]+)\\b",
      text)
    if (length(natural) == 1L) {
      value <- .ru_w3_int_literal(natural)
      if (is.null(value))
        return(list(error = "INVALID_EVENT_THRESHOLD", status = "INVALID"))
      result[[length(result) + 1L]] <- .ru_w3_event("equal", value)
    }
  }
  if (grepl("\\b(?:probability|chance)\\b.{0,75}\\b(?:sum|total|x)\\s+(?:is\\s+)?(?:greater\\s+than|less\\s+than|odd\\b|between\\b|>=|>)",
            text, perl = TRUE))
    return(list(error = "EVENT_EXPRESSION_UNSUPPORTED", status = "UNSUPPORTED"))
  if (grepl("\\b(?:probability|chance)\\b.{0,75}\\b(?:sum|total|x)\\s+(?:is\\s+|equals\\s+|=\\s*)(?:k|n|\\?)",
            text, perl = TRUE))
    return(list(error = "EVENT_THRESHOLD_REQUIRED", status = "NEEDS_INPUT"))
  if (length(result) > 12L)
    return(list(error = "EVENT_LIMIT_EXCEEDED", status = "UNSUPPORTED"))
  if (length(result)) {
    labels <- vapply(result, function(event) event$label, character(1L))
    result <- result[!duplicated(labels)]
  }
  list(events = result)
}

.ru_w3_parse <- function(question) {
  # Hard limit prevents expensive parsing and keeps untrusted material bounded.
  if (!is.character(question) || length(question) != 1L ||
      is.na(question) || !nzchar(trimws(question)) ||
      is.na(nchar(question, type = "bytes")) ||
      nchar(question, type = "bytes") > 4096L ||
      !validUTF8(question))
    return(.ru_w3_parsed("INVALID", "QUESTION_INVALID",
                         parser_rule_id = "question_validation_v1"))

  text <- .ru_w3_normalize(question)
  refused <- function(status, reason, family = NA_character_, inputs = list(),
                      outputs = character(), missing = character(),
                      rule = "dice_sum_gate_v1", assumptions = list()) {
    .ru_w3_parsed(status, reason, question, family, inputs, outputs,
                  assumptions, missing, rule)
  }
  if (grepl("<\\s*/?\\s*[[:alpha:]]|\\b(?:eval|parse|system|system2|unlink|source|setwd)\\s*\\(|__import__|\\$\\{|\\bignore\\s+(?:all\\s+)?(?:previous|prior)\\s+instructions\\b|[\x60]",
            text, perl = TRUE))
    return(refused("INVALID", "UNSAFE_QUESTION_CONTENT",
                   rule = "untrusted_content_v1"))

  intent <- character()
  if (grepl("\\bpmf\\b|\\bprobability\\s+(?:mass\\s+function|distribution)\\b|\\bprobability\\s+function\\b",
            text, perl = TRUE)) intent <- c(intent, "pmf")
  if (grepl("\\bcdf\\b|\\bcumulative\\s+(?:distribution|probability)\\b",
            text, perl = TRUE)) intent <- c(intent, "cdf")
  if (grepl("\\bexpected\\s+value\\b|\\bexpectation\\b|\\bmean\\b|\\be\\s*\\(\\s*x\\s*\\)",
            text, perl = TRUE)) intent <- c(intent, "expected_value")
  if (grepl("\\bvariance\\b|\\bvar\\s*\\(\\s*x\\s*\\)",
            text, perl = TRUE)) intent <- c(intent, "variance")

  dice_context <- grepl("\\b(?:dice|die|sided|faced)\\b|(?<![[:alpha:]])[0-9]*d[0-9]+\\b", text,
                        perl = TRUE)
  sum_context <- grepl("\\b(?:sum|total|plus|added|adding)\\b|\\+",
                       text, perl = TRUE)
  inferential <- grepl("\\b(?:t-test|hypothesis|regression|p-value|confidence\\s+interval|anova|chi[- ]?squared)\\b",
                       text, perl = TRUE)
  # Route other named model families before the dice-specific missing-input
  # logic. Recognition alone must not pretend the family is computed.
  other_family <- .ru_w3_other_family(text)
  if (inferential)
    return(refused("UNSUPPORTED", "INFERENTIAL_METHOD_NOT_IN_GUIDED_FAMILY",
                   "inference", outputs = intent, rule = "method_boundary_v1"))
  if (!is.null(other_family)) {
    if (dice_context)
      return(refused("INVALID", "CONFLICTING_STATISTICAL_MODELS",
                     "dice_sum_independent_fair", outputs = intent,
                     rule = "multiple_family_gate_v1"))
    return(refused("UNSUPPORTED",
                   paste0(toupper(other_family), "_FAMILY_UNSUPPORTED"),
                   other_family, outputs = intent,
                   rule = "unsupported_family_registry_v1"))
  }
  if (!dice_context) {
    if (grepl("\\bhistogram\\b|\\bhist\\s*\\(", text, perl = TRUE))
      return(refused("NEEDS_INPUT", "DATA_AND_HISTOGRAM_SPEC_REQUIRED",
                     "histogram", outputs = intent,
                     missing = c("data", "histogram_spec"),
                     rule = "existing_ru_method_route_v1"))
    if (grepl("\\b(?:csv|import\\s+data|missing\\s+values|na\\s+values)\\b",
              text, perl = TRUE))
      return(refused("NEEDS_INPUT", "DATA_SOURCE_REQUIRED",
                     "data_workflow", outputs = intent,
                     missing = "data_source",
                     rule = "existing_ru_method_route_v1"))
    if (identical(trimws(gsub("[[:punct:]\\s]+$", "", text, perl = TRUE)),
                  "pmf") ||
        grepl("^(?:what\\s+is\\s+|define\\s+|explain\\s+|meaning\\s+of\\s+)?(?:a\\s+|the\\s+)?(?:pmf|probability\\s+mass\\s+function)\\??$",
              text, perl = TRUE))
      return(refused("GUIDED_REFERENCE", "CONCEPT_ONLY",
                     "discrete_pmf", outputs = "pmf",
                     rule = "concept_only_v1"))
    if (grepl("^(?:what\\s+is\\s+|define\\s+|explain\\s+)?(?:a\\s+|the\\s+)?cdf\\??$",
              text, perl = TRUE))
      return(refused("GUIDED_REFERENCE", "CONCEPT_ONLY",
                     "discrete_cdf", outputs = "cdf",
                     rule = "concept_only_v1"))
    if (sum_context || length(intent) ||
        grepl("\\bprobability\\b", text, perl = TRUE))
      return(refused("NEEDS_INPUT", "DISTRIBUTION_MODEL_REQUIRED",
                     "unspecified_distribution", outputs = intent,
                     missing = "distribution_model",
                     rule = "unidentified_model_v1"))
    return(refused("UNSUPPORTED", "QUESTION_FAMILY_UNSUPPORTED",
                   rule = "unsupported_family_v1"))
  }

  # Explicit contradictory models always outrank the ordinary fair-dice route.
  negative_fair <- grepl("\\b(?:loaded|biased|unfair|weighted|unequal|non-uniform)\\b|\\bnot\\s+fair\\b|\\bnot\\s+equally\\s+likely\\b|\\bunequal\\s+probabilit(?:y|ies)\\b|\\b(?:probabilities|weights)\\s+(?:are\\s+)?(?:different|unequal)\\b|\\b(?:probabilities|probability|prob|weights?)\\s*(?:of|for|:|=)?\\s*(?:0?\\.[0-9]+|[0-9]+\\s*%)",
                         text, perl = TRUE)
  fair_clean <- gsub("\\bnot\\s+fair\\b", "", text, perl = TRUE)
  positive_fair <- grepl("\\bfair\\b|\\bequiprobable\\b|\\bequally\\s+likely\\b",
                         fair_clean, perl = TRUE)
  negative_independent <- grepl("\\b(?:dependent|correlated)\\b|\\b(?:not|non[- ]?)\\s*independent\\b",
                                 text, perl = TRUE)
  independent_clean <- gsub("\\b(?:not|non[- ]?)\\s*independent\\b", "",
                            text, perl = TRUE)
  positive_independent <- grepl("\\bindependent(?:ly)?\\b",
                                independent_clean, perl = TRUE)
  # Fair and loaded may describe different operands: reject the fair
  # model until the actual distributions are supplied, not as a global lie.
  if (negative_fair && positive_fair)
    negative_fair <- TRUE
  if (negative_independent && positive_independent)
    return(refused("INVALID", "CONTRADICTORY_INDEPENDENCE",
                   "dice_sum_independent_fair", outputs = intent))

  # A stated group of three or more dice is outside this family even
  # when none of its face counts were provided.
  if (grepl("\\b(?:[3-9]|[1-9][0-9]+)\\s+(?:(?:fair|ordinary|independent|standard|identical|random|unknown)\\s+)*(?:dice|die)\\b",
            text, perl = TRUE))
    return(refused("UNSUPPORTED", "ONLY_TWO_DICE_SUPPORTED",
                   "dice_sum_independent_fair", outputs = intent,
                   rule = "dice_inventory_v2"))
  inventory <- .ru_w3_die_literals(text, detailed = TRUE)
  literals <- inventory$literals
  if (inventory$invalid_quantity)
    return(refused("INVALID", "INVALID_DIE_QUANTITY",
                   "dice_sum_independent_fair", outputs = intent,
                   rule = "dice_inventory_v2"))
  if (inventory$aggregate_excess)
    return(refused("UNSUPPORTED", "ONLY_TWO_DICE_SUPPORTED",
                   "dice_sum_independent_fair", outputs = intent,
                   rule = "dice_inventory_v2"))
  if (inventory$ambiguous_quantity)
    return(refused("NEEDS_INPUT", "DIE_QUANTITY_REQUIRED",
                   "dice_sum_independent_fair", outputs = intent,
                   missing = "die_quantities",
                   rule = "dice_inventory_v2"))
  if (length(literals) > 2L ||
      sum(as.double(inventory$quantities)) > 2)
    return(refused("UNSUPPORTED", "ONLY_TWO_DICE_SUPPORTED",
                   "dice_sum_independent_fair", outputs = intent,
                   rule = "dice_inventory_v2"))
  if (inventory$extra_die &&
      (length(literals) >= 2L ||
       sum(as.double(inventory$quantities)) >= 2))
    return(refused("UNSUPPORTED", "ADDITIONAL_DIE_UNSUPPORTED",
                   "dice_sum_independent_fair", outputs = intent,
                   rule = "dice_inventory_v2"))
  # A single known die and an unqualified second die need the second face
  # specification; they do not become a valid two-die calculation.
  if (length(literals) == 1L && length(inventory$quantities) == 1L &&
      identical(inventory$quantities[[1L]], 2L))
    literals <- rep(literals, 2L)
  if (length(literals) < 2L) {
    inputs <- list()
    if (length(literals) == 1L) {
      known <- .ru_w3_int_literal(literals[[1L]], 2, 1000000000)
      if (is.null(known))
        return(refused("INVALID", "INVALID_DIE_FACES",
                       "dice_sum_independent_fair", outputs = intent))
      inputs$die1_faces <- known
    }
    return(refused("NEEDS_INPUT", "DIE_FACE_COUNTS_REQUIRED",
                   "dice_sum_independent_fair", inputs, intent,
                   if (!length(literals)) c("die1_faces", "die2_faces")
                   else "die2_faces", rule = "missing_dice_v1"))
  }
  faces <- lapply(literals, .ru_w3_int_literal, minimum = 2L,
                  maximum = 1000000000)
  if (any(vapply(faces, is.null, logical(1L))))
    return(refused("INVALID", "INVALID_DIE_FACES",
                   "dice_sum_independent_fair", outputs = intent))
  faces <- as.integer(unlist(faces, use.names = FALSE))
  inputs <- list(die1_faces = faces[[1L]], die2_faces = faces[[2L]],
                 events = list())
  if (any(faces > 10000L) ||
      prod(as.double(faces)) > 200000 ||
      sum(as.double(faces)) > 20000)
    return(refused("UNSUPPORTED", "COMPUTATION_CAP_EXCEEDED",
                   "dice_sum_independent_fair", inputs, intent,
                   rule = "finite_enumeration_cap_v1"))
  if (grepl("\\b(?:rm\\s+-rf|sudo|curl\\s+https?://|wget\\s+https?://|delete\\s+files?)\\b",
            text, perl = TRUE))
    return(refused("INVALID", "UNSAFE_QUESTION_CONTENT",
                   rule = "untrusted_content_v1"))
  model_issue <- .ru_w3_model_boundary(text)
  if (!is.null(model_issue))
    return(refused("UNSUPPORTED", model_issue,
                   "dice_sum_independent_fair", inputs, intent,
                   rule = "composite_model_gate_v1"))
  if (grepl("\\b(?:product|difference|subtract|subtracting|quotient|multiply|maximum|minimum)\\b",
            text, perl = TRUE))
    return(refused("UNSUPPORTED", "DICE_OPERATION_UNSUPPORTED",
                   "dice_sum_independent_fair", inputs, intent))
  if (grepl("\\b(?:3|three|4|four|5|five)\\s+(?:ordinary\\s+|fair\\s+)?(?:dice|die)\\b",
            text, perl = TRUE))
    return(refused("UNSUPPORTED", "ONLY_TWO_DICE_SUPPORTED",
                   "dice_sum_independent_fair", inputs, intent))
  assumptions <- list(
    fair = !negative_fair, independent = !negative_independent,
    description = if (!negative_fair && !negative_independent)
      "Assume each die is fair and the two rolls are independent; these are model assumptions, not observed facts."
    else "A fair independent dice model has not been established."
  )
  if (negative_fair)
    return(refused("NEEDS_INPUT", "DIE_PROBABILITIES_REQUIRED",
                   "dice_sum_independent_fair", inputs, intent,
                   c("die1_face_probabilities", "die2_face_probabilities"),
                   "loaded_dice_gate_v1", assumptions))
  if (negative_independent)
    return(refused("NEEDS_INPUT", "JOINT_DISTRIBUTION_REQUIRED",
                   "dice_sum_independent_fair", inputs, intent,
                   "joint_distribution",
                   "dependent_dice_gate_v1", assumptions))
  event_result <- .ru_w3_events(text)
  if (!is.null(event_result$error))
    return(refused(event_result$status, event_result$error,
                   "dice_sum_independent_fair", inputs,
                   c(intent, "events"),
                   if (identical(event_result$error, "EVENT_THRESHOLD_REQUIRED"))
                     "event_threshold" else character(),
                   "event_validation_v1", assumptions))
  inputs$events <- event_result$events
  if (length(inputs$events)) intent <- c(intent, "events")
  intent <- unique(intent)
  intent <- c("pmf", "cdf", "expected_value", "variance", "events")[
    c("pmf", "cdf", "expected_value", "variance", "events") %in% intent]
  if (!length(intent))
    return(refused("NEEDS_INPUT", "REQUESTED_OUTPUT_REQUIRED",
                   "dice_sum_independent_fair", inputs, intent,
                   "requested_outputs", "output_selection_v1", assumptions))
  if (!sum_context)
    return(refused("NEEDS_INPUT", "SUM_OPERATION_REQUIRED",
                   "dice_sum_independent_fair", inputs, intent,
                   "sum_operation", "dice_operation_v1", assumptions))
  refused("SOLVED", "DICE_SUM_PARSED", "dice_sum_independent_fair",
          inputs, intent, rule = "two_fair_independent_dice_v1",
          assumptions = assumptions)
}