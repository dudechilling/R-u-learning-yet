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
 c("Compute sample SD from measurements","sample_sd"),
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
 c("What does a p-value mean?","hypothesis_tests_pvalues"),
 c("With known population variance 9, calculate a 90% confidence interval for average rainfall",
   "mean_ci_z"),
 c("Given a known population variance, estimate a mean confidence interval",
   "mean_ci_z"),
 c("How do I calculate Spearman's rho?","spearman"),
 c("How do I compare car weight and fuel economy using Spearman?","spearman"),
 c("How do I run a t test?","one_sample_t"),
 c("How do I calculate quartiles?","quartiles"),
 c("How do I calculate the mean?","mean"),
 c("How do I calculate sample variance?","variance"),
 c("How do I calculate sample standard deviation?","variance_sd"),
 c("How do I calculate Pearson correlation?","pearson"),
 c("How do I calculate Spearman’s rho?","spearman")
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
  "Calculate sample standard deviation and perform an independent two sample t-test",
  "Compute population variance and estimate a mean confidence interval")
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

# SUP79 W5-R8: independently authored closed statistical compatibility tests.

# Original synthetic acceptance section: synthetic-positive.R
# SUP79 independently authored method paraphrases. No sealed A5 fixtures.
suppressPackageStartupMessages(library(rulearn))
ns<-asNamespace("rulearn")
ids<-get(".ru_w5_method_ids",ns)()
caps<-get(".ru_w5_method_capabilities",ns)()
stopifnot(length(caps)==46L,identical(names(caps),ids),
 all(vapply(caps,function(z)length(z$outputs)>0L,logical(1))),
 all(vapply(caps,function(z)identical(z$roles,
   get(".ru_allowed_arguments",ns)(z$id)),logical(1))))
find_id<-function(q){x<-ru_find(q,n=1L);if(nrow(x))x$id[[1L]]else NA_character_}
guide_id<-function(q){g<-ru_guide(q);if(is.list(g))return(g$method_id);
 if(is.character(g)&&length(g)==1L&&nzchar(g))
   return(tools::file_path_sans_ext(basename(g)));NA_character_}
