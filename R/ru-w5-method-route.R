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

# W5-R8: closed statistical-task compatibility contract.
# The method catalog describes only outputs implemented by ru_apply(); a
# matching noun or lexical search score is never sufficient authorization
# for a statistically different method. No question or user data is run.
.ru_w5_method_capabilities <- local({
  cached <- NULL
  function() {
    if (!is.null(cached)) return(cached)
    signatures <- list(
      import_csv="\\b(?:import|load|read)\\b.{0,45}\\b(?:csv|comma[- ]separated)\\b|\\bcsv\\b.{0,45}\\b(?:import|load|read)\\b",
      inspect_columns="\\b(?:inspect|list|examine|view|check)\\b.{0,35}\\b(?:columns?|variables?|fields?|data\\s*frame|dataset)\\b|\\b(?:column\\s+names?|column\\s+types?|data\\s+structure|dataset\\s+schema)\\b",
      filter_rows="\\b(?:filter|subset|keep|retain|select)\\b.{0,38}\\b(?:rows?|records?|observations?)\\b|\\b(?:rows?|records?)\\b.{0,30}\\b(?:where|meeting|satisfying)\\b",
      group_means="\\b(?:(?:for\\s+each|by|per)\\s+(?:group|category|region|site)\\b.{0,45}\\b(?:mean|average)|group\\s+means?|grouped?\\s+(?:means?|averages?)|(?:means?|averages?)\\s+(?:by|per|for\\s+each|across)\\s+(?:each\\s+)?(?:group|category|site|region|treatment|class))\\b|\\bcompare\\s+(?:the\\s+)?mean\\s+for\\s+each\\s+group\\b",
      missing_values="\\b(?:missing\\s+(?:values?|observations?|entries|data)|missingness|count\\s+(?:missing|na)\\b|\\bna\\s+counts?|missing\\b.{0,32}\\b(?:counts?|available|observations?))\\b",
      mean_median="\\b(?:mean|average|median)\\b",
      sample_sd="\\b(?:sample\\s+sd|sample\\s+standard\\s+deviation|standard\\s+deviation|\\bsd\\b|sample\\s+variance)\\b",
      five_number="\\b(?:five[- ]number|quartiles?|interquartile\\s+range|\\biqr\\b|\\bq[13]\\b)\\b",
      percentile_cutoff="\\b(?:percentile\\s+cutoff|sample\\s+percentile|empirical\\s+(?:percentile|quantile)|quantile\\s+of\\s+(?:the\\s+)?(?:data|observations)|\\b[0-9]+(?:st|nd|rd|th)\\s+percentile)\\b",
      relative_frequency="\\b(?:categor(?:y|ical)\\s+proportions?|relative\\s+frequenc(?:y|ies)|frequency\\s+table|category\\s+counts?|tabulat(?:e|ion)|proportions?\\s+(?:by|for)\\s+categor(?:y|ies)|percentage\\s+table)\\b",
      categorical_mode="\\b(?:categorical\\s+mode|most\\s+common\\s+category|most\\s+frequent\\s+category|\\bmode\\b)\\b",
      z_score="\\b(?:z[- ]?scores?|standard\\s+scores?|standardiz(?:e|ed|ing)\\s+(?:numeric\\s+)?(?:values?|measurements?|observations?))\\b",
      histogram="\\b(?:histograms?|histgram|binned\\s+(?:numeric|continuous)\\s+plot)\\b",
      bar_chart="\\b(?:bar\\s*(?:charts?|graphs?|plots?)|barplots?|categor(?:y|ical)[- ]count\\s+bars?|bars?\\s+of\\s+(?:category|categorical)\\s+counts?|count\\s+bars?)\\b",
      boxplot="\\b(?:box\\s*plots?|box[- ]and[- ]whisker\\s+plots?)\\b",
      grouped_boxplot="\\b(?:grouped\\s+box\\s*plots?|box\\s*plots?\\s+(?:by|per|across|grouped\\s+by|separated\\s+by)\\s+(?:a\\s+)?(?:group|category|site|region|treatment|class)|box\\s*plots?\\s+of\\s+.*\\s+by\\s+(?:group|category))\\b",
      scatterplot="\\b(?:scatter\\s*plots?|scatter\\s*diagrams?|plot\\s+one\\s+quantitative\\s+variable\\s+against\\s+another|plot\\s+.*\\s+against\\s+.*)\\b|\\b(?:plot|draw|graph)\\b.{0,48}\\b(?:x\\s+(?:and|versus|vs\\.?|against|by)\\s+y|y\\s+(?:and|versus|vs\\.?|against|by)\\s+x|(?:two|paired)\\s+(?:numeric|numerical|quantitative|continuous)\\s+(?:variables?|measurements?|columns?))\\b|\\b(?:plot|draw|graph)\\b.{0,48}\\b(?:numeric|quantitative)\\s+[xy]\\s+(?:and|versus|vs\\.?|against|by)\\s+(?:numeric|quantitative)\\s+[xy]\\b|\\b(?:plot|draw|graph)\\b.{0,48}\\b(?:relationship|association)\\s+between\\s+(?:two|2)\\s+(?:(?:numeric|numerical|quantitative|continuous)\\s+)?(?:columns?|variables?|measurements?)\\b",
      zero_correlation="\\b(?:zero\\s+correlation|zero\\s+pearson\\s+r|nonlinear\\s+pattern\\s+with\\s+zero\\s+correlation)\\b",
      normal_shaded_area="\\b(?:shade|shading|shaded|colour\\s+the\\s+area|color\\s+the\\s+area|area\\s+under\\s+(?:the\\s+)?normal\\s+curve)\\b",
      line_chart="\\b(?:line\\s+(?:charts?|plots?|graphs?)|time[- ](?:ordered|series)\\s+(?:line|plot|graph)|plot\\s+.*\\s+over\\s+time|time[- ]ordered\\s+(?:measurements?|values?)|time\\s+series\\s+plots?)\\b",
      moving_average="\\b(?:moving\\s+averages?|rolling\\s+(?:means?|averages?)|running\\s+means?|smooth\\s+.*\\s+moving\\s+window)\\b",
      autocorrelation="\\b(?:autocorrelations?|\\bacf\\b|serial\\s+correlation|lagged\\s+correlation)\\b",
      stationarity="\\b(?:stationarit(?:y|ies)|stationary|stable\\s+mean\\s+over\\s+time|time[- ]series\\s+stability)\\b",
      event_probability="\\b(?:event\\s+probability|probability\\s+of\\s+an?\\s+event|empirical\\s+probability|event\\s+rate|fraction\\s+of\\s+events?)\\b",
      conditional_probability="\\b(?:given\\s+(?:event\\s+)?[ab]\\b.{0,50}\\bprobability|conditional\\s+event\\s+probability|conditional\\s+probability|probability\\s+of\\s+\\w+\\s+given\\s+\\w+|given\\s+that|conditioned\\s+on)\\b|\\bp\\s*\\(\\s*\\w+\\s*\\|\\s*\\w+\\s*\\)",
      probability_union="\\b(?:union\\s+probability|probability\\s+of\\s+(?:a\\s+or\\s+b|either\\s+event)|union\\s+of\\s+events?|probability\\s+of\\s+at\\s+least\\s+one\\s+of\\s+two\\s+events)\\b",
      binomial_exact="\\b(?:binomial\\s+.*\\b(?:exactly|exact|precisely)|(?:exactly|precisely)\\s+.*\\b(?:successes?|binomial)|binomial\\s+point\\s+probability)\\b",
      binomial_at_least="\\b(?:binomial\\s+.*\\b(?:at\\s+least|no\\s+fewer\\s+than)|(?:at\\s+least|no\\s+fewer\\s+than)\\s+.*\\bsuccesses?)\\b",
      normal_left_tail="\\b(?:normal|gaussian)\\b.*\\b(?:left\\s+tail|lower\\s+tail|below|less\\s+than|at\\s+most|cdf)\\b|\\b(?:left|lower)\\s+tail\\b.*\\b(?:normal|gaussian)\\b",
      normal_right_tail="\\b(?:normal|gaussian)\\b.*\\b(?:right\\s+tail|upper\\s+tail|above|greater\\s+than|at\\s+least|exceeds?)\\b|\\b(?:right|upper)\\s+tail\\b.*\\b(?:normal|gaussian)\\b",
      normal_percentile="\\b(?:normal|gaussian)\\b.*\\b(?:percentile|quantile|inverse\\s+cdf)\\b|\\b(?:percentile|quantile)\\b.*\\b(?:normal|gaussian)\\b",
      discrete_expectation="\\b(?:expected\\s+value|expectation)\\b.*\\b(?:discrete|random\\s+variable|probability\\s+mass)\\b|\\bdiscrete\\b.*\\b(?:expected\\s+value|expectation)\\b",
      sample_random="\\b(?:(?:select|choose|draw)\\s+random\\s+(?:rows?|records?|observations?)|random(?:ly)?\\s+(?:sample|select|choose|draw)|simple\\s+random\\s+sample|sample\\s+random(?:ly)?|sample\\s+[0-9]+\\s+rows?\\s+randomly|select\\s+.*\\s+at\\s+random)\\b",
      sampling_distribution="\\b(?:sampling\\s+distribution|bootstrap\\s+(?:distribution|sample\\s+means?|means?)|resampl(?:e|ing)\\s+.*\\b(?:sample\\s+mean|bootstrap))\\b",
      standard_error="\\b(?:standard\\s+error|\\bse\\s+of\\s+(?:the\\s+)?mean|sd\\s*/\\s*sqrt\\s*\\(\\s*n\\s*\\))\\b",
      mean_confidence_interval="\\b(?:mean\\s+confidence\\s+interval|confidence\\s+interval\\s+(?:for|of)\\s+(?:the\\s+)?(?:population\\s+)?mean|confidence\\s+bounds?\\s+for\\s+(?:the\\s+)?mean|t\\s+interval\\s+for\\s+(?:the\\s+)?mean|confidence\\s+interval\\s+for\\s+average)\\b",
      one_sample_t="\\b(?:one[- ]sample\\s+t[- ]?test|single\\s+sample\\s+t|t[- ]?test\\s+against\\s+(?:a\\s+)?reference|student\\s+t\\s+.*\\b(?:single|one)\\s+sample|test\\s+(?:a\\s+)?single\\s+sample\\s+mean|test\\s+.*\\bsingle\\s+sample\\s+mean)\\b",
      two_sample_t="\\b(?:test\\s+two\\s+independent\\s+means|two[- ]sample\\s+t[- ]?test|(?:two\\s+independent|independent\\s+two)\\s+(?:groups?|samples?)\\b.*\\b(?:test|means?|t)|welch\\s+t|unpaired\\s+t|unrelated\\s+samples?\\b.*\\bt[- ]?test|compare\\s+.*\\btwo\\s+independent\\s+groups?)\\b|\\bcompare\\s+(?:(?:two|2)\\s+)?(?:independent|unpaired|unrelated)\\s+(?:groups?|samples?)\\b",
      paired_t="\\b(?:paired\\s+t[- ]?test|matched\\s+pairs?\\b.*\\bt|before[- ]after\\b.*\\bt|within[- ]person\\b.*\\bt|paired\\s+student\\s+t)\\b",
      correlation_test="\\b(?:correlation\\s+significance\\s+test|pearson\\s+test|pearson\\s+association|pearson\\s+correlation\\s+test|correlation\\s+tests?|test\\s+(?:the\\s+)?(?:pearson\\s+)?correlation|significance\\s+of\\s+(?:pearson\\s+)?correlation|p[- ]?value\\s+for\\s+pearson\\s+correlation)\\b",
      spearman_correlation="\\b(?:spearman|rank\\s+correlation|ranked\\s+association)\\b",
      linear_regression="\\b(?:regression\\s+coefficients?|linear\\s+regression|regression\\s+line|fit\\s+(?:an?\\s+)?(?:ordinary\\s+)?linear\\s+model|\\bols\\b|regress\\s+y\\s+on\\s+x|slope\\s+confidence\\s+interval\\s+from\\s+.*\\s+regression|(?:fit|run|estimate)\\s+(?:a\\s+)?regression)\\b",
      predict_regression="\\b(?:predict\\w*\\s+.*\\s+(?:fitted\\s+)?regression|regression\\s+prediction|predict\\w*\\s+new\\s+(?:value|response)\\s+using\\s+(?:a\\s+)?fitted\\s+regression|prediction\\s+interval\\s+from\\s+.*\\s+regression)\\b",
      interpolation="\\b(?:interpolat(?:e|ion|ing)|estimate\\s+between\\s+.*\\bsampled\\s+positions?)\\b",
      categorical_independence="\\b(?:chi[- ]square\\s+independence\\s+test|categorical\\s+independence|chi[- ]square\\s+(?:test|of\\s+independence)|test\\s+association\\s+between\\s+(?:two\\s+)?categorical|test\\s+independence\\s+of\\s+(?:two\\s+)?categorical|contingency\\s+table\\s+test)\\b",
      proportion_interval="\\b(?:proportion\\s+interval|confidence\\s+interval\\s+(?:for|of)\\s+(?:a\\s+)?(?:population\\s+)?proportion|proportion\\s+confidence\\s+interval|wilson\\s+interval|confidence\\s+limits\\s+for\\s+percentage)\\b"
    )
    ids <- .ru_w5_method_ids()
    stopifnot(identical(names(signatures),ids))
    # Every entry declares actual result fields/operations, not just a topic.
    outputs <- list(
      import_csv=c("table"),inspect_columns=c("column_metadata"),
      filter_rows=c("filtered_rows"),group_means=c("group_mean","group_n"),
      missing_values=c("missing_n","available_n","mean_available"),
      mean_median=c("mean","median","n"),
      sample_sd=c("sample_sd","sample_variance","range","minimum","maximum","n"),
      five_number=c("minimum","q1","median","q3","maximum","iqr"),
      percentile_cutoff=c("empirical_quantile"),
      relative_frequency=c("category_counts","category_proportions"),
      categorical_mode=c("category_mode"),
      z_score=c("sample_z_score"),
      histogram=c("numeric_histogram"),
      bar_chart=c("category_bar_chart"),
      boxplot=c("numeric_boxplot"),
      grouped_boxplot=c("grouped_numeric_boxplot"),
      scatterplot=c("numeric_scatterplot"),
      zero_correlation=c("nonlinear_pattern_plot","pearson_r"),
      normal_shaded_area=c("normal_left_shading","normal_left_probability"),
      line_chart=c("time_series_line","ordered_values"),
      moving_average=c("smoothed_values","moving_average_plot"),
      autocorrelation=c("acf_values","acf_plot"),
      stationarity=c("exploratory_time_halves","exploratory_time_plot"),
      event_probability=c("empirical_event_proportion"),
      conditional_probability=c("empirical_conditional_probability"),
      probability_union=c("empirical_union_probability","event_marginals"),
      binomial_exact=c("binomial_point_probability"),
      binomial_at_least=c("binomial_inclusive_upper_probability"),
      normal_left_tail=c("normal_lower_probability"),
      normal_right_tail=c("normal_upper_probability"),
      normal_percentile=c("normal_quantile"),
      discrete_expectation=c("expected_value","discrete_variance"),
      sample_random=c("sampled_rows_without_replacement"),
      sampling_distribution=c("bootstrap_mean_distribution","bootstrap_se"),
      standard_error=c("estimated_mean_se","sample_sd","n"),
      mean_confidence_interval=c("t_mean_interval","sample_mean"),
      one_sample_t=c("one_sample_t_test","t_p_value","t_confidence_interval"),
      two_sample_t=c("welch_two_sample_t_test","t_p_value","t_confidence_interval"),
      paired_t=c("paired_t_test","t_p_value","t_confidence_interval"),
      correlation_test=c("pearson_test","pearson_r","p_value","confidence_interval"),
      spearman_correlation=c("spearman_test","spearman_rho","p_value"),
      linear_regression=c("ols_fit","ols_coefficients","slope_ci","fitted_scatter"),
      predict_regression=c("ols_prediction","prediction_interval"),
      interpolation=c("one_dimensional_linear_interpolation"),
      categorical_independence=c("contingency_test_or_declined_test"),
      proportion_interval=c("wilson_proportion_interval"))
    stopifnot(identical(names(outputs),ids))
    domain <- c(rep("data",3L),rep("summary",9L),rep("chart",6L),
                "normal_chart",rep("time",4L),rep("event",3L),
                rep("binomial",2L),rep("normal",3L),
                "discrete",rep("sampling",2L),
                rep("inference",6L),rep("association",1L),
                rep("regression",2L),"interpolation","categorical_test",
                "proportion_interval")
    stopifnot(length(domain)==length(ids))
    cached <<- stats::setNames(lapply(seq_along(ids),function(i) {
      id <- ids[[i]]
      list(id=id,domain=domain[[i]],outputs=outputs[[id]],
           roles=.ru_allowed_arguments(id),signature=signatures[[id]],
           capability_status=if(id %in% c("inspect_columns","missing_values",
                                           "discrete_expectation"))
             "QUALIFIED" else "LIMITED")
    }),ids)
    cached
  }
})

