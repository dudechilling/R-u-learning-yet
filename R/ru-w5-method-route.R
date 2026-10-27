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

# A single bounded method-resolution policy for both public discovery and
# guidance. The existing compatibility-ranked search remains the authority
# for ordinary references; only unambiguous, positively identified method
# operations can refine a walkthrough choice.
.ru_w5_request_operations <- function(question) {
  q <- tolower(trimws(question))
  # "A instead of B" and "A, not B" request A, not both operations.
  q <- sub("\\binstead\\s+of\\b.*$", "", q, perl=TRUE)
  q <- sub("\\bnot\\s+(?:a\\s+|an\\s+|the\\s+)?(?:bar\\s+charts?|histograms?|box\\s*plots?|scatter\\s*plots?)\\b.*$",
           "", q, perl=TRUE)
  has <- function(pattern) grepl(pattern,q,perl=TRUE)
  ops <- character()
  add <- function(id,pattern) if (has(pattern)) ops <<- c(ops,id)
  box <- has("\\bbox\\s*plots?\\b")
  grouped <- has("\\b(grouped|by\\s+(?:a\\s+)?(?:group|category|site|region)|per\\s+group|across\\s+(?:groups|categories)|separated\\s+by\\s+(?:group|category))\\b")
  if (box) ops <- c(ops,if (grouped) "grouped_boxplot" else "boxplot")
  add("histogram","\\bhistograms?\\b|\\bhistgram\\b")
  if (has("\\bdensity\\s+(?:curve|line|overlay)\\b|\\boverlay\\s+(?:a\\s+)?density\\b"))
    ops <- c(ops,"density_overlay")
  add("bar_chart","\\bbar\\s+(?:charts?|graphs?|plots?)\\b|\\bbarplots?\\b")
  add("scatterplot","\\bscatter\\s*(?:plots?|diagrams?)\\b")
  add("group_means","\\b(grouped?\\s+means?|means?\\s+(?:by|for|per)\\s+(?:each\\s+)?(?:group|category|site|region)|averages?\\s+(?:by|for)\\s+(?:each\\s+)?(?:group|category|site))\\b")
  mean_median <- has("\\bmean\\s+(?:and|&)\\s+median\\b|\\bmedian\\s+(?:and|&)\\s+mean\\b")
  if (mean_median) ops <- c(ops,"mean_median")
  add("moving_average","\\bmoving\\s+averages?\\b|\\brolling\\s+means?\\b|\\brunning\\s+means?\\b")
  add("mean_confidence_interval","\\b(confidence\\s+interval|\\bci\\b)\\b.*\\bmean\\b|\\bmean\\b.*\\bconfidence\\s+interval\\b")
  add("proportion_interval","\\b(confidence\\s+interval|\\bci\\b)\\b.*\\bproportions?\\b|\\bproportions?\\b.*\\bconfidence\\s+interval\\b")
  if (has("\\bconfidence\\s+interval\\b") &&
      !any(c("mean_confidence_interval","proportion_interval") %in% ops))
    ops <- c(ops,"generic_confidence_interval")
  # Distribution mean/mu is a model parameter, not an extra requested
  # sample mean when computing a probability from known parameters.
  model_parameter_mean <- has("\\b(normal|gaussian|poisson|binomial|uniform)\\b") &&
    has("\\b(probability|between|tail|cdf|percentile|p\\s*\\()") &&
    !has("\\b(compute|calculate|find|report)\\s+(?:the\\s+)?mean\\b")
  if (!mean_median && !("group_means" %in% ops) &&
      !model_parameter_mean &&
      !has("\\b(moving\\s+average|rolling\\s+mean|running\\s+mean|confidence\\s+interval|standard\\s+error)\\b") &&
      has("\\b(mean|average)\\b") &&
      !has("^what\\s+does\\b.*\\bmean\\b")) ops <- c(ops,"mean_median")
  add("sample_sd","\\b(sample\\s+sd|standard\\s+deviation|sample\\s+variance)\\b")
  # Separate requested summaries with no dedicated ru_apply method are
  # conflict signals, not invitations to fabricate a supported method.
  if (has("\\bvariance\\b") && !has("\\bsample\\s+variance\\b"))
    ops <- c(ops,"variance")
  if (has("\\binterquartile\\s+range\\b|\\biqr\\b")) {
    # Already represented by five_number below.
  } else if (has("\\brange\\b") && has("\\bcompute|calculate|find\\b"))
    ops <- c(ops,"range")
  if (has("\\bskewness\\b")) ops <- c(ops,"skewness")
  if (has("\\bmode\\b") && !has("\\bmodel\\b"))
    ops <- c(ops,"categorical_mode")
  add("standard_error","\\bstandard\\s+error\\b")
  add("five_number","\\b(five[- ]number|quartiles?|interquartile\\s+range|\\biqr\\b)\\b")
  add("relative_frequency","\\brelative\\s+frequenc(?:y|ies)\\b|\\bfrequency\\s+table\\b")
  add("missing_values","\\bmissing\\s+(?:values?|observations?|data)\\b|\\bcount\\s+na\\b")
  add("inspect_columns","\\binspect\\s+(?:columns?|variables?)\\b")
  add("filter_rows","\\bfilter\\s+rows?\\b|\\bsubset\\s+rows?\\b")
  add("import_csv","\\bimport\\s+(?:a\\s+)?csv\\b|\\bread\\s+(?:a\\s+)?csv\\b")
  add("line_chart","\\bline\\s+(?:charts?|plots?)\\b|\\btime\\s+(?:series\\s+)?plots?\\b")
  add("autocorrelation","\\bautocorrelations?\\b|\\bacf\\b")
  add("stationarity","\\bstationarit(?:y|ies)\\b|\\bstationary\\b")
  add("spearman_correlation","\\bspearman\\b|\\brank\\s+correlation\\b")
  add("correlation_test","\\bcorrelation\\s+tests?\\b|\\btest\\s+(?:the\\s+)?(?:pearson\\s+)?correlation\\b")
  # A coefficient alone is not a significance test or a scatterplot.
  if (has("\\bcorrelation\\b") &&
      !has("\\b(spearman|rank\\s+correlation|correlation\\s+test|test\\s+(?:the\\s+)?correlation)\\b"))
    ops <- c(ops,"correlation_coefficient")
  prediction <- has("\\b(predict|prediction|forecast)\\b") &&
    has("\\b(regression|linear\\s+model|fitted\\s+line)\\b")
  if (prediction) ops <- c(ops,"predict_regression")
  else add("linear_regression","\\b(regression|ols|linear\\s+model)\\b")
  add("interpolation","\\binterpolat(?:e|ion|ing)\\b")
  add("paired_t","\\bpaired\\b.*\\bt[- ]?tests?\\b|\\bt[- ]?tests?\\b.*\\bpaired\\b")
  add("two_sample_t","\\b(two|2)\\s+(?:independent\\s+)?(?:sample|group)\\b.*\\bt[- ]?tests?\\b|\\bindependent\\b.*\\bt[- ]?tests?\\b")
  add("one_sample_t","\\bone[- ]sample\\b.*\\bt[- ]?tests?\\b")
  if (has("\\bt[- ]?tests?\\b") &&
      !any(c("one_sample_t","two_sample_t","paired_t") %in% ops))
    ops <- c(ops,"generic_t_test")
  if (has("\\banova\\b")) ops <- c(ops,"anova")
  add("conditional_probability","\\bconditional\\s+probability\\b|\\bprobability\\b.*\\bgiven\\b")
  add("probability_union","\\bunion\\s+probability\\b|\\bprobability\\b.*\\b(?:a\\s+or\\s+b|either\\s+event)\\b")
  add("discrete_expectation","\\bexpected\\s+value\\b.*\\bdiscrete\\b|\\bdiscrete\\b.*\\bexpected\\s+value\\b")
  add("sampling_distribution","\\bsampling\\s+distributions?\\b")
  add("sample_random","\\brandom\\s+sample\\b")
  add("categorical_independence","\\bcategorical\\s+independence\\b|\\bchi[- ]square\\s+test\\b")
  add("binomial_exact","\\bbinomial\\b.*\\b(exactly|exact)\\b|\\bexactly\\b.*\\b(successes?|binomial)\\b")
  add("binomial_at_least","\\bbinomial\\b.*\\b(at\\s+least|more\\s+than)\\b|\\bat\\s+least\\b.*\\bsuccesses?\\b")
  add("normal_left_tail","\\bnormal\\b.*\\b(left\\s+tail|less\\s+than|below)\\b")
  add("normal_right_tail","\\bnormal\\b.*\\b(right\\s+tail|greater\\s+than|above)\\b")
  add("normal_percentile","\\bnormal\\b.*\\b(percentile|quantile)\\b")
  add("percentile_cutoff","\\bpercentile\\s+cutoff\\b")
  # The existing sample_sd contract reports range, variance and SD together.
  if ("sample_sd" %in% ops && all(c("range","variance") %in% ops))
    ops <- setdiff(ops,c("range","variance"))
  unique(ops)
}