positive2<-list(
import_csv=c("Import a CSV file into an R data frame","Read a comma-separated dataset as a table"),
inspect_columns=c("Inspect variables in the supplied dataset","List column names and types"),
filter_rows=c("Filter rows based on a threshold","Keep records where the value exceeds a cutoff"),
group_means=c("Report average by region","Compute means for each category"),
missing_values=c("Count missing observations in a column","Summarize missingness in a dataset"),
mean_median=c("Calculate both the mean and median of a numeric vector","Report median and mean from measurements"),
sample_sd=c("Estimate sample standard deviation from measurements","Compute sample SD and sample variance"),
five_number=c("Compute the five-number summary of numeric observations","Report quartiles and interquartile range for sample values"),
percentile_cutoff=c("Find an empirical percentile cutoff from a sample","Calculate the sample percentile of recorded measurements"),
relative_frequency=c("Create a frequency table of observed categories","Report relative frequencies for factor levels"),
categorical_mode=c("Find the most common category in a factor","Compute categorical mode of responses"),
z_score=c("Calculate z-scores of sample measurements","Standardize numeric values into standard scores"),
histogram=c("Draw a histogram for continuous measurements","Make a binned numeric plot of heights"),
bar_chart=c("Draw category-count bars for labels","Plot a bar chart of survey categories"),
boxplot=c("Make a box-and-whisker plot of numeric heights","Draw a boxplot for a numeric variable"),
grouped_boxplot=c("Draw a grouped boxplot of numeric scores","Plot boxplots by region for measured values"),
scatterplot=c("Make a scatterplot of two quantitative variables","Plot one quantitative variable against another"),
zero_correlation=c("Illustrate zero correlation in a nonlinear pattern","Plot a nonlinear pattern with zero Pearson r"),
normal_shaded_area=c("Shade the lower tail under a normal density","Plot the shaded left area under a normal curve"),
line_chart=c("Plot a time-series line graph of observations","Create a line chart of temperature over dates"),
moving_average=c("Calculate rolling mean of regularly spaced time data","Compute a moving average for dated observations"),
autocorrelation=c("Plot autocorrelation of a regularly spaced series","Estimate serial correlation at observation lags"),
stationarity=c("Explore stationarity of a time series","Check time-series stability using early and late summaries"),
event_probability=c("Estimate empirical event probability from observed rows","Find the fraction of events recorded in a sample"),
conditional_probability=c("Estimate conditional probability from paired events","Compute probability of A given B"),
probability_union=c("Compute union probability for events A and B","Find probability of either event A or B"),
binomial_exact=c("Calculate a binomial point probability exactly 4 successes","Compute exactly two successes in binomial trials"),
binomial_at_least=c("Calculate binomial probability at least 3 successes","Find no fewer than four successes under binomial trials"),
normal_left_tail=c("Compute lower tail probability under a Gaussian model","Find normal probability below a threshold"),
normal_right_tail=c("Compute upper tail probability under a Gaussian model","Find normal probability above a cutoff"),
normal_percentile=c("Find normal 90th percentile of a distribution","Calculate a quantile from a Gaussian model"),
discrete_expectation=c("Compute expected value for a discrete random variable","Find expectation of a random variable with a probability mass"),
sample_random=c("Randomly select rows from a population table","Draw a simple random sample of records with a fixed seed"),
sampling_distribution=c("Simulate a bootstrap distribution of sample means","Explore the sampling distribution of the mean"),
standard_error=c("Compute standard error of the sample mean","Estimate the SE of mean from sample measurements"),
mean_confidence_interval=c("Construct a mean confidence interval with unknown population sigma","Calculate a t interval for the mean of numeric observations"),
one_sample_t=c("Run a one-sample t test against the null mean","Test a single sample mean against a benchmark"),
two_sample_t=c("Use Welch t test for unrelated groups","Run two-sample t-test on independent measurements"),
paired_t=c("Run paired t test on matched subjects","Use a matched-pairs t procedure for before-after scores"),
correlation_test=c("Test Pearson correlation between two numeric variables","Run a correlation test for numeric x and y"),
spearman_correlation=c("Compute Spearman rank correlation for ordinal scores","Test rank correlation between paired ordinal measurements"),
linear_regression=c("Fit ordinary linear regression of y on x","Estimate an OLS slope for a numeric response"),
predict_regression=c("Predict a new response using a fitted regression","Calculate prediction interval from a fitted regression"),
interpolation=c("Interpolate a numeric y value between observed x positions","Use linear interpolation within the sampled range"),
categorical_independence=c("Run a chi-square test of independence for two factors","Test association between two categorical variables"),
proportion_interval=c("Compute a confidence interval for a population proportion","Calculate a Wilson interval from successes and trials"))
stopifnot(identical(names(positive2),ids),
          all(lengths(positive2)==2L),length(unique(unlist(positive2)))==92L)
n<-0L
for(id in ids)for(q in positive2[[id]])for(v in unique(c(q,toupper(q),paste0(q,"?")))){
 r<-get(".ru_w5_method_resolve",ns)(v,n=1L)
 f<-find_id(v);g<-guide_id(v)
 if(!identical(r$status,"METHOD")||!identical(r$method_id,id)||
    !identical(f,id)||!identical(g,id))
   stop("SUP79_POSITIVE_FAIL: ",v," expected=",id,
        " status=",r$status," find=",f," guide=",g,call.=FALSE)
 n<-n+1L
}
cat("SUP79_92_POSITIVE_PARAPHRASES_PASS",n,"case/punctuation checks\n")

# Original synthetic acceptance section: synthetic-multi.R
# SUP79 independent multi-operation semantic coverage, no A5 sealed prompts.
suppressPackageStartupMessages(library(rulearn))
ns<-asNamespace("rulearn")
resolve<-get(".ru_w5_method_resolve",ns)
find_id<-function(q){x<-ru_find(q,n=1L);if(nrow(x))x$id[[1L]]else NA_character_}
guide_id<-function(q){g<-ru_guide(q);if(is.list(g))return(g$method_id);
 if(is.character(g)&&length(g)==1L&&nzchar(g))
   return(tools::file_path_sans_ext(basename(g)));NA_character_}