.ru_w5_normalize <- function(query) {
  q <- tolower(trimws(query))
  q <- gsub("\u2264","<=",q,fixed=TRUE)
  q <- gsub("\u2265",">=",q,fixed=TRUE)
  q <- gsub("\u03c3","sigma",q,fixed=TRUE)
  q <- gsub("\u2019","'",q,fixed=TRUE)
  q <- gsub("(?<=[[:alpha:]])-(?=[[:alpha:]])"," ",q,perl=TRUE)
  q <- gsub("[[:space:]]+"," ",q,perl=TRUE)
  q
}

# Explicitly unsupported statistical TASK FAMILIES. These are model/design
# classes absent from the 46 real implementations, not failed-question IDs.
.ru_w5_unimplemented_families <- function(q) {
  unsupported <- c(
    spatial_model="\\b(?:geographically\\s+weighted|spatial[- ](?:lag|error|regression|autoregressive|econometric|panel)|gwr\\b|kriging|geostatistic|semivariogram|moran'?s\\s+i|spatial\\s+interpolation|\\bcrs\\b|coordinate\\s+reference\\s+system)\\b",
    network_routing="\\b(?:network\\s+(?:travel|distance|route|routing|time|analysis)|road\\s+network|shortest\\s+path|travel\\s+time|travel\\s+distance|route\\s+optimization|origin[- ]destination|transport\\s+network)\\b",
    causal_inference="\\b(?:causal\\s+(?:effect|impact|inference|model)|cause[- ]and[- ]effect|difference[- ]in[- ]differences|regression\\s+discontinuity|instrumental\\s+variable|propensity\\s+score|counterfactual\\s+effect)\\b",
    unsupported_regression="\\b(?:poisson\\s+(?:regression|glm|log\\s+linear)|(?:fit|estimate|run)\\s+(?:a\\s+)?poisson\\s+(?:regression|model)|logistic|probit|negative\\s+binomial|multilevel|hierarchical|mixed[- ]effects?|random[- ]effects?|fixed[- ]effects?|ridge|lasso|elastic\\s+net|nonlinear|polynomial|quadratic|multivariate|multiple[- ]predictor|generalized\\s+linear|generalized\\s+additive)\\b.{0,35}\\b(?:regression|model|fit|estimate)\\b|\\b(?:regression|model)\\b.{0,35}\\b(?:logistic|probit|poisson|mixed[- ]effects?|spatial|multilevel|ridge|lasso|multiple\\s+predictors|nonlinear|quadratic)\\b",
    robust_inference="\\b(?:cluster[- ]robust|heteroskedasticity[- ]robust|robust\\s+standard\\s+errors?|sandwich\\s+estimator|clustered\\s+errors?|heteroskedastic\\s+consistent)\\b",
    survival_model="\\b(?:survival\\s+analysis|cox\\s+regression|kaplan[- ]meier|hazard\\s+ratio|time[- ]to[- ]event\\s+model)\\b",
    multivariate_methods="\\b(?:anova|ancova|manova|principal\\s+components?|\\bpca\\b|factor\\s+analysis|discriminant\\s+analysis|canonical\\s+correlation|k[- ]?means|cluster\\s+analysis|hierarchical\\s+clustering)\\b",
    advanced_temporal="\\b(?:arima|sarima|granger\\s+causality|unit[- ]root\\s+test|dickey[- ]fuller|seasonal\\s+decomposition|exponential\\s+smoothing|forecast\\s+future\\s+time[- ]series|vector\\s+autoregression)\\b",
    bayesian_inference="\\b(?:bayesian|posterior|markov\\s+chain\\s+monte\\s+carlo|\\bmcmc\\b|credible\\s+interval)\\b",
    unsupported_tests="\\b(?:wilcoxon|mann[- ]whitney|kruskal|friedman\\s+test|levene|bartlett\\s+test|shapiro[- ]wilk|permutation\\s+test|randomization\\s+test|f[- ]test\\s+for\\s+variances?)\\b",
    complex_sampling="\\b(?:stratified\\s+random\\s+sampl(?:e|ing)|cluster\\s+sampling|systematic\\s+sampling|survey\\s+weights?|probability\\s+proportional\\s+to\\s+size|sampling\\s+with\\s+replacement)\\b",
    other_analysis="\\b(?:multiple\\s+imputation|impute\\s+missing|power\\s+analysis|sample[- ]size\\s+calculation|optimiz(?:e|ation)\\s+.*\\b(?:model|route)|geodesic\\s+distance|classification\\s+model|random\\s+forest|neural\\s+network|support\\s+vector\\s+machine)\\b")
  names(unsupported)[vapply(unsupported,function(p) grepl(p,q,perl=TRUE),
                             logical(1))]
}

