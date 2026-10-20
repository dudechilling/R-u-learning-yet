# Shared validation for applications to arbitrary data frames.
.ru_column <- function(a, key, numeric=FALSE, needed=TRUE) {
  value <- a[[key]]
  if (is.null(value)) {
    if (needed) stop("Supply ",key,"= with a column name or vector.",call.=FALSE)
    return(NULL)
  }
  d <- a$data
  if (is.character(value) && length(value)==1L && !is.null(d)) {
    if (!value %in% names(d))
      stop("Column '",value,"' not found. Use ru_columns(data).",call.=FALSE)
    value <- d[[value]]
  } else if (!is.null(d) && length(value)!=nrow(d)) {
    stop(key," must name a column or match the data frame's rows.",call.=FALSE)
  }
  if (numeric && !is.numeric(value))
    stop(key," must be numeric; do not silently convert categories.",call.=FALSE)
  value
}
.ru_numeric_values <- function(a,key="x",min_n=1L) {
  z <- .ru_column(a,key,numeric=TRUE)
  missing <- sum(!is.finite(z))
  if (missing) message("Excluded ",missing," non-finite ",key," values.")
  z <- z[is.finite(z)]
  if (length(z)<min_n) stop("Not enough usable numeric observations.",call.=FALSE)
  z
}
.ru_pairs <- function(a,second="y",min_n=3L) {
  x <- .ru_column(a,"x",numeric=TRUE)
  y <- .ru_column(a,second,numeric=TRUE)
  if (length(x)!=length(y)) stop("Paired columns must have matching lengths.")
  good <- is.finite(x)&is.finite(y)
  if (sum(good)<min_n) stop("Not enough complete pairs.",call.=FALSE)
  if (sum(!good)) message("Excluded ",sum(!good)," incomplete pairs.")
  data.frame(x=x[good],y=y[good])
}
.ru_groups <- function(a, two=FALSE) {
  x <- .ru_column(a,"x",numeric=TRUE)
  g <- .ru_column(a,"group")
  if (length(g)!=length(x)) stop("Groups must align with observations.")
  ok <- is.finite(x)&!is.na(g)
  if (!any(ok)) stop("No usable grouped observations.")
  if (sum(!ok)) message("Excluded ",sum(!ok)," incomplete grouped observations.")
  g <- droplevels(factor(g[ok]))
  if (nlevels(g)<2L) stop("At least two observed groups are needed.")
  if (two && nlevels(g)!=2L) stop("Exactly two groups are required for this test.")
  data.frame(value=x[ok],group=g)
}
.ru_required <- function(x,label) {
  if (is.null(x) || length(x)!=1L || is.na(x) || !is.finite(x))
    stop("Supply a finite numeric ",label,".",call.=FALSE)
  as.numeric(x)
}
.ru_positive <- function(x,label) {
  z <- .ru_required(x,label)
  if (z<=0) stop(label," must be positive.",call.=FALSE)
  z
}
.ru_probability <- function(x,label="probability",strict=FALSE) {
  z <- .ru_required(x,label)
  if (z<0 || z>1 || (strict && (z==0 || z==1)))
    stop(label," must be between 0 and 1",if (strict) " (exclusive)" else "",".")
  z
}
.ru_integer <- function(x,label,min=0L) {
  v <- .ru_required(x,label)
  if (v<min || v!=floor(v)) stop(label," must be a whole number >= ",min,".")
  as.integer(v)
}
.ru_level <- function(a) {
  if (is.null(a$confidence))
    stop("Supply confidence= explicitly, for example confidence=.95.",call.=FALSE)
  .ru_probability(a$confidence,"confidence",strict=TRUE)
}
.ru_time <- function(a,minimum=3L) {
  v <- .ru_column(a,"x",numeric=TRUE)
  t <- .ru_column(a,"time")
  if (length(t)!=length(v)) stop("Time must match the observations.")
  good <- is.finite(v) & !is.na(t)
  if (sum(good)<minimum) stop("Not enough complete time observations.")
  d <- data.frame(time=t[good],value=v[good])
  d <- d[order(d$time),,drop=FALSE]
  if (anyDuplicated(d$time))
    stop("Duplicate timestamps: first aggregate or resolve duplicates.",call.=FALSE)
  d
}
.ru_warn_inference <- function() {
  message("Check sampling, independence and model assumptions before ",
          "generalizing beyond the observed data.")
}