multi_good<-list(
 c("Calculate mean and median of one numeric sample","mean_median"),
 c("Find median and mean from the same measurements","mean_median"),
 c("Compute sample SD and sample variance","sample_sd"),
 c("Report sample variance and range and sample SD","sample_sd"),
 c("Calculate the five-number summary including quartiles and IQR","five_number"),
 c("Find quartiles and interquartile range for numeric observations","five_number"),
 c("Report category counts and relative frequencies in a frequency table","relative_frequency"),
 c("Calculate categorical proportions and frequencies in a frequency table","relative_frequency"),
 c("Report missing and available observation counts","missing_values"),
 c("Find missing values and the number of available measurements","missing_values"),
 c("Calculate sample standard error and its estimated sample SD","standard_error"),
 c("Find estimated SE of mean and sample SD from numeric data","standard_error"),
 c("Compute discrete expected value and variance of the probability mass","discrete_expectation"),
 c("Calculate expectation and variance for a discrete random variable","discrete_expectation"),
 c("Plot shaded left tail and report normal probability","normal_shaded_area"),
 c("Shade lower area of normal density and compute its probability","normal_shaded_area"),
 c("Estimate union probability and event marginals for A or B","probability_union"),
 c("Compute probability of either event and the separate A and B rates","probability_union"),
 c("Calculate bootstrap mean distribution and bootstrap standard error","sampling_distribution"),
 c("Simulate a sampling distribution and report bootstrap SE","sampling_distribution"),
 c("Run a paired t test with p-value and confidence interval","paired_t"),
 c("Perform one-sample t test and report its p-value and interval","one_sample_t"),
 c("Run Welch two-sample t test and report p-value and interval","two_sample_t"),
 c("Fit ordinary linear regression and report slope coefficient interval","linear_regression"))
multi_bad<-c(
 "Calculate mean and produce a scatterplot of two columns",
 "Estimate median and draw a bar chart for categories",
 "Find sample variance and run a correlation significance test",
 "Plot numeric histogram and compute empirical category proportions",
 "Run a one-sample t test and construct a proportion interval",
 "Calculate Pearson test p-value and fit a separate OLS model",
 "Draw grouped boxplots and test categorical independence",
 "Compute an event union probability and a conditional event probability",
 "Calculate exact binomial mass and upper-tail binomial probability",
 "Compute two different exact binomial event probabilities",
 "Find two separate binomial at-least threshold probabilities",
 "Draw a line chart and test categorical independence",
 "Compute moving average and perform paired t test",
 "Compute autocorrelation and estimate standard error",
 "Plot scatter diagram and estimate an unrelated proportion interval",
 "Inspect columns and calculate an unrelated t test",
 "Import CSV and run a regression model",
 "Filter rows and then compute a sample mean",
 "Randomly sample rows and then draw a histogram",
 "Calculate a sample mean and a bootstrap distribution",
 "Compute categorical mode and normal percentile",
 "Compute quartiles and a conditional probability",
 "Estimate sample SD and a normal right-tail probability",
 "Draw a bar chart and fit a linear regression",
 "Make a grouped boxplot and test two independent means",
 "Run a paired t test and an unpaired t test",
 "Calculate standard error and an event union probability",
 "Compute binomial exact mass and a sample percentile",
 "Estimate linear interpolation and a correlation test",
 "Report mean and construct a mean confidence interval",
 "Calculate relative frequency table and sample variance",
 "Find the standard error and the categorical mode",
 "Calculate normal lower tail and normal upper tail probabilities",
 "Test Spearman association and Pearson association",
 "Report regression coefficients and an unrelated categorical chi-square test",
 "Compute the sample SD and run a chi-square independence test",
 "Calculate a proportion interval and conditional probability",
 "Find group means and draw a time-series line chart",
 "Compute a discrete expectation and perform a one-sample t test",
 "Run a two-sample t test and estimate a bootstrap sampling distribution")
stopifnot(length(multi_good)+length(multi_bad)>=40L,
          !anyDuplicated(multi_bad))
for(item in multi_good){
 q<-item[[1L]];id<-item[[2L]]
 r<-resolve(q,n=1L);f<-find_id(q);g<-guide_id(q)
 if(!identical(r$status,"METHOD")||!identical(f,id)||!identical(g,id))
   stop("SUP79_MULTI_SUPPORTED_FAIL ",q," expected=",id,
        " status=",r$status," find=",f," guide=",g,call.=FALSE)
}
for(q in multi_bad){
 r<-resolve(q,n=1L);f<-find_id(q);g<-guide_id(q)
 if(!r$status %in% c("AMBIGUOUS","UNSUPPORTED")||!is.na(f)||!is.na(g))
   stop("SUP79_MULTI_ABSTAIN_FAIL ",q," status=",r$status,
        " find=",f," guide=",g,call.=FALSE)
}
cat("SUP79_MULTI_REQUEST_PASS",length(multi_good),"genuine same-method outputs",
    length(multi_bad),"complete-request abstentions\n")