.ru_w5_concept_intent <- function(q) {
  grepl("^(?:what\\s+(?:is|are|does)|define|definition\\s+of|meaning\\s+of|explain\\s+(?:why|what)|difference\\s+between|how\\s+does\\s+(?:the\\s+)?(?:\\w+\\s+){1,4}work|when\\s+(?:is|should)|can\\s+i\\s+use|should\\s+i\\s+use)\\b",
        q,perl=TRUE) ||
    grepl("^what\\s+is\\s+the\\s+difference\\s+between\\b",q,perl=TRUE)
}

.ru_w5_role_conflict <- function(q,methods) {
  has <- function(p) grepl(p,q,perl=TRUE)
  nominal <- has("\\b(?:nominal|categorical|factor|labels?|category\\s+names?)\\b")
  numeric <- has("\\b(?:numeric|numerical|quantitative|continuous|measured\\s+(?:heights?|weights?|values?))\\b")
  if ("histogram" %in% methods &&
      has("\\b(?:histogram|histgram)\\b.{0,32}\\b(?:nominal|categorical|labels?|names?)\\b") &&
      !has("\\b(?:numeric|continuous|quantitative)\\b")) return("NUMERIC_HISTOGRAM_REQUIRED")
  if (any(c("boxplot","grouped_boxplot") %in% methods) &&
      has("\\bbox\\s*plot\\b.{0,35}\\b(?:of|for)\\s+(?:nominal|categorical|category)\\b.{0,24}\\b(?:labels?|names?|respondents?|countries|occupations?|categories)\\b"))
    return("NUMERIC_BOXPLOT_REQUIRED")
  if ("categorical_mode" %in% methods &&
      ((numeric && !nominal) ||
       has("\\b(?:continuous|quantitative)\\s+(?:numeric\\s+)?(?:variable|measurements?|scores?|data)\\b") ||
       has("\\bnumeric\\s+continuous\\b")))
    return("CATEGORY_MODE_REQUIRES_CATEGORY")
  if ("categorical_independence" %in% methods &&
      ((numeric && !nominal) ||
       has("\\b(?:continuous\\s+numeric|numeric\\s+(?:x\\s+and\\s+(?:numeric\\s+)?y|measurements?|variables?))\\b")))
    return("CATEGORICAL_TEST_REQUIRES_CATEGORIES")
  if ("scatterplot" %in% methods &&
      has("\\b(?:two\\s+nominal|categorical\\s+(?:x\\s+and\\s+y|variables?|axes)|unordered\\s+categories)\\b"))
    return("SCATTERPLOT_REQUIRES_NUMERIC_PAIRS")
  # A paired x/y plotting request denotes a numerical scatterplot only.
  # An explicit categorical role or a geographic map is a different output.
  if ("scatterplot" %in% methods &&
      has("\\b(?:nominal|categorical|factor|unordered)\\b.{0,36}\\b(?:x|y|variables?|axes|values?|columns?)\\b|\\b(?:x|y)\\b.{0,36}\\b(?:nominal|categorical|factor|unordered)\\b"))
    return("SCATTERPLOT_REQUIRES_NUMERIC_PAIRS")
  if ("scatterplot" %in% methods &&
      has("\\b(?:on|onto|as)\\s+(?:a\\s+)?(?:geograph(?:ic|ical)|geospatial|spatial|road|street)?\\s*maps?\\b"))
    return("SCATTERPLOT_NOT_GEOGRAPHIC_MAP")
  if ("bar_chart" %in% methods &&
      has("\\b(?:bar\\s+(?:chart|graph|plot))\\b.{0,38}\\b(?:raw\\s+continuous|unbinned\\s+continuous|numeric\\s+measurements?\\s+without\\s+categories)\\b"))
    return("BAR_CHART_REQUIRES_CATEGORIES")
  if (any(c("one_sample_t","two_sample_t","paired_t") %in% methods) &&
      has("\\b(?:categorical|nominal|binary)\\s+(?:response|outcome|dependent\\s+variable)\\b"))
    return("T_TEST_REQUIRES_NUMERIC_OUTCOME")
  if ("two_sample_t" %in% methods &&
      has("\\b(?:three|four|multiple|more\\s+than\\s+two)\\s+(?:independent\\s+)?groups?\\b"))
    return("TWO_SAMPLE_TEST_REQUIRES_TWO_GROUPS")
  if ("paired_t" %in% methods &&
      (has("\\b(?:unmatched|unpaired|unrelated)\\s+(?:subjects?|observations?|groups?|samples?)\\b") ||
       has("\\bindependent\\s+(?:groups?|samples?|observations?)\\b") ||
       (has("\\bindependent\\s+subjects?\\b") &&
        !has("\\b(?:before\\s+after|matched|within\\s+subject|repeated\\s+measures|paired\\s+measurements?)\\b"))))
    return("PAIRED_TEST_REQUIRES_MATCHED_PAIRS")
  if (any(c("correlation_test","linear_regression","predict_regression") %in% methods) &&
      has("\\b(?:binary|nominal|categorical)\\s+(?:response|outcome|dependent\\s+variable)\\b"))
    return("NUMERIC_RESPONSE_REQUIRED")
  if ("correlation_test" %in% methods &&
      has("\\b(?:ordinal|ranked)\\s+(?:only|variables?|measurements?)\\b"))
    return("PEARSON_REQUIRES_NUMERIC_MEASUREMENTS")
  if ("standard_error" %in% methods &&
      has("\\b(?:nominal|categorical)\\s+(?:categories|labels|data|variables?)\\b"))
    return("STANDARD_ERROR_REQUIRES_NUMERIC_SAMPLE")
  if ("sampling_distribution" %in% methods &&
      has("\\b(?:dependent\\s+(?:time\\s+series|observations?|measurements?|data)|time\\s+series|serially\\s+correlated|clustered|stratified|block\\s+bootstrap|without\\s+replacement)\\b"))
    return("IID_BOOTSTRAP_REQUIRES_INDEPENDENT_OBSERVATIONS")
  if ("sample_random" %in% methods && has("\\bwith\\s+replacement\\b"))
    return("SAMPLE_RANDOM_WITHOUT_REPLACEMENT_ONLY")
  if (any(c("normal_left_tail","normal_right_tail","normal_percentile",
            "normal_shaded_area") %in% methods) &&
      has("\\b(?:without\\s+assuming\\s+normality|non[- ]normal\\s+distribution)\\b"))
    return("NORMAL_MODEL_ASSUMPTION_REQUIRED")
  if (any(c("line_chart","moving_average","autocorrelation","stationarity") %in% methods) &&
      has("\\b(?:unordered\\s+categor(?:y|ies)|no\\s+(?:time|date|timestamps?)|without\\s+time\\s+ordering)\\b"))
    return("TIME_ROLE_REQUIRED")
  NULL
}