.ru_w5_method_resolve <- function(query,n=10L,type=NULL) {
  if (!is.character(query) || length(query)!=1L || is.na(query) ||
      !nzchar(trimws(query)) || nchar(query,type="bytes")>4096L)
    return(list(status="NO_MATCH",method_id=NULL,
                hits=.ru_catalog()[FALSE,,drop=FALSE],reason_code=NULL))
  if (!is.null(type) &&
      (length(type)!=1L || is.na(type) ||
       !(type %in% c("concept","function","walkthrough"))))
    stop("type must be 'concept', 'function' or 'walkthrough'.",call.=FALSE)
  ids <- .ru_w5_method_ids()
  q <- tolower(trimws(query))
  canonical <- trimws(sub("[?.!,:;]+$", "", q))
  # Exact canonical method IDs need no fuzzy search or question inspection.
  if (canonical %in% ids && (is.null(type) || identical(type,"walkthrough"))) {
    exact <- .ru_catalog()
    exact <- exact[exact$id==canonical & exact$type=="walkthrough",,drop=FALSE]
    if (nrow(exact))
      return(list(status="METHOD",method_id=canonical,
                  hits=exact[1L,,drop=FALSE],reason_code=NULL))
  }
  # One search pass is the canonical compatibility/ranking authority.
  ranked <- .ru_search_results(query,n=50L,type=type)
  count <- if(length(n)!=1L || is.na(n) || !is.finite(n))
    10L else max(1L,min(as.integer(n),50L))
  hits <- utils::head(ranked,count)
  attr(hits,"corrected_terms") <- attr(ranked,"corrected_terms")
  result <- function(status,id=NULL,rows=hits,reason=NULL) {
    list(status=status,method_id=id,hits=rows,reason_code=reason)
  }
  if (canonical %in% ids) return(result("LEGACY_REFERENCE"))
  # Multiple explicitly named canonical IDs cannot be satisfied by one guide.
  named <- ids[vapply(ids,function(id)
    grepl(paste0("(?<![[:alnum:]_])",id,"(?![[:alnum:]_])"),
          q,perl=TRUE),logical(1))]
  ops <- .ru_w5_request_operations(q)
  if (grepl("\\bpearson\\b",q,perl=TRUE) &&
      grepl("\\bspearman\\b",q,perl=TRUE))
    return(result("AMBIGUOUS",rows=hits[FALSE,,drop=FALSE],
                  reason="MULTIPLE_CORRELATION_METHODS"))
  # Data roles and incompatible designs cannot be repaired by choosing
  # the nearest lexical method.
  role_conflict <-
    (grepl("\\bhistograms?\\b",q,perl=TRUE) &&
       grepl("\\b(of|for)\\s+(?:nominal|categorical)(?:\\s+(?:nominal|categorical))?\\s+(?:labels?|names?|categories)\\b",q,perl=TRUE)) ||
    (grepl("\\bbox\\s*plots?\\b",q,perl=TRUE) &&
       grepl("\\b(?:of|for)\\s+(?:nominal|categorical)\\s+(?:labels?|names?)\\b",q,perl=TRUE)) ||
    (grepl("\\bmode\\b",q,perl=TRUE) &&
       grepl("\\b(numeric|continuous|quantitative)\\b",q,perl=TRUE) &&
       !grepl("\\b(categorical|category|nominal|factor)\\b",q,perl=TRUE)) ||
    (grepl("\\bpearson\\b",q,perl=TRUE) &&
       grepl("\\brank\\s+correlation\\b",q,perl=TRUE)) ||
    (grepl("\\bpaired\\b",q,perl=TRUE) &&
       grepl("\\bindependent\\b",q,perl=TRUE) &&
       grepl("\\bt[- ]?tests?\\b",q,perl=TRUE))
  if (role_conflict)
    return(result("UNSUPPORTED",rows=hits[FALSE,,drop=FALSE],
                  reason="INCOMPATIBLE_VARIABLE_ROLE_OR_DESIGN"))
  if (length(unique(named))>1L) {
    return(result("AMBIGUOUS",rows=hits[FALSE,,drop=FALSE],
                  reason="MULTIPLE_METHOD_IDS"))
  }
  # Explicitly named unsupported operations are not synonyms for a
  # statistically different supported method or a legacy reference.
  if (grepl("\\b(kriging|moran'?s\\s+i|geodesic\\s+distance|prediction\\s+interval|causal\\s+effect)\\b",
            q,perl=TRUE))
    return(result("UNSUPPORTED",rows=hits[FALSE,,drop=FALSE],
                  reason="UNSUPPORTED_OPERATION"))
  # Two distinct requested outputs are not a single-method plan. This is
  # independent of whether a lexical search would rank one of them first.
  conceptual_sd_se <- grepl("^what\\s+is\\s+the\\s+difference\\s+between\\b",
                            q,perl=TRUE) &&
    all(c("sample_sd","standard_error") %in% ops)
  if (length(ops)>1L && !conceptual_sd_se &&
      (grepl("\\b(and|plus|also|as\\s+well\\s+as|versus|vs\\.?|then|with|followed\\s+by)\\b",
             q,perl=TRUE) ||
       grepl("\\b(calculate|compute|draw|plot|make|create|fit|estimate|predict|test|generate|run|show)\\b",
             q,perl=TRUE)))
    return(result("AMBIGUOUS",rows=hits[FALSE,,drop=FALSE],
                  reason="MULTIPLE_REQUESTED_OPERATIONS"))
  # The historical search owns compatibility. A positive single-method cue
  # may refine ranking only when the legacy compatible results contain that
  # very method, never by inventing a method or bypassing a closed gate.
  action <- grepl("\\b(calculate|compute|draw|plot|make|create|fit|estimate|predict|test|generate|run|show|compare|import|inspect|filter|summarize|find)\\b",
                  q,perl=TRUE)
  # "Standard deviation" alone does not specify a sample/population
  # convention. Keep the original variance/SD concept reference unless
  # the question explicitly requests the sample SD method.
  if (length(ops)==1L && identical(ops[[1L]],"sample_sd") &&
      !grepl("\\bsample\\b",q,perl=TRUE))
    action <- FALSE
  if (length(ops)==1L && identical(ops[[1L]],"correlation_coefficient") &&
      action)
    return(result("UNSUPPORTED",rows=hits[FALSE,,drop=FALSE],
                  reason="COEFFICIENT_ONLY_NOT_VERIFIED"))
  if (length(ops)==1L && action &&
      (is.null(type) || identical(type,"walkthrough"))) {
    candidate <- ops[[1L]]
    candidates <- ranked[ranked$type=="walkthrough",,drop=FALSE]
    if (candidate %in% candidates$id) {
      choice <- candidates[which(candidates$id==candidate)[1L],,drop=FALSE]
      return(result("METHOD",candidate,choice))
    }
    # Never recommend a different operation when the named operation
    # cannot be validated against the compatibility-ranked walkthroughs.
    if (nrow(hits) && hits$id[[1L]] %in% ids &&
        !identical(hits$id[[1L]],candidate))
      return(result("UNSUPPORTED",rows=hits[FALSE,,drop=FALSE],
                    reason="METHOD_INCOMPATIBLE"))
  }
  if (nrow(hits) && hits$id[[1L]] %in% ids)
    return(result("METHOD",hits$id[[1L]]))
  result(if(nrow(hits)) "LEGACY_REFERENCE" else "NO_MATCH")
}