# Original synthetic acceptance section: synthetic-role.R
# SUP79 independent input-role/design incompatibilities, not A5 sealed cases.
suppressPackageStartupMessages(library(rulearn))
ns<-asNamespace("rulearn")
resolve<-get(".ru_w5_method_resolve",ns)
role_bad<-c(
 "Draw histogram of nominal occupation labels",
 "Plot histogram for unordered categorical site names",
 "Show histogram of nonnumeric category labels",
 "Make boxplot of nominal respondent names",
 "Draw boxplot of categorical country names",
 "Plot boxplot of categorical labels",
 "Compute mode for numeric continuous measurements",
 "Find categorical mode of a continuous numeric variable",
 "Compute most common category from quantitative continuous scores",
 "Run categorical independence on two continuous numeric measures",
 "Test categorical independence of numeric x and numeric y",
 "Perform chi-square test on continuous numeric measurements",
 "Plot scatterplot of two nominal categories",
 "Make scatterplot of categorical x and y axes",
 "Create scatterplot of unordered categories",
 "Draw bar chart of raw continuous numeric measurements without categories",
 "Plot bar graph of unbinned continuous values",
 "Create bar chart for numeric measurements without categories",
 "Run a one-sample t test on a categorical response",
 "Run a two-sample t test with a binary outcome",
 "Run a paired t test with nominal outcome",
 "Compare three independent groups with a two-sample t test",
 "Compare four groups using a Welch t test",
 "Run paired t test for unmatched subjects",
 "Use a paired t test for unrelated observations",
 "Fit linear regression for a binary response",
 "Predict from linear regression with a nominal outcome",
 "Test Pearson correlation on ordinal only measurements",
 "Draw random sample of rows with replacement",
 "Select random records with replacement using a seed",
 "Calculate normal right-tail probability without assuming normality",
 "Shade left tail of a non-normal distribution",
 "Calculate moving average with no timestamps",
 "Compute autocorrelation for unordered categories",
 "Plot a line chart without time ordering",
 "Run a paired t test on independent samples",
 "Test two-sample t on before-after paired observations",
 "Estimate standard error from nominal categories")
stopifnot(length(role_bad)>=30L,!anyDuplicated(role_bad))
for(q in role_bad){
 r<-resolve(q,n=1L)
 f<-ru_find(q,n=1L)
 g<-ru_guide(q)
 if(!r$status %in% c("UNSUPPORTED","AMBIGUOUS") ||
    nrow(f)!=0L || !is.null(g))
   stop("SUP79_ROLE_FAIL ",q," status=",r$status,
        " find=",if(nrow(f))f$id[[1L]]else "EMPTY",
        " guide=",if(is.list(g))g$method_id else as.character(g),
        call.=FALSE)
}
cat("SUP79_ROLE_DESIGN_REFUSALS_PASS",length(role_bad),"\n")

# Original synthetic acceptance section: synthetic-research.R
# SUP79 unsupported research method families; no A5 blind inputs.
suppressPackageStartupMessages(library(rulearn))
ns<-asNamespace("rulearn")
resolve<-get(".ru_w5_method_resolve",ns)
research_bad<-c(
 "Fit geographically weighted regression to local outcomes",
 "Estimate spatial lag regression for neighborhood observations",
 "Run a spatial error model on districts",
 "Perform kriging of georeferenced measurements",
 "Estimate a semivariogram and map residual dependence",
 "Calculate Moran's I for spatial autocorrelation",
 "Predict spatial outcomes with a coordinate reference system",
 "Compute shortest path travel time across a road network",
 "Estimate network travel distance between locations",
 "Optimize road-network route for delivery stops",
 "Perform origin-destination network analysis",
 "Estimate causal effect from observational correlation",
 "Apply difference-in-differences to policy outcomes",
 "Fit regression discontinuity for a treatment cutoff",
 "Estimate propensity score matching for a treatment",
 "Fit a multinomial logistic regression for a three-class outcome",
 "Run a Poisson regression for event counts",
 "Fit a mixed-effects regression with random intercepts",
 "Estimate a multilevel hierarchical model",
 "Fit ridge regression to multiple predictors",
 "Estimate a nonlinear quadratic regression",
 "Compute cluster-robust standard errors for OLS",
 "Calculate heteroskedasticity-robust confidence intervals",
 "Run Kaplan-Meier survival analysis",
 "Fit a Cox proportional hazards model",
 "Run ANOVA for four treatment means",
 "Compute MANOVA for multiple outcomes",
 "Perform principal components analysis",
 "Cluster observations using k-means",
 "Fit a Bayesian posterior distribution",
 "Run an MCMC model for the parameters",
 "Forecast future time-series values with ARIMA",
 "Test unit roots using Dickey-Fuller",
 "Estimate seasonal decomposition of monthly counts",
 "Run a Wilcoxon rank-sum test",
 "Perform a permutation significance test",
 "Use stratified random sampling with proportional strata",
 "Draw a sample with replacement from population rows",
 "Impute missing data using multiple imputation",
 "Compute a power analysis for an experiment",
 "Fit a random forest classification model",
 "Compute geodesic distance between GPS points",
 "Run multivariate factor analysis on survey items",
 "Estimate an instrumental-variable causal model")
