# P1-B: synthetic held-out transfer, numeric oracles, model boundaries.
# No course/exam prompts, real student data, or external services.
library(rulearn)

# This set is independently authored for P1-B, not copied from the design
# acceptance Q questions, predecessor fixtures, or lesson titles.
transfer <- list(
  c("T01", "For uniform voltage on [-5,7], what is F(1)?", "uniform_cdf"),
  c("T02", "Use punif() at a threshold for a continuous uniform reading.", "uniform_cdf"),
  c("T03", "For a continuous uniform signal, what fraction falls below 3.5?", "uniform_cdf"),
  c("T04", "If U has Uniform(-5,7), evaluate P(0.5<U<4.5).", "uniform_interval"),
  c("T05", "For a uniform wait, what fraction falls inside the interval 2.3 to 5.7?", "uniform_interval"),
  c("T06", "Find uniform probability from -3 to 8 with support [0,4].", "uniform_interval"),
  c("T07", "With punif, find an interval probability partly outside the support.", "uniform_interval"),
  c("T08", "In a normal sensor model, evaluate P(-1.2<X<0.4).", "normal_between"),
  c("T09", "Under Normal(mean=4, sd=2), find the chance inside the range 2 to 9.", "normal_between"),
  c("T10", "For a normal measurement, find area from -2 to 1.", "normal_between"),
  c("T11", "With a normal model, which pnorm operation covers two endpoints?", "normal_between"),
  c("T12", "Normal X: find its chance strictly above 12.", "normal_right_tail"),
  c("T13", "Using pnorm for a normal outcome, find the probability below 3.", "normal_left_tail"),
  c("T14", "Which value marks the 90th percentile of a normal model using qnorm?", "normal_percentile"),
  c("T15", "For 11 independent binomial trials, what is P(X>4)?", "binomial_more_than"),
  c("T16", "A binomial count exceeds three successes; which upper tail applies?", "binomial_more_than"),
  c("T17", "Precisely five successes in nine independent binomial trials?", "binomial_exact"),
  c("T18", "At least six successes for a binomial count: which cutoff?", "binomial_at_least"),
  c("T19", "For a binomial count, I need no more than three successes.", "NO_MATCH"),
  c("T20", "Could I use ppois with a uniform distribution for arrivals?", "NO_MATCH"),
  c("T21", "Use dbinom for a normal CDF, please.", "NO_MATCH"),
  c("T22", "Should punif calculate a Poisson point-mass count?", "NO_MATCH"),
  c("T23", "I need a z confidence interval for a normal mean, not a probability.", "NO_MATCH"),
  c("T24", "Conduct a one-sided hypothesis test about a population proportion.", "NO_MATCH"),
  c("T25", "What repairs a cracked bicycle handlebar?", "NO_MATCH"),
  c("T26", "In a Poisson arrivals model, find the chance of at most two.", "poisson_cdf"),
  c("T27", "For discrete values with given masses, create a cumulative CDF.", "discrete_cdf"),
  c("T28", "Fair independent octahedral dice sum probability mass.", "discrete_pmf"),
  c("T29", "Would punif estimate the correlation coefficient?", "NO_MATCH"),
  c("T30", "What does dunif return for a continuous uniform model?", "NO_MATCH"),
  c("T31", "For a binomial X, compute P(X>=5).", "binomial_at_least"),
  c("T32", "A Poisson count is more than four; what R upper tail is needed?", "poisson_upper_tail")
)
failures <- character()
for (item in transfer) {
  observed_text <- capture.output(hits <- ru_find(item[2L], n=3L))
  observed <- if (nrow(hits)) hits$id[1L] else "NO_MATCH"
  if (!identical(observed, item[3L]) || length(observed_text)) {
    failures <- c(failures, paste(item[1L], "expected", item[3L],
                                  "observed", observed,
                                  "stdout_lines", length(observed_text)))
  }
}
if (length(failures)) stop(paste(failures, collapse="\n"), call.=FALSE)
cat("P1-B held-out transfer:", length(transfer), "/", length(transfer),
    "first-rank/silent queries PASS\n")

# Verify the exact four installed source pages, their editable inputs and code.
ids <- c("uniform_cdf", "uniform_interval", "normal_between",
         "binomial_more_than")
