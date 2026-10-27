# W5 A1: installed public discovery/guide parity, method roles and abstention.
# These are independent synthetic prompts, not assessed course materials.
suppressPackageStartupMessages(library(rulearn))
ns <- asNamespace("rulearn")
take <- function(name) get(name,envir=ns,inherits=FALSE)
ids <- take(".ru_w5_method_ids")()
route <- take(".ru_w5_method_route")
resolve <- take(".ru_w5_method_resolve")
allowed <- take(".ru_allowed_arguments")
teach <- take(".ru_w5_method_teach")
render <- take(".ru_w5_method_render")
check <- function(ok,label) {
  if (!isTRUE(ok)) stop(paste("A1 W5 FAIL:",label),call.=FALSE)
}
find_one <- function(q) {
  hits <- suppressMessages(ru_find(q,n=1L))
  check(is.data.frame(hits),paste("find data.frame",q))
  if (nrow(hits)) hits$id[[1L]] else NA_character_
}
guide_one <- function(q) {
  g <- ru_guide(q)
  if (is.list(g)) return(g$method_id)
  if (is.character(g) && length(g)==1L && nzchar(g))
    return(paste0("LEGACY:",tools::file_path_sans_ext(basename(g))))
  NA_character_
}
check(length(ids)==46L && !anyDuplicated(ids),"46 unique IDs")
check(identical(length(intersect(ids,c("inspect_columns","missing_values",
                                      "discrete_expectation"))),3L),
      "three qualified method IDs")
gaps <- c("import_csv","filter_rows","categorical_mode","z_score",
          "normal_shaded_area","normal_right_tail")
qualified <- setdiff(ids,gaps)
check(length(qualified)==40L,"40 new A2 guides")
for (id in ids) {
  r <- route(id)
  check(is.list(r) && identical(r$method_id,id) &&
        identical(r$status,"NEEDS_INPUT") &&
        identical(r$executed,FALSE),paste("typed route",id))
  check(identical(r$capability_status,
        if (id %in% c("inspect_columns","missing_values",
                      "discrete_expectation")) "QUALIFIED" else "LIMITED"),
        paste("A3 capability honesty",id))
  check(identical(r$required_data,
                  intersect(allowed(id),c("data","file"))) &&
        identical(r$required_columns,
                  intersect(allowed(id),c("x","y","group","time","weight"))) &&
        identical(r$accepted_parameters,
                  setdiff(allowed(id),c(r$required_data,r$required_columns,
                    "show_plot","title","col","xlab","ylab","units"))),
        paste("argument roles",id))
  check(identical(find_one(id),id) &&
        identical(find_one(toupper(id)),id) &&
        identical(find_one(paste0(id,"?")),id),
        paste("canonical public find",id))
  guide <- ru_guide(id)
  if (id %in% qualified) {
    check(is.list(guide) &&
          identical(guide$schema_version,"ru.w5.method-guide.v1") &&
          identical(guide$method_id,id) &&
          identical(guide$status,"GUIDED_REFERENCE") &&
          identical(guide$executed,FALSE) &&
          identical(guide$code_preview,teach(id)$code_preview) &&
          length(guide$required_inputs)>0L &&
          length(guide$assumptions)>=2L &&
          length(guide$cautions)>=2L,
          paste("authentic A2 guide",id))
  } else {
    check(is.null(teach(id)),paste("A2 six missing guides",id))
    check(is.null(guide) ||
          (is.character(guide) && length(guide)==1L &&
           file.exists(guide) &&
           identical(tools::file_path_sans_ext(basename(guide)),id)),
          paste("honest same-ID legacy fallback",id))
  }
}
check(identical(route("grouped_boxplot")$required_columns,
                c("x","group")),"grouped numeric/category roles")
check(!("group" %in% route("boxplot")$required_columns),
      "ungrouped boxplot cannot invent group")
check(all(c("x","y") %in% route("scatterplot")$required_columns),
      "scatterplot numeric x/y roles")
check("time" %in% route("moving_average")$required_columns,
      "time ordering required")
check("group" %in% route("two_sample_t")$required_columns,
      "independent-group role required")