stopifnot(length(research_bad)>=30L,!anyDuplicated(research_bad))
for(q in research_bad){
 r<-resolve(q,n=1L)
 f<-ru_find(q,n=1L)
 g<-ru_guide(q)
 if(!r$status %in% c("UNSUPPORTED","AMBIGUOUS") ||
    nrow(f)!=0L || !is.null(g))
   stop("SUP79_RESEARCH_FAIL ",q," status=",r$status,
        " find=",if(nrow(f))f$id[[1L]]else "EMPTY",
        " guide=",if(is.list(g))g$method_id else as.character(g),
        call.=FALSE)
}
cat("SUP79_UNIMPLEMENTED_RESEARCH_REFUSALS_PASS",length(research_bad),"\n")

# The historical 84-lesson library includes legitimate *reference-only*
# native-R methods absent from the 46 ru_apply contracts. Treating ordinary
# logistic regression as an unsupported instructional topic would contradict
# the unchanged 180-case enterprise acceptance contract. No ru_apply call or
# W5 computed-result claim is authorized by these legacy references.
legacy_native <- list(
 c("Fit a logistic regression for a binary outcome","glm_binomial"),
 c("Run Welch one-way ANOVA on independent groups with unequal variances",
   "anova_oneway"),
 c("Bootstrap a sample mean with replacement from independent observations",
   "bootstrap_mean"),
 c("Inspect residual diagnostics for ordinary least squares regression",
   "regression_diagnostics"),
 c("Apply Holm adjustment to a family of p-values","multiple_testing_holm"))
for (item in legacy_native) {
  q <- item[[1L]]; id <- item[[2L]]
  r <- resolve(q,n=1L)
  f <- ru_find(q,n=1L)
  g <- ru_guide(q)
  stopifnot(!id %in% ids,
            identical(r$status,"LEGACY_REFERENCE"),
            nrow(f)==1L,identical(f$id[[1L]],id),
            is.null(g))
}
cat("SUP81_VERIFIED_NATIVE_LEGACY_REFERENCE_ONLY_PASS",
    length(legacy_native),"\n")


# Original synthetic acceptance section: synthetic-parity.R
# SUP79 public ru_find/ru_guide parity under reordered phrasing.
suppressPackageStartupMessages(library(rulearn))
ns<-asNamespace("rulearn")
resolve<-get(".ru_w5_method_resolve",ns)
pairs<-list(
 c("Compute normal upper-tail probability","Under a normal model find the upper tail probability","normal_right_tail"),
 c("Plot bar chart of category counts","For category counts, draw a bar chart","bar_chart"),
 c("Draw a line chart over time","Over time, plot a line chart of measurements","line_chart"),
 c("Randomly select rows from a population table","From the records, select a random sample","sample_random"),
 c("Compute median and mean","Find mean and median","mean_median"),
 c("Run Welch t test on two independent groups","For two independent groups, run a Welch t test","two_sample_t"),
 c("Shade left tail under normal density","Under normal model, shade the lower tail","normal_shaded_area"),
 c("Compute conditional probability of A given B","Given B, compute probability of A","conditional_probability"),
 c("Compute union probability of A or B","For A or B, find union probability","probability_union"),
 c("Report mean by group","For each group, calculate mean","group_means"),
 c("Find 90th percentile of normal model","For normal distribution, find the 90th percentile","normal_percentile"))
