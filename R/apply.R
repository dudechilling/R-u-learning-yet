# Apply a known method to an explicitly named dataset and columns.
# Reject supplied options a method does not use; do not ignore them silently.
.ru_allowed_arguments <- function(id) {
  f <- function(...) c(...)
  common <- c("data", "x")
  graphics <- c("show_plot", "title", "col")
  axes <- c("xlab", "ylab")
  switch(id,
    import_csv = "file",
    inspect_columns = "data",
    filter_rows = c(common, "threshold", "operator"),
    group_means = c(common, "group"),
    missing_values = common,
    mean_median = common,
    sample_sd = common,
    five_number = common,
    percentile_cutoff = c(common, "prob"),
    relative_frequency = c(common, "weight"),
    categorical_mode = c(common, "weight"),
    z_score = c(common, "threshold"),
    histogram = c(common, graphics, "units", "xlab"),
    bar_chart = c(common, graphics, "weight", "xlab"),
    boxplot = c(common, graphics, "units"),
    grouped_boxplot = c(common, "group", graphics, "units"),
    scatterplot = c(common, "y", graphics, axes),
    zero_correlation = c(common, "y", graphics, axes),
    normal_shaded_area = c("mu", "sigma", "threshold", "assume_normal",
                           graphics, "xlab"),
    line_chart = c(common, "time", graphics, axes),
    moving_average = c(common, "time", "window", graphics, axes),
    autocorrelation = c(common, "time", "show_plot", "title"),
    stationarity = c(common, "time", graphics, axes),
    event_probability = c(common, "event", "weight"),
    conditional_probability = c(common, "y", "event", "given", "weight"),
    probability_union = c(common, "y", "event", "given", "weight"),
    binomial_exact = c("n", "k", "prob"),
    binomial_at_least = c("n", "k", "prob"),
    normal_left_tail = c("mu", "sigma", "threshold", "assume_normal"),
    normal_right_tail = c("mu", "sigma", "threshold", "assume_normal"),
    normal_percentile = c("mu", "sigma", "prob", "assume_normal"),
    discrete_expectation = c(common, "y"),
    sample_random = c("data", "n", "seed"),
    sampling_distribution = c(common, "n", "seed", "reps", "show_plot"),
    standard_error = common,
    mean_confidence_interval = c(common, "confidence"),
    one_sample_t = c(common, "confidence", "reference", "alternative"),
    two_sample_t = c(common, "group", "independent", "confidence", "alternative"),
    paired_t = c(common, "y", "paired", "confidence", "alternative"),
    correlation_test = c(common, "y", "confidence", "alternative"),
    spearman_correlation = c(common, "y", "alternative"),
    linear_regression = c(common, "y", graphics, axes),
    predict_regression = c(common, "y", "new_x", "confidence", "allow_extrapolate"),
    interpolation = c(common, "y", "threshold", graphics, axes),
    categorical_independence = c(common, "y", "weight"),
    proportion_interval = c("successes", "n", "confidence"),
    stop("No method-specific argument contract for ", id, call. = FALSE)
  )
}

ru_apply <- function(problem, data=NULL, x=NULL, y=NULL, group=NULL,
                     time=NULL, threshold=NULL, prob=NULL,
                     n=NULL, k=NULL, mu=NULL, sigma=NULL, confidence=NULL,
                     reference=NULL, event=NULL, given=NULL,
                     window=3L, seed=42L, reps=500L, independent=FALSE,
                     paired=FALSE, assume_normal=FALSE,
                     alternative="two.sided", new_x=NULL,
                     allow_extrapolate=FALSE, weight=NULL, operator=">=",
                     file=NULL, successes=NULL, show_plot=TRUE,
                     units=NULL, xlab=NULL, ylab=NULL, title=NULL, col=NULL) {
  supplied <- setdiff(names(as.list(match.call(expand.dots=FALSE))), "")
  item <- .ru_pick(problem)
  if (is.null(item)) return(invisible(NULL))
  id <- item$id
  unused <- setdiff(supplied, c("problem", .ru_allowed_arguments(id)))
  if (length(unused)) {
    stop("Method '", id, "' does not use: ",
         paste(paste0(unused, "="), collapse=", "),
         ". Remove these options or choose a suitable method.",
         call. = FALSE)
  }
  if (!is.null(data) && !is.data.frame(data))
    stop("data= must be a data frame. Try ru_data('iris').",call.=FALSE)
  a <- list(data=data,x=x,y=y,group=group,time=time,
            threshold=threshold,prob=prob,n=n,k=k,mu=mu,sigma=sigma,
            confidence=confidence,reference=reference,event=event,given=given,
            window=window,seed=seed,reps=reps,independent=independent,
            paired=paired,assume_normal=assume_normal,
            alternative=alternative,new_x=new_x,
            allow_extrapolate=allow_extrapolate,weight=weight,
            operator=operator,file=file,successes=successes,
            show_plot=show_plot,units=units,xlab=xlab,ylab=ylab,
            title=title,col=col)
  basics <- c("import_csv","inspect_columns","filter_rows","group_means",
              "missing_values","mean_median","sample_sd","five_number",
              "percentile_cutoff","relative_frequency","categorical_mode",
              "z_score")
  visuals <- c("histogram","bar_chart","boxplot","grouped_boxplot",
               "scatterplot","zero_correlation","normal_shaded_area")
  temporal <- c("line_chart","moving_average","autocorrelation","stationarity")
  probability <- c("event_probability","conditional_probability",
                   "probability_union","binomial_exact","binomial_at_least",
                   "normal_left_tail","normal_right_tail",
                   "normal_percentile","discrete_expectation",
                   "sample_random","sampling_distribution")
  inference <- c("standard_error","mean_confidence_interval","one_sample_t",
                 "two_sample_t","paired_t","correlation_test",
                 "spearman_correlation","linear_regression",
                 "predict_regression","interpolation",
                 "categorical_independence","proportion_interval")
  if(id %in% basics) return(.ru_apply_basic(id,a))
  if(id %in% visuals) return(.ru_apply_graph(id,a))
  if(id %in% temporal) return(.ru_apply_time(id,a))
  if(id %in% probability) return(.ru_apply_probability(id,a))
  if(id %in% inference) return(.ru_apply_inference(id,a))
  stop("No verified reusable method is available for this problem.")
}