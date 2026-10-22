# Search installed local references and worked questions; no network or LLM.
.ru_db <- function(name) {
  dir <- system.file("extdata",package="rulearn")
  prefix <- sub("[.]csv$","",name)
  files <- list.files(dir,pattern=paste0("^",prefix,"-[a-z]+[.]csv$"),
                      full.names=TRUE)
  if (!length(files)) stop("Problem index unavailable.",call.=FALSE)
  do.call(rbind,lapply(files,function(path)
    utils::read.csv(path,stringsAsFactors=FALSE,na.strings=character(),
             check.names=FALSE,fileEncoding="UTF-8")))
}
.ru_words <- function(x) {
  s <- tolower(gsub("p[- ]?values?", "pvalue", x, perl=TRUE))
  # Apostrophe clitics are not independent search terms: "car's" must
  # not supply an "s" that matches statistical notation such as "r_s".
  # Strip a one-letter apostrophe suffix before punctuation splitting,
  # including a typographic apostrophe. Standalone r, s, t, x and y stay.
  s <- gsub("(?<=[[:alnum:]])['\u2019][[:alpha:]]\\b","",s,perl=TRUE)
  s <- gsub("[^[:alnum:]]+"," ",s)
  t <- strsplit(s,"[[:space:]]+")[[1]]
  unique(setdiff(t[nzchar(t)],c(
    "how","do","i","the","a","an","to","of","in","is","can","my",
    "with","what","are","does","on","by","and","from","using","for",
    "define","definition","does","work","works","function","between",
    "make","create","calculate","find","show","draw","have",
    "different","two","me","please","tell","about","as",
    "this","that","something","anything","library","not","cover",
    "if","whether","when","should","use","describe",
    # Generic question scaffolding cannot justify a statistical hit alone.
    "whether","causes","why","change","compare")))
}

