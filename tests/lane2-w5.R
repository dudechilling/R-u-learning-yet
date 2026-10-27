# W5 A2: qualify fixed teaching examples against actual installed ru_apply.
# These automatic tests verify method/code contracts, NOT human learning.
suppressPackageStartupMessages(library(rulearn))
ns <- asNamespace("rulearn")
teach <- get(".ru_w5_method_teach", envir = ns)
allowed <- get(".ru_allowed_arguments", envir = ns)
all_ids <- c(
  "import_csv", "inspect_columns", "filter_rows", "group_means",
  "missing_values", "mean_median", "sample_sd", "five_number",
  "percentile_cutoff", "relative_frequency", "categorical_mode", "z_score",
  "histogram", "bar_chart", "boxplot", "grouped_boxplot", "scatterplot",
  "zero_correlation", "normal_shaded_area", "line_chart", "moving_average",
  "autocorrelation", "stationarity", "event_probability",
  "conditional_probability", "probability_union", "binomial_exact",
  "binomial_at_least", "normal_left_tail", "normal_right_tail",
  "normal_percentile", "discrete_expectation", "sample_random",
  "sampling_distribution", "standard_error", "mean_confidence_interval",
  "one_sample_t", "two_sample_t", "paired_t", "correlation_test",
  "spearman_correlation", "linear_regression", "predict_regression",
  "interpolation", "categorical_independence", "proportion_interval"
)
stopifnot(length(all_ids) == 46L, !anyDuplicated(all_ids))
gaps <- c("import_csv", "filter_rows", "categorical_mode", "z_score",
          "normal_shaded_area", "normal_right_tail")
qualified <- setdiff(all_ids, gaps)
stopifnot(length(qualified) == 40L)
check <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}
near <- function(a, b, tolerance = 1e-10) {
  isTRUE(all.equal(as.double(a), as.double(b), tolerance = tolerance,
                   check.attributes = FALSE))
}
run_preview <- function(guide) {
  # This is the TEST HARNESS only. The teaching function never executes code.
  e <- new.env(parent = globalenv())
  sink_output <- capture.output({
    source_conn <- textConnection(guide$code_preview)
    tryCatch(source(source_conn, local = e, echo = FALSE),
             finally = close(source_conn))
  })
  check(exists("result", envir = e, inherits = FALSE),
        paste("Example did not assign result:", guide$method_id))
  check(length(sink_output) < 800L, "Excessive synthetic example output")
  list(value = get("result", envir = e), data = if (exists("data", envir = e, inherits = FALSE))
    get("data", e) else NULL, env = e)
}
schema_fields <- c("schema_version", "status", "method_id", "question",
  "title", "required_inputs", "why_this_method", "assumptions", "steps",
  "interpretation", "cautions", "code_preview", "hints", "executed")
tricky <- "<script>system('forbidden'); do not execute this text</script>"
results <- list()
for (id in qualified) {
  g <- teach(id, question = tricky)
  check(is.list(g), paste("No method guide", id))
  check(identical(names(g), schema_fields), paste("wrong schema fields", id))
  check(identical(g$schema_version, "ru.w5.method-guide.v1") &&
        identical(g$status, "GUIDED_REFERENCE") &&
        identical(g$method_id, id) &&
        identical(g$question, tricky) &&
        identical(g$executed, FALSE), paste("inert guide contract", id))
  check(is.character(g$title) && length(g$title) == 1L &&
        nzchar(g$title) && validUTF8(g$title), paste("title", id))
  check(length(g$required_inputs) > 0L &&
        all(g$required_inputs %in% allowed(id)) &&
        !anyDuplicated(g$required_inputs), paste("wrong input contract", id))
  check(is.character(g$why_this_method) && length(g$why_this_method) == 1L &&
        nzchar(g$why_this_method) &&
        length(g$assumptions) >= 2L && length(g$steps) >= 3L &&
        grepl("^Transfer exercise: ", tail(g$steps, 1L)) &&
        length(g$interpretation) >= 1L && length(g$cautions) >= 2L,
        paste("missing method-specific instruction", id))
  check(identical(names(g$hints), c("H0", "H1", "H2", "H3")) &&
        all(vapply(g$hints, function(z) is.character(z) &&
          length(z) == 1L && nzchar(z), logical(1L))) &&
        length(unique(unlist(g$hints))) == 4L &&
        grepl("Worked scaffold", g$hints$H3, fixed = TRUE),
        paste("H0-H3 not progressive", id))
  check(is.character(g$code_preview) && length(g$code_preview) == 1L &&
        nzchar(g$code_preview) &&
        !grepl(tricky, g$code_preview, fixed = TRUE) &&
        grepl(paste0("ru_apply('", id, "'"), g$code_preview, fixed = TRUE),
        paste("unsafe/nonmatching code preview", id))
  check(nchar(g$code_preview, type = "bytes") < 32768L,
        paste("code bound", id))
  check(identical(g$code_preview, teach(id)$code_preview) &&
        identical(g$code_preview, teach(id, "another inert question")$code_preview),
        paste("question influenced static code", id))
  check(!any(vapply(g$assumptions, function(z) z %in% c("TRUE", "FALSE"),
                    logical(1L))), paste("boolean assumptions", id))
  out <- tryCatch(run_preview(g), error = function(e) {
    stop("Fixed runnable example failed for ", id, ": ",
         conditionMessage(e), call. = FALSE)
  })
  results[[id]] <- out
  cat("W5 A2 VERIFIED EXAMPLE: ", id, "\n", sep = "")
}
for (id in gaps) check(is.null(teach(id)),
                      paste("unqualified guide falsely returned", id))
