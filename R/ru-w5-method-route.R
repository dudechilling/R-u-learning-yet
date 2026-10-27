# Fixed private W5 route. Never evaluates a question or inspects user data.
.ru_w5_method_ids <- function() {
  c("import_csv","inspect_columns","filter_rows","group_means",
    "missing_values","mean_median","sample_sd","five_number",
    "percentile_cutoff","relative_frequency","categorical_mode","z_score",
    "histogram","bar_chart","boxplot","grouped_boxplot","scatterplot",
    "zero_correlation","normal_shaded_area","line_chart","moving_average",
    "autocorrelation","stationarity","event_probability",
    "conditional_probability","probability_union","binomial_exact",
    "binomial_at_least","normal_left_tail","normal_right_tail",
    "normal_percentile","discrete_expectation","sample_random",
    "sampling_distribution","standard_error","mean_confidence_interval",
    "one_sample_t","two_sample_t","paired_t","correlation_test",
    "spearman_correlation","linear_regression","predict_regression",
    "interpolation","categorical_independence","proportion_interval")
}

.ru_w5_method_route <- function(query) {
  if (!is.character(query) || length(query)!=1L || is.na(query) ||
      nchar(query,type="bytes")>4096L || !nzchar(trimws(query)))
    return(NULL)
  q <- tolower(trimws(query))
  ids <- .ru_w5_method_ids()
  # Explicit method IDs take precedence. Multiple distinct IDs mean that
  # a single-method guide cannot truthfully satisfy the entire request.
  found <- ids[vapply(ids,function(id)
    grepl(paste0("(?<![[:alnum:]_])",id,"(?![[:alnum:]_])"),
          q,perl=TRUE),logical(1))]
  if (!length(found)) {
    # The fixed bank's actual walkthrough questions are the only accepted
    # natural-language aliases. Never fuzzy-match incompatible operations.
    bank <- .ru_db("problems.csv")
    bank <- bank[bank$id %in% ids,,drop=FALSE]
    if (nrow(bank) && "question" %in% names(bank)) {
      normalized <- function(x) gsub("[^[:alnum:]]+"," ",
                                    tolower(trimws(x)),perl=TRUE)
      hits <- bank$id[normalized(bank$question)==normalized(query)]
      found <- unique(hits)
    }
  }
  if (length(found)!=1L) return(NULL)
  id <- found[[1L]]
  args <- .ru_allowed_arguments(id)
  data_args <- intersect(args,c("data","file"))
  column_args <- intersect(args,c("x","y","group","time","weight"))
  parameter_args <- setdiff(args,c(data_args,column_args,
    "show_plot","title","col","xlab","ylab","units"))
  # A method route is guidance, not a computed statistical result.
  list(method_id=id,status="NEEDS_INPUT",
       required_data=data_args,required_columns=column_args,
       accepted_parameters=parameter_args,
       executed=FALSE,
       code_preview=paste0("# Supply required inputs explicitly before execution.\n",
                           "ru_apply('",id,"')"))
}

.ru_w5_method_guide <- function(query) {
  route <- .ru_w5_method_route(query)
  if (is.null(route)) return(NULL)
  teach <- get0(".ru_w5_method_teach",mode="function",inherits=TRUE)
  if (is.null(teach)) return(NULL)
  guide <- tryCatch(teach(route$method_id,question=query),
                    error=function(e) NULL)
  if (!is.list(guide) ||
      !identical(guide$schema_version,"ru.w5.method-guide.v1") ||
      !identical(guide$method_id,route$method_id) ||
      !identical(guide$executed,FALSE) ||
      !guide$status %in% c("GUIDED_REFERENCE","NEEDS_INPUT","UNSUPPORTED"))
    return(NULL)
  guide
}
