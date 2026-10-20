# Explicit probability calculations with documented inputs and assumptions.
.ru_apply_probability <- function(id,a) {
  if (id %in% c("event_probability","conditional_probability","probability_union")) {
    v <- .ru_column(a,"x")
    event <- a$event
    if (is.null(event)) {
      if (!is.logical(v)) stop("Supply event= (which value counts as A).")
      event <- TRUE
    }
    A <- v==event
    if (id=="event_probability") {
      A <- A[!is.na(A)]
      if (!length(A)) stop("No observed events.")
      out <- c(events=sum(A),trials=length(A),proportion=mean(A))
      print(out); return(out)
    }
    w <- .ru_column(a,"y")
    if (length(v)!=length(w)) stop("Event conditions must be paired.")
    if (is.null(a$given) || length(a$given)!=1L)
      stop("Supply given= (the B event value).")
    B <- w==a$given
    ok <- !is.na(A)&!is.na(B)
    A <- A[ok]; B <- B[ok]
    if (!length(A)) stop("No complete event observations.")
    if (id=="conditional_probability") {
      denominator <- sum(B)
      if (!denominator) stop("No observations satisfy the given event.")
      out <- c(both=sum(A&B),given=denominator,
               probability=sum(A&B)/denominator)
    } else {
      out <- c(A=mean(A),B=mean(B),both=mean(A&B),
               either=mean(A|B))
      stopifnot(isTRUE(all.equal(unname(out["either"]),
                                   unname(out["A"]+out["B"]-out["both"]))))
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
    set.seed(.ru_integer(a$seed,"seed"))
    idx <- sample.int(nrow(a$data),n,replace=FALSE)
    message("Randomly sampled rows from the supplied table; ",
            "this does not make the original table representative.")
    return(a$data[idx,,drop=FALSE])
  }
  if (id=="sampling_distribution") {
    z <- .ru_numeric_values(a,min_n=2L)
    n <- if (is.null(a$n)) length(z) else .ru_integer(a$n,"n",min=2L)
    reps <- .ru_integer(a$reps,"reps",min=50L)
    if (reps>20000L) stop("Limit reps to 20000 for an interactive exercise.")
    set.seed(.ru_integer(a$seed,"seed"))
    means <- replicate(reps,mean(sample(z,n,replace=TRUE)))
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