check(is.null(teach("kriging")) && is.null(teach("spatial_autocorrelation")),
      "unsupported STAT/GEOG method invented")
for (bad in list(NULL, character(), NA_character_, 7, list("mean"),
                 "MEAN_MEDIAN", "", "ru_apply('sample_sd')"))
  check(is.null(teach(bad)), "invalid/noncanonical ID accepted")
for (bad in list(NA_character_, 3, character(0), list("script"),
                 paste(rep("X", 4200L), collapse = "")))
  check(is.null(teach("mean_median", bad)), "unbounded/nontext question accepted")
no_q <- teach("mean_median")
check(is.null(no_q$question), "omitted question should remain NULL")

# Independently specified numerical oracles, not copied code previews.
num <- c(2, 4, 6, 8, 10, 12)
v <- c(3, 5, 4, 7, 6, 8, 5, 9)
x <- 1:6
y <- c(2, 3, 5, 5, 8, 9)
d <- list()
d$inspect_columns <- is.data.frame(results$inspect_columns$value)
d$missing_values <- near(results$missing_values$value[c("total", "missing",
                                                        "available", "mean_available")],
                          c(5, 2, 3, 4))
d$mean_median <- near(results$mean_median$value[c("n", "mean", "median")],
                      c(6, 7, 7))
d$sample_sd <- near(results$sample_sd$value[c("sample_variance", "sample_sd")],
                    c(14, sqrt(14)))
d$five_number <- near(results$five_number$value$quantile,
                      c(2, 4.5, 7, 9.5, 12)) &&
                 near(results$five_number$value$IQR, 5)
d$percentile_cutoff <- near(results$percentile_cutoff$value, 9.5)
freq <- results$relative_frequency$value
d$relative_frequency <- is.data.frame(freq) &&
  near(freq$n[match(c("A", "B", "C"), freq$category)], c(3, 2, 1)) &&
  near(sum(freq$proportion), 1)
gm <- results$group_means$value
d$group_means <- near(gm$mean, c(4, 10)) && near(gm$n, c(3, 3))
histogram <- results$histogram$value
d$histogram <- inherits(histogram, "histogram") &&
  near(histogram$counts, graphics::hist(num, plot = FALSE)$counts) &&
  near(sum(histogram$counts), length(num))
d$bar_chart <- near(results$bar_chart$value[c("A", "B", "C")], c(3, 2, 1))
d$boxplot <- near(results$boxplot$value$stats,
                  grDevices::boxplot.stats(c(2, 3, 3, 4, 5, 6, 20))$stats)
d$grouped_boxplot <- near(results$grouped_boxplot$value, c(4, 10))
d$scatterplot <- inherits(results$scatterplot$value, "lm") &&
  near(unname(stats::coef(results$scatterplot$value)),
       unname(stats::coef(stats::lm(y ~ x))))
d$zero_correlation <- abs(results$zero_correlation$value) < 1e-12
d$line_chart <- is.data.frame(results$line_chart$value) &&
  near(results$line_chart$value$time, 1:12) &&
  near(results$line_chart$value$value, c(4,5,4,6,7,6,8,9,8,10,9,11))