# P0-A: constrain statistical methods *before* lexical ranking.
# NULL means ordinary existing lookup; character(0) means an unsupported,
# conflicting or underspecified method. Existing lesson IDs are used as-is.
# Do not substitute a nearby model, operation or statistical task.
.ru_method_compatible_ids <- function(question) {
  q <- tolower(trimws(question))
  q <- gsub("\u2264", "<=", q, fixed=TRUE)
  q <- gsub("\u2265", ">=", q, fixed=TRUE)
  q <- gsub("\u03c3", "sigma", q, fixed=TRUE)
  has <- function(pattern) grepl(pattern, q, perl=TRUE)
  product <- .ru_product_compatible_ids(q)
  if(!is.null(product)) return(product)

  poisson <- has("\\bpoiss+on\\b|\\b[dpqr]pois\\b") ||
    has("\\bexpected arrivals?\\b|\\barrival rate\\b")
  binomial <- has("\\bbinomial\\b|\\b[dpqr]binom\\b") ||
    (has("\\b(success(es)?|yes/no|success/failure)\\b") &&
     has("\\b(independent|fixed|repeated|\\d+)\\b.*\\btrials?\\b|\\btrials?\\b.*\\b(independent|fixed|\\d+)\\b"))
  uniform <- has("\\buniform\\b|\\b[dpqr]unif\\b")
  normal <- has("\\bnormal\\b|\\b[dpqr]norm\\b")
  pmf <- has("\\bpmf\\b|\\bprobability mass function\\b")
  cdf <- has("\\bcdf\\b|\\bcumulative\\b|\\bcummulative\\b|\\baccumulat\\w*\\b|\\bf\\([xy]\\)")
  exact <- has("\\b(exactly|precisely)\\b|\\b[dp]binom\\b.*\\bexact\\b")
  inclusive_upper <- has("\\b(at least|no fewer than|not less than)\\b|>=")
  strict_upper <- has("\\b((?<!no )more than|exceeds?|over|strictly greater|greater than)\\b|(?<![<>=])>(?![=])")
  lower_tail <- has("\\b(at most|no more than|less than|below|under)\\b|<=|(?<![<>=])<(?![=>])")
  between <- has("\\bbetween\\b|\\bfrom\\b.+\\bto\\b|\\binterval probability\\b|\\bwithin\\b.+\\band\\b") ||
    has("\\bp\\s*\\([^)]*<[^)]*<[^)]*\\)")
  test <- has("\\b(hypothes(?:is|es)|test(?:ing)?|significance|p.value|null|h0|reject)\\b") &&
    !has("\\bnot testing\\b|\\brather than testing\\b")
  ci <- has("\\b(confidence interval|\\bci\\b|interval estimate|estimating a percentage|estimate a population proportion)\\b")
  # prop.test() can compute an interval too; its function name alone
  # is not evidence that the student requested a hypothesis test.
  if(ci && has("\\bprop[.]test\\b") &&
     !has("\\b(hypothesis|null|reject|significance|differs?)\\b"))
    test <- FALSE
  proportion <- has("\\b(proportion|proprotion|proportion[s]?|percentage|percentages)\\b")
  variance <- has("\\bvariance\\b|\\bpopulation sigma squared\\b")
  sided <- has("\\b(one|two)[ -]?sided\\b|\\b(one|two)[ -]?tailed\\b|\\b(increase|decrease)\\b.*\\bhypothes")
  # Population sigma is never inferred from the sample SD.
  known_sigma <- has(paste0(
    "\\b(known|given|provided|specified)\\s+(population\\s+)?(sigma|sd|standard deviation)\\b|",
    "\\b(population\\s+)?(sigma|sd|standard deviation)\\s+(is\\s+)?(known|given|provided)\\b|",
    "\\b(known|given|provided)\\s+population\\s+variance\\b|",
    "\\bpopulation\\s+variance\\s+(is\\s+)?known\\b"))
  unknown_sigma <- has(paste0(
    "\\b(unknown|estimated|unavailable|not known)\\s+(population\\s+)?(sigma|sd|standard deviation)\\b|",
    "\\b(population\\s+)?(sigma|sd|standard deviation)\\s+(is\\s+)?(unknown|estimated|unavailable|not known)\\b|",
    "\\bsample\\s+(sd|standard deviation|s)\\b"))
  sigma_conflict <- (known_sigma && unknown_sigma) ||
    (has("\\bknown\\b") && has("\\bunknown\\b") &&
     has("\\b(sigma|sd|standard deviation|population variance)\\b"))
  mean_target <- has("\\b(mean|average|mu|xbar|x.bar)\\b")
  ci <- ci || has("\\bconfidence\\s+(limits|bounds)\\b") ||
    has("\\b(interval for (a |the )?(population )?mean|mean interval)\\b")
  ci_selection <- has(paste0(
    "\\b(z|t)\\s*(vs[.]?|versus|or)\\s*(z|t)\\b|",
    "\\b(choose|select|decide|which|what)\\b.*\\b(ci|confidence interval)\\b.*\\b(method|approach|procedure|type)\\b|",
    "\\b(ci|confidence interval)\\b.*\\b(choose|select|which)\\b.*\\b(method|approach|procedure|type)\\b"))
  explicit_t <- has("\\bt\\s+(confidence\\s+)?interval\\b|\\bstudent[']?s\\s+t\\s+(confidence\\s+)?interval\\b")
  two_design <- has(paste0(
    "\\b(two|2)\\s+(independent\\s+)?(groups|samples|populations)\\b|",
    "\\b(groups|samples|populations)\\s+(are\\s+)?independent\\b|",
    "\\b(paired|matched|before[ -]?after|clustered|clustering|repeated measures?)\\b"))
  model_count <- sum(c(poisson, binomial, uniform, normal))

  # Generic non-statistical repair/prevention tasks must abstain. This is
  # an intent/domain check, not a rule for a particular acceptance phrase.
  if(has("\\b(stop|prevent|repair|fix|clean|treat|remove|replace)\\b") &&
     !has(paste0("\\b(statistic|statistics|data|sample|population|mean|variance|",
                 "probability|distribution|normal|uniform|poisson|binomial|",
                 "confidence|interval|\\bci\\b|hypothesis|outlier|missing|",
                 "code|errors?|objects?|columns?|regression|correlation|",
                 "programming|rstudio|rank(ed)?|ordinal|measurement|opinion|scale|category|\\br\\b)\\b")))
    return(character())
  # Cross-model selection is a question requiring comparative guidance,
  # not permission to return one of the mutually named calculations.
  if(model_count > 1L) return(character())
  if(has("\\b[dpqr]unif\\b") && has("\\b(correlation|regression|covariance)\\b"))
    return(character())
  if(has("\\bvar[.]test\\b|\\b[dpqr]chisq\\b")) return(character())
  if(has("\\bbinom[.]test\\b") && test && !ci) return(character())
  if(has("\\bchisq[.]test\\b") && variance) return(character())
  if(has("\\bchisq[.]test\\b|\\bchi[ -]?squared?\\b") &&
     has("\\b(test|association|independence|categorical|contingency)\\b"))
    return(character())
  if(variance && test && has("\\b(population|chi[ -]?square|variance)\\b"))
    return(character()) # No validated one-population variance test page.
  if(has("\\b(wiring|electrical|kitchen outlet|bicycle tire)\\b") &&
     !has("\\b(statistic|statistics|data|probability|regression|correlation|sampling)\\b"))
    return(character())
  if(has("\\bwilcox\\b|\\bwilcoxon\\b|\\brank.based\\b.*\\b(test|method|two.sample)\\b"))
    return(character()) # No validated rank-test lesson.
  if(has("\\bcategorical\\b.*\\b(association|independence)\\b|\\b(association|independence)\\b.*\\bcategorical\\b") &&
     test) return(character()) # Categorical chi-square not yet a released page.
  # A computed hypothesis-test p-value is not a definition page.
  if(test && has("\\b(p.value|pvalue)\\b") &&
     has("\\b(calculate|compute|find|obtain|perform|run)\\b") &&
     has("\\b(population|mean|proportion|variance|one.sample)\\b"))
    return(character())
  if(has("\\b(p.value|pvalue)\\b") &&
     has("\\bmean|meaning\\b") &&
     !has("\\b(if|when|after|given|reject|null|h0)\\b"))
    return("hypothesis_tests_pvalues")
  if(has("\\b(p.value|pvalue)\\b") &&
     has("\\b(mean|meaning|interpret|reject|null|h0)\\b"))
    return("p_value")
  if(has("\\bpearson\\b") && has("\\bcorrelation\\b") &&
     !has("\\b(zero|nonlinear|u[ -]?shaped|curved|hide)\\b"))
    return("pearson")
  if(has("\\binterpolation\\b|\\binterpolate\\b"))
    return("interpolation")
  if(has("\\bplot\\b.+\\bagainst\\b") &&
     !has("\\b(over time|time series|histogram|bar chart)\\b"))
    return("scatterplot")
  if(has("\\bestimat\\w*\\b.+\\bbetween\\b.+\\bsampled\\b.+\\bpositions?\\b"))
    return(character()) # Unsure how to interpolate; no guessed method.
  # A theorem about averages is not a normal event probability.
  if(has("\\bcentral\\s+limit\\s+theorem\\b|\\bclt\\b") ||
     (has("\\b(sample means?|sample averages?)\\b") &&
      has("\\b(approximately normal|approximate normal|become normal|normal approximation|bell[ -]?shaped|converge)\\b")))
    return("central_limit_theorem")
  if(has("\\bstandard error\\b") &&
     has("\\b(sd|standard deviation)\\b") &&
     has("\\b(sample mean|individual observations?|individual measurements?)\\b"))
    return("standard_error")
  # P2-A1: commit to a mean interval only after design and sigma checks.
  if(ci || ci_selection) {
    if(has("\\bt[.]test\\b") &&
       !has("\\b(p[ -]?value|h0|null|reject|hypothesis|significance)\\b"))
      test <- FALSE
    if(test || two_design || sigma_conflict ||
       (proportion && mean_target) || has("\\bone[ -]?(sided|tailed)\\b"))
      return(character())
    if(proportion) return("proportion_interval") # Verified compact Wilson score interval.
    interpretation <- has("\\b(interpret|interpretation|meaning|coverage|confuse|difference|explain)\\b") &&
      !has("\\b(calculate|compute|construct|build|estimate|find|bounds?|margin)\\b")
    if(!mean_target) {
      if(ci_selection) return("ci_method_selection")
      if(interpretation) return("confidence_intervals")
      return(character())
    }
    if(ci_selection && !known_sigma && !unknown_sigma)
      return("ci_method_selection")
    if(known_sigma) return("mean_ci_z")
    if(unknown_sigma || explicit_t) return("mean_confidence_interval")
    if(interpretation) return("confidence_intervals")
    return(character()) # No route from sample size alone.
  }
  if(known_sigma && mean_target && !ci && !test &&
     has("\\b(estimate|estimation|infer|inference)\\b"))
    return(character()) # Parameter-estimation task unspecified.
  if(variance && !test && has("\\bdescriptive\\b|\\bcompute\\b"))
    return("variance")
  if(test && has("\\b(before.after|matched|paired)\\b") &&
     has("\\bt[.]test\\b|\\bt test\\b")) {
    if(has("^\\s*(can i use|when is|when should)\\b"))
      return("independent_paired") # Design question, not a t-test calculation.
    return("paired_t")
  }
  # An eligible paired-test *design* question is not CI selection.
  if(test && !ci && has("\\bpaired\\b") &&
     has("\\bt[ -]?test\\b") &&
     has("\\b(can|when|appropriate|should|suitable)\\b"))
    return("independent_paired")
  if(has("\\bindependent\\b") && has("\\b(two|2)\\b.*\\b(samples?|groups?)\\b") &&
     has("\\bcompare|mean|t.test|procedure\\b")) return("two_sample_t")
  if(proportion && test && ci) return(character())
  if(proportion && test) return(character()) # Test != interval.
  if(sided) return(character()) # No validated direction-selection guide.

  # P1-A: only verified discrete model/operation references are eligible.
  # Method compatibility is resolved before lexical ranking.
  # P1-B: a continuous uniform cumulative question uses punif.
  # A two-bound event requires a CDF difference; other uniform functions
  # and inference tasks are not substitutes for probability calculations.
  if(uniform) {
    if(test || ci || pmf || has("\\b(dunif|qunif|runif)\\b"))
      return(character())
    if(between || has("\\b(interval|inside (the |an? )?range)\\b"))
      return("uniform_interval")
    if(cdf || has("\\bpunif\\b|\\bf\\s*\\(") || lower_tail ||
       strict_upper || inclusive_upper || has("\\bup to\\b"))
      return("uniform_cdf")
    return(character())
  }
  if(poisson) {
    if(test || between || (pmf && cdf)) return(character())
    # Comparing named distributions/functions is not an exact calculation.
    if(has("\\b(dpois|ppois)\\b.*\\b(dbinom|pbinom)\\b|\\b(dbinom|pbinom)\\b.*\\b(dpois|ppois)\\b"))
      return(character())
    # "no more than" is a lower-tail phrase, not strictly more than.
    if(has("\\bno more than\\b")) strict_upper <- FALSE
    if(inclusive_upper && strict_upper) return(character())
    if(inclusive_upper || strict_upper || has("\\bupper[ -]?tail\\b"))
      return("poisson_upper_tail")
    if(lower_tail || cdf || has("\\bppois\\b|\\bat most\\b|\\bup to\\b"))
      return("poisson_cdf")
    if(exact || has("\\bdpois\\b|\\bexact\\b|\\bpmf\\b"))
      return("poisson_exact")
    return(character())
  }
  # Without specified mass or fair outcome law, a PMF cannot be built.
  if(has("\\birregular dice\\b|\\barbitrary categorical score\\b"))
    return(character())
  discrete <- has("\\bdiscrete\\b|\\bprobabilit(y|ies)\\b|\\bpmf\\b|\\bcdf\\b")
  dice_sum <- has("\\b(dice|die)\\b") && has("\\b(sum|total)\\b")
  if(!binomial && (pmf || cdf || (dice_sum && discrete))) {
    if(test || (pmf && cdf)) return(character())
    if(cdf || strict_upper || inclusive_upper || lower_tail)
      return("discrete_cdf")
    if(pmf || dice_sum) return("discrete_pmf")
    return(character())
  }
  if(pmf || cdf) {
    if(cdf) return(character())
    if(binomial && exact) return("binomial_exact")
    return(character())
  }

  # A binomial variable counts successes, not continuously recorded times.
  if(binomial && has("\\b(wait|waiting|duration|minutes|hours)\\b") &&
     has("\\btime\\b|\\bminutes\\b|\\bhours\\b")) return(character())
  if(binomial) {
    if(test) return(character()) # Probability model != binomial hypothesis test.
    if(has("\\bdbinom\\b") && has("\\bpbinom\\b")) return(character())
    if(strict_upper && (inclusive_upper || exact || lower_tail))
      return(character()) # Multiple conflicting event operators.
    if(strict_upper) return("binomial_more_than")
    if(inclusive_upper) return("binomial_at_least")
    if(lower_tail || has("\\bpbinom\\b")) return(character())
    if(exact || has("\\bdbinom\\b")) return("binomial_exact")
    return("binomial") # Model selection, not a specific tail.
  }
  if(normal) {
    if(test || ci) return(character()) # Inference is not event probability.
    normal_interval <- between ||
      has("\\b(inside|within)\\b.*\\b(interval|range|bounds?)\\b") ||
      has("\\b(two|2|both)\\s+(endpoints?|bounds?|limits?|cutoffs?)\\b")
    if(normal_interval) {
      if(has("\\b(qnorm|dnorm)\\b")) return(character())
      return("normal_between")
    }
    if(has("\\bqnorm\\b|\\bpercentile\\b|\\bquantile\\b")) return("normal_percentile")
    if(has("\\bdnorm\\b")) return(character())
    if(strict_upper || has("\\bupper tail\\b")) return("normal_right_tail")
    if(lower_tail || has("\\bpnorm\\b")) return("normal_left_tail")
    return(NULL) # Preserve valid general normal-concept lookups.
  }

  # Discrete success-count wording can be binomial even without the name,
  # but never infer a binomial count model from arrivals or a dice sum.
  if(has("\\b(independent|fixed)\\b.*\\btrials?\\b") &&
     has("\\bsuccess(es)?\\b") && exact)
    return("binomial_exact")
  if(has("\\bbernoulli\\b")) return("bernoulli")
  if(proportion && ci && !test) return("proportion_interval")
  if(has("\\bchisq[.]test\\b")) return(character())
  NULL
}

