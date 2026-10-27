# Deterministic W4 candidate recognition. No ambient objects or command execution.
# Independently frozen IDs from SUP49/A1 exact c931d1f8 registry. The map
# is immutable and never accepts a function or method string from question text.
.ru_w4_method_model <- function(family_id) {
  ids <- list(
    "descriptive.numeric" = c("describe.numeric", "observed_numeric_list"),
    "probability.event_scalar" = c("event_probability", "finite_scalar_event_probabilities"),
    "distribution.binomial" = c("binomial_exact", "iid_bernoulli_fixed_n_p"),
    "distribution.poisson" = c("poisson_exact", "poisson_count_fixed_exposure"),
    "distribution.normal" = c("normal_between", "normal_continuous_measurement"),
    "distribution.uniform_continuous" = c("uniform_interval", "continuous_uniform_bounded_interval"),
    "inference.one_sample_t" = c("one_sample_t", "iid_unknown_sigma_one_sample_mean"),
    "regression.simple_ols" = c("linear_regression", "simple_gaussian_ols_with_intercept")
  )
  if (!is.character(family_id) || length(family_id) != 1L ||
      is.na(family_id) || !family_id %in% names(ids))
    return(c(method_id="unregistered_method", model_id="unregistered_model"))
  stats::setNames(ids[[family_id]], c("method_id", "model_id"))
}
.ru_w4_result <- function(status, reason_code, original_question, family_id,
                          inputs=list(), requested_outputs=character(),
                          assumptions=list(), missing_inputs=character(),
                          parser_rule_id="w4.family.v1") {
  structure(list(schema_version="ru.guided.v1",status=status,
    reason_code=reason_code,original_question=original_question,
    family_id=family_id, inputs=inputs,
    requested_outputs=unique(as.character(requested_outputs)),
    assumptions=assumptions,missing_inputs=unique(as.character(missing_inputs)),
    parser_rule_id=parser_rule_id,
    method_id=unname(.ru_w4_method_model(family_id)[["method_id"]]),
    model_id=unname(.ru_w4_method_model(family_id)[["model_id"]]),
    estimand=if (identical(family_id,"inference.one_sample_t")) "population_mean" else
      "model_quantity",
    study_design=if (identical(family_id,"inference.one_sample_t")) "one_sample" else
      if (identical(family_id,"regression.simple_ols")) "observed_pairs" else "theoretical",
    execution_scope="INLINE_LITERAL_ONLY"),class=c("ru_w4_parsed","list"))
}
.ru_w4_norm <- function(s) {
  s<-gsub("[\u2010-\u2015\u2212]","-",s,perl=TRUE)
  s<-gsub("\u2264","<=",s,fixed=TRUE)
  s<-gsub("\u2265",">=",s,fixed=TRUE)
  tolower(gsub("\\s+"," ",trimws(s),perl=TRUE))
}
.ru_w4_hit<-function(re,s) grepl(re,s,perl=TRUE)
.ru_w4_group<-function(re,s) {
  m<-regexec(re,s,perl=TRUE); z<-regmatches(s,m)[[1L]]
  if(length(z))z[-1L] else character()
}
.ru_w4_numre<-"[+-]?(?:[0-9]+(?:\\.[0-9]*)?|\\.[0-9]+)(?:e[+-]?[0-9]+)?"
.ru_w4_num<-function(s, integer=FALSE,lo=-1e9,hi=1e9) {
  if(length(s)!=1L||!is.character(s)||is.na(s)||!
     .ru_w4_hit(paste0("^",.ru_w4_numre,"$"),trimws(s)))return(NULL)
  x<-suppressWarnings(as.double(s))
  if(!is.finite(x)||x<lo||x>hi||(integer&&x!=floor(x)))return(NULL)
  if(integer)as.integer(x) else x
}
.ru_w4_key<-function(s,keys,integer=FALSE,lo=-1e9,hi=1e9) {
  z<-.ru_w4_group(paste0("\\b(?:",keys,")\\s*(?:=|:)\\s*(",
                         .ru_w4_numre,")"),s)
  if(!length(z)) z<-.ru_w4_group(paste0("\\b(?:",keys,")\\s+(",.ru_w4_numre,")"),s)
  if(!length(z))return(NULL)
  .ru_w4_num(z[[1L]],integer,lo,hi)
}
.ru_w4_vec<-function(s,name=NULL,free=FALSE) {
  # A comma-separated literal must be consumed in full. A successful prefix
  # is not evidence of a valid list: [1,2,NA], 1,2,Inf, a trailing comma,
  # 257 observations, and damaged brackets must never become [1,2].
  # The question is NEVER parsed or evaluated as R source.
  sequence<-paste0(.ru_w4_numre,"(?:\\s*,\\s*",.ru_w4_numre,"){1,255}")
  bad<-NA_real_
  # Also reject invalid tokens that precede a later valid-looking sequence.
  # Otherwise "NA and 1,2,3" could be misread as just [1,2,3].
  if(.ru_w4_hit("(?<![[:alnum:]_])(?:na|nan|inf(?:inity|inite)?)(?![[:alnum:]_])\\s*(?:[,\\]\\).]|\\b(?:and|or)\\b)",s))
    return(bad)
  named<-FALSE
  body<-NULL
  before<-""
  if(!is.null(name)) {
    label<-paste0("\\b(?:",name,")\\s*(?:=|:)\\s*")
    m<-regexpr(label,s,perl=TRUE)
    if(m[[1L]]>0L) {
      named<-TRUE
      body<-substr(s,m[[1L]]+attr(m,"match.length"),nchar(s))
    }
  }
  if(is.null(body)) {
    if(!free)return(NULL)
    # An unmatched comma before the candidate disqualifies a later suffix
    # as the complete list (e.g., NA,2,3 or 1,foo,2,3).
    match<-regexpr(paste0("(?<![[:alnum:].,])",sequence),s,perl=TRUE)
    if(match[[1L]]<1L)return(NULL)
    before<-if(match[[1L]]>1L)substr(s,1L,match[[1L]]-1L) else ""
    body<-substr(s,match[[1L]],nchar(s))
    # Unlabeled numeric lists may be bracketed or c(...) literals, too.
    # Refuse an incomplete prefix that follows an earlier bare number.
    if(.ru_w4_hit(paste0("(?:^|\\s)",.ru_w4_numre,"\\s+$"),before))
      return(bad)
  }
  wrapper<-""
  if(named) {
    open<-regexpr("^\\s*(?:c\\s*\\(|\\[)",body,perl=TRUE)
    if(open[[1L]]==1L) {
      token<-regmatches(body,open)
      wrapper<-if(.ru_w4_hit("\\[",token)) "]" else ")"
      body<-substr(body,attr(open,"match.length")+1L,nchar(body))
    }
  } else {
    preceding<-trimws(before,which="right")
    if(nzchar(preceding)) {
      ch<-substr(preceding,nchar(preceding),nchar(preceding))
      if(ch%in%c("[","("))wrapper<-if(ch=="[") "]" else ")"
    }
  }
  m<-regexpr(paste0("^",sequence),body,perl=TRUE)
  if(m[[1L]]!=1L)return(if(named)bad else NULL)
  part<-regmatches(body,m)
  suffix<-substr(body,attr(m,"match.length")+1L,nchar(body))
  if(nzchar(wrapper)) {
    close<-regexpr(paste0("^\\s*\\",wrapper),suffix,perl=TRUE)
    if(close[[1L]]!=1L)return(bad)
    suffix<-substr(suffix,attr(close,"match.length")+1L,nchar(suffix))
  }
  # A completed vector cannot leave an extra item, unmatched bracket, or
  # arithmetic continuation. In paired data only a named second vector may
  # follow a bracketed first vector after a comma.
  # A comma may separate a complete numeric list from a calculation verb,
  # but never a further token, NA/Inf, dangling comma or malformed suffix.
  if(.ru_w4_hit("^\\s*[,\\]\\)]",suffix) &&
     !(.ru_w4_hit(paste0("^\\s*,\\s*(?:compute|calculate|find|give|report|",
                         "estimate|test|construct|predict|fit)\\b"),suffix) ||
       (nzchar(wrapper) &&
        .ru_w4_hit("^\\s*,\\s*(?:x|y)\\s*(?:=|:)",suffix))))
    return(bad)
  if(.ru_w4_hit("^\\s*(?:[;|]\\s*|[+*/^]\\s*)",suffix) &&
     .ru_w4_hit(paste0("^\\s*(?:[;|+*/^]\\s*)",.ru_w4_numre),suffix))
    return(bad)
  # A verb can terminate a list, but not legitimize a stray trailing
  # numeric operand in the subsequent output clause.
  if(.ru_w4_hit(paste0("^\\s*,\\s*(?:compute|calculate|find|give|report|",
                       "estimate|test|construct|predict|fit)\\b",
                       "[^;!?]{0,180},\\s*",.ru_w4_numre,
                       "(?:[,;.]|$)"),suffix))
    return(bad)
  if(.ru_w4_hit("^[[:alnum:]_]",suffix) ||
     .ru_w4_hit(paste0("^\\s*(?:and|or|plus)\\s+(?:\\[|c\\s*\\(|",
                        .ru_w4_numre,")"),suffix) ||
     .ru_w4_hit(paste0("^\\s+",.ru_w4_numre,"(?:\\s|[,;.]|$)"),suffix))
    return(bad)
  values<-strsplit(part,"\\s*,\\s*",perl=TRUE)[[1L]]
  if(length(values)>256L)return(bad)
  numbers<-lapply(values,.ru_w4_num)
  if(any(vapply(numbers,is.null,logical(1L))))return(bad)
  unlist(numbers,use.names=FALSE)
}
.ru_w4_event<-function(text) {
  inner<-.ru_w4_group("\\bp\\s*\\(([^()]*)\\)",text)
  if(!length(inner))return(NULL)
  s<-trimws(inner[[1L]])
  re<-paste0("^(",.ru_w4_numre,")\\s*<\\s*(?:x|z)\\s*<\\s*(",
             .ru_w4_numre,")$")
  range<-.ru_w4_group(re,s)
  if(length(range)==2L) return(list(type="interval",
    lower=.ru_w4_num(range[[1L]]),upper=.ru_w4_num(range[[2L]])))
  for(op in c("<=",">=","<",">","==","=")) {
    z<-.ru_w4_group(paste0("^(?:x|z)\\s*",op,"\\s*(",.ru_w4_numre,")$"),s)
    if(length(z))return(list(type=switch(op,"<="="cdf",">="="at_least",
      "<"="below",">"="above","="="exact","=="="exact"),
      k=.ru_w4_num(z[[1L]])))
  }
  z<-.ru_w4_group(paste0("^(?:x|z)\\s+at least\\s+(",.ru_w4_numre,")$"),s)
  if(length(z))return(list(type="at_least",k=.ru_w4_num(z[[1L]])))
  NULL
}
# Whole-request accounting: collect independently requested outputs and
# distinct probability events. The current typed schema can express one event.
# Only fixed bounded string matching is used, never R evaluation or lookups.
.ru_w4_request_inventory <- function(s, family, outputs) {
  hit<-function(re) .ru_w4_hit(re,s)
  distribution<-family%in%c("distribution.binomial","distribution.poisson",
                             "distribution.normal","distribution.uniform_continuous")
  events<-character()
  if(distribution) {
    open<-gregexpr("\\bp\\s*\\(",s,perl=TRUE)[[1L]]
    events<-regmatches(s,gregexpr("\\bp\\s*\\([^()]{0,160}\\)",
                               s,perl=TRUE))[[1L]]
    count<-if(open[[1L]]<0L)0L else length(open)
    if(count!=length(events))
      return(list(reason="PROBABILITY_EVENT_EXPRESSION_INCOMPLETE"))
    events<-unique(gsub("\\s+","",events,perl=TRUE))
    if(length(events)>1L)
      return(list(reason="MULTIPLE_PROBABILITY_EVENTS_UNSUPPORTED"))
    if(length(events)&&hit("\\b(?:quantile|percentile)\\b"))
      return(list(reason="MULTIPLE_DISTRIBUTION_OPERATIONS_UNSUPPORTED"))
  }
  need<-character()
  if(family=="descriptive.numeric") {
    if(hit("\\b(?:mean|average)\\b"))need<-c(need,"mean")
    if(hit("\\bmedian\\b"))need<-c(need,"median")
    if(hit("\\bvariance\\b")) {
      v<-outputs[grepl("^(?:sample|population)_variance$",outputs)]
      if(!length(v))return(list(reason="REQUESTED_OUTPUT_NOT_COMPUTED"))
      need<-c(need,v)
    }
    if(hit("\\bstandard deviation\\b")) {
      v<-outputs[grepl("^(?:sample|population)_sd$",outputs)]
      if(!length(v))return(list(reason="REQUESTED_OUTPUT_NOT_COMPUTED"))
      need<-c(need,v)
    }
    if(hit("\\b(?:quantile|quartile|percentile)\\b"))need<-c(need,"quantile")
  } else if(distribution) {
    if(length(events))need<-c(need,"probability")
    if(hit("\\b(?:expected value|expectation|mean of (?:the )?distribution)\\b"))
      need<-c(need,"expected_value")
    if(hit("\\bvariance\\b"))need<-c(need,"variance")
    if(hit("\\b(?:percentile|quantile)\\b"))need<-c(need,"quantile")
  } else if(family=="probability.event_scalar") {
    if(hit("\\bunion\\b|\\ba\\s+or\\s+b\\b"))need<-c(need,"union")
    if(hit("\\bconditional\\b|\\bgiven\\s+b\\b|p\\s*\\(\\s*a\\s*\\|\\s*b"))
      need<-c(need,"conditional")
    if(hit("\\bcomplement\\b|\\ba\\s*\\^\\s*c\\b"))need<-c(need,"complement")
    if(length(unique(need))>1L)
      return(list(reason="MULTIPLE_EVENT_OPERATIONS_UNSUPPORTED"))
  } else if(family=="inference.one_sample_t") {
    test<-hit("\\b(?:t[- ]test|hypothesis\\s+test|p[- ]value|test\\s+mu0|t[- ]statistic|test statistic)\\b")
    interval<-hit("\\b(?:confidence interval|confidence limits|\\bci\\b)")
    if(test&&interval)
      return(list(reason="MULTIPLE_INFERENCE_OPERATIONS_UNSUPPORTED"))
    if(test)need<-c(need,"t_statistic","degrees_freedom","p_value")
    if(interval)need<-c(need,"ci_lower","ci_upper")
  } else if(family=="regression.simple_ols") {
    # Bare "OLS model" describes a prediction source, not necessarily a
    # request to report all coefficients.
    if(hit("\\b(?:slope|intercept|coefficients?|fit)\\b"))
      need<-c(need,"intercept","slope")
    if(hit("\\b(?:r[- ]?squared|r\\s*\\^\\s*2)\\b"))need<-c(need,"r_squared")
    if(hit("\\b(?:predict\\s+y|prediction)\\b"))need<-c(need,"prediction")
  }
  if(!all(unique(need)%in%outputs))
    return(list(reason="REQUESTED_OUTPUT_NOT_COMPUTED"))
  list(reason=NULL,events=events,required=unique(need))
}
# Every additional requested action must be explainable by an actual
# output ID; conjunctions among model inputs/data are not actions.
.ru_w4_request_complete <- function(s, family, outputs) {
  inventory<-.ru_w4_request_inventory(s,family,outputs)
  if(!is.null(inventory$reason))return(inventory$reason)
  hit<-function(re,txt=s).ru_w4_hit(re,txt)
  if(hit("\\b(?:workspace|working environment|ambient (?:object|variable)|current session)\\b") &&
     hit("\\b(?:access|read|load|retrieve|output|display|show|print|return|list|fetch)\\b"))
    return("WORKSPACE_OBJECT_ACCESS_UNSUPPORTED")
  # Requests for other mathematical operations, graphics or artifacts cannot
  # be silently substituted by a supported scalar, even if one exists.
  other<-c(
    "\\b(?:histograms?|boxplots?|scatterplots?|scatter\\s+plots?|bar\\s+charts?|charts?|graphs?|visuali[sz](?:e|ation)|plots?|figures?|density\\s+plots?)\\b",
    "\\b(?:prediction\\s+interval|prediction\\s+band|credible\\s+interval|forecast|extrapolation|standard\\s+errors?)\\b",
    "\\b(?:variance\\s+(?:hypothesis\\s+)?test|test\\s+(?:of|for)\\s+(?:the\\s+)?variance|geometric\\s+mean|entropy|skewness|kurtosis|covariance|correlation|pearson|spearman)\\b",
    "\\b(?:anova|chi[- ]?square|bootstrap|permutation|resampling|spatial|geospatial|time\\s+series|causal\\s+effect|power\\s+analysis)\\b"
  )
  if(any(vapply(other,hit,logical(1L))))
    return("ADDITIONAL_ANALYSIS_UNSUPPORTED")
  if(family!="inference.one_sample_t" &&
     hit("\\b(?:hypothesis\\s+test|significance\\s+test|test\\s+of\\s+(?:independence|means?|proportions?)|p[- ]value|z[- ]test|confidence\\s+interval|confidence\\s+limits)\\b"))
    return("ADDITIONAL_ANALYSIS_UNSUPPORTED")
  action<-paste0("(?:\\b(?:and|also|then|plus)\\b|[;,])\\s*",
    "(?:also\\s+)?(?:calculate|compute|find|give|report|return|provide|",
    "estimate|determine|derive|fit|predict|construct|generate|produce|",
    "display|show|plot|draw|output|retrieve|load|read|access|run|test|",
    "list|create|build|explain|summari[sz]e)\\b[^;!?]{0,512}")
  clauses<-regmatches(s,gregexpr(action,s,perl=TRUE))[[1L]]
  if(length(clauses)>16L)return("REQUEST_ACTION_CAP_EXCEEDED")
  for(clause in clauses) {
    cv<-function(pattern)hit(pattern,clause)
    required<-switch(family,
      "descriptive.numeric"=c(
        if(cv("\\b(?:mean|average)\\b"))"mean",
        if(cv("\\bmedian\\b"))"median",
        if(cv("\\bvariance\\b"))
          outputs[grepl("_variance$",outputs)],
        if(cv("\\bstandard\\s+deviation\\b"))
          outputs[grepl("_sd$",outputs)],
        if(cv("\\b(?:quantile|percentile|quartile)\\b"))"quantile"),
      "probability.event_scalar"=c(
        if(cv("\\bunion\\b"))"union",
        if(cv("\\b(?:conditional|given)\\b"))"conditional",
        if(cv("\\bcomplement\\b"))"complement"),
      "distribution.binomial"=c(
        if(cv("\\bp\\s*\\(|\\b(?:probability|cdf|pmf|tail)\\b"))"probability",
        if(cv("\\b(?:expected value|expectation)\\b"))"expected_value",
        if(cv("\\bvariance\\b"))"variance"),
      "distribution.poisson"=c(
        if(cv("\\bp\\s*\\(|\\b(?:probability|cdf|pmf|tail)\\b"))"probability",
        if(cv("\\b(?:expected value|expectation)\\b"))"expected_value",
        if(cv("\\bvariance\\b"))"variance"),
      "distribution.normal"=c(
        if(cv("\\bp\\s*\\(|\\b(?:probability|cdf|tail)\\b"))"probability",
        if(cv("\\b(?:expected value|expectation)\\b"))"expected_value",
        if(cv("\\bvariance\\b"))"variance",
        if(cv("\\b(?:quantile|percentile)\\b"))"quantile"),
      "distribution.uniform_continuous"=c(
        if(cv("\\bp\\s*\\(|\\b(?:probability|cdf|tail)\\b"))"probability",
        if(cv("\\b(?:expected value|expectation)\\b"))"expected_value",
        if(cv("\\bvariance\\b"))"variance"),
      "inference.one_sample_t"=c(
        if(cv("\\b(?:p[- ]value|hypothesis|t[- ]test|test|t[- ]statistic|test statistic)\\b"))
          c("t_statistic","p_value"),
        if(cv("\\b(?:confidence\\s+interval|confidence\\s+limits|ci)\\b"))
          c("ci_lower","ci_upper")),
      "regression.simple_ols"=c(
        if(cv("\\b(?:slope|intercept|coefficients?|ols|regression|fit)\\b"))
          c("intercept","slope"),
        if(cv("\\b(?:r[- ]?squared|r\\s*\\^\\s*2)\\b"))"r_squared",
        if(cv("\\b(?:predict|prediction)\\b"))"prediction"),
      character())
    if((!length(required)||!all(required%in%outputs)) &&
       !cv("\\b(?:r\\s+code|code\\s+preview|r\\s+script|results?|answers?)\\b"))
      return("ADDITIONAL_REQUEST_ACTION_UNSUPPORTED")
  }
  NULL
}