ma <- results$moving_average$value
d$moving_average <- is.data.frame(ma) && is.na(ma$smoothed[1]) &&
  near(ma$smoothed[2], (4+5+4)/3)
d$autocorrelation <- inherits(results$autocorrelation$value, "acf") &&
  near(as.numeric(results$autocorrelation$value$acf[1]), 1)
d$stationarity <- is.data.frame(results$stationarity$value) &&
  near(results$stationarity$value$mean, c(32/6, 55/6))
d$event_probability <- near(results$event_probability$value["proportion"], 4/6)
d$conditional_probability <- near(results$conditional_probability$value["probability"], 1)
d$probability_union <- near(results$probability_union$value["either"], 4/6)
d$binomial_exact <- near(results$binomial_exact$value, choose(10, 2)*.3^2*.7^8)
d$binomial_at_least <- near(results$binomial_at_least$value, 1 - sum(
  choose(10, 0:2)*.3^(0:2)*.7^(10-(0:2))))
d$normal_left_tail <- near(results$normal_left_tail$value, stats::pnorm(1))
d$normal_percentile <- near(results$normal_percentile$value, 100+15*stats::qnorm(.9))
d$discrete_expectation <- near(results$discrete_expectation$value,
                               c(expected=1, variance=.5))
sampled <- results$sample_random$value
d$sample_random <- is.data.frame(sampled) &&
  nrow(sampled)==4L && !anyDuplicated(sampled$id) &&
  all(sampled$id %in% 1:12)
d$sampling_distribution <- length(results$sampling_distribution$value)==60L &&
  all(is.finite(results$sampling_distribution$value))
d$standard_error <- near(results$standard_error$value["estimated_se"],
                         stats::sd(v)/sqrt(length(v)))
d$mean_confidence_interval <- near(results$mean_confidence_interval$value$conf.int,
                                  stats::t.test(v,conf.level=.95)$conf.int)
d$one_sample_t <- near(results$one_sample_t$value$statistic,
                       (mean(v)-5)/(stats::sd(v)/sqrt(length(v))))
d$two_sample_t <- near(results$two_sample_t$value$statistic,
                       stats::t.test(c(2,4,5,7), c(8,10,11,12))$statistic)
d$paired_t <- near(results$paired_t$value$estimate,
                   mean(c(4,6,6,8,9)-c(3,4,5,6,7)))
d$correlation_test <- near(results$correlation_test$value$estimate,
                           stats::cor(x,y))
d$spearman_correlation <- near(results$spearman_correlation$value$estimate,
                               stats::cor(x,y,method="spearman"))
d$linear_regression <- inherits(results$linear_regression$value, "lm") &&
  near(unname(stats::coef(results$linear_regression$value)),
       unname(stats::coef(stats::lm(y~x))))
pred <- results$predict_regression$value
d$predict_regression <- is.matrix(pred) &&
  near(pred[1,"fit"], unname(stats::predict(stats::lm(y~x),
                              newdata=data.frame(x=3.5))))
d$interpolation <- near(results$interpolation$value$y, 18) &&
                   near(results$interpolation$value$x, 4)
chisq <- results$categorical_independence$value
tab <- matrix(c(24, 12, 16, 28), nrow=2L)
d$categorical_independence <- inherits(chisq, "htest") &&
  near(unname(chisq$statistic), unname(suppressWarnings(
    stats::chisq.test(tab,correct=FALSE)$statistic)))
d$proportion_interval <- near(results$proportion_interval$value$conf.int,
                               stats::prop.test(26,50,conf.level=.95,
                                                correct=FALSE)$conf.int)
stopifnot(setequal(names(d), qualified),
          all(vapply(d, isTRUE, logical(1L))))
cat("W5 A2 QUALIFIED METHODS:", length(qualified), "/ 46\n")
cat("W5 A2 INDEPENDENT METHOD ORACLES:", sum(unlist(d)), "/",
    length(d), "\n")
cat("W5 A2 UNQUALIFIED GAPS:", paste(gaps, collapse = ", "), "\n")
cat("W5 A2 METHOD-GUIDE CONTRACT AND EXECUTABLE SYNTHETIC EXAMPLES PASS\n")