# Each positive is a genuinely phrased operation; variants test casing.
positive <- list(
 c("Compare measurements separated by category with a boxplot","grouped_boxplot"),
 c("create a grouped boxplot","grouped_boxplot"),
 c("Create a boxplot grouped by a category","grouped_boxplot"),
 c("Make a boxplot of numeric measurements","boxplot"),
 c("Draw a boxplot","boxplot"),
 c("How do I make a histogram?","histogram"),
 c("Plot a histogram of numeric values","histogram"),
 c("Draw a bar chart for categories","bar_chart"),
 c("Make a bar chart instead of a histogram","bar_chart"),
 c("Plot a histogram, not a bar chart","histogram"),
 c("Plot one quantitative variable against another","scatterplot"),
 c("Compare the mean for each group","group_means"),
 c("How do I calculate an average by group?","group_means"),
 c("Find the mean and median of measurements","mean_median"),
 c("How do I calculate mean and median?","mean_median"),
 c("Find the sample SD","sample_sd"),
 c("Calculate the sample standard deviation","sample_sd"),
 c("Summarize missing observations","missing_values"),
 c("Count missing values in a numeric column","missing_values"),
 c("Compute a moving average of time series values","moving_average"),
 c("Calculate the autocorrelation of a time series","autocorrelation"),
 c("Make a line chart of values over time","line_chart"),
 c("Test for stationarity of a time series","stationarity"),
 c("Fit a simple linear regression of y on x","linear_regression"),
 c("Predict a new value using a fitted regression","predict_regression"),
 c("Run a correlation test on numeric variables","correlation_test"),
 c("Compute Spearman rank correlation between ordinal measurements","spearman_correlation"),
 c("Use a paired t-test on before and after measurements","paired_t"),
 c("Test whether two independent groups have equal means","two_sample_t"),
 c("Estimate a confidence interval for a proportion","proportion_interval"),
 c("Compute a binomial probability of exactly three successes","binomial_exact"),
 c("Calculate probability at least four successes","binomial_at_least"),
 c("Find the conditional probability of A given B","conditional_probability"),
 c("Compute an event union probability","probability_union"),
 c("Compute a normal distribution left tail","normal_left_tail"),
 c("Calculate the normal distribution right tail","normal_right_tail"),
 c("Find the 90th percentile of a normal distribution","normal_percentile"),
 c("Calculate the expected value of a discrete random variable","discrete_expectation"),
 c("Create a histogram for measured heights","histogram"),
 c("Draw a bar graph for nominal categories","bar_chart")
)
# Explicit t-test inputs (null mean, SD, design) are not extra outputs.
positive <- c(positive,list(
 c("Run a one-sample t test against a reference mean","one_sample_t"),
 c("Test a single sample mean against 8 with Student t","one_sample_t"),
 c("Run a Welch t test on two independent groups","two_sample_t"),
 c("Compare unrelated samples using Welch t test","two_sample_t"),
 c("Use a paired Student t procedure for matched observations","paired_t"),
 c("Estimate the slope confidence interval from a linear regression",
   "linear_regression")
))
for (item in positive) {
  q <- item[[1L]]; id <- item[[2L]]
  for (variant in unique(c(q,tolower(q),toupper(q)))) {
    actual <- find_one(variant)
    check(identical(actual,id),
          paste("compatible method",encodeString(variant),id,actual))
    actual_guide <- guide_one(variant)
    expected_guide <- if(id %in% gaps) paste0("LEGACY:",id) else id
    check(identical(actual_guide,expected_guide),
          paste("find-guide parity",encodeString(variant),
                expected_guide,actual_guide))
  }
}
check(length(positive)>=40L,"at least 40 positive natural-language cases")
# Preserve original legacy concept/function semantics rather than forcing a
# W5 data-dependent method for a question about a definition or R function.
legacy <- list(
 c("What is stationarity?","stationarity"),
 c("Define standard deviation","variance_sd"),
 c("How does the sd function work?","r_sd"),
 c("Can I use a paired t test?","independent_paired"),
 c("What is the difference between standard deviation and standard error?",
   "sampling_distributions"),
 c("What does a p-value mean?","hypothesis_tests_pvalues")
)
for (item in legacy)
  check(identical(find_one(item[[1L]]),item[[2L]]),
        paste("historical reference preserved",item[[1L]]))