# W5-R2: conservative, bounded recognition of *requested* atomic results.
# Lexicon entries describe statistic types (not specific A5 questions). Each
# atom retains its source position; the existing typed answer IDs are the sole
# authority for what can be reported as computed.
.ru_w4_result_atoms <- function(s, family) {
  verb <- "(?:calculate|compute|find|give|report|return|estimate|determine|derive|fit|predict|construct|generate|produce|display|show|plot|draw|output|retrieve|load|read|access|run|test|list|create|build|explain|summari[sz]e)"
  start <- regexpr(paste0("\\b",verb,"\\b|\\bwhat\\s+is\\b"),s,perl=TRUE)[[1L]]
  request <- if(start>0L) substr(s,start,nchar(s)) else s
  if(nchar(request)>4096L) return(list(reason="REQUEST_ACTION_CAP_EXCEEDED"))
  # Remove numerical model parameter assignments, not action language.
  # These do not request a separate computed statistic.
  q <- gsub(paste0("\\b(?:mean|standard deviation|sd|mu|sigma|mu0|",
                    "lambda|rate|n|p|a|b|x0|x_new|lower|upper)\\s*(?:=|:)\\s*",
                    .ru_w4_numre), " ",request,perl=TRUE)
  terms <- list(
    mean="\\b(?:arithmetic\\s+mean|mean|average)\\b",
    expectation="\\b(?:expected\\s+(?:value|number|count|arrivals?|successes?)|expectation)\\b",
    median="\\bmedian\\b",
    mode="\\b(?:modal\\s+value|mode)\\b",
    variance="\\bvariance\\b",
    deviation="\\b(?:standard\\s+deviation|std\\.?\\s*deviation)\\b",
    quantile="\\b(?:quantile|quartile|percentile)\\b",
    range="",  # Composite statistic labels are completed below.
    ratio="",
    density="\\b(?:probability\\s+density|density\\s+(?:at|of)|density\\s+function)\\b",
    effect="",
    ols_diagnostic="",
    spatial="",
    time="",
    hazard="\\b(?:hazard\\s+(?:function|rate)|z[- ]scores?)\\b",
    probability_extra="\\b(?:credible\\s+interval|confidence\\s+interval\\s+for\\s+(?:the\\s+)?chance)\\b",
    graph="\\b(?:histograms?|boxplots?|scatterplots?|bar\\s+charts?|plots?|graphs?|graphics?|charts?)\\b",
    document="\\b(?:csv\\s+files?|workspace\\s+objects?|unprovided\\s+datasets?)\\b",
    coefficient="\\b(?:coefficients?|intercept|slope)\\b",
    rsquared="\\b(?:r[- ]?squared|r\\s*\\^\\s*2)\\b",
    prediction="\\b(?:predict\\s+y|predictions?)\\b",
    complement="\\bcomplement\\b",
    union="\\bunion\\b|\\ba\\s+or\\s+b\\b",
    conditional="\\bconditional\\b|\\ba\\s+given\\s+b\\b",
    tstatistic="\\b(?:t[- ]statistic|test\\s+statistic|p[- ]value)\\b"
  )
  terms$range <- paste0("\\b(?:range|interquartile\\s+range|iqr|",
                        "five[- ]number\\s+summary|median\\s+absolute\\s+deviation|",
                        "coefficient\\s+of\\s+variation|maximum|minimum|",
                        "ninety[- ]?th\\s+percentile|gini\\s+coefficient)\\b")
  terms$ratio <- paste0("\\b(?:odds\\s+ratio|risk\\s+ratio|bayes\\s+factor|",
                        "fano\\s+factor|entropy|skewness|kurtosis)\\b")
  terms$effect <- paste0("\\b(?:cohen'?s?\\s+d|effect\\s+sizes?|",
                         "standardized\\s+(?:effects?|beta))\\b")
  terms$ols_diagnostic <- paste0("\\b(?:adjusted\\s+r[- ]?squared|",
                                 "adjusted\\s+r\\s*\\^\\s*2|residuals?|",
                                 "cook'?s?\\s+distance|\\baic\\b|\\bbic\\b)\\b")
  terms$spatial <- paste0("\\b(?:nearest[- ]neighbou?r\\s+distance|",
                         "moran'?s?\\s+i|kriging|semivariogram|",
                         "geodesic\\s+distance|spatial\\s+autocorrelation)\\b")
  terms$time <- paste0("\\b(?:sample\\s+autocorrelation|",
                       "autocorrelations?|acf|moving\\s+average|forecast)\\b")
  # Ignore a mean/variance/deviation noun when it is an *input* label,
  # e.g. "Normal mean=0, standard deviation=1; calculate P(X<=2)".
  supported <- switch(family,
    "descriptive.numeric"=c(mean="mean",median="median",
          variance="__variance__",deviation="__sd__",quantile="quantile"),
    "probability.event_scalar"=c(complement="complement",union="union",
                                  conditional="conditional"),
    "distribution.binomial"=c(expectation="expected_value",mean="expected_value",
                               variance="variance"),
    "distribution.poisson"=c(expectation="expected_value",mean="expected_value",
                              variance="variance"),
    "distribution.normal"=c(expectation="expected_value",mean="expected_value",
                             variance="variance",quantile="quantile"),
    "distribution.uniform_continuous"=c(expectation="expected_value",
                                         mean="expected_value",variance="variance"),
    "inference.one_sample_t"=c(tstatistic="__test__"),
    "regression.simple_ols"=c(coefficient="__coefficients__",
                               rsquared="r_squared",prediction="prediction"),
    character())
  atoms<-list()
  offset<-if(start>0L)start-1L else 0L
  for(kind in names(terms)){
    m<-gregexpr(terms[[kind]],q,perl=TRUE)[[1L]]
    if(m[[1L]]<1L)next
    lengths<-attr(m,"match.length")
    for(i in seq_along(m)){
      if(length(atoms)>=32L)return(list(reason="REQUEST_ACTION_CAP_EXCEEDED"))
      atoms[[length(atoms)+1L]]<-list(kind=kind,
                       start=as.integer(m[[i]]+offset),
                       end=as.integer(m[[i]]+lengths[[i]]-1L+offset),
                       output=unname(supported[kind]))
    }
  }
  list(reason=NULL,atoms=atoms,request_start=if(start>0L)start else 1L)
}