# Deterministic, conservative spelling repair using the words already
# indexed by the reference library. Never send text outside the machine.
.ru_correct_tokens <- function(tokens,catalog) {
  words <- c(catalog$id,catalog$title,catalog$keywords)
  vocabulary <- unique(unlist(lapply(words,.ru_words),use.names=FALSE))
  vocabulary <- vocabulary[nchar(vocabulary)>=4L]
  changed <- character()
  if (!length(vocabulary)) return(list(words=tokens,changes=changed))
  for(i in seq_along(tokens)) {
    term <- tokens[i]
    if (nchar(term)<6L || term %in% vocabulary) next
    choices <- vocabulary[abs(nchar(vocabulary)-nchar(term))<=2L]
    if (!length(choices)) next
    distances <- as.integer(utils::adist(term,choices))
    best <- min(distances)
    threshold <- if(nchar(term)>=8L) 2L else 1L
    winners <- unique(choices[distances==best])
    if(best<=threshold && length(winners)==1L) {
      changed <- c(changed,paste(term,"->",winners))
      tokens[i] <- winners
    }
  }
  list(words=unique(tokens),changes=changed)
}

.ru_score <- function(query,bank) {
  keys <- .ru_words(query)
  vapply(seq_len(nrow(bank)),function(i) {
    txt <- tolower(paste(bank$id[i],bank$question[i],bank$keywords[i]))
    terms <- .ru_words(txt)
    points <- sum(vapply(keys,function(k) {
      if(k %in% terms) 5L else if(grepl(k,txt,fixed=TRUE)) 2L else 0L
    },integer(1)))
    if(query==bank$id[i]) points <- points+100L
    if(grepl(query,txt,fixed=TRUE)) points <- points+20L
    points
  },integer(1))
}

