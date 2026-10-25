# learnr evaluates code; this checker inspects results, never re-evaluates code.
# Correct exercise feedback is formative and never writes independent progress.
.ru_l2_feedback <- function(ok, text) {
  list(message = paste0(text, if (isTRUE(ok)) " (Guided practice only.)" else ""),
       correct = isTRUE(ok), type = if(isTRUE(ok)) "success" else "error",
       location = "append")
}
.ru_l2_value <- function(env, key) {
  if (!is.environment(env) || !exists(key, envir=env, inherits=FALSE))
    return(NULL)
  get(key, envir=env, inherits=FALSE)
}
.ru_l2_number <- function(x, y) {
  is.numeric(x) && length(x)==1L && !is.na(x) && is.finite(x) &&
    isTRUE(all.equal(as.numeric(x),y,tolerance=1e-10))
}
.ru_l2_expr <- function(code) {
  if (!is.character(code) || length(code)!=1L || is.na(code))
    return(expression())
  tryCatch(parse(text=code,keep.source=FALSE),error=function(e)expression())
}
.ru_l2_calls <- function(expr) {
  if (!is.call(expr)) return(character())
  head <- expr[[1L]]
  out <- if (is.symbol(head)) as.character(head) else character()
  if (is.call(head) && length(head)==3L &&
      identical(head[[1L]],as.name("::")) &&
      identical(head[[2L]],as.name("base")) && is.symbol(head[[3L]]))
    out <- c(out,as.character(head[[3L]]))
  unique(c(out,unlist(lapply(as.list(expr)[-1L],.ru_l2_calls),use.names=FALSE)))
}
.ru_l2_rhs <- function(code,key) {
  e <- .ru_l2_expr(code)
  for (i in rev(seq_along(e))) {
    x <- e[[i]]
    if (is.call(x) && length(x)==3L &&
        (identical(x[[1L]],as.name("<-")) ||
         identical(x[[1L]],as.name("="))) &&
        identical(x[[2L]],as.name(key))) return(x[[3L]])
  }
  NULL
}
.ru_l2_mean_method <- function(expr, object) {
  if (!is.call(expr)) return(FALSE)
  head <- expr[[1L]]
  is_mean <- identical(head,as.name("mean")) ||
    (is.call(head) && length(head)==3L &&
     identical(head[[1L]],as.name("::")) &&
     identical(head[[2L]],as.name("base")) &&
     identical(head[[3L]],as.name("mean")))
  if (is_mean) return(length(expr)==2L && identical(expr[[2L]],as.name(object)))
  if (!identical(head,as.name("/")) || length(expr)!=3L) return(FALSE)
  a <- expr[[2L]]; b <- expr[[3L]]
  is_call <- function(x,name) is.call(x) && length(x)==2L &&
    identical(x[[1L]],as.name(name)) &&
    identical(x[[2L]],as.name(object))
  is_call(a,"sum") && is_call(b,"length")
}
.ru_l2_missing_method <- function(expr) {
  if (!is.call(expr) || length(expr)!=2L) return(FALSE)
  inner <- expr[[2L]]
  if (identical(expr[[1L]],as.name("sum")))
    return(is.call(inner) && length(inner)==2L &&
           identical(inner[[1L]],as.name("is.na")) &&
           identical(inner[[2L]],as.name("x")))
  if (!identical(expr[[1L]],as.name("length")) ||
      !is.call(inner) || length(inner)!=2L ||
      !identical(inner[[1L]],as.name("which"))) return(FALSE)
  inner <- inner[[2L]]
  is.call(inner) && length(inner)==2L &&
    identical(inner[[1L]],as.name("is.na")) &&
    identical(inner[[2L]],as.name("x"))
}
.ru_l2_observed_mean_method <- function(expr) {
  if (!is.call(expr) || length(expr)<2L ||
      !identical(expr[[1L]],as.name("mean")) ||
      !"guided" %in% all.vars(expr[[2L]]) ||
      "replace" %in% .ru_l2_calls(expr)) return(FALSE)
  items <- as.list(expr)
  key <- which(names(items)=="na.rm")
  if (length(key)==1L) {
    val <- items[[key]]
    if (identical(val,TRUE) || identical(val,as.name("exclude_missing")))
      return(TRUE)
  }
  "is.na" %in% .ru_l2_calls(expr[[2L]])
}
.ru_learning_checker <- function(label,user_code,envir_result=NULL,
                                 last_value=NULL,stage="check",engine="r",...) {
  helper <- function(key) utils::getFromNamespace(key,"rulearn")
  yes <- function(x) helper(".ru_l2_feedback")(TRUE,x)
  no <- function(x) helper(".ru_l2_feedback")(FALSE,x)
  if (!identical(engine,"r")) return(no("This exercise needs R."))
  if (identical(stage,"error_check"))
    return(no("R could not evaluate that code. Check delimiters, object names and types."))
  if (!identical(stage,"check")) return(no("Run code before checking."))
  e <- helper(".ru_l2_expr")(user_code)
  last <- if(length(e)) e[[length(e)]] else NULL
  names_last <- helper(".ru_l2_calls")(last)
  names_all <- unlist(lapply(e,helper(".ru_l2_calls")),use.names=FALSE)
  getv <- function(k) helper(".ru_l2_value")(envir_result,k)
  if(label=="ru-f01-guided")
    return(if(is.call(last) && helper(".ru_l2_number")(last_value,5)) yes("Arithmetic evaluates to five.") else no("Write arithmetic, not a bare five or the Console prompt."))
  if(label=="ru-f01-repair")
    return(if(is.call(last) && helper(".ru_l2_number")(last_value,6)) yes("Parentheses are balanced; result six.") else no("Balance the opening parenthesis, then calculate."))
  if(label=="ru-f01-transfer")
    return(if(is.call(last) && helper(".ru_l2_number")(last_value,3)) yes("New expression evaluated.") else no("Enter an expression rather than the final number alone."))
  if(label=="ru-f02-assignment")
    return(if(identical(getv("scores"),c(6,8,10)) && !is.null(helper(".ru_l2_rhs")(user_code,"scores"))) yes("Numeric scores vector created.") else no("Assign numeric scores. == compares, not assigns."))
  if(label %in% c("ru-f02-assign-create","ru-f02-assign-modify")) {
    expected <- if(label=="ru-f02-assign-create") c(2,4,6) else c(2,5,6)
    ok <- identical(getv("scores"),expected) && !is.null(helper(".ru_l2_rhs")(user_code,"scores"))
    return(if(ok) yes("Complete assignment accepted (either <- or =).") else no("Assign the entire scores vector; printing or comparing does not change it."))
  }
  if(label=="ru-f02-average") {
    ok <- helper(".ru_l2_number")(last_value,8) &&
      helper(".ru_l2_mean_method")(last,"scores")
    return(if(ok) yes("Arithmetic mean operation accepted.") else no("Use mean(scores), base::mean(scores) or the taught sum/length ratio; median and hard-coded eight do not count."))
  }
  if(label=="ru-f03-index") {
    ok <- helper(".ru_l2_number")(last_value,1) && helper(".ru_l2_missing_method")(last)
    return(if(ok) yes("One missing observation detected.") else no("x == NA is not a missingness test. Use is.na with sum or length(which)."))
  }
  if(label=="ru-f03-frame") {
    d <- getv("d")
    ok <- is.data.frame(d) && identical(names(d),c("site_group","reading")) &&
      is.character(d[["site_group"]]) &&
      identical(d[["reading"]],c(13,NA_real_,18,20)) &&
      "data.frame" %in% names_all
    return(if(ok) yes("Data frame schema and row values matched.") else no("Build a frame with site_group character and reading numeric. Site labels are not participant IDs."))
  }
  if(label=="ru-f03-types") {
    g <- getv("group"); p <- getv("parts")
    ok <- is.factor(g) && identical(levels(g),c("North","South")) &&
      is.list(p) && !is.data.frame(p) &&
      is.factor(p[["group"]]) &&
      identical(p[["observed"]],c(13,18,20))
    return(if(ok) yes("Factor, list and vector extraction checked.") else no("Use factor() for categories, list() for heterogeneous components and [[ ]] to extract a list value."))
  }
  if(label=="ru-f03-csv") {
    d <- getv("guided")
    ok <- is.data.frame(d) && nrow(d)==4L &&
      identical(names(d),c("row_key","site_group","reading")) &&
      identical(d[["row_key"]],sprintf("G%03d",1:4)) &&
      identical(d[["site_group"]],c("North","North","South","South")) &&
      identical(d[["reading"]],c(13,NA_real_,18,20)) &&
      "read.csv" %in% names_all
    return(if(ok) yes("Installed guided CSV and types were inspected.") else no("Use read.csv and preserve character row_key, repeated site categories and missing numeric reading."))
  }
  if(label=="ru-f03-summary") {
    ok <- identical(getv("exclude_missing"),TRUE) &&
      helper(".ru_l2_number")(getv("average"),17) &&
      helper(".ru_l2_observed_mean_method")(helper(".ru_l2_rhs")(user_code,"average"))
    return(if(ok) yes("With explicit exclusion consent, three observed readings average 17 Celsius.") else no("Consent must be logical TRUE before excluding NA. Replacing the missing value by zero gives 12.75 and changes the calculation."))
  }
  no("Unregistered exercise identifier; no credit granted.")
}