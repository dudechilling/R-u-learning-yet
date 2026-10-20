# Apply an indexed method to any appropriately structured data frame.
# Inputs are never guessed from the column names.
ru_apply <- function(problem, data=NULL, x=NULL, y=NULL, group=NULL,
                     time=NULL, threshold=NULL, prob=NULL,
                     n=NULL, k=NULL, mu=NULL, sigma=NULL, confidence=NULL,
                     reference=NULL, event=NULL, given=NULL,
                     window=3L, seed=42L, reps=500L, independent=FALSE,
                     paired=FALSE, assume_normal=FALSE,
                     alternative="two.sided", new_x=NULL,
                     allow_extrapolate=FALSE, weight=NULL,operator=">=",
                     file=NULL, successes=NULL,show_plot=TRUE) {
  item <- .ru_pick(problem)
  if (is.null(item)) return(invisible(NULL))
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
            show_plot=show_plot)
  id <- item$id
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