# Extract outputs first, then check whether one implemented method covers
# all of them. Inputs/assumptions (null mean, population sigma, group label,
# normal parameters, seed, time column) do not create extra requested outputs.
.ru_w5_request_contract <- function(query) {
  q <- .ru_w5_normalize(query)
  has <- function(p) grepl(p,q,perl=TRUE)
  cap <- .ru_w5_method_capabilities()
  supported <- names(cap)
  # "A instead of B" and "A, not B" do not request B.
  intent <- sub("\\binstead\\s+of\\b.*$","",q,perl=TRUE)
  intent <- sub("\\bnot\\s+(?:a\\s+|an\\s+|the\\s+)?(?:bar\\s*charts?|histograms?|box\\s*plots?|scatter\\s*plots?)\\b.*$",
                "",intent,perl=TRUE)
  match <- function(id) grepl(cap[[id]]$signature,intent,perl=TRUE)
  methods <- supported[vapply(supported,match,logical(1))]
  blocked <- .ru_w5_unimplemented_families(q)
  if (length(blocked))
    return(list(status="UNSUPPORTED",reason="UNIMPLEMENTED_TASK_FAMILY",
                detail=blocked,methods=character()))
  # Signed statistical events: a numeric tail and a shaded tail are
  # different outputs. The implemented shaded graph is LEFT-only.
  shade <- "normal_shaded_area" %in% methods &&
    has("\\b(?:normal|gaussian|bell\\s+curve|density)\\b")
  upper <- has("\\b(?:upper|right)\\s+(?:tail|area|region|side)\\b|\\b(?:above|greater\\s+than|exceeds?)\\b")
  lower <- has("\\b(?:lower|left)\\s+(?:tail|area|region|side)\\b|\\b(?:below|less\\s+than|at\\s+most)\\b")
  if (shade && (upper || !lower))
    return(list(status="UNSUPPORTED",reason="UNIMPLEMENTED_NORMAL_SHADING_DIRECTION",
                detail="normal_shaded_area supports left shading only",
                methods=character()))
  if (shade) {
    methods <- setdiff(methods,c("normal_left_tail","normal_right_tail"))
    methods <- c(methods,"normal_shaded_area")
  }
  # A named grouped boxplot includes its base boxplot, not a second plot.
  if ("grouped_boxplot" %in% methods)
    methods <- setdiff(methods,"boxplot")
  else if ("boxplot" %in% methods &&
           has("\\b(?:grouped|by\\s+(?:a\\s+)?(?:group|category|site|region|treatment|class)|per\\s+group|across\\s+groups?|separated\\s+by\\s+(?:group|category))\\b")) {
    methods <- c(setdiff(methods,"boxplot"),"grouped_boxplot")
  }
  # Ordinary category bars and count tables are not independence tests.
  if ("bar_chart" %in% methods &&
      !has("\\b(?:test\\s+independence|chi[- ]square|association\\s+test)\\b"))
    methods <- setdiff(methods,"categorical_independence")
  if ("bar_chart" %in% methods &&
      !has("\\b(?:also|and|plus)\\b.{0,20}\\b(?:frequency\\s+table|relative\\s+frequency|tabulate)\\b"))
    methods <- setdiff(methods,"relative_frequency")
  # Explicitly random row selection is sampling, not conditional filtering.
  if ("sample_random" %in% methods &&
      !has("\\b(?:also|and|then)\\b.{0,30}\\b(?:filter|subset|keep\\s+rows)\\b"))
    methods <- setdiff(methods,"filter_rows")
  # A time-ordered line is not an x/y scatterplot.
  if ("line_chart" %in% methods &&
      !has("\\b(?:and|also|plus|then)\\b.{0,25}\\bscatter\\b"))
    methods <- setdiff(methods,"scatterplot")
  # A model parameter or null-hypothesis value is not a separately
  # requested descriptive sample mean or standard deviation.
  t_context <- has("\\b(?:t[- .]?tests?|student\\s+t|welch\\s+t|t\\s+procedure|t\\s+statistic)\\b")
  t_design <- c("one_sample_t","two_sample_t","paired_t")
  if (t_context) {
    if (has("\\b(?:paired|matched|before[- ]after|within[- ]person)\\b"))
      methods <- c(methods,"paired_t")
    if (has("\\b(?:welch|unpaired|unrelated|two[- ]sample|two\\s+groups?|two\\s+independent\\s+groups?|independent\\s+(?:groups?|samples?|populations?|t\\s*test))\\b"))
      methods <- c(methods,"two_sample_t")
    if (has("\\b(?:one[- ]sample|single\\s+sample|one\\s+population|reference\\s+mean|benchmark\\s+mean|target\\s+mean)\\b"))
      methods <- c(methods,"one_sample_t")
    if (!any(t_design %in% methods))
      methods <- c(methods,"one_sample_t")
    if (!has("\\b(?:compute|calculate|find|report)\\s+(?:(?:the|a)\\s+)?(?:sample\\s+)?mean\\b.{0,40}\\b(?:and|then|plus|also)\\b"))
      methods <- setdiff(methods,"mean_median")
    if (!has("\\b(?:compute|calculate|find|report)\\s+(?:the\\s+)?(?:sample\\s+)?(?:standard\\s+deviation|sd|variance)\\b.{0,40}\\b(?:and|then|plus|also)\\b"))
      methods <- setdiff(methods,"sample_sd")
  }
  # A test against a benchmark mean has a null parameter, not a second
  # requested descriptive mean. This also covers test wordings without "t".
  if (any(t_design %in% methods) &&
      !has("\\b(?:compute|calculate|find|report)\\s+(?:(?:the|a)\\s+)?(?:sample\\s+)?mean\\b.{0,40}\\b(?:and|then|plus|also)\\b"))
    methods <- setdiff(methods,"mean_median")
  if ("standard_error" %in% methods) {
    if (!has("\\b(?:compute|calculate|find|report)\\s+(?:the\\s+)?(?:sample\\s+)?(?:sd|standard\\s+deviation)\\b.{0,45}\\b(?:and|then|plus|also)\\b"))
      methods <- setdiff(methods,"sample_sd")
    if (!has("\\b(?:compute|calculate|find|report)\\s+(?:the\\s+)?mean\\b.{0,45}\\b(?:and|then|plus|also)\\b"))
      methods <- setdiff(methods,"mean_median")
  }
  if (any(c("mean_confidence_interval","proportion_interval") %in% methods)) {
    if (!has("\\b(?:compute|calculate|report)\\s+(?:the\\s+)?mean\\b.{0,35}\\b(?:and|then|plus|also)\\b"))
      methods <- setdiff(methods,"mean_median")
    if (has("\\b(?:known|given|provided|specified)\\s+(?:population\\s+)?variance\\b|\\bpopulation\\s+variance\\s+(?:is\\s+)?(?:known|given)\\b"))
      methods <- setdiff(methods,"sample_sd")
  }
  # Independently requested variance and range are sample_sd outputs.
  if ((has("\\bvariance\\b") || (has("\\brange\\b") && !has("\\binterquartile\\s+range\\b"))) &&
      has("\\b(?:compute|calculate|find|report|estimate)\\b") &&
      !has("\\b(?:known|given|provided|specified)\\s+(?:population\\s+)?variance\\b") &&
      !has("\\b(?:confidence\\s+interval|normal\\s+(?:distribution|model))\\b"))
    methods <- c(methods,"sample_sd")
  # The discrete-expectation result includes the distribution variance.
  # This is not an independent sample-variance request.
  if ("discrete_expectation" %in% methods &&
      !has("\\bsample\\s+variance\\b"))
    methods <- setdiff(methods,"sample_sd")
  if ("group_means" %in% methods) methods <- setdiff(methods,"mean_median")
  if ("moving_average" %in% methods) methods <- setdiff(methods,"mean_median")
  if ("sampling_distribution" %in% methods) {
    methods <- setdiff(methods,"standard_error")
    if (!has("\\b(?:compute|calculate|find|report)\\s+(?:(?:the|a)\\s+)?(?:sample\\s+)?mean\\b.{0,45}\\b(?:and|then|plus|also)\\b"))
      methods <- setdiff(methods,"mean_median")
  }
  if (any(c("normal_left_tail","normal_right_tail","normal_percentile",
            "normal_shaded_area") %in% methods)) {
    if (!has("\\b(?:compute|calculate|estimate|find|report)\\s+(?:(?:the|a)\\s+)?(?:sample\\s+)?mean\\b.{0,45}\\b(?:and|plus|then)\\b"))
      methods <- setdiff(methods,"mean_median")
    if (!has("\\b(?:compute|calculate|estimate|find|report)\\s+(?:(?:the|a)\\s+)?(?:sample\\s+)?(?:sd|standard\\s+deviation)\\b.{0,45}\\b(?:and|plus|then)\\b"))
      methods <- setdiff(methods,"sample_sd")
    methods <- setdiff(methods,"percentile_cutoff")
  }
  if ("normal_percentile" %in% methods)
    methods <- setdiff(methods,c("normal_left_tail","normal_right_tail"))
  if ("predict_regression" %in% methods)
    methods <- setdiff(methods,"linear_regression")
  if ("spearman_correlation" %in% methods &&
      !has("\\b(?:and|plus|versus|vs\\.?|compare)\\b.{0,30}\\bpearson\\b"))
    methods <- setdiff(methods,"correlation_test")
  if ("correlation_test" %in% methods &&
      !has("\\b(?:and|also|plus)\\b.{0,35}\\bscatter\\b"))
    methods <- setdiff(methods,"scatterplot")
  if ("categorical_independence" %in% methods &&
      !has("\\b(?:and|also|plus)\\b.{0,30}\\b(?:frequency\\s+table|relative\\s+frequency)\\b"))
    methods <- setdiff(methods,"relative_frequency")
  if ("conditional_probability" %in% methods || "probability_union" %in% methods)
    methods <- setdiff(methods,"event_probability")
  if ("binomial_at_least" %in% methods || "binomial_exact" %in% methods)
    methods <- setdiff(methods,"event_probability")
  if ("zero_correlation" %in% methods)
    methods <- setdiff(methods,c("correlation_test","scatterplot"))
  # The numerical strict upper binomial tail needs a shifted threshold;
  # binomial_at_least is not a claim to support an unshifted "more than".
  if (has("\\bbinomial\\b.*\\bmore\\s+than\\b|\\bmore\\s+than\\b.*\\bsuccesses?\\b") &&
      !has("\\bat\\s+least\\b"))
    return(list(status="LEGACY_ONLY",reason="STRICT_BINOMIAL_UPPER_LEGACY",
                detail=NULL,methods=character()))
  # Lower/cumulative binomial probability is not implemented as a method.
  if (has("\\bbinomial\\b") &&
      has("\\b(?:at\\s+most|no\\s+more\\s+than|less\\s+than|below|cdf|cumulative)\\b") &&
      !has("\\b(?:at\\s+least|exactly)\\b"))
    return(list(status="UNSUPPORTED",reason="UNIMPLEMENTED_BINOMIAL_LOWER_TAIL",
                detail=NULL,methods=character()))
  if (has("\\bbinomial\\b") &&
      has("\\b(?:exact|exactly|precisely|point\\s+mass)\\b") &&
      has("\\b(?:at\\s+least|no\\s+fewer\\s+than|inclusive\\s+upper)\\b") &&
      has("\\b(?:and|plus|also|then)\\b"))
    return(list(status="AMBIGUOUS",reason="EXACT_AND_CUMULATIVE_EVENTS",
                detail=NULL,methods=character()))
  # A binomial point mass and an upper-tail probability are different
  # events, even when a question names the family only once.
  if (has("\\bbinomial\\b") &&
      has("\\b(?:exact|exactly|point\\s+mass|probability\\s+mass)\\b") &&
      has("\\b(?:upper|right)\\s+tail\\b") &&
      has("\\b(?:and|plus|also|then)\\b"))
    return(list(status="AMBIGUOUS",reason="EXACT_AND_CUMULATIVE_EVENTS",
                detail=NULL,methods=character()))
  if (has("\\b(?:two|both|multiple|several)\\b.{0,45}\\b(?:different|distinct|separate|exact)\\b.{0,45}\\b(?:events?|probabilities|thresholds?)\\b") &&
      has("\\b(?:binomial|normal|probability|event)\\b"))
    return(list(status="AMBIGUOUS",reason="MULTIPLE_EVENT_THRESHOLDS",
                detail=NULL,methods=character()))
  # Two distinct probability thresholds are two computations even if both
  # use the same mathematical family; do not supply one partial guide.
  if (has("\\b(?:binomial|normal|probabilit(?:y|ies))\\b") &&
      (has("\\b(?:two|both|each|separate|different|distinct)\\s+(?:binomial\\s+)?(?:events?|probabilities|thresholds?)\\b") || has("\\btwo\\s+separate\\b.*\\b(?:binomial|probabilities|thresholds?)\\b") ||
       (length(gregexpr("\\bexactly\\b",q,perl=TRUE)[[1L]])>1L &&
          gregexpr("\\bexactly\\b",q,perl=TRUE)[[1L]][1L]>0L) ||
       (length(gregexpr("\\bat\\s+least\\b",q,perl=TRUE)[[1L]])>1L &&
          gregexpr("\\bat\\s+least\\b",q,perl=TRUE)[[1L]][1L]>0L)))
    return(list(status="AMBIGUOUS",reason="MULTIPLE_EVENT_THRESHOLDS",
                detail=NULL,methods=character()))
  # A generic probability request without its event algebra is not a
  # license to substitute an unrelated normal/binomial method.
  # "Upper and lower tail probabilities" names two signed outputs,
  # even if the noun "tail" occurs only after the second adjective.
  if (has("\\b(?:normal|gaussian)\\b") &&
      has("\\b(?:(?:upper|right)\\s+(?:and|or|plus)\\s+(?:lower|left)|(?:lower|left)\\s+(?:and|or|plus)\\s+(?:upper|right))\\s+(?:tails?|areas?|probabilities?)\\b"))
    return(list(status="AMBIGUOUS",reason="MULTIPLE_NORMAL_DIRECTIONS",
                detail=NULL,methods=character()))
  if (has("\\b(?:normal|gaussian)\\b") &&
      upper && lower && !has("\\b(?:between|interval)\\b"))
    return(list(status="AMBIGUOUS",reason="MULTIPLE_NORMAL_DIRECTIONS",
                detail=NULL,methods=character()))
  methods <- unique(methods)
  role <- .ru_w5_role_conflict(q,methods)
  if (!is.null(role))
    return(list(status="UNSUPPORTED",reason=role,detail=NULL,
                methods=character()))
  # A scatterplot cannot silently stand in for a separately requested
  # inference, descriptive calculation or second graphic. The second
  # operation can be phrased without a canonical method signature.
  if ("scatterplot" %in% methods &&
      has("\\b(?:and|plus|then|also)\\b.{0,40}\\b(?:fit|run|test|compute|calculate|estimate|draw|plot|make|create)\\b") &&
      has("\\b(?:regression|correlation|means?|median|variance|standard\\s+deviation|histograms?|box\\s*plots?|bar\\s*charts?|t[- ]?test|p[- ]?value)\\b"))
    return(list(status="AMBIGUOUS",reason="MULTIPLE_REQUESTED_OPERATIONS",
                detail=methods,methods=methods))
  # Creating or extracting a data-frame column is an R programming
  # operation, not an input to a subsequent statistical analysis. A
  # second requested calculation/plot is a separate whole-request output.
  if (has("\\b(?:make|create|add|assign|store|save|extract)\\b.{0,50}\\b(?:columns?|fields?|variables?)\\b") &&
      has("\\b(?:and|then|plus|also)\\b.{0,50}\\b(?:plot|graph|draw|fit|test|compute|calculate|estimate|run|predict)\\b"))
    return(list(status="AMBIGUOUS",reason="MULTIPLE_REQUESTED_OPERATIONS",
                detail=methods,methods=methods))
  # Explicit outputs absent from every implemented method are unsupported,
  # even when a related keyword appears in a legacy lesson.
  if (has("\\b(?:prediction\\s+interval|predictive\\s+interval)\\b") &&
      !("predict_regression" %in% methods))
    return(list(status="UNSUPPORTED",reason="PREDICTION_INTERVAL_REQUIRES_REGRESSION",
                detail=NULL,methods=character()))
  if (has("\\b(?:density\\s+(?:curve|line|overlay)|overlay\\s+(?:a\\s+)?density)\\b") &&
      "histogram" %in% methods)
    return(list(status="UNSUPPORTED",reason="DENSITY_OVERLAY_NOT_IMPLEMENTED",
                detail=NULL,methods=character()))
  if (has("\\b(?:skewness|kurtosis)\\b") &&
      has("\\b(?:compute|calculate|estimate|find|report)\\b"))
    return(list(status="UNSUPPORTED",reason="UNIMPLEMENTED_DESCRIPTIVE_OUTPUT",
                detail=NULL,methods=character()))
  if (has("\\bcorrelation\\s+coefficient\\b") &&
      has("\\b(?:compute|calculate|find|report)\\b") &&
      !any(c("correlation_test","spearman_correlation","zero_correlation") %in% methods))
    return(list(status="UNSUPPORTED",reason="COEFFICIENT_NOT_REGRESSION",
                detail=NULL,methods=character()))
  if (has("\\b(?:pearson\\s+rank\\s+correlation|pearson\\s+and\\s+spearman)\\b"))
    return(list(status="UNSUPPORTED",reason="INCOMPATIBLE_ASSOCIATION_DEFINITION",
                detail=NULL,methods=character()))
  # Ordinary sample variance is provided by sample_sd, but a POPULATION
  # variance is not the same estimand and cannot be inferred from sample SD.
  if (has("\\b(?:compute|calculate|estimate|find)\\s+(?:the\\s+)?population\\s+variance\\b") &&
      !has("\\b(?:known|given|provided)\\s+population\\s+variance\\b"))
    return(list(status="UNSUPPORTED",reason="POPULATION_VARIANCE_NOT_IMPLEMENTED",
                detail=NULL,methods=character()))
  # Exact conjunction is handled by a capability, not a blanket "and" veto:
  # mean+median and sample variance+SD+range are genuine single-method outputs.
  if (length(methods)>1L) {
    return(list(status="AMBIGUOUS",reason="MULTIPLE_REQUESTED_OPERATIONS",
                detail=methods,methods=methods))
  }
  if (length(methods)==1L)
    return(list(status="METHOD",reason=NULL,detail=NULL,methods=methods))
  list(status="UNCLASSIFIED",reason="NO_VERIFIED_OPERATION",
       detail=NULL,methods=character())
}