.ru_w5_method_route <- function(query) {
  resolved <- .ru_w5_method_resolve(query,n=1L)
  if (!identical(resolved$status,"METHOD") ||
      is.null(resolved$method_id)) return(NULL)
  id <- resolved$method_id
  args <- .ru_allowed_arguments(id)
  data_args <- intersect(args,c("data","file"))
  column_args <- intersect(args,c("x","y","group","time","weight"))
  parameter_args <- setdiff(args,c(data_args,column_args,
    "show_plot","title","col","xlab","ylab","units"))
  list(method_id=id,status="NEEDS_INPUT",
       capability_status=if(id %in% c("inspect_columns","missing_values",
                                      "discrete_expectation"))
         "QUALIFIED" else "LIMITED",
       required_data=data_args,required_columns=column_args,
       accepted_parameters=parameter_args,
       executed=FALSE,
       code_preview=paste0("# Supply required inputs explicitly before execution.\\n",
                           "ru_apply('",id,"')"))
}

.ru_w5_method_guide <- function(query,method_id=NULL) {
  if (is.null(method_id)) {
    route <- .ru_w5_method_route(query)
    if (is.null(route)) return(NULL)
    method_id <- route$method_id
  }
  if (!is.character(method_id) || length(method_id)!=1L ||
      !method_id %in% .ru_w5_method_ids()) return(NULL)
  teach <- get0(".ru_w5_method_teach",mode="function",inherits=TRUE)
  if (is.null(teach)) return(NULL)
  guide <- tryCatch(teach(method_id,question=query),
                    error=function(e) NULL)
  if (!is.list(guide) ||
      !identical(guide$schema_version,"ru.w5.method-guide.v1") ||
      !identical(guide$method_id,method_id) ||
      !identical(guide$executed,FALSE) ||
      !guide$status %in% c("GUIDED_REFERENCE","NEEDS_INPUT","UNSUPPORTED"))
    return(NULL)
  guide
}