.ru_w4_request_accountable <- function(s,family,outputs) {
  inv<-.ru_w4_result_atoms(s,family)
  if(!is.null(inv$reason))return(inv$reason)
  atoms<-inv$atoms
  # The same P(X...) twice denotes one event; a distinct natural-language
  # event clause is a second target even without a second P(...) token.
  distribution<-family%in%c("distribution.binomial","distribution.poisson",
                             "distribution.normal","distribution.uniform_continuous")
  request<-substr(s,inv$request_start,nchar(s))
  formal<-if(distribution)regmatches(request,gregexpr(
    "\\bp\\s*\\([^()]{0,160}\\)",request,perl=TRUE))[[1L]] else character()
  formal<-unique(gsub("\\s+","",formal,perl=TRUE))
  if(length(formal)>1L)return("MULTIPLE_PROBABILITY_EVENTS_UNSUPPORTED")
  prose<-if(distribution) regmatches(request,gregexpr(
    "\\b(?:chance|probability|likelihood)\\s+(?:that\\s+)?of\\s+",
    request,perl=TRUE))[[1L]] else character()
  # The expression "probability of P(X=...)" is the same single event;
  # "probability of no successes" is an independently specified event.
  if(length(prose)){
    positions<-gregexpr("\\b(?:chance|probability|likelihood)\\s+(?:that\\s+)?of\\s+",
                       request,perl=TRUE)[[1L]]
    len<-attr(positions,"match.length")
    descriptions<-vapply(seq_along(positions),function(i){
      suffix<-substr(request,positions[[i]]+len[[i]],nchar(request))
      .ru_w4_hit("^p\\s*\\(",suffix)
    },logical(1L))
    if(length(formal)>0L && any(!descriptions))
      return("MULTIPLE_PROBABILITY_EVENTS_UNSUPPORTED")
    if(length(formal)==0L && any(!descriptions))
      return("UNREPRESENTED_PROBABILITY_EVENT_UNSUPPORTED")
  }
  # Every observed output noun, including a second result joined to a
  # supported one, must have a fixed exact output ID. The parser cannot
  # silently convert a request for a different statistic to the first one.
  if(length(atoms)){
    for(a in atoms){
      id<-a$output
      if(is.null(id)||!length(id)||is.na(id))
        return("UNREPRESENTED_STATISTICAL_OUTPUT_UNSUPPORTED")
      if(identical(id,"__variance__"))
        id<-outputs[grepl("^(?:sample|population)_variance$",outputs)]
      if(identical(id,"__sd__"))
        id<-outputs[grepl("^(?:sample|population)_sd$",outputs)]
      if(identical(id,"__coefficients__"))
        id<-c("intercept","slope")
      if(identical(id,"__test__"))
        id<-c("t_statistic","p_value")
      if(!length(id)||!all(id%in%outputs))
        return("REQUESTED_OUTPUT_NOT_COMPUTED")
    }
  }
  # The old W4 schema carries one event only. Event identity is checked
  # above, and exact output IDs here; an unknown additional *action* after
  # a coordinating conjunction must not be swallowed as a model modifier.
  connector<-paste0("\\b(?:and|plus|also|along\\s+with|",
                    "as\\s+well\\s+as|together\\s+with)\\b")
  indices<-gregexpr(connector,request,perl=TRUE)[[1L]]
  if(indices[[1L]]>0L){
    lengths<-attr(indices,"match.length")
    if(length(indices)>32L)return("REQUEST_ACTION_CAP_EXCEEDED")
    for(i in seq_along(indices)){
      from<-indices[[i]]+lengths[[i]]
      until<-if(i<length(indices))indices[[i+1L]]-1L else nchar(request)
      segment<-substr(request,from,until)
      segment<-trimws(strsplit(segment,"[;.!?]",perl=TRUE)[[1L]][[1L]])
      if(!nzchar(segment))next
      # Verified model operands, parameter bindings, and assumptions do not
      # constitute extra output requests; these are syntactically recognized.
      if(.ru_w4_hit(paste0("^(?:(?:the|a|an)\\s+)?",
                          "(?:x|y|z|mu|sigma|mu0|n|p|lambda|a|b|",
                          "x0|x_new|values|observations)\\s*(?:=|:)"),
                    segment))next
      # Coordinated probability assignments are model inputs, not events.
      # Only accept a complete scalar assignment, not an extra request.
      if(family=="probability.event_scalar" &&
         .ru_w4_hit(paste0("^p\\s*\\([^()]{1,100}\\)\\s*(?:=|:)\\s*",
                           .ru_w4_numre,"(?:\\s|[,;.]|$)"),segment))next
      if(.ru_w4_hit(paste0("^(?:(?:the|a|an)\\s+)?",
                            "(?:mean|standard\\s+deviation|sd|",
                            "success\\s+probability|rate|trials?)",
                            "\\s*(?:=|:)\\s*",.ru_w4_numre,
                            "(?:\\s|[,;.]|$)"),segment))next
      if(.ru_w4_hit("^(?:identically distributed|independent|approximately normal)\\b",
                    segment))next
      if(.ru_w4_hit("^(?:r\\s+code|code\\s+preview|r\\s+script|results?|answers?)\\b",
                    segment))next
      # Require an actual atom *in this coordinated component*, never a
      # recognized atom in a later component that would conceal an omission.
      from_abs<-inv$request_start+from-1L
      to_abs<-from_abs+nchar(segment)-1L
      if(any(vapply(atoms,function(a)
          a$start>=from_abs && a$start<=to_abs,logical(1L))))next
      if(distribution && .ru_w4_hit("\\bp\\s*\\(",segment))next
      # Unknown coordinated output is never automatically identified with
      # a calculated predecessor, regardless of what keyword that had.
      return("ADDITIONAL_REQUEST_ACTION_UNSUPPORTED")
    }
  }
  # Also catch independent verb-started requests separated by semicolons,
  # e.g. "calculate P(X=2); derive an unfamiliar index".
  clauses<-strsplit(request,"[;!?]",perl=TRUE)[[1L]]
  if(length(clauses)>16L)return("REQUEST_ACTION_CAP_EXCEEDED")
  if(length(clauses)>1L)for(i in seq_along(clauses)){
    clause<-trimws(clauses[[i]])
    if(i==1L||!nzchar(clause))next
    if(.ru_w4_hit("^(?:also\\s+)?(?:compute|calculate|derive|show|report)\\b",
                  clause)){
      begin<-regexpr(clause,request,fixed=TRUE)[[1L]]+inv$request_start-1L
      if(!any(vapply(atoms,function(a)a$start>=begin,logical(1L))) &&
         !.ru_w4_hit("\\bp\\s*\\(",clause))
        return("ADDITIONAL_REQUEST_ACTION_UNSUPPORTED")
    }
  }
  # Independently introduced verbs (including comma-separated verbs)
  # define a new obligation even without an "and". A recognized target in
  # another clause cannot discharge it. Exceptions are fixed model actions
  # that inherently return the registered OLS coefficients or t test outputs.
  actions<-gregexpr(paste0("\\b(?:calculate|compute|find|give|report|",
                            "return|estimate|determine|derive|fit|predict|",
                            "construct|generate|produce|display|show|plot|",
                            "draw|output|retrieve|load|read|access|run|test|",
                            "list|create|build|explain|summari[sz]e)\\b"),
                    request,perl=TRUE)[[1L]]
  if(actions[[1L]]>0L){
    if(length(actions)>24L)return("REQUEST_ACTION_CAP_EXCEEDED")
    for(i in seq_along(actions)){
      from<-actions[[i]]
      until<-if(i<length(actions))actions[[i+1L]]-1L else nchar(request)
      action_clause<-substr(request,from,until)
      end_marker<-regexpr("[;!?]",action_clause,perl=TRUE)[[1L]]
      if(end_marker>0L)action_clause<-substr(action_clause,1L,end_marker-1L)
      begin<-inv$request_start+from-1L
      end<-begin+nchar(action_clause)-1L
      has_atom<-any(vapply(atoms,function(a)
        a$start>=begin&&a$start<=end,logical(1L)))
      has_event<-distribution&&.ru_w4_hit("\\bp\\s*\\(",action_clause)
      t_test<-family=="inference.one_sample_t"&&
        .ru_w4_hit("^test\\b|t[- ]test\\b",action_clause)&&
        all(c("t_statistic","p_value")%in%outputs)
      t_ci<-family=="inference.one_sample_t"&&
        .ru_w4_hit("\\bconfidence\\s+interval\\b",action_clause)&&
        all(c("ci_lower","ci_upper")%in%outputs)
      ols_fit<-family=="regression.simple_ols"&&
        .ru_w4_hit("^fit\\b",action_clause)&&
        all(c("intercept","slope")%in%outputs)
      code_only<-.ru_w4_hit("\\b(?:r\\s+code|code\\s+preview|r\\s+script)\\b",
                           action_clause)
      if(!has_atom&&!has_event&&!t_test&&!t_ci&&!ols_fit&&!code_only)
        return("ADDITIONAL_REQUEST_ACTION_UNSUPPORTED")
    }
  }
  NULL
}