.ru_catalog <- function() {
  path <- system.file("extdata","reference.csv",package="rulearn")
  if (!nzchar(path)) stop("The reference index is not installed.",call.=FALSE)
  refs <- utils::read.csv(path,stringsAsFactors=FALSE,
                          na.strings=character(),fileEncoding="UTF-8")
  refs$question <- refs$title
  refs$inputs <- ""
  guide <- .ru_db("problems.csv")
  guide <- data.frame(
    id=guide$id,type="walkthrough",
    title=guide$question,keywords=guide$keywords,
    topic=guide$id,package="rulearn",
    question=guide$question,inputs=guide$inputs,
    stringsAsFactors=FALSE)
  data <- rbind(refs[,names(guide)],guide)
  # Enrich the existing reference index with the aliases from the one
  # canonical Markdown source for each compact learner lesson.
  lessons <- .ru_lesson_index()
  if(nrow(lessons)) {
    overlap <- match(data$id,lessons$id)
    found <- which(!is.na(overlap))
    if(length(found))
      data$keywords[found] <- paste(data$keywords[found],
                                    lessons$keywords[overlap[found]])
    missing <- lessons[!lessons$id %in% data$id,,drop=FALSE]
    if(nrow(missing)) {
      add <- data.frame(id=missing$id,type=missing$type,
                        title=missing$title,keywords=missing$keywords,
                        topic=missing$id,package="rulearn",
                        question=missing$title,inputs="",
                        stringsAsFactors=FALSE)
      data <- rbind(data,add)
    }
  }
  data$path <- vapply(seq_len(nrow(data)), function(i) {
    item <- data[i,]
    if(item$type=="walkthrough")
      paste0("ru_guide('",item$id,"')")
    else
      paste0("ru_open('",item$id,"')")
  },character(1))
  data
}
.ru_search_results <- function(query,n=10L,type=NULL) {
  if(!is.character(query) || length(query)!=1L || is.na(query) ||
     !nzchar(trimws(query))) return(.ru_catalog()[FALSE,,drop=FALSE])
  catalog <- .ru_catalog()
  if (!is.null(type)) {
    if (length(type)!=1L || !(type %in% c("concept","function","walkthrough")))
      stop("type must be 'concept', 'function' or 'walkthrough'.",call.=FALSE)
    catalog <- catalog[catalog$type==type,,drop=FALSE]
  }
  # Explicit incompatible statistical methods are removed before any
  # lexical score or subject bonus can make them appear applicable.
  compatible <- .ru_method_compatible_ids(query)
  if (!is.null(compatible)) {
    catalog <- catalog[catalog$id %in% compatible,,drop=FALSE]
    if(!nrow(catalog)) return(catalog)
  }
  q <- tolower(trimws(query))
  # "What does a p-value mean?" is asking for the term "p-value",
  # not arithmetic mean. Preserve "mean" for queries about averages.
  q <- sub("^what does (a |the )?(.+) mean[?]?$","\\2",q)
  corrected <- .ru_correct_tokens(.ru_words(q),catalog)
  tokens <- corrected$words
  # The subject named by the question takes priority over incidental
  # mentions in other descriptions (e.g. bimodal "mean" or density histogram).
  # These map a method to its existing/native reference, never to a solver.
  subject <- ""
  qstat <- tolower(trimws(query))
  if(grepl("\\bsort\\b.*\\b(observations?|measurements?|values?|numbers?)\\b",qstat,perl=TRUE))
    subject <- "sort_values"
  else if(grepl("\\b(lowest|smallest|minimum)\\b",qstat,perl=TRUE) &&
          !grepl("\\b(maximum|highest|range)\\b",qstat,perl=TRUE))
    subject <- "minimum"
  if(!nzchar(subject) &&
     grepl("\\b(stem.and.leaf|stem and leaf)\\b",q,perl=TRUE))
    subject <- "r_stem"
  else if(grepl("\\b(skew|skewed|skewness)\\b",q,perl=TRUE))
    subject <- "skewness"
  else if(grepl("\\bunimodal\\b",q,perl=TRUE)) subject <- "unimodal"
  else if(grepl("\\bbimodal\\b",q,perl=TRUE)) subject <- "bimodal"
  else if(grepl("\\b(histograms?|histgram)\\b",q,perl=TRUE)) {
    if(grepl("\\b(bins?|breaks?|intervals?|binwidth)\\b",q,perl=TRUE))
      subject <- "histogram_breaks"
    else if(!grepl("\\bdensity\\b",q,perl=TRUE)) subject <- "histogram"
  }
  else if(grepl("\\bbar (chart|graph)\\b|\\bbarplot\\b",q,perl=TRUE))
    subject <- "bar_chart"
  else if(grepl("\\b(sample mean|mean median)\\b",q,perl=TRUE) &&
          grepl("\\bmedian\\b",q,perl=TRUE))
    subject <- "mean_median"
  else if(grepl("\\brange\\b",q,perl=TRUE) &&
          grepl("\\bvariance\\b",q,perl=TRUE) &&
          grepl("\\bstandard deviation\\b",q,perl=TRUE))
    subject <- "sample_sd"
  else if(grepl("\\bstandard deviation\\b",q,perl=TRUE) &&
          grepl("\\bstandard error\\b",q,perl=TRUE))
    subject <- "sampling_distributions"
  else if(grepl("\\bquartiles?\\b|\\bq1\\b|\\bq3\\b",q,perl=TRUE))
    subject <- "quartiles"
  else if(grepl("\\bsample space\\b",q,perl=TRUE)) subject <- "sample_space"
  else if(grepl("\\bstandard deviation\\b",q,perl=TRUE))
    subject <- "variance_sd"
  else if(grepl("\\bvariance\\b",q,perl=TRUE)) subject <- "variance"
  else if(grepl("\\brange\\b",q,perl=TRUE) &&
          !grepl("\\b(interquartile|iqr)\\b",q,perl=TRUE)) subject <- "range"
  else if(grepl("\\b(mean|average)\\b",q,perl=TRUE) &&
          !grepl("^what does it mean|\\bmean for\\b",qstat,perl=TRUE)) {
    if(grepl("\\bmedian\\b",q,perl=TRUE)) subject <- "mean_median"
    else if(grepl("\\b(group|groups|grouped)\\b",q,perl=TRUE))
      subject <- "group_means"
    else if(!grepl("\\b(trimmed|weighted|moving)\\b",q,perl=TRUE))
      subject <- "mean"
  }
  if(grepl("\\b(describe|inspect|summarize)\\b.*\\bdataset\\b",qstat,perl=TRUE) &&
     !grepl("\\b(statistic|mean|variance|quartile|graph|plot)\\b",qstat,perl=TRUE))
    subject <- "inspect_columns"
  # Preserve statistical-population and foundational exam wordings
  # when newer, narrower lesson titles introduce competing terms.
  if(grepl("\\bstatistical population\\b",qstat,perl=TRUE))
    subject <- "population_sample"
  if(grepl("\\bstatistical experiment\\b",qstat,perl=TRUE))
    subject <- "probability_events"
  if(grepl("\\bindependen\\w*\\b",qstat,perl=TRUE) &&
     grepl("\\bmutually exclusive\\b",qstat,perl=TRUE))
    subject <- "mutually_exclusive"
  if(grepl("\\bcomplement\\b",qstat,perl=TRUE) &&
     !grepl("\\bcomplementary probabilities\\b",qstat,perl=TRUE))
    subject <- "probability_complement"
  if(grepl("^what does a p-value mean",qstat,perl=TRUE))
    subject <- "hypothesis_tests_pvalues"
  # Prefer the precise *question intent*, not a generic term shared with
  # several older reference pages. Only disambiguate when the full set of
  # qualifying concept words is present; preserve unrelated searches.
  if(grepl("\\bpercentile\\b",qstat,perl=TRUE) &&
     grepl("\\brank\\b|\\branked\\b",qstat,perl=TRUE))
    subject <- "percentile_rank"
  if(grepl("\\b(mean|median)\\b.*\\b(mean|median)\\b",qstat,perl=TRUE) &&
     grepl("\\b(when|choose|select|report|better|instead)\\b",qstat,perl=TRUE))
    subject <- "choose_center"
  if(grepl("\\b(event|events)\\b",qstat,perl=TRUE) &&
     grepl("\\b(probability|random)\\b",qstat,perl=TRUE) &&
     !grepl("\\b(conditional|independent|union|or|mutually|complement)\\b",qstat,perl=TRUE))
    subject <- "probability_events"
  if(grepl("\\bexpected value\\b|\\bexpectation of\\b",qstat,perl=TRUE))
    subject <- "expected_value"
  if(grepl("\\brandom variables?\\b",qstat,perl=TRUE) &&
     grepl("\\bvariance\\b",qstat,perl=TRUE))
    subject <- "random_variance"
  if(grepl("\\bsampling distribution\\b",qstat,perl=TRUE) &&
     !grepl("\\bstandard error\\b",qstat,perl=TRUE))
    subject <- "sampling_distribution"
  if(grepl("\\bstandard error\\b",qstat,perl=TRUE) &&
     !grepl("\\bstandard deviation\\b",qstat,perl=TRUE))
    subject <- "standard_error"
  if(grepl("\\bconfidence interval\\b",qstat,perl=TRUE) &&
     !grepl("\\b(for|of) (the )?mean\\b|\\bt interval\\b",qstat,perl=TRUE))
    subject <- "confidence_intervals"
  # Recognize method intent from several independent study terms, rather
  # than merely finding an incidental noun in a legacy reference title.
  # These are conservative domain disambiguations, not assignment solvers.
  if(grepl("\\b(rank(ed)?|ordered|ordinal)\\b",qstat,perl=TRUE) &&
     grepl("\\b(opinion|rating|response|measurement|difference|scale)\\b",qstat,perl=TRUE))
    subject <- "measurement_scales"
  if(grepl("\\b(fraction|share|proportion|percentage|percent)\\b",qstat,perl=TRUE) &&
     grepl("\\b(categories|category|counts?|recorded|frequency)\\b",qstat,perl=TRUE))
    subject <- "relative_frequency"
  if(grepl("\\b(treatment|experiment|intervention)\\b",qstat,perl=TRUE) &&
     grepl("\\b(random|assigned|allocation)\\b",qstat,perl=TRUE))
    subject <- "experiment_design"
  if(grepl("\\bunion\\b|\\b(at least one)\\b",qstat,perl=TRUE) &&
     grepl("\\b(events?|overlap|probability|rule)\\b",qstat,perl=TRUE))
    subject <- "probability_union"
  if(grepl("\\b(conditioned|conditioning|given)\\b",qstat,perl=TRUE) &&
     grepl("\\b(probability|events?|occurred)\\b",qstat,perl=TRUE))
    subject <- "conditional_independence"
  if(grepl("\\b(success|failure)\\b",qstat,perl=TRUE) &&
     grepl("\\b(count|number|independent|multiple|trials?|distribution)\\b",qstat,perl=TRUE) &&
     !grepl("\\bone (trial|single trial)\\b",qstat,perl=TRUE))
    subject <- "binomial"
  if(grepl("\\b(expectation|expected value|weighted expectation)\\b",qstat,perl=TRUE) &&
     grepl("\\b(probability|weighted|random)\\b",qstat,perl=TRUE))
    subject <- "expected_value"
  if(grepl("\\b(sample means?|sampling means?)\\b",qstat,perl=TRUE) &&
     grepl("\\b(variation|variability|across|repeated|sampling|distribution)\\b",qstat,perl=TRUE))
    subject <- "sampling_distribution"
  if(grepl("\\b(false|falsely|incorrect|wrong)\\b",qstat,perl=TRUE) &&
     grepl("\\b(reject|rejecting|rejection)\\b",qstat,perl=TRUE) &&
     grepl("\\b(null|h0|hypothesis)\\b",qstat,perl=TRUE))
    subject <- "type_errors_power"
  # A validated specific route beats generic matches such as arithmetic mean
  # in "what does a p-value mean" and data spread in a hypothesis question.
  if(!is.null(compatible) && length(compatible)==1L)
    subject <- compatible[[1L]]
  # Programming requests need assignment/extraction, not statistical models.
  # Inspect the original query before punctuation tokenization removes <- and $.
  intent_objects <- grepl(paste0(
    "\\b(create|make|assign|store|save|declare|copy|extract|select|pull)\\b.*\\b(variables?|varibles|objects?|columns?|fields?)\\b|",
    "\\b(add|new)\\b.*\\bcolumns?\\b|",
    "\\bassignment\\s+(operator|arrow)\\b|",
    "df[$][[:alnum:]_.]+|",
    "<-|",
    "\\b(select|extract)\\b.*\\b(csv|data[ -]?frame)\\b"
    ),tolower(trimws(query)),perl=TRUE)
  # A named scatter display or plotting a pair of measurements is a
  # visualization question, not a paired hypothesis-test question.
  intent_scatter <- grepl(
    "\\bscatter\\b|\\b(plot|draw|graph)\\b.*\\b(two|paired|relationship)\\b",
    tolower(trimws(query)),perl=TRUE) &&
    !grepl("\\b(over time|time series)\\b",tolower(query),perl=TRUE)
  # A mechanical repair request is not a statistical inference
  # question merely because a reference example mentions vehicles.
  out_of_scope_repair <- grepl(
    "\\b(engine|mechanic|transmission|vehicle repair|car repair)\\b",
    tolower(query),perl=TRUE) &&
    grepl("\\b(broken|repair|fix|diagnose|malfunction)\\b",
          tolower(query),perl=TRUE) &&
    !grepl("\\b(data|statistics?|correlation|regression|sampling)\\b",
           tolower(query),perl=TRUE)
  out_of_scope_explanation <- grepl(
    "^what causes\\b",tolower(trimws(query)),perl=TRUE) &&
    !grepl(
      "\\b(data|statistics?|sampling|sample|population|probability|correlation|autocorrelation|stationarity|variance|hypothesis|pvalue|trend|model)\\b",
      tolower(query),perl=TRUE)
  intent_statistical_variable <- grepl(paste0(
    "\\b(statistical|statistics|measured|observed)\\b.*\\bvariables?\\b|",
    "\\bvariables?\\b.*\\b(statistical|statistics)\\b"
    ),tolower(trimws(query)),perl=TRUE)
  intent_concept <- grepl(
    "^(what is|what are|define|definition|meaning of|when is|can i use|should i use)\\b",
    tolower(trimws(query)),perl=TRUE) ||
    grepl("\\bmean[?]?$",tolower(trimws(query)),perl=TRUE)
  intent_function <- grepl(
    "\\b(function|syntax|arguments?|returns?|code for)\\b",
    tolower(query),perl=TRUE) ||
    grepl("^(how does|how do)\\s+(sd|mean|median|hist|cor|acf|quantile|table|t[.]test)\\b",
          tolower(query),perl=TRUE)
  intent_walkthrough <- grepl(
    "^(how do i|how can i|how to|steps to|when should|create|import|inspect|calculate|investigate|compare|plot|draw|make)\\b",
    tolower(trimws(query)),perl=TRUE)
  intent_error <- grepl(
    "\\b(wrong|error|failed|cannot|invalid|troubleshoot)\\b|not found",
    tolower(query),perl=TRUE) &&
    !grepl(
      "\\b(standard error|sampling error|margin of error|type [i1] error)\\b",
      tolower(query),perl=TRUE)
  score <- vapply(seq_len(nrow(catalog)),function(i) {
    item <- catalog[i,]
    heading <- tolower(paste(item$id,item$title))
    title_words <- .ru_words(heading)
    keys <- .ru_words(paste(item$keywords,item$question,item$id))
    # "What does unimodal mean?" is NOT about arithmetic mean.
    if(grepl("^what does .* mean[?]?$",tolower(item$title),perl=TRUE) &&
       !item$id %in% c("mean","mean_median","r_mean")) {
      title_words <- setdiff(title_words,"mean")
      keys <- setdiff(keys,"mean")
    }
    # Exact token matches, rather than accidental matches inside words such
    # as "not" in "cannot". Corrected search tokens are shown to the learner.
    hit <- sum(vapply(tokens,function(t) {
      if(t %in% title_words) 10L
      else if(t %in% keys) 5L
      else 0L
    },integer(1)))
    if(q==tolower(item$id) ||
       (item$type=="function" &&
          q==sub("^r_","",tolower(item$id))))
      hit <- hit + 100L
    if(nzchar(subject) && item$id==subject) hit <- hit + 125L
    if(nzchar(q) && grepl(q,tolower(item$title),fixed=TRUE))
      hit <- hit + 22L
    if(nzchar(q) && grepl(q,tolower(item$keywords),fixed=TRUE))
      hit <- hit + 18L
    # When the learner names an R method explicitly, favor references to
    # that named method over a generic nearby task such as grouped means.
    method_terms <- intersect(tokens,c(
      "boxplot","histogram","barplot","scatterplot","stem","quantile",
      "median","sd","acf","csv"))
    if(length(method_terms) &&
       any(method_terms %in% title_words))
      hit <- hit + 18L
    # A request for both mean AND median needs their combined reference,
    # not the histogram article that happens to demonstrate both markers.
    # Only use this disambiguation when no plot method was requested.
    if (all(c("mean","median") %in% tokens) &&
        !any(c("histogram","boxplot","plot","graph","chart") %in% tokens) &&
        item$id=="mean_median")
      hit <- hit + 30L
    # Variables alone are not evidence of correlation or plotting.
    # This is a topic-specific disambiguation, not a new calculation system.
    if(intent_objects) {
      hit <- if(item$id=="r_objects_columns") 350L else 0L
    } else if(intent_statistical_variable) {
      hit <- if(item$id=="statistical_variable") 350L else 0L
    } else {
      meaningful <- setdiff(tokens,c("variable","variables","varibles",
                                     "numeric","numerical","data"))
      # Two independent intent cues can justify a precise local reference
      # even if the novice wording shares no title/alias tokens.
      if((!length(meaningful) || !any(meaningful %in% keys)) &&
         !(nzchar(subject) && item$id==subject))
        hit <- 0L
    }
    if(intent_scatter && item$id=="scatterplot") hit <- hit + 115L
    if(intent_concept && item$type=="concept") hit <- hit + 17L
    if(intent_function && item$type=="function") hit <- hit + 20L
    if(intent_walkthrough && item$type=="walkthrough") hit <- hit + 8L
    if(intent_error && item$id=="r_errors") hit <- hit + 21L
    # Do not revive unrelated hits via an intent bonus alone.
    valid <- if(intent_objects) item$id=="r_objects_columns"
      else if(intent_statistical_variable) item$id=="statistical_variable"
      else {
        meaningful <- setdiff(tokens,c("variable","variables","varibles",
                                       "numeric","numerical","data"))
        (length(meaningful)>0L && any(meaningful %in% keys)) ||
          (nzchar(subject) && item$id==subject)
      }
    if (!valid || out_of_scope_explanation || out_of_scope_repair) hit <- 0L
    hit
  },integer(1))
  ord <- order(-score,match(catalog$type,c("concept","function","walkthrough")),
               catalog$id)
  n <- if (length(n)!=1L || is.na(n) || !is.finite(n))
    10L else max(1L,min(as.integer(n),50L))
  ord <- head(ord[score[ord]>0L],n)
  out <- catalog[ord,,drop=FALSE]
  rownames(out) <- NULL
  attr(out,"corrected_terms") <- corrected$changes
  out
}
ru_topics <- function() {
  topics <- .ru_coverage()
  if(.ru_rstudio_ready("viewer"))
    .ru_viewer_show(hits=NULL,query="",force_page="catalog")
  invisible(topics)
}