index <- getFromNamespace(".ru_lesson_index", "rulearn")()
coverage <- getFromNamespace(".ru_coverage", "rulearn")()
read_lesson <- getFromNamespace(".ru_lesson_read", "rulearn")
stopifnot(nrow(index) == 84L, nrow(coverage) == 174L,
          !anyDuplicated(index$id), !anyDuplicated(coverage$id),
          !anyDuplicated(coverage$reference_id),
          all(ids %in% index$id),
          all(vapply(ids, function(id)
            identical(coverage$content_status[coverage$id == id], "VERIFIED"),
            logical(1L))))
required <- c("immediate answer", "what the question asks", "recognize the method",
              "numbered solution steps", "original worked example",
              "use this in r", "what to edit", "what to check",
              "interpret your results", "frequent mistakes", "learn more")
results <- list()
for (id in ids) {
  page <- read_lesson(id)
  stopifnot(!is.null(page), all(required %in% names(page$sections)),
            nzchar(page$code), length(page$edit) >= 4L,
            identical(page$meta$status, "VERIFIED"),
            grepl("search.r-project.org/R/refmans/stats/html/",
                  page$meta$sources, fixed=TRUE),
            !grepl("http|curl|download.file|install.packages", page$code))
  scope <- new.env(parent=globalenv())
  results[[id]] <- eval(parse(text=page$code), envir=scope)
}
cat("P1-B four installed native R code examples execute: 4/4 PASS\n")
# Existing Viewer must expose the new structured explanation, not only read
# it from Markdown. The native Copy selector and local links stay intact.
render <- getFromNamespace(".ru_page_html", "rulearn")
for (id in ids) {
  item <- read_lesson(id)
  html <- render(item)
  stopifnot(grepl("What the question asks", html, fixed=TRUE),
            grepl("Recognize the method", html, fixed=TRUE),
            grepl("Reasoning and worked example", html, fixed=TRUE),
            grepl("<ol>", html, fixed=TRUE),
            grepl("Original worked example", html, fixed=TRUE),
            grepl("Frequent mistakes", html, fixed=TRUE),
            grepl(paste0("data-target='code-", id, "'"), html, fixed=TRUE),
            grepl("class='copy'", html, fixed=TRUE),
            grepl("class='edit'", html, fixed=TRUE),
            !grepl("file://", html, fixed=TRUE))
}
cat("P1-B four Viewer explanations, ordered steps and copy controls: PASS\n")


near <- function(x, y, tol=1e-12) {
  isTRUE(all.equal(as.numeric(x), as.numeric(y), tolerance=tol))
}

# Uniform CDF oracle from clipped support geometry, independently of punif.
u_cdf <- results[["uniform_cdf"]]
stopifnot(near(u_cdf[1L], 3/8), near(u_cdf[2L], 0),
          near(u_cdf[3L], 2/8), near(u_cdf[4L], 1),
          near(u_cdf[5L], 1))
x <- c(-50, -2, 0.5, 4, 12)
a <- -2
b <- 4
geometric_cdf <- pmax(0, pmin(1, (x-a)/(b-a)))
stopifnot(near(stats::punif(x, min=a, max=b), geometric_cdf),
          near(stats::punif(0.5, a, b) - stats::punif(0.5, a, b), 0))

# Uniform interval oracle from intersection length (including out-of-support).
u_int <- results[["uniform_interval"]]
stopifnot(near(u_int["inside"], 6/12),
          near(u_int["partly_outside"], 3/12))
intersection_prob <- function(lower, upper, a, b) {
  stopifnot(all(is.finite(c(lower,upper,a,b))), a < b, lower < upper)
  max(0, min(upper,b)-max(lower,a))/(b-a)
}
stopifnot(near(stats::punif(14, 2, 14)-stats::punif(-10, 2, 14),
               intersection_prob(-10, 14, 2, 14)),
          near(stats::punif(18, 2, 14)-stats::punif(15, 2, 14), 0),
          near(stats::punif(11, 2, 14)-stats::punif(5, 2, 14),
               intersection_prob(5, 11, 2, 14)))