# Speech act is distinct from the statistical operation being discussed.
# A question about a verified lesson or R function must not be forced through
# the numerical capability matcher merely because its subject is statistical.
# Conversely, an actual unsupported model, multiple operations or incompatible
# data roles must never be rescued by a vaguely related lesson.
# A closed set of VERIFIED lesson subjects disambiguates explanatory
# questions from numerical requests. These are existing 84-lesson/function
# identities, never aliases for unsupported ru_apply computations.
.ru_w5_reference_subject <- function(q,catalog) {
  has <- function(p) grepl(p,q,perl=TRUE)
  if (!has("^(?:what|why|which|when|how\\s+(?:can|does|should)|define|explain)\\b") &&
      !has("^(?:does|can|is)\\s+(?:pearson(?:'s)?\\s+)?r\\b"))
    return(NULL)
  pick <- function(id,kind=NULL) {
    rows <- catalog[catalog$id==id,,drop=FALSE]
    if (!is.null(kind)) rows <- rows[rows$type==kind,,drop=FALSE]
    if(nrow(rows)) rows[1L,,drop=FALSE] else NULL
  }
  # An explicit native function call in a definition question takes
  # precedence over the statistical quantity returned by the function.
  if (has("^(?:what\\s+does|how\\s+does|explain|define)\\b")) {
    call <- regmatches(q,regexpr("\\b[a-z][a-z0-9._]*\\s*\\(\\s*\\)",
                                q,perl=TRUE))
    if (length(call) && nzchar(call)) {
      fn <- sub("\\s*\\(\\s*\\)$","",call,perl=TRUE)
      titles <- tolower(gsub("[[:space:]]+","",catalog$title))
      rows <- catalog[catalog$type=="function" &
                      startsWith(titles,paste0(fn,"(")),,drop=FALSE]
      if (nrow(rows)==1L) return(rows)
    }
  }
  # "Does r measure correlation?" is an explanatory yes/no question
  # about a statistical symbol, not an instruction to calculate a
  # correlation coefficient or substitute Spearman's rank statistic.
  if (has("^(?:does|can|is)\\s+(?:pearson(?:'s)?\\s+)?r\\b") &&
      has("\\b(?:correlation|association|linear\\s+relationship)\\b") &&
      has("\\b(?:measure|represent|describe|indicate|mean|express)\\b"))
    return(pick("correlation","concept"))
  # Comparative dispersion, time-series stationarity, sampling design and
  # event conditioning each have a verified, dedicated teaching reference.
  if (has("\\b(?:iqr|interquartile\\s+range)\\b") &&
      has("\\b(?:sd|standard\\s+deviation)\\b") &&
      has("\\b(?:prefer\\w*|choos\\w*|versus|vs|better|resistan\\w*|robust|outliers?|extremes?|difference)\\b"))
    return(pick("choose_spread"))
  if (has("\\b(?:stationarit(?:y|ies)|stationary)\\b"))
    return(pick("stationarity","concept"))
  if (has("\\bclusters?\\b") &&
      has("\\b(?:select\\w*|whole|groups?|sampled|sampling)\\b"))
    return(pick("cluster_stratified","concept"))
  if (has("\\b(?:conditional|conditioned|given)\\b") &&
      has("\\b(?:probabilit(?:y|ies)|event|independence)\\b") &&
      has("\\b(?:interpret\\w*|mean\\w*|explain|definition)\\b"))
    return(pick("conditional_independence","concept"))
  NULL
}

