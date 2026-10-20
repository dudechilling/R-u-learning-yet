# Data preparation and descriptive-statistic recipes.
.ru_apply_basic <- function(id,a) {
  if (id=="import_csv") {
    if (!is.character(a$file) || length(a$file)!=1L ||
        !file.exists(a$file)) stop("Supply file= with an existing CSV path.")
    d <- utils::read.csv(a$file,stringsAsFactors=FALSE,check.names=FALSE)
    cat("Imported ",nrow(d)," rows and ",ncol(d)," columns.\n",sep="")
    ru_columns(d)
    return(d)
  }
  if (id=="inspect_columns") {
    if (!is.data.frame(a$data)) stop("Supply a data frame.")
    return(ru_columns(a$data))
  }
  if (id=="filter_rows") {
    if (!is.data.frame(a$data)) stop("Supply a data frame.")
    value <- .ru_column(a,"x")
    if (is.null(a$threshold) || length(a$threshold)!=1L)
      stop("Supply threshold= as the value to compare.")
    op <- a$operator
    if (!(op %in% c(">=",">","<=","<","==","!=")))
      stop("operator= must be one of >=, >, <=, <, ==, !=.")
    if (!is.numeric(value) && !(op %in% c("==","!=")))
      stop("Category comparisons support == and != only.")
    if (op=="==") test <- value==a$threshold
    else if (op=="!=") test <- value!=a$threshold
    else if (op==">") test <- value>a$threshold
    else if (op==">=") test <- value>=a$threshold
    else if (op=="<") test <- value<a$threshold
    else test <- value<=a$threshold
    out <- a$data[which(!is.na(test)&test),,drop=FALSE]
    cat("Retained ",nrow(out)," of ",nrow(a$data)," rows.\n",sep="")
    return(out)
  }
  if (id=="group_means") {
    z <- .ru_groups(a)
    out <- aggregate(z$value,list(group=z$group),
                     function(v) c(n=length(v),mean=mean(v)))
    result <- data.frame(group=out$group,n=out$x[,"n"],mean=out$x[,"mean"])
    print(result,row.names=FALSE)
    return(result)
  }
  if (id=="missing_values") {
    v <- .ru_column(a,"x",numeric=TRUE)
    out <- c(total=length(v),missing=sum(!is.finite(v)),
             available=sum(is.finite(v)),
             mean_available=if (any(is.finite(v))) mean(v[is.finite(v)]) else NA_real_)
    print(out)
    return(out)
  }
  if (id=="mean_median") {
    z <- .ru_numeric_values(a)
    out <- c(n=length(z),mean=mean(z),median=stats::median(z))
    print(out); return(out)
  }
  if (id=="sample_sd") {
    z <- .ru_numeric_values(a,min_n=2L)
    out <- c(n=length(z),min=min(z),max=max(z),
             range=diff(range(z)),sample_variance=stats::var(z),
             sample_sd=stats::sd(z))
    print(out); return(out)
  }
  if (id=="five_number") {
    z <- .ru_numeric_values(a)
    out <- list(
      quantile=stats::quantile(z,probs=c(0,.25,.5,.75,1)),
      fivenum=stats::fivenum(z),IQR=stats::IQR(z))
    print(out); return(out)
  }
  if (id=="percentile_cutoff") {
    z <- .ru_numeric_values(a)
    p <- .ru_probability(a$prob)
    out <- stats::quantile(z,probs=p)
    print(out); return(out)
  }
  if (id %in% c("relative_frequency","categorical_mode")) {
    z <- .ru_column(a,"x")
    count <- table(z,useNA="no")
    if (!length(count)) stop("No categories to count.")
    if (id=="categorical_mode") {
      result <- names(count)[count==max(count)]
      print(result); return(result)
    }
    out <- data.frame(category=names(count),n=as.integer(count),
                      proportion=as.numeric(count)/sum(count))
    out$percent <- 100*out$proportion
    print(out,row.names=FALSE); return(out)
  }
  if (id=="z_score") {
    z <- .ru_numeric_values(a,min_n=2L)
    s <- stats::sd(z)
    if (!is.finite(s) || s==0) stop("No sample variation; z-scores are undefined.")
    target <- if (is.null(a$threshold)) z else .ru_required(a$threshold,"threshold")
    out <- (target-mean(z))/s
    print(out); return(out)
  }
  stop("Unknown data or summary problem.")
}