# Normal area: independent quadrature of the density, plus z-transform.
zlo <- (25-28)/4
zhi <- (34-28)/4
normal_quad <- stats::integrate(function(y) stats::dnorm(y, mean=28, sd=4),
                                lower=25, upper=34, rel.tol=1e-12)$value
stopifnot(near(results[["normal_between"]], normal_quad, tol=1e-10),
          near(results[["normal_between"]],
               stats::pnorm(zhi) - stats::pnorm(zlo)))
# Near-one cancellation: naive subtraction can be zero while the
# direct survival-function difference remains strictly positive.
stable_right <- stats::pnorm(9, lower.tail=FALSE) -
                stats::pnorm(9.5, lower.tail=FALSE)
naive_right <- stats::pnorm(9.5) - stats::pnorm(9)
stopifnot(stable_right > 0, stable_right <= 1,
          naive_right <= stable_right, near(stats::pnorm(0), 0.5))

# Binomial exact finite support: independent pmf sum using choose() formula.
n <- 9L
prob <- 0.35
k <- 3L
x <- seq.int(k+1L, n)
oracle_gt <- sum(choose(n,x) * prob^x * (1-prob)^(n-x))
b_vals <- results[["binomial_more_than"]]
stopifnot(near(b_vals["strictly_more"], oracle_gt),
          near(b_vals["inclusive_at_least"] - b_vals["strictly_more"],
               b_vals["exactly_cutoff"]),
          near(b_vals["exactly_cutoff"],
               choose(n,k) * prob^k * (1-prob)^(n-k)))
for (p in c(0, 0.3, 1)) {
  stopifnot(near(stats::pbinom(0, 0, p, lower.tail=FALSE), 0),
            near(stats::pbinom(-1, 0, p, lower.tail=FALSE), 1),
            near(stats::pbinom(n, n, p, lower.tail=FALSE), 0),
            near(stats::pbinom(n+2, n, p, lower.tail=FALSE), 0))
}
stopifnot(near(stats::pbinom(0, 9, 0, lower.tail=FALSE), 0),
          near(stats::pbinom(0, 9, 1, lower.tail=FALSE), 1),
          near(stats::pbinom(-1, 9, 0.35, lower.tail=FALSE), 1),
          near(stats::dpois(0, lambda=0), 1),
          near(stats::ppois(-1, lambda=0, lower.tail=FALSE), 1))

# Force genuine source-code validation failures for malformed user edits;
# merely checking an independent stopifnot would not test the worked examples.
must_reject <- function(id, before, after) {
  txt <- read_lesson(id)$code
  stopifnot(grepl(before, txt, fixed=TRUE))
  bad <- sub(before, after, txt, fixed=TRUE)
  rejected <- inherits(try(eval(parse(text=bad),
                                envir=new.env(parent=globalenv())),
                           silent=TRUE), "try-error")
  if (!rejected) stop(id, " accepted malformed input: ", after)
}
must_reject("uniform_cdf", "b_seconds <- 9", "b_seconds <- 1")
must_reject("uniform_cdf", "x_seconds <- 4", "x_seconds <- NA_real_")
must_reject("uniform_cdf", "a_seconds <- 1", "a_seconds <- Inf")
must_reject("uniform_interval", "lower_minutes <- 5", "lower_minutes <- 12")
must_reject("uniform_interval", "b_minutes <- 14", "b_minutes <- 2")
must_reject("uniform_interval", "outside_lower_minutes <- -3",
            "outside_lower_minutes <- NaN")
must_reject("normal_between", "sigma_seconds <- 4", "sigma_seconds <- 0")
must_reject("normal_between", "upper_seconds <- 34", "upper_seconds <- 24")
must_reject("normal_between", "mu_seconds <- 28", "mu_seconds <- Inf")
must_reject("binomial_more_than", "size_trials <- 9L", "size_trials <- -1L")
must_reject("binomial_more_than", "size_trials <- 9L", "size_trials <- 2.5")
must_reject("binomial_more_than", "success_probability <- 0.35",
            "success_probability <- 1.2")
must_reject("binomial_more_than", "cutoff_successes <- 3L",
            "cutoff_successes <- NA_real_")
cat("P1-B geometry, integration, PMF oracles, strict/inclusive boundaries,",
    "lambda=0 and 13 malformed input rejections PASS\n")