.ru_w4_parse<-function(question) {
  if(!is.character(question)||length(question)!=1L||is.na(question)||
     !nzchar(trimws(question))||!validUTF8(question)||
     nchar(question,type="bytes")>4096L)
    return(.ru_w4_result("INVALID","QUESTION_INVALID","",NA_character_))
  s<-.ru_w4_norm(question)
  flags<-c(
    .ru_w4_hit("\\b(?:mean|median|standard deviation|variance|quantile|percentile|quartile|average)\\b",s),
    .ru_w4_hit("\\bp\\s*\\(\\s*a\\b|\\b(?:union|intersection|complement|conditional probability)\\b",s),
    .ru_w4_hit("\\b(?:binomial|bernoulli trials?)\\b",s),
    .ru_w4_hit("\\bpoisson\\b",s),
    .ru_w4_hit("\\b(?:normal|gaussian)\\b",s),
    .ru_w4_hit("\\b(?:continuous uniform|uniform distribution|uniform u\\s*\\()\\b",s),
    .ru_w4_hit("\\b(?:one[- ]sample\\s+t|student'?s?\\s+t|t[- ]test|t\\s+confidence interval)\\b",s),
    .ru_w4_hit("\\b(?:ordinary least squares|\\bols\\b|simple linear regression|linear regression|regression line)\\b",s))
  ids<-c("descriptive.numeric","probability.event_scalar","distribution.binomial",
         "distribution.poisson","distribution.normal","distribution.uniform_continuous",
         "inference.one_sample_t","regression.simple_ols")
  if(flags[[7L]] &&
     .ru_w4_hit("\\b(?:approximately normal|normally distributed|normality|normal population)\\b",s) &&
     !.ru_w4_hit("\\bnormal distribution\\b",s))
    flags[[5L]]<-FALSE
  if(any(flags[3:8]) &&
     !.ru_w4_hit("\\b(?:population|sample)\\s+(?:variance|standard deviation)\\s+of\\s+(?:data|observations|numbers)\\b",s))
    flags[[1L]]<-FALSE
  dice<-.ru_w4_hit("\\b(?:dice|die)\\b|(?<![a-z])[0-9]*d[0-9]+\\b",s)
  other<-.ru_w4_hit("\\b(?:permutation|bootstrap|holm|chi[- ]?square|anova|welch|paired|multiple regression|multivariable regression|nonlinear regression|two[- ]predictor linear model|hypergeometric|exponential|arima|acf|moran|kriging|geog(?:raphy|raphic)?|gis|spatial|geodesic|time series|survey|sampling|hypothesis test|confidence interval|correlation|covariance|factorial|resampling|logistic|categorical|histogram)\\b",s)
  hits<-which(flags)
  if(dice&&!length(hits))return(NULL)
  family<-if(length(hits))ids[[hits[[1L]]]] else
    if(other)"unimplemented.statistical_method" else
    if(.ru_w4_hit("\\bp\\s*\\(\\s*[xz]|\\b(?:cdf|pmf|distribution)\\b",s))
      "unspecified.statistical_model" else return(NULL)
  ret<-function(status,reason,inp=list(),outs=character(),missing=character(),
               assum=list(),fam=family) {
    # Omit absent/invalid optional literals; never serialize NULL or NA as a
    # supplied numeric value even in a NEEDS_INPUT or INVALID refusal.
    if(is.list(inp)&&length(inp))
      inp<-inp[!vapply(inp,function(z)is.null(z) ||
        (is.atomic(z)&&anyNA(z)),logical(1L))]
    if(identical(status,"SOLVED")) {
      uncovered<-.ru_w4_request_complete(s,fam,outs)
      if(is.null(uncovered))
        uncovered<-.ru_w4_request_accountable(s,fam,outs)
      if(!is.null(uncovered)) {
        status<-"UNSUPPORTED"
        reason<-uncovered
        missing<-character()
      }
    }
    .ru_w4_result(status,reason,question,fam,inp,outs,assum,missing)
  }
  # Do not misinterpret a legitimate P(3<X<5) as HTML.
  if(.ru_w4_hit("<\\s*/?\\s*[a-z][a-z0-9]*(?:\\s+[^>]*?)?\\s*/?>|\\x60|\\b(?:system|eval|parse|unlink|source|setwd|file\\.remove)\\s*\\(|ignore\\s+(?:all\\s+)?(?:previous|prior)\\s+instructions",s))
    return(ret("INVALID","UNSAFE_QUESTION_CONTENT"))
  # A complete model cannot include an unnoticed random operand,
  # shifted output, unexplained transformation, or unsupported side request.
  if(.ru_w4_hit("\\b(?:coin toss|coin flip|flipped coin|spinner|independent coin|random noise|random number|stochastic noise|plus (?:a|an|one) die)\\b",s))
    return(ret("UNSUPPORTED","ADDITIONAL_RANDOM_COMPONENT_UNSUPPORTED"))
  if(.ru_w4_hit("\\b(?:plus|minus|subtract|add)\\s+[0-9]+(?:\\.[0-9]+)?\\s*(?:to|from)?\\s*(?:the\\s+)?(?:sum|answer|result)?\\s*$|\\b(?:shifted|(?<!r-)squared|scaled|doubled|twice the|multiplied|divide by)\\b",s))
    return(ret("UNSUPPORTED","OUTPUT_TRANSFORMATION_UNSUPPORTED"))
  tokens<-regmatches(s,gregexpr(.ru_w4_numre,s,perl=TRUE))[[1L]]
  if(length(tokens)>256L)
    return(ret("UNSUPPORTED","INPUT_CAP_EXCEEDED"))
  if(length(hits)>1L||dice&&length(hits))
    return(ret("INVALID","CONFLICTING_STATISTICAL_MODELS"))
  if(.ru_w4_hit("\\b(?:without replacement|clustered|autocorrelated|mixed effects|spatial dependence|repeated measures|paired observations|survey weighted)\\b",s))
    return(ret("UNSUPPORTED","DESIGN_INCOMPATIBLE"))
  # Disjoint statistical methods have priority over an incidental word
  # such as "mean", "variance", "sample", or a numeric vector. This is the
  # specific negative gate for independent A5 holdout challenges.
  if(.ru_w4_hit("\\b(?:bootstrap|permutation|resampling|moving average|acf|arima|holm|benjamini|spatial|moran|kriging|anova|chi[- ]?square|logistic|sample correlation|pearson|randomization|semivariogram|time series)\\b",s) &&
     !.ru_w4_hit("\\b(?:a normal distribution|binomial distribution|poisson distribution)\\b",s))
    return(ret("UNSUPPORTED","STATISTICAL_METHOD_NOT_IMPLEMENTED"))
  if(family=="unimplemented.statistical_method")
    return(ret("UNSUPPORTED","STATISTICAL_METHOD_NOT_IMPLEMENTED"))
  if(family=="unspecified.statistical_model")
    return(ret("NEEDS_INPUT","SPECIFIC_MODEL_REQUIRED",missing="statistical_model"))
  if(family=="distribution.poisson" &&
     .ru_w4_hit("\\b(?:waiting\\s*[- ]?time|wait\\s+(?:until|for)|inter[- ]?arrival|interarrival|time\\s+(?:to|until|between)\\s+(?:(?:the|a)\\s+)?(?:first|next|events?|arrivals?)|continuous\\s+(?:time|duration)|exponential\\s+(?:waiting|time))\\b",s))
    # A Poisson random variable counts events; continuous waiting time needs
    # a separate, explicitly specified duration model and assumptions.
    return(ret("UNSUPPORTED","POISSON_WAITING_TIME_MODEL_INCOMPATIBLE"))
  if(.ru_w4_hit("\\b(?:and|plus)\\s+(?:a\\s+)?(?:histogram|boxplot|chi[- ]square|bootstrap|permutation|skewness|kurtosis|standard error|correlation|anova|plot|forecast)\\b",s))
    return(ret("UNSUPPORTED","ADDITIONAL_OUTPUT_UNSUPPORTED"))
  if(.ru_w4_hit("\\b(?:my dataframe|my data frame|my dataset|from csv|from file|read\\.csv|in column|from dataset)\\b",s))
    return(ret("NEEDS_INPUT","INLINE_DATA_REQUIRED",missing="inline_data"))
  if(family=="descriptive.numeric" &&
     .ru_w4_hit("\\b(?:without stating whether|without specifying whether|not specifying whether|unspecified whether|unclear whether)\\b",s))
    return(ret("NEEDS_INPUT","VARIANCE_CONVENTION_REQUIRED",
               missing="sample_or_population"))
  if(family=="descriptive.numeric"){
    if(.ru_w4_hit("\\b(?:weighted|frequency weights)\\b",s))
      return(ret("UNSUPPORTED","WEIGHTED_METHOD_UNSUPPORTED"))
    if(.ru_w4_hit("\\b(?:metres?|kilometres?|fahrenheit|celsius)\\b",s))
      return(ret("UNSUPPORTED","UNIT_COMPARABILITY_NOT_ESTABLISHED"))
    outs<-character()
    if(.ru_w4_hit("\\b(?:mean|average)\\b",s))outs<-c(outs,"mean")
    if(.ru_w4_hit("\\bmedian\\b",s))outs<-c(outs,"median")
    v<-.ru_w4_hit("\\bvariance\\b",s); sd<-.ru_w4_hit("\\bstandard deviation\\b",s)
    conv<-if(.ru_w4_hit("\\b(?:population|entire population|denominator\\s+n(?!\\s*-))\\b",s))"population" else
      if(.ru_w4_hit("\\b(?:sample|n\\s*-\\s*1)\\b",s))"sample" else NA_character_
    if((v||sd)&&is.na(conv))return(ret("NEEDS_INPUT","VARIANCE_CONVENTION_REQUIRED",
                                     missing="sample_or_population"))
    if(v)outs<-c(outs,paste0(conv,"_variance"))
    if(sd)outs<-c(outs,paste0(conv,"_sd"))
    if(.ru_w4_hit("\\b(?:quantile|quartile|percentile)\\b",s))outs<-c(outs,"quantile")
    if(!length(outs))return(ret("NEEDS_INPUT","STATISTIC_REQUIRED",missing="requested_outputs"))
    x<-.ru_w4_vec(s,"x|values|observations|sample|data|numbers",TRUE)
    if(is.null(x))return(ret("NEEDS_INPUT","INLINE_NUMERIC_VALUES_REQUIRED",
                          outs=outs,missing="values"))
    if(anyNA(x)||length(x)<2L)return(ret("INVALID","NUMERIC_DATA_INVALID",outs=outs))
    inp<-list(values=x)
    if (!is.na(conv)) inp$convention<-conv
    if("quantile"%in%outs){
      z<-.ru_w4_group(paste0("\\b(",.ru_w4_numre,")(?:st|nd|rd|th)?\\s*percentile"),s)
      if(!length(z))z<-.ru_w4_group(paste0("\\bquantile\\s*(?:at|of|=)?\\s*(",.ru_w4_numre,")"),s)
      if(!length(z))return(ret("NEEDS_INPUT","QUANTILE_LEVEL_REQUIRED",inp,outs,"quantile_probability"))
      prob<-.ru_w4_num(z[[1L]])
      if(is.null(prob))return(ret("INVALID","QUANTILE_LEVEL_INVALID",inp,outs))
      if(.ru_w4_hit("percentile",s)||prob>1)prob<-prob/100
      if(prob<0||prob>1)return(ret("INVALID","QUANTILE_LEVEL_INVALID",inp,outs))
      if(!.ru_w4_hit("\\btype[- ]?7\\b",s))
        return(ret("NEEDS_INPUT","QUANTILE_METHOD_REQUIRED",inp,outs,"quantile_method"))
      inp$quantile_probability<-prob
    }
    assum<-list(missing="No missing observations are supplied.")
    if(!is.na(conv))assum$convention<-conv
    return(ret("SOLVED","W4_INPUTS_VALID",inp,outs,assum=assum))
  }
  if(family=="probability.event_scalar"){
    op<-if(.ru_w4_hit("\\bunion\\b|a\\s+or\\s+b",s))"union" else
      if(.ru_w4_hit("\\b(?:given b|conditional)\\b|p\\s*\\(\\s*a\\s*\\|\\s*b",s))"conditional" else
      if(.ru_w4_hit("\\bcomplement\\b|a\\s*\\^\\s*c\\b",s))"complement" else NULL
    if(is.null(op))return(ret("NEEDS_INPUT","EVENT_OPERATION_REQUIRED",missing="event_operation"))
    a<-.ru_w4_key(s,"p\\s*\\(\\s*a\\s*\\)",lo=0,hi=1)
    b<-.ru_w4_key(s,"p\\s*\\(\\s*b\\s*\\)",lo=0,hi=1)
    joint<-.ru_w4_key(s,"p\\s*\\(\\s*a\\s*(?:intersection|and)\\s*b\\s*\\)",lo=0,hi=1)
    raw_a<-.ru_w4_key(s,"p\\s*\\(\\s*a\\s*\\)")
    raw_b<-.ru_w4_key(s,"p\\s*\\(\\s*b\\s*\\)")
    raw_j<-.ru_w4_key(s,"p\\s*\\(\\s*a\\s*(?:intersection|and)\\s*b\\s*\\)")
    if(any(vapply(list(raw_a,raw_b,raw_j),function(z)!is.null(z)&&(z<0||z>1),logical(1L))))
      return(ret("INVALID","PROBABILITY_OUT_OF_RANGE"))
    inp<-list(p_a=a,p_b=b,p_intersection=joint)
    # Unstated event operands are missing, never present-as-NULL typed numbers.
    inp<-inp[!vapply(inp,is.null,logical(1L))]
    needed<-switch(op,union=c("p_a","p_b","p_intersection"),
                   conditional=c("p_b","p_intersection"),complement="p_a")
    missing<-needed[vapply(needed,function(n)is.null(inp[[n]]),logical(1L))]
    if(length(missing))return(ret("NEEDS_INPUT","EVENT_PROBABILITIES_REQUIRED",inp,op,missing))
    if(!is.null(a)&&!is.null(b)&&!is.null(joint)&&
       (joint<max(0,a+b-1)-1e-12||joint>min(a,b)+1e-12))
      return(ret("INVALID","PROBABILITY_AXIOMS_VIOLATED",inp,op))
    if(op=="conditional"&&b==0)return(ret("INVALID","ZERO_CONDITIONING_PROBABILITY",inp,op))
    return(ret("SOLVED","W4_INPUTS_VALID",inp,op,
               assum=list(model="Events share one consistent probability space.")))
  }
  if(family%in%c("distribution.binomial","distribution.poisson",
                 "distribution.normal","distribution.uniform_continuous")){
    moments<-character()
    if(.ru_w4_hit("\\b(?:expected value|expectation|mean of (?:the )?distribution)\\b",s))
      moments<-c(moments,"expected_value")
    if(.ru_w4_hit("\\bvariance\\b",s))
      moments<-c(moments,"variance")
    event<-.ru_w4_event(s)
    if(is.null(event) && family=="distribution.normal" &&
       .ru_w4_hit("\\b(?:percentile|quantile)\\b",s)) {
      z<-.ru_w4_group(paste0("\\b(",.ru_w4_numre,")(?:st|nd|rd|th)?\\s*percentile\\b"),s)
      if(!length(z))z<-.ru_w4_group(paste0("\\bquantile\\s*(?:at|of|=)?\\s*(",.ru_w4_numre,")"),s)
      if(!length(z))return(ret("NEEDS_INPUT","QUANTILE_LEVEL_REQUIRED",missing="quantile_probability"))
      qp<-.ru_w4_num(z[[1L]])
      if(is.null(qp))return(ret("INVALID","QUANTILE_LEVEL_INVALID"))
      if(.ru_w4_hit("percentile",s)||qp>1)qp<-qp/100
      if(qp<=0||qp>=1)return(ret("INVALID","QUANTILE_LEVEL_INVALID"))
      event<-list(type="quantile",probability=qp)
    }
    wants_event<-.ru_w4_hit("\\bp\\s*\\(|\\b(?:pmf|cdf|tail|probability)\\b",s)
    if(is.null(event) && (wants_event||!length(moments)))
      return(ret("NEEDS_INPUT","EVENT_THRESHOLD_REQUIRED",outs=moments,missing="event"))
    if(!is.null(event)&&any(vapply(event,is.null,logical(1L))))
      return(ret("INVALID","EVENT_LITERAL_INVALID"))
    outputs<-c(if(!is.null(event))if(event$type=="quantile")"quantile" else "probability",
               moments)
    if(family=="distribution.binomial"){
      n<-.ru_w4_key(s,"n|trials?",TRUE,0,5000)
      prob<-.ru_w4_key(s,"p|success probability",FALSE,0,1)
      raw_n<-.ru_w4_key(s,"n|trials?",FALSE)
      raw_p<-.ru_w4_key(s,"p|success probability",FALSE)
      if(!is.null(raw_n)&&(raw_n<0||raw_n!=floor(raw_n)))
        return(ret("INVALID","BINOMIAL_TRIALS_INVALID"))
      if(!is.null(raw_n)&&raw_n>5000)
        return(ret("UNSUPPORTED","INPUT_CAP_EXCEEDED"))
      if(!is.null(raw_p)&&(raw_p<0||raw_p>1))
        return(ret("INVALID","PROBABILITY_OUT_OF_RANGE"))
      inp<-list(n=n,p=prob)
      if(!is.null(event))inp$event<-event
      missing<-c(if(is.null(n))"n",if(is.null(prob))"p")
      if(length(missing))return(ret("NEEDS_INPUT","BINOMIAL_PARAMETERS_REQUIRED",inp,outputs,missing))
      if(.ru_w4_hit("\\b(?:waiting time|minutes|without replacement)\\b",s))
        return(ret("UNSUPPORTED","INCOMPATIBLE_VARIABLE_MODEL",inp,outputs))
      if(!is.null(event)&&event$type%in%c("interval","quantile"))return(ret("UNSUPPORTED","DISCRETE_INTERVAL_UNSUPPORTED",inp,outputs))
      if(!is.null(event)&&(is.null(event$k)||event$k!=floor(event$k)))return(ret("INVALID","DISCRETE_THRESHOLD_INVALID",inp,outputs))
      return(ret("SOLVED","W4_INPUTS_VALID",inp,outputs,
                 assum=list(model="n iid Bernoulli trials with fixed success probability.")))
    }
    if(family=="distribution.poisson"){
      lambda<-.ru_w4_key(s,"lambda|rate",FALSE,0,1e6)
      raw_lambda<-.ru_w4_key(s,"lambda|rate")
      if(!is.null(raw_lambda)&&raw_lambda<0)
        return(ret("INVALID","POISSON_RATE_INVALID"))
      if(!is.null(raw_lambda)&&raw_lambda>1e6)
        return(ret("UNSUPPORTED","INPUT_CAP_EXCEEDED"))
      inp<-list(lambda=lambda)
      if(!is.null(event))inp$event<-event
      if(is.null(lambda))return(ret("NEEDS_INPUT","POISSON_RATE_REQUIRED",inp,outputs,"lambda"))
      if(!is.null(event)&&(is.null(event$k)||event$type%in%c("interval","quantile")||event$k!=floor(event$k)))
        return(ret("UNSUPPORTED","COUNT_EVENT_UNSUPPORTED",inp,outputs))
      return(ret("SOLVED","W4_INPUTS_VALID",inp,outputs,
                 assum=list(model="Poisson number of arrivals in the specified interval.")))
    }
    if(family=="distribution.normal"){
      standard<-.ru_w4_hit("\\bstandard normal\\b|\\bp\\s*\\(\\s*z",s)
      mu<-if(standard)0 else .ru_w4_key(s,"mu|mean")
      sigma<-if(standard)1 else .ru_w4_key(s,"sigma|sd|standard deviation")
      inp<-list(mu=mu,sigma=sigma)
      if(!is.null(event))inp$event<-event
      missing<-c(if(is.null(mu))"mu",if(is.null(sigma))"sigma")
      if(length(missing))return(ret("NEEDS_INPUT","NORMAL_PARAMETERS_REQUIRED",inp,outputs,missing))
      if(sigma<=0)return(ret("INVALID","NORMAL_SD_INVALID",inp,outputs))
      if(!is.null(event)&&event$type=="exact")return(ret("UNSUPPORTED","CONTINUOUS_POINT_EVENT_UNSUPPORTED",inp,outputs))
      return(ret("SOLVED","W4_INPUTS_VALID",inp,outputs,
                 assum=list(model="Continuous normal with stated mu and sigma.")))
    }
    if(family=="distribution.uniform_continuous"){
      ab<-.ru_w4_group(paste0("\\bu\\s*\\(\\s*(",.ru_w4_numre,")\\s*,\\s*(",
                               .ru_w4_numre,")\\s*\\)"),s)
      a<-if(length(ab)==2L).ru_w4_num(ab[[1L]]) else .ru_w4_key(s,"a|lower")
      b<-if(length(ab)==2L).ru_w4_num(ab[[2L]]) else .ru_w4_key(s,"b|upper")
      inp<-list(a=a,b=b)
      if(!is.null(event))inp$event<-event
      missing<-c(if(is.null(a))"a",if(is.null(b))"b")
      if(length(missing))return(ret("NEEDS_INPUT","UNIFORM_BOUNDS_REQUIRED",inp,outputs,missing))
      if(a>=b)return(ret("INVALID","UNIFORM_BOUNDS_INVALID",inp,outputs))
      if(!is.null(event)&&event$type=="exact")return(ret("UNSUPPORTED","CONTINUOUS_POINT_EVENT_UNSUPPORTED",inp,outputs))
      return(ret("SOLVED","W4_INPUTS_VALID",inp,outputs,
                 assum=list(model="Continuous uniform distribution with finite ordered bounds.")))
    }
  }
  if(family=="inference.one_sample_t"){
    if(.ru_w4_hit("\\b(?:known population sigma|z[- ]test|known sigma)\\b",s))
      return(ret("UNSUPPORTED","KNOWN_SIGMA_Z_METHOD_REQUIRED"))
    mode<-if(.ru_w4_hit("\\b(?:confidence interval|\\bci\\b)\\b",s))"interval" else "test"
    outs<-if(mode=="test")c("t_statistic","degrees_freedom","p_value") else c("ci_lower","ci_upper")
    x<-.ru_w4_vec(s,"x|observations|sample|data|values",TRUE)
    if(is.null(x))return(ret("NEEDS_INPUT","INLINE_SAMPLE_REQUIRED",outs=outs,missing="values"))
    if(anyNA(x)||length(x)<3L||stats::sd(x)==0)return(ret("INVALID","SAMPLE_VALUES_INVALID",outs=outs))
    declared_independent<-.ru_w4_hit("\\b(?:independent|iid|random sample)\\b",s)
    declared_normal<-.ru_w4_hit("\\b(?:normal population|approximately normal|normally distributed|normality)\\b",s)
    if(!declared_independent||!declared_normal)
      return(ret("NEEDS_INPUT","T_DESIGN_ASSUMPTIONS_REQUIRED",
                 list(values=x),outs,
                 c(if(!declared_independent)"independent_sampling",
                   if(!declared_normal)"normality_assumption")))
    if(mode=="test"){
      mu0<-.ru_w4_key(s,"mu0|mu_0|null mean|null value")
      if(is.null(mu0))return(ret("NEEDS_INPUT","NULL_MEAN_REQUIRED",list(values=x),outs,"mu0"))
      alternative<-if(.ru_w4_hit("\\b(?:two[- ]sided|two[- ]tailed)\\b",s))"two.sided" else
        if(.ru_w4_hit("\\b(?:greater|right[- ]tailed)\\b",s))"greater" else
        if(.ru_w4_hit("\\b(?:less|left[- ]tailed)\\b",s))"less" else NULL
      if(is.null(alternative))return(ret("NEEDS_INPUT","TEST_ALTERNATIVE_REQUIRED",
                                       list(values=x,mu0=mu0),outs,"alternative"))
      inp<-list(values=x,mode=mode,mu0=mu0,alternative=alternative)
    } else {
      z<-.ru_w4_group(paste0("\\b(",.ru_w4_numre,")\\s*%\\s*(?:student\\s+t\\s+)?confidence"),s)
      if(!length(z))return(ret("NEEDS_INPUT","CONFIDENCE_LEVEL_REQUIRED",list(values=x),outs,"confidence_level"))
      level<-.ru_w4_num(z[[1L]])
      if(is.null(level)||level<=0||level>=100)return(ret("INVALID","CONFIDENCE_LEVEL_INVALID",list(values=x),outs))
      if(!.ru_w4_hit("\\btwo[- ]sided\\b",s))
        return(ret("NEEDS_INPUT","INTERVAL_SIDE_REQUIRED",list(values=x),outs,"side"))
      inp<-list(values=x,mode=mode,confidence_level=level/100,alternative="two.sided")
    }
    return(ret("SOLVED","W4_INPUTS_VALID",inp,outs,
               assum=list(independence="Declared, not independently verified.",
                          normality="Assumed approximately normal by question.")))
  }
  if(family=="regression.simple_ols"){
    if(.ru_w4_hit("\\b(?:multiple|multivariable|logistic|mixed|polynomial|weighted|spatial)\\b",s))
      return(ret("UNSUPPORTED","REGRESSION_MODEL_UNSUPPORTED"))
    x<-.ru_w4_vec(s,"x");y<-.ru_w4_vec(s,"y")
    if(is.null(x)||is.null(y)){
      pairs<-regmatches(s,gregexpr(paste0("\\(\\s*",.ru_w4_numre,"\\s*,\\s*",
                                          .ru_w4_numre,"\\s*\\)"),s,perl=TRUE))[[1L]]
      if(length(pairs)>=3L&&length(pairs)<=256L){
        coords<-lapply(pairs,function(pair)as.double(regmatches(pair,gregexpr(.ru_w4_numre,pair,perl=TRUE))[[1L]]))
        x<-vapply(coords,function(z)z[[1L]],numeric(1L))
        y<-vapply(coords,function(z)z[[2L]],numeric(1L))
      }
    }
    outs<-character()
    if(.ru_w4_hit("\\b(?:fit|regression|line|coefficients?|intercept|slope)\\b",s))
      outs<-c("intercept","slope")
    if(.ru_w4_hit("\\b(?:r[- ]?squared|r\\s*\\^\\s*2)\\b",s))
      outs<-c(outs,"r_squared")
    if(.ru_w4_hit("\\b(?:predict|prediction)\\b",s))outs<-c(outs,"prediction")
    if(!length(outs))return(ret("NEEDS_INPUT","REGRESSION_OUTPUT_REQUIRED",missing="requested_outputs"))
    if(is.null(x)||is.null(y))
      return(ret("NEEDS_INPUT","PAIRED_NUMERIC_DATA_REQUIRED",outs=outs,missing=c("x","y")))
    inp<-list(x=x,y=y)
    if(length(x)!=length(y)||length(x)<3L||anyNA(x)||anyNA(y)||
       stats::var(x)==0||stats::var(y)==0)
      return(ret("INVALID","OLS_DESIGN_INVALID",inp,outs))
    if(.ru_w4_hit("\\b(?:p[- ]value|standard error|confidence interval|causes|causal)\\b",s))
      return(ret("UNSUPPORTED","OLS_INFERENCE_UNSUPPORTED",inp,outs))
    if("prediction"%in%outs){
      at<-.ru_w4_key(s,"x0|x_new|predict\\s+(?:y\\s+)?at\\s+x")
      if(is.null(at))return(ret("NEEDS_INPUT","PREDICTION_VALUE_REQUIRED",inp,outs,"prediction_x"))
      if(at<min(x)||at>max(x))
        return(ret("UNSUPPORTED","EXTRAPOLATION_REQUIRES_REVIEW",inp,outs))
      inp$prediction_x<-at
    }
    return(ret("SOLVED","W4_INPUTS_VALID",inp,outs,
               assum=list(model="Simple descriptive OLS; x predictor, y response.",
                          inference="No causal claim or independent-error inference.")))
  }
  ret("UNSUPPORTED","FAMILY_NOT_IMPLEMENTED")
}