ru_find <- function(query,n=10L,type=NULL) {
  if(missing(query) || !is.character(query) || length(query)!=1L ||
     is.na(query) || !nzchar(trimws(query)))
    return(invisible(.ru_catalog()[FALSE,,drop=FALSE]))
  hits <- .ru_search_results(query,n=n,type=type)
  if(.ru_rstudio_ready("viewer")) .ru_viewer_show(hits,query)
  invisible(hits)
}

ru_open <- function(query,type=NULL) {
  if(!is.character(query) || length(query)!=1L || is.na(query))
    stop("Provide one search phrase or reference ID.",call.=FALSE)
  result <- .ru_search_results(query,n=3L,type=type)
  if(.ru_rstudio_ready("viewer"))
    .ru_viewer_show(result,query,force_page=if(nrow(result))result$id[1L] else NULL)
  invisible(if(nrow(result))result[1L,,drop=FALSE] else NULL)
}

# Internal method lookup remains restricted to walkthroughs for compatibility.
.ru_pick <- function(query) {
  bank <- .ru_db("problems.csv")
  q <- tolower(trimws(query))
  exact <- match(q,bank$id)
  if(!is.na(exact)) return(bank[exact,,drop=FALSE])
  scores <- .ru_score(q,bank)
  if(!length(scores) || max(scores)==0L) {
    cat("No matching method. Try ru_find('keyword').\n")
    return(NULL)
  }
  ix <- which(scores==max(scores))
  if(length(ix)>1L) {
    cat("Several methods match. Use an exact walkthrough ID:\n")
    print(bank[ix,c("id","question"),drop=FALSE],row.names=FALSE)
    return(NULL)
  }
  bank[ix,,drop=FALSE]
}