# Distinct incompatible pairs, unsupported operations and invalid variable
# roles. Neither public API may imply one method completes the request.
negative <- c(
 "Compute the mean and draw a boxplot",
 "Plot a histogram and compute the mean",
 "Draw a bar chart and calculate sample standard deviation",
 "Create a scatterplot and compute the mean",
 "Compute grouped means and make a bar chart",
 "Plot a grouped boxplot and fit linear regression",
 "Draw a boxplot and compute Spearman correlation",
 "Make a histogram and calculate autocorrelation",
 "Draw a line chart and compute a moving average",
 "Compute a moving average and test stationarity",
 "Calculate autocorrelation and fit regression",
 "Compute mean and standard deviation",
 "Calculate mean and quartiles",
 "Find mean and IQR",
 "Compute mean and mode",
 "Compute mean and range",
 "Compute mean and variance",
 "Compute mean and skewness",
 "Find sample SD and draw a histogram",
 "Find sample SD and fit regression",
 "Compute sample SD and run a paired t-test",
 "Calculate standard error and draw a boxplot",
 "Calculate standard error and test Spearman correlation",
 "Calculate a proportion confidence interval and draw a histogram",
 "Compute a mean confidence interval and plot a bar chart",
 "Run a paired t-test and make a scatterplot",
 "Run an independent two sample t-test and plot a histogram",
 "Run a correlation test and draw a boxplot",
 "Compute Spearman correlation and fit regression",
 "Compute conditional probability and event union probability",
 "Calculate binomial probability exactly three and at least five successes",
 "Compute normal left tail and right tail probabilities",
 "Plot a histogram and overlay a density curve",
 "Create a scatterplot and calculate a correlation coefficient",
 "Show a grouped boxplot and predict from regression",
 "Plot a line chart and compute an event union probability",
 "Compute a moving average and draw a grouped boxplot",
 "Find the expected value of a discrete random variable and draw a bar chart",
 "Compute a binomial exact probability and draw a histogram",
 "Estimate a proportion confidence interval and fit linear regression",
 "Calculate a sample SD and a frequency table",
 "Compare Pearson and Spearman correlation",
 "Estimate a prediction interval for a new observation",
 "Use kriging to interpolate spatial measurements",
 "Compute a causal effect from this correlation",
 "Calculate a geodesic distance and plot a histogram",
 "Plot a histogram and run ANOVA",
 "Compute mean and perform ANOVA",
 "Calculate a correlation coefficient and fit linear regression",
 "Find a mean and construct a 95% prediction interval",
 "Draw a histogram of nominal categorical labels",
 "Make a boxplot of categorical names",
 "Compute the mode of numeric continuous measurements",
 "Calculate Pearson rank correlation",
 "Run a paired and independent t-test on the same unmatched groups"
)
negative <- c(negative,
  "Compute the sample mean and run a paired t-test",
  "Calculate sample standard deviation and perform an independent two sample t-test")
check(length(negative)>=40L && !anyDuplicated(negative),
      "40 independently distinct incompatible prompts")
for (q in negative) {
  for (variant in unique(c(q,tolower(q)))) {
    result <- resolve(variant,n=1L)
    check(result$status %in% c("AMBIGUOUS","UNSUPPORTED"),
          paste("whole-request refusal",variant,result$status,
                paste(result$method_id,collapse=",")))
    check(is.na(find_one(variant)),
          paste("public find cannot substitute",variant))
    check(is.null(ru_guide(variant)),
          paste("public guide cannot partially fulfill",variant))
  }
}
check(is.null(route("histogram and boxplot")) &&
      is.null(route("histogramming")) &&
      is.null(route("")) &&
      is.null(route(NA_character_)) &&
      is.null(route(paste(rep("a",5000L),collapse=""))),
      "bounded ambiguity and malformed-input checks")
# No implicit data access, preview evaluation, network, or source rewriting.
ambient <- data.frame(value=c(999,999,999))
assign("data",ambient,envir=.GlobalEnv)
sentinel <- tempfile("ru-w5-injection-")
inert <- paste0("mean_median; system('touch ",sentinel,"')")
invisible(ru_find(inert,n=1L))
invisible(ru_guide(inert))
check(!file.exists(sentinel),"no user question execution")
g <- ru_guide("mean_median")
check(identical(g$executed,FALSE) &&
      !grepl(sentinel,g$code_preview,fixed=TRUE),
      "no ambient data or code preview execution")
# Genuine installed public discovery -> A2 guide -> A4 headless Viewer,
# and separate user-controlled ru_apply with a numerical base-R oracle.
rendered <- 0L
for (item in positive) {
  id <- item[[2L]]
  if(id %in% gaps) next
  q <- item[[1L]]
  hits <- ru_find(q,n=1L)
  guide <- ru_guide(q)
  check(nrow(hits)==1L && identical(hits$id[[1L]],guide$method_id),
        paste("public pipeline method identity",q))
  view <- render(guide,open=FALSE)
  check(identical(view$status,"GUIDED_REFERENCE") &&
        identical(view$opened,FALSE) &&
        is.character(view$html_path) && file.exists(view$html_path),
        paste("actual A4 offline Viewer",q))
  html <- paste(readLines(view$html_path,warn=FALSE),collapse="\n")
  check(grepl("Guide only",html,fixed=TRUE) &&
        grepl("no method executed",html,fixed=TRUE) &&
        !grepl("SOLVED",html,fixed=TRUE),
        paste("Viewer is not a calculated result",q))
  rendered <- rendered+1L
}
sample_data <- data.frame(value=c(2,4,6,8))
actual <- ru_apply("mean_median",data=sample_data,x="value")
check(is.numeric(actual) &&
      isTRUE(all.equal(unname(actual["mean"]),mean(sample_data$value))) &&
      isTRUE(all.equal(unname(actual["median"]),median(sample_data$value))),
      "deliberate explicit-data execution versus base R")
cat("A1 W5 PUBLIC ROUTING PASS: 46 canonical IDs; ",
    length(positive)," positive natural-language prompts and casing variants; ",
    length(negative)," distinct adversarial conflicts with casing variants; ",
    "40 genuine A2 guides; six same-ID legacy fallbacks; ",
    rendered," A4 headless Viewer renderings; explicit-data base-R oracle; ",
    "3 QUALIFIED/43 LIMITED; no autoexecution.\n",sep="")