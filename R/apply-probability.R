# Explicit probability calculations with documented inputs and assumptions.
.ru_apply_probability <- function(id,a) {
  if (id %in% c("event_probability","conditional_probability","probability_union")) {
    value <- .ru_column(a, "x")
    event <- a$event
    if (is.null(event)) {
      if (!is.logical(value)) stop("Supply event= (which value counts as A).")
      event <- TRUE
    }
    if (length(event)!=1L || is.na(event))
      stop("event= must identify one non-missing value.")
    A <- value == event
    weights <- if (is.null(a$weight)) rep(1, length(value)) else
      .ru_column(a, "weight", numeric=TRUE)
    if (length(weights)!=length(value))
      stop("Frequency weights must align with event observations.")
    if (any(!is.finite(weights)) ||
        any(weights<0) || any(weights!=floor(weights)))
      stop("Frequency weights must be finite nonnegative whole counts.")

    if (id=="event_probability") {
      ok <- !is.na(A)
      if (sum(!ok)) message("Excluded ",sum(!ok)," missing event rows.")
      if (!any(ok) || sum(weights[ok])==0)
        stop("No observed events with positive total frequency.")
      events <- sum(weights[ok] * A[ok])
      total <- sum(weights[ok])
      out <- c(events=events, trials=total, proportion=events/total)
      print(out); return(out)
    }
    other <- .ru_column(a, "y")
    if (length(other)!=length(value))
      stop("Event conditions must be paired.")
    if (length(a$given)!=1L || is.na(a$given))
      stop("Supply given= with one non-missing value defining event B.")
    B <- other==a$given
    ok <- !is.na(A) & !is.na(B)
    if (sum(!ok)) message("Excluded ",sum(!ok)," incomplete event pairs.")
    if (!any(ok) || sum(weights[ok])==0)
      stop("No complete event pairs with positive total frequency.")
    A <- A[ok]; B <- B[ok]; weights <- weights[ok]
    if (id=="conditional_probability") {
      denominator <- sum(weights[B])
      if (denominator==0)
        stop("No observed weight satisfies the given event.")
      joint <- sum(weights[A & B])
      out <- c(both=joint, given=denominator,
               probability=joint/denominator)
    } else {
      total <- sum(weights)
      out <- c(A=sum(weights[A])/total,
               B=sum(weights[B])/total,
               both=sum(weights[A & B])/total,
               either=sum(weights[A | B])/total)
    }
    print(out); return(out)
  }
  if (id %in% c("binomial_exact","binomial_at_least")) {
    n <- .ru_integer(a$n,"n",min=1L)
    p <- .ru_probability(a$prob)
    k <- .ru_integer(a$k,"k")
    if (k>n) stop("k must not exceed n.")
    out <- if (id=="binomial_exact")
      stats::dbinom(k,size=n,prob=p) else
      stats::pbinom(k-1,size=n,prob=p,lower.tail=FALSE)
    message("Requires independent, identical Bernoulli trials ",
            "with fixed probability. An empirical rate alone does not establish these.")
    print(out); return(out)
  }
  if (id %in% c("normal_left_tail","normal_right_tail","normal_percentile")) {
    if (!isTRUE(a$assume_normal))
      stop("Explicitly set assume_normal=TRUE after judging model suitability.")
    mu <- .ru_required(a$mu,"mu")
    sigma <- .ru_positive(a$sigma,"sigma")
    if (id=="normal_percentile") {
      p <- .ru_probability(a$prob,strict=TRUE)
      out <- stats::qnorm(p,mean=mu,sd=sigma)
    } else {
      threshold <- .ru_required(a$threshold,"threshold")
      out <- stats::pnorm(threshold,mean=mu,sd=sigma,
                         lower.tail=id=="normal_left_tail")
    }
    message("This is a probability under the assumed normal model, ",
            "not an observed sample fraction.")
    print(out); return(out)
  }
  if (id=="discrete_expectation") {
    value <- .ru_column(a,"x",numeric=TRUE)
    p <- .ru_column(a,"y",numeric=TRUE)
    if (length(value)!=length(p) || !length(value) ||
        any(!is.finite(value)) || any(!is.finite(p)))
      stop("Provide complete, paired outcomes and probabilities.")
    if (any(p<0) || abs(sum(p)-1)>1e-8)
      stop("Probabilities must be nonnegative and sum to 1.")
    mean_value <- sum(value*p)
    variance <- sum(p*(value-mean_value)^2)
    out <- c(expected=mean_value,variance=variance)
    print(out); return(out)
  }
  if (id=="sample_random") {
    if (!is.data.frame(a$data)) stop("Supply data= with population rows.")
    n <- .ru_integer(a$n,"n",min=1L)
    if (n>nrow(a$data)) stop("n exceeds available rows.")
    idx <- .ru_seeded(a$seed,sample.int(nrow(a$data),n,replace=FALSE))
    message("Randomly sampled rows from the supplied table; ",
            "this does not make the original table representative.")
    return(a$data[idx,,drop=FALSE])
  }
  if (id=="sampling_distribution") {
    z <- .ru_numeric_values(a,min_n=2L)
    n <- if (is.null(a$n)) length(z) else .ru_integer(a$n,"n",min=2L)
    reps <- .ru_integer(a$reps,"reps",min=50L)
    if (reps>20000L) stop("Limit reps to 20000 for an interactive exercise.")
    means <- .ru_seeded(a$seed,replicate(reps,mean(sample(z,n,replace=TRUE))))
    if (isTRUE(a$show_plot)) {
      graphics::hist(means,col="#CEE2F0",border="#244967",
                     main="Bootstrap distribution of sample means",
                     xlab="Resampled mean")
      graphics::abline(v=mean(z),col="#A35E20",lty=2,lwd=2)
    }
    message("Empirical bootstrap from this dataset. ",
            "It cannot repair a biased or non-representative original sample.")
    print(c(original_mean=mean(z),bootstrap_se=stats::sd(means)))
    return(means)
  }
  stop("Unknown probability or sampling problem.")
}