.ru_w5_reference_intent <- function(q,hits,contract) {
  if (!nrow(hits)) return(FALSE)
  if (identical(contract$status,"UNSUPPORTED") &&
      !identical(contract$reason,"UNIMPLEMENTED_TASK_FAMILY"))
    return(FALSE)
  first <- hits[1L,,drop=FALSE]
  id <- first$id[[1L]]
  kind <- first$type[[1L]]
  explanatory <- grepl(
    "^(?:what\\s+(?:is|are|does)|why\\b|which\\b|when\\b|define\\b|explain\\b|how\\s+does\\b)",
    q,perl=TRUE) ||
    (identical(id,"correlation") &&
     grepl("^(?:does|can|is)\\s+(?:pearson(?:'s)?\\s+)?r\\b",
           q,perl=TRUE))
  procedural <- grepl("^how\\s+(?:do|can|should)\\s+i\\b",q,perl=TRUE)
  if (!explanatory && !procedural) return(FALSE)
  # An explicit supported graphic action takes precedence over an
  # unrelated fuzzy-ranked concept. This does not alter explanatory
  # questions about a graph or historical non-graphic how-to lessons.
  if (procedural && identical(contract$status,"METHOD") &&
      length(contract$methods)==1L &&
      contract$methods[[1L]] %in%
        c("histogram","bar_chart","boxplot","grouped_boxplot",
          "scatterplot","line_chart") &&
      grepl("\\b(?:plot|draw|graph|make|create)\\b",q,perl=TRUE))
    return(FALSE)
  # Method selection is still a method decision. A concrete supported W5
  # walkthrough should not be converted into an unrelated concept.
  if (procedural && kind=="walkthrough" && id %in% .ru_w5_method_ids())
    return(FALSE)
  if (!kind %in% c("concept","function","walkthrough"))
    return(FALSE)
  if (kind=="walkthrough" && !id %in% .ru_lesson_index()$id)
    return(FALSE)
  # A question beginning with "how" can request several separate outputs.
  # Its instructional phrasing never licenses an incomplete answer.
  if (procedural && contract$status %in% c("AMBIGUOUS","UNSUPPORTED"))
    return(FALSE)
  if (grepl("\\b(?:and|then|plus|also)\\b.{0,45}\\b(?:compute|calculate|run|fit|test|plot|draw|predict|estimate|sample|select|forecast)\\b",
            q,perl=TRUE))
    return(FALSE)
  # Preserve known conceptual lessons about study designs even when the
  # corresponding W5 computational operation is not implemented. Do not
  # generalize this exemption to spatial, network or advanced analyses.
  blocked <- .ru_w5_unimplemented_families(q)
  if (length(blocked)) {
    conceptual_coverage <- list(
      complex_sampling=c("cluster_stratified","sampling_design"),
      unsupported_regression=c("glm_binomial"),
      multivariate_methods=c("anova_oneway"),
      causal_inference=c("confounding","experiment_design"))
    if (!explanatory ||
        !all(vapply(blocked,function(family)
          id %in% conceptual_coverage[[family]],logical(1))))
      return(FALSE)
    if (grepl("\\b(?:fit|run|perform|calculate|compute|estimate|model|predict|sample|draw|select|forecast)\\b",
              q,perl=TRUE))
      return(FALSE)
  }
  TRUE
}