checks<-0L
for(item in pairs){
 for(q in item[1:2])for(v in unique(c(q,toupper(q),paste0(q,"!")))){
  r<-resolve(v,n=1L)
  f<-ru_find(v,n=1L)
  g<-ru_guide(v)
  got<-if(nrow(f))f$id[[1L]]else NA_character_
  guide<-if(is.list(g))g$method_id else
    if(is.character(g)&&length(g)==1L&&nzchar(g))
      tools::file_path_sans_ext(basename(g)) else NA_character_
  if(!identical(r$status,"METHOD")||!identical(got,item[[3L]])||
     !identical(guide,item[[3L]]))
    stop("SUP79_REORDER_PARITY_FAIL ",v," expected=",item[[3L]],
         " status=",r$status," find=",got," guide=",guide,call.=FALSE)
  checks<-checks+1L
 }
}
cat("SUP79_REORDERED_PUBLIC_IDENTITY_PARITY_PASS",checks,"\n")


# SUP81 independent conceptual intent and native function transfer.
# SUP81 new independent conceptual/procedural and native R-function transfer.
# No A5 blind text or expected files used.
suppressPackageStartupMessages(library(rulearn))
teaching <- c(
 "Why does percentile rank describe position rather than a score threshold?"="percentile_rank",
 "How should I interpret a percentile rank in a sample?"="percentile_rank",
 "Which spread statistic resists extreme observations?"="choose_spread",
 "When is IQR preferable to SD for outlier-prone measurements?"="choose_spread",
 "Explain weak stationarity in a time series."="stationarity",
 "What does stationarity imply for the mean over time?"="stationarity",
 "How can I assign a data-frame column to an R variable?"="r_objects_columns",
 "How do I extract a column with the dollar operator?"="r_objects_columns",
 "Why do cluster designs select whole groups?"="cluster_stratified",
 "What is the rationale for selecting whole clusters?"="cluster_stratified",
 "How can I interpret a probability conditional on another event?"="conditional_independence",
 "What does conditional independence mean?"="conditional_independence",
 "How does the base R sd() function calculate spread?"="r_sd",
 "What does sd() do to a numeric vector?"="r_sd",
 "Create a stem and leaf plot for numeric scores"="r_stem",
 "Show a stem and leaf diagram of observations"="r_stem")
refused <- c(
 "How do I fit a multinomial logistic regression for three outcome classes?",
 "Explain how to estimate spatial lag regression for districts",
 "Why should ordinary regression estimate network travel time?",
 "How do I calculate a sample mean and then run a two-sample t test?",
 "How do I calculate normal upper and lower tail probabilities?",
 "How do I plot a histogram of nominal categories?",
 "How do I estimate a geographically weighted regression?",
 "How do I draw a category bar chart and run a chi-square independence test?")
bad<-character()
for(q in names(teaching)){
 h<-ru_find(q,n=1L)
 got<-if(nrow(h))h$id[[1L]]else "EMPTY"
 if(!identical(got,unname(teaching[[q]])))
  bad<-c(bad,paste("TEACH",q,"EXPECTED",teaching[[q]],"GOT",got))
 g<-ru_guide(q)
 if(!is.null(g)){
  guide_id<-if(is.list(g))g$method_id else
    tools::file_path_sans_ext(basename(g))
  if(!identical(guide_id,got))
   bad<-c(bad,paste("GUIDE_ID",q,"FIND",got,"GUIDE",guide_id))
 }
}
for(q in refused){
 h<-ru_find(q,n=1L)
 g<-ru_guide(q)
 if(nrow(h)||!is.null(g))
  bad<-c(bad,paste("REFUSE",q,"GOT",if(nrow(h))h$id[[1L]]else "EMPTY"))
}
cat("SUP81_NEW_TEACHING_PROBES",length(teaching),
    "REFUSAL_PROBES",length(refused),"FAILURES",length(bad),"\n")
if(length(bad))cat(paste(bad,collapse="\n"),"\n")
if(length(bad))stop("SUP81_NEW_TEACHING_TRANSFER_FAIL",call.=FALSE)

# SUP82 exact historical search-tokenization compatibility:
# Explicit paired x/y plotting is a scatterplot request, not an unclassified
# statistical action. It is NOT permission to map, infer, plot categories,
# or silently omit a separately requested operation. Independent A1 tests;
# no A5 sealed corpus or expected-answer files consulted.
xy_scatter_positives <- c(
  "How do I plot x and y?",
  "Plot x versus y",
  "Plot y by x",
  "How can I graph y against x?",
  "Plot the two numeric variables x and y",
  "Graph numeric x and numeric y as points",
  "Draw x and y as a scatterplot")