.ru_w5_method_resolve <- function(query,n=10L,type=NULL) {
  empty <- .ru_catalog()[FALSE,,drop=FALSE]
  corrected_terms <- NULL
  result <- function(status,id=NULL,rows=empty,reason=NULL,detail=NULL) {
    # A method-specific row still retains the search engine's typo
    # correction metadata; legacy clients inspect this data-frame attribute.
    if (!is.null(corrected_terms))
      attr(rows,"corrected_terms") <- corrected_terms
    list(status=status,method_id=id,hits=rows,reason_code=reason,
         detail=detail)
  }
  if (!is.character(query) || length(query)!=1L || is.na(query) ||
      !nzchar(trimws(query)) || nchar(query,type="bytes")>4096L)
    return(result("NO_MATCH"))
  if (!is.null(type) &&
      (length(type)!=1L || is.na(type) ||
       !(type %in% c("concept","function","walkthrough"))))
    stop("type must be 'concept', 'function' or 'walkthrough'.",call.=FALSE)
  count <- if(length(n)!=1L || is.na(n) || !is.finite(n))
    10L else max(1L,min(as.integer(n),50L))
  q <- .ru_w5_normalize(query)
  ids <- .ru_w5_method_ids()
  canonical <- trimws(sub("[?.!,:;]+$","",q))
  catalog <- .ru_catalog()
  if (canonical %in% ids && (is.null(type) || identical(type,"walkthrough"))) {
    exact <- catalog[catalog$id==canonical & catalog$type=="walkthrough",
                     ,drop=FALSE]
    if(nrow(exact)) return(result("METHOD",canonical,exact[1L,,drop=FALSE]))
  }
  ranked <- .ru_search_results(query,n=50L,type=type)
  corrected_terms <- attr(ranked,"corrected_terms")
  hits <- utils::head(ranked,count)
  attr(hits,"corrected_terms") <- attr(ranked,"corrected_terms")
  if (canonical %in% ids) return(result("LEGACY_REFERENCE",rows=hits))
  contract <- .ru_w5_request_contract(q)
  subject <- .ru_w5_reference_subject(q,catalog)
  if (!is.null(subject) &&
      (is.null(type) || identical(type,subject$type[[1L]])) &&
      .ru_w5_reference_intent(q,subject,contract))
    return(result("LEGACY_REFERENCE",rows=subject,
                  reason="VERIFIED_CONCEPTUAL_SUBJECT"))
  # The frozen P0/P1/P2 and enterprise route contracts already validate
  # supported native-R lesson methods and explicit estimator exclusions.
  # W5 adds 46 ru_apply operations; it does not revoke these earlier
  # verified teaching references or turn their exclusions into permission
  # to recommend a new, statistically incompatible method.
  legacy <- .ru_method_compatible_ids(q)
  if (!is.null(legacy) && !length(legacy)) {
    new_capability <- identical(contract$status,"METHOD") &&
      length(contract$methods)==1L &&
      (contract$methods[[1L]] %in%
         c("categorical_independence","sampling_distribution") ||
       contract$methods[[1L]] %in%
         c("one_sample_t","two_sample_t","paired_t") &&
         grepl("\\bp[- ]?value\\b",q,perl=TRUE) &&
         grepl("\\bconfidence\\s+interval\\b",q,perl=TRUE))
    if (!new_capability)
      return(result("UNSUPPORTED",rows=empty,
                    reason="PREVIOUSLY_VALIDATED_METHOD_INCOMPATIBILITY"))
  }
  if (.ru_w5_reference_intent(q,hits,contract))
    return(result("LEGACY_REFERENCE",rows=hits,
                  reason="VERIFIED_INSTRUCTIONAL_REFERENCE"))
  # Positive historical method gates are real, independently tested
  # instructional capabilities, even when no ru_apply method implements
  # their calculations. A legacy hit must have the SAME verified ID as
  # the gate; a nearby lexical hit never qualifies as a substitute.
  if (!is.null(legacy) && length(legacy)==1L && nrow(hits) &&
      identical(hits$id[[1L]],legacy[[1L]]) &&
      (is.null(type) || identical(type,"walkthrough"))) {
    old_id <- legacy[[1L]]
    requested <- if (identical(contract$status,"METHOD"))
      contract$methods[[1L]] else NULL
    # W5 supplies genuinely different outputs: shading a normal tail is
    # not its numeric CDF, a Pearson test is not only a coefficient lesson,
    # and sample SD+variance is a single implemented combined result.
    new_output <- !is.null(requested) && (
      requested=="normal_shaded_area" &&
        grepl("\\b(?:shade|shaded|shading)\\b",q,perl=TRUE) ||
      requested=="correlation_test" &&
        grepl("\\b(?:test|significance|hypothesis|p[- ]?value)\\b",
              q,perl=TRUE) ||
      requested=="sample_sd" &&
        grepl("\\b(?:sample\\s+sd|sample\\s+standard\\s+deviation)\\b",
              q,perl=TRUE) &&
        grepl("\\b(?:variance|range)\\b",q,perl=TRUE) ||
      requested=="sampling_distribution" &&
        grepl("\\b(?:sampling\\s+distribution|bootstrap\\s+(?:mean\\s+)?distribution)\\b",
              q,perl=TRUE) ||
      requested=="discrete_expectation" &&
        grepl("\\b(?:expected\\s+value|expectation)\\b",q,perl=TRUE) &&
        grepl("\\b(?:discrete|probability\\s+mass)\\b",q,perl=TRUE) &&
        grepl("\\bvariance\\b",q,perl=TRUE))
    if (!new_output) {
      second_action <- grepl(
        "\\b(?:and\\s+then|and|then|plus|also)\\s+(?:(?:the|a|an|another|separate|new)\\s+)?(?:compute|calculate|perform|run|fit|test|plot|draw|estimate|report|predict|sample|select|make|create)\\b",
        q,perl=TRUE)
      explicit_summary <- grepl(
        "\\b(?:compute|calculate|find|estimate|report)\\s+(?:(?:the|a)\\s+)?(?:sample\\s+)?(?:mean|median|sd|standard\\s+deviation|variance|range)\\b.{0,45}\\b(?:and|plus|then|also)\\b",
        q,perl=TRUE)
      # A known legacy method can legitimately include model inputs
      # such as population sigma or an ANOVA group's mean. Two separately
      # requested outputs are not inputs to the same method.
      if (second_action && (is.null(requested) ||
                            !identical(requested,old_id) ||
                            identical(contract$status,"AMBIGUOUS")))
        return(result("AMBIGUOUS",rows=empty,
                      reason="MULTIPLE_INDEPENDENT_ACTIONS"))
      # Each established method has only the listed ancillary W5 inputs.
      # A distinct chart, categorical mode or second hypothesis test is
      # never silently counted as an ANOVA/normal-model parameter.
      legacy_inputs <- list(
        central_limit_theorem=c("mean_median","sampling_distribution"),
        normal_between=c("mean_median","sample_sd"),
        uniform_interval=character(),
        mean_ci_z=c("mean_median","sample_sd","mean_confidence_interval"),
        mean_confidence_interval=c("mean_median","sample_sd","standard_error"),
        ci_method_selection=c("mean_median","sample_sd",
                              "mean_confidence_interval"),
        anova_oneway=c("mean_median","sample_sd","group_means"),
        regression_diagnostics=c("linear_regression","scatterplot"),
        glm_binomial=character(),
        bootstrap_mean=c("mean_median","sampling_distribution",
                         "standard_error"),
        multiple_testing_holm=character(),
        one_sample_t=c("mean_median","sample_sd","standard_error"),
        two_sample_t=c("mean_median","sample_sd","standard_error"),
        paired_t=c("mean_median","sample_sd","standard_error"),
        linear_regression=c("mean_median","sample_sd","scatterplot"),
        proportion_interval=c("relative_frequency"),
        poisson_exact=c("event_probability"),
        poisson_cdf=c("event_probability"),
        poisson_upper_tail=c("event_probability"),
        discrete_pmf=c("event_probability"),
        discrete_cdf=c("event_probability"),
        binomial_exact=c("event_probability"),
        binomial_at_least=c("event_probability"),
        binomial_more_than=c("event_probability"),
        normal_left_tail=c("mean_median","sample_sd"),
        normal_right_tail=c("mean_median","sample_sd"),
        normal_percentile=c("mean_median","sample_sd"))
      input_compatible <- old_id %in% names(legacy_inputs) &&
        all(contract$methods %in%
            c(old_id,legacy_inputs[[old_id]]))
      if (identical(contract$status,"AMBIGUOUS") &&
          (contract$reason!="MULTIPLE_REQUESTED_OPERATIONS" ||
           explicit_summary || !input_compatible ||
           !old_id %in% c(
             "central_limit_theorem","normal_between","uniform_interval",
             "mean_ci_z","mean_confidence_interval","ci_method_selection",
             "anova_oneway","regression_diagnostics","glm_binomial",
             "bootstrap_mean","multiple_testing_holm","one_sample_t",
             "two_sample_t","paired_t","linear_regression",
             "proportion_interval","poisson_exact","poisson_cdf",
             "poisson_upper_tail","discrete_pmf","discrete_cdf",
             "binomial_exact","binomial_at_least","binomial_more_than",
             "normal_left_tail","normal_right_tail","normal_percentile")))
        return(result("AMBIGUOUS",rows=empty,
                      reason=contract$reason,detail=contract$detail))
      if (identical(contract$status,"UNSUPPORTED")) {
        blocked <- .ru_w5_unimplemented_families(q)
        legacy_instruction <- identical(contract$reason,
                                        "UNIMPLEMENTED_TASK_FAMILY") &&
          ((identical(old_id,"glm_binomial") &&
            identical(blocked,"unsupported_regression")) ||
           (identical(old_id,"anova_oneway") &&
            identical(blocked,"multivariate_methods")))
        if (!legacy_instruction)
          return(result("UNSUPPORTED",rows=empty,
                        reason=contract$reason,detail=contract$detail))
      }
      if (old_id %in% ids) {
        row <- catalog[catalog$id==old_id &
                         catalog$type=="walkthrough",,drop=FALSE]
        if (nrow(row))
          return(result("METHOD",old_id,row[1L,,drop=FALSE],
                        reason="PREVIOUSLY_VERIFIED_METHOD"))
      }
      return(result("LEGACY_REFERENCE",rows=hits,
                    reason="PREVIOUSLY_VERIFIED_INSTRUCTIONAL_METHOD"))
    }
  }
  if (contract$status %in% c("AMBIGUOUS","UNSUPPORTED"))
    return(result(contract$status,rows=empty,reason=contract$reason,
                  detail=contract$detail))
  if (identical(contract$status,"LEGACY_ONLY"))
    return(result(if(nrow(hits)) "LEGACY_REFERENCE" else "NO_MATCH",
                  rows=hits,reason=contract$reason))
  # Conceptual teaching and method suitability retain historical references.
  # No new method is inferred from a question about what a term means.
  concept <- .ru_w5_concept_intent(q)
  if (concept) {
    if (nrow(hits)) return(result("LEGACY_REFERENCE",rows=hits,
                                 reason="CONCEPTUAL_INSTRUCTION"))
    return(result("NO_MATCH"))
  }
  method <- if(identical(contract$status,"METHOD"))
    contract$methods[[1L]] else NULL
  # Historical first-ranked single-quantity references are not silently
  # displaced by broader workflows that happen to calculate that quantity.
  legacy_quantities <- list(
    mean_median=c("mean"),sample_sd=c("variance","variance_sd"),
    five_number=c("quartiles"),correlation_test=c("pearson"),
    spearman_correlation=c("spearman"))
  if (!is.null(method) && nrow(hits) &&
      method %in% names(legacy_quantities) &&
      hits$id[[1L]] %in% legacy_quantities[[method]]) {
    explicit_workflow <- grepl("\\b(?:compute|calculate|find|report|estimate|run|test)\\b",
                               q,perl=TRUE) &&
      (grepl("\\b(?:and\\s+median|median\\s+and|sample\\s+sd\\b|from\\s+measurements|rank\\s+correlation\\b|ordinal\\s+measurements?)\\b",
             q,perl=TRUE) ||
       method=="correlation_test" &&
         grepl("\\b(?:significance|hypothesis|p[- ]?value|test)\\b",q,perl=TRUE) ||
       method=="five_number" &&
         grepl("\\b(?:iqr|interquartile\\s+range|five[- ]number)\\b",
               q,perl=TRUE))
    if (!explicit_workflow)
      return(result("LEGACY_REFERENCE",rows=hits,
                    reason="SINGLE_QUANTITY_REFERENCE"))
  }
  # A known population variance is an INPUT to a z interval; the W5
  # t-interval is not a statistically equivalent replacement.
  if (identical(method,"mean_confidence_interval") &&
      grepl("\\b(?:known|given|provided|specified)\\s+(?:population\\s+)?variance\\b|\\bpopulation\\s+variance\\s+(?:is\\s+)?(?:known|given|provided|specified)\\b",
            q,perl=TRUE)) {
    if(nrow(hits) && identical(hits$id[[1L]],"mean_ci_z"))
      return(result("LEGACY_REFERENCE",rows=hits,
                    reason="KNOWN_POPULATION_VARIANCE_Z_INTERVAL"))
    return(result("UNSUPPORTED",rows=empty,
                  reason="KNOWN_POPULATION_VARIANCE_Z_INTERVAL_UNAVAILABLE"))
  }
  # Preserve the historically taught Spearman rho reference; explicit
  # ordinal rank-data correlation uses the W5 Spearman method.
  if (identical(method,"spearman_correlation") && nrow(hits) &&
      identical(hits$id[[1L]],"spearman") &&
      (grepl("\\brho\\b|\\busing\\s+spearman\\b",q,perl=TRUE) ||
       !grepl("\\b(?:rank\\s+correlation|paired\\s+ranks?|ordinal\\s+measurements?)\\b",
              q,perl=TRUE)))
    return(result("LEGACY_REFERENCE",rows=hits,
                  reason="SPEARMAN_REFERENCE"))
  # A generic t-test guide retains the legacy one-sample-first convention
  # without pretending the data/design have been inspected.
  if (!is.null(method) && identical(method,"one_sample_t") &&
      grepl("\\bt[- ]?test\\b",q,perl=TRUE) &&
      !grepl("\\b(?:paired|independent|two[- ]sample|welch)\\b",q,perl=TRUE)) {
    # This is a guide, never a computed hypothesis test.
  }
  if (!is.null(method)) {
    if (!is.null(type) && type!="walkthrough")
      return(result(if(nrow(hits)) "LEGACY_REFERENCE" else "NO_MATCH",
                    rows=hits))
    row <- catalog[catalog$id==method & catalog$type=="walkthrough",
                   ,drop=FALSE]
    if (!nrow(row))
      return(result("UNSUPPORTED",rows=empty,
                    reason="METHOD_GUIDE_NOT_INSTALLED"))
    return(result("METHOD",method,row[1L,,drop=FALSE]))
  }
  # The installed Pearson coefficient lesson is the exact historical
  # single-quantity reference. It does not assert a hypothesis test.
  if (is.null(method) && nrow(hits) &&
      identical(hits$id[[1L]],"pearson") &&
      grepl("\\bpearson\\b",q,perl=TRUE) &&
      grepl("\\bcorrelation\\b",q,perl=TRUE) &&
      !grepl("\\b(?:test|significance|p[- ]?value|hypothesis)\\b",q,perl=TRUE))
    return(result("LEGACY_REFERENCE",rows=hits,
                  reason="PEARSON_COEFFICIENT_REFERENCE"))
  # Native R function references may legitimately describe an operation
  # absent from ru_apply(). Require a substantial subject match with the
  # installed function title; do not promote an arbitrary fuzzy method hit.
  if (is.null(method) && identical(contract$status,"UNCLASSIFIED") &&
      nrow(hits) && identical(hits$type[[1L]],"function") &&
      !length(.ru_w5_unimplemented_families(q))) {
    subject <- .ru_words(hits$title[[1L]])
    asked <- .ru_words(q)
    common <- length(intersect(subject,asked))
    if (length(subject)>=2L && common>=2L &&
        common/length(subject)>=0.6)
      return(result("LEGACY_REFERENCE",rows=hits,
                    reason="VERIFIED_NATIVE_FUNCTION_REFERENCE"))
  }
  # Ordinary R data-frame mutation/extraction belongs to the installed
  # r_objects_columns instructional reference. The 46 ru_apply methods
  # do not implement arbitrary derived-column creation; this is a
  # reference-only route with an exact verified top-ranked function.
  if (is.null(method) && identical(contract$status,"UNCLASSIFIED") &&
      nrow(hits) && identical(hits$id[[1L]],"r_objects_columns") &&
      identical(hits$type[[1L]],"function") &&
      grepl("^(?:make|create|add|assign|store|save|extract|select)\\b",
            q,perl=TRUE) &&
      grepl("\\b(?:columns?|fields?|variables?|vectors?)\\b",q,perl=TRUE) &&
      grepl("\\b(?:data\\s*frame|dataframe|dataset|r\\s+object)\\b",
            q,perl=TRUE) &&
      !grepl("\\b(?:and|then|plus|also)\\b.{0,50}\\b(?:compute|calculate|test|fit|run|plot|draw|forecast|predict|estimate)\\b",
             q,perl=TRUE))
    return(result("LEGACY_REFERENCE",rows=hits,
                  reason="VERIFIED_R_DATAFRAME_COLUMN_INSTRUCTION"))
  # An unfamiliar analytical action is not an invitation to show the nearest
  # lexical hit. A reference-only question without a requested action may
  # still use the original installed concept/function ranking.
  action <- grepl("\\b(?:compute|calculate|estimate|fit|test|run|plot|draw|make|create|generate|select|sample\\s+(?:[0-9]+\\s+)?(?:rows?|records?|observations?|data|from\\b)|forecast|predict|model|analy[sz]e|infer|measure|simulate|map|classify|optimi[sz]e|evaluate|compare)\\b",
                  q,perl=TRUE)
  if (action && !grepl("\\b(?:what|why|when|which|how)\\b.*\\b(?:mean|means|work|works|definition|appropriate)\\b",
                       q,perl=TRUE))
    return(result("UNSUPPORTED",rows=empty,
                  reason="UNCLASSIFIED_ANALYTICAL_REQUEST"))
  result(if(nrow(hits)) "LEGACY_REFERENCE" else "NO_MATCH",rows=hits)
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