xy_checks <- 0L
for (query in xy_scatter_positives) {
  for (v in unique(c(query,toupper(query),paste0(query,"!")))) {
    route <- resolve(v,n=1L)
    found <- ru_find(v,n=1L)
    guide <- ru_guide(v)
    guide_id <- if(is.list(guide)) guide$method_id else
      if(is.character(guide) && length(guide)==1L && nzchar(guide))
        tools::file_path_sans_ext(basename(guide)) else NA_character_
    stopifnot(identical(route$status,"METHOD"),
              identical(route$method_id,"scatterplot"),
              nrow(found)==1L,
              identical(found$id[[1L]],"scatterplot"),
              identical(guide_id,"scatterplot"))
    xy_checks <- xy_checks+1L
  }
}
xy_invalid <- c(
  "Plot categorical x and y",
  "Plot two nominal variables x and y",
  "Plot x and y on a geographical map",
  "Plot x and y on a map",
  "Plot x and y on a road network",
  "Plot x and y, then fit a regression",
  "Plot x and y and test their correlation",
  "Plot x and y and calculate their means",
  "Plot x and y and make a histogram",
  "Plot x and y as separate histograms",
  "How do I repair the x and y axes of a printer?")
for (query in xy_invalid) {
  route <- resolve(query,n=1L)
  found <- ru_find(query,n=1L)
  guide <- ru_guide(query)
  stopifnot(route$status %in% c("UNSUPPORTED","AMBIGUOUS","NO_MATCH"),
            nrow(found)==0L,is.null(guide))
}
xy_time <- "Plot x and y over time as a line chart"
xy_time_found <- ru_find(xy_time,n=1L)
stopifnot(nrow(xy_time_found)==1L,
          identical(xy_time_found$id[[1L]],"line_chart"))
cat("SUP82_XY_SCATTERPLOT_COMPATIBILITY_PASS",
    xy_checks,"positive variants",length(xy_invalid),
    "incompatible requests; time chart preserved\n")


# The unchanged search-tokenization test also preserves a historically
# verified generic independent-groups guide. An explicit group count >2,
# categorical outcome or separate analysis is not a two-sample t test.
independent_group_queries <- c(
  "How do I compare independent groups?",
  "Compare two independent groups",
  "How can I compare unrelated samples?",
  "Compare unpaired groups")
for (query in independent_group_queries) {
  result <- resolve(query,n=1L)
  hit <- ru_find(query,n=1L)
  guide <- ru_guide(query)
  stopifnot(identical(result$status,"METHOD"),
            identical(result$method_id,"two_sample_t"),
            nrow(hit)==1L,identical(hit$id[[1L]],"two_sample_t"),
            is.list(guide),identical(guide$method_id,"two_sample_t"))
}
independent_group_invalid <- c(
  "Compare three independent groups",
  "Compare independent groups with a categorical response",
  "Compare independent groups and fit a linear regression")
for (query in independent_group_invalid) {
  result <- resolve(query,n=1L)
  stopifnot(result$status %in% c("AMBIGUOUS","UNSUPPORTED","NO_MATCH"),
            nrow(ru_find(query,n=1L))==0L,
            is.null(ru_guide(query)))
}
cat("SUP82_INDEPENDENT_GROUPS_METHOD_GUIDE_PASS",
    length(independent_group_queries),"positive",
    length(independent_group_invalid),"incompatible\n")


# Statistical notation in an explanatory yes/no question is a concept,
# not a request to execute a coefficient or an incompatible rank test.
r_concept_questions <- c(
  "Does r measure correlation?",
  "Can r measure the strength of a linear association?",
  "Does Pearson r represent correlation?")
for (query in r_concept_questions) {
  result <- resolve(query,n=1L)
  found <- ru_find(query,n=1L)
  stopifnot(identical(result$status,"LEGACY_REFERENCE"),
            nrow(found)==1L,
            identical(found$id[[1L]],"correlation"),
            is.null(ru_guide(query)))
}
stopifnot(nrow(ru_find("Does r measure regression slope?",n=1L))==0L)
cat("SUP82_R_CORRELATION_CONCEPT_ROUTING_PASS",
    length(r_concept_questions),"symbolic explanations\n")
