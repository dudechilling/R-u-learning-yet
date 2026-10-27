# W4 bounded computations + R-only code preview; never evaluate user text.
.ru_w4_computed <- function(parsed,status,reason_code,answer=list(),
                            checks=list(verified=FALSE),code_preview="") {
  v<-function(key,default)if(is.list(parsed)&&!is.null(parsed[[key]])) parsed[[key]] else default
  structure(list(schema_version="ru.guided.v1",status=status,
    reason_code=reason_code, original_question=v("original_question",""),
    family_id=v("family_id",NA_character_),inputs=v("inputs",list()),
    requested_outputs=v("requested_outputs",character()),
    assumptions=v("assumptions",list()),answer=answer,checks=checks,
    code_preview=code_preview,executed=FALSE,
    missing_inputs=v("missing_inputs",character()),
    method_id=v("method_id",NA_character_),model_id=v("model_id",NA_character_),
    estimand=v("estimand",NA_character_),
    study_design=v("study_design","theoretical"),
    execution_scope="INLINE_LITERAL_ONLY"),class=c("ru_w4_computed","list"))
}
.ru_w4_code_number_literal <- function(x) {
  stopifnot(is.double(x)||is.integer(x),length(x)>0L,
            all(is.finite(x)),all(abs(x)<=1e9))
  paste(vapply(as.double(x),function(y) sprintf("%.17g",y),character(1L)),
        collapse=", ")
}
.ru_w4_preview <- function(parsed, expressions) {
  inp<-parsed$inputs;family<-parsed$family_id
  lines<-c("# RU preview: mathematical answer locally validated; R code NOT EXECUTED by RU.",
           "# Only fixed R operations and already validated inline numeric literals.")
  if(family=="descriptive.numeric")
    lines<-c(lines,paste0("values <- c(",.ru_w4_code_number_literal(inp$values),")"))
  if(family=="probability.event_scalar")
    for(n in c("p_a","p_b","p_intersection"))
      if(!is.null(inp[[n]]))lines<-c(lines,paste0(n," <- ",.ru_w4_code_number_literal(inp[[n]])))
  if(family=="distribution.binomial")
    lines<-c(lines,paste0("n <- ",inp$n,"L"),
             paste0("p <- ",.ru_w4_code_number_literal(inp$p)),
             if(!is.null(inp$event))paste0("k <- ",.ru_w4_code_number_literal(inp$event$k)))
  if(family=="distribution.poisson")
    lines<-c(lines,paste0("lambda <- ",.ru_w4_code_number_literal(inp$lambda)),
             if(!is.null(inp$event))paste0("k <- ",.ru_w4_code_number_literal(inp$event$k)))
  if(family=="distribution.normal")
    lines<-c(lines,paste0("mu <- ",.ru_w4_code_number_literal(inp$mu)),
             paste0("sigma <- ",.ru_w4_code_number_literal(inp$sigma)))
  if(family=="distribution.uniform_continuous")
    lines<-c(lines,paste0("a <- ",.ru_w4_code_number_literal(inp$a)),
             paste0("b <- ",.ru_w4_code_number_literal(inp$b)))
  if(family%in%c("distribution.normal","distribution.uniform_continuous")) {
    if(!is.null(inp$event)){
      if(identical(inp$event$type,"interval"))
        lines<-c(lines,paste0("lower <- ",.ru_w4_code_number_literal(inp$event$lower)),
                 paste0("upper <- ",.ru_w4_code_number_literal(inp$event$upper)))
      else if(identical(inp$event$type,"quantile"))
        lines<-c(lines,paste0("quantile_p <- ",.ru_w4_code_number_literal(inp$event$probability)))
      else lines<-c(lines,paste0("k <- ",.ru_w4_code_number_literal(inp$event$k)))
    }
  }
  if(family=="inference.one_sample_t"){
    lines<-c(lines,paste0("values <- c(",.ru_w4_code_number_literal(inp$values),")"))
    if(inp$mode=="test"){
      lines<-c(lines,paste0("mu0 <- ",.ru_w4_code_number_literal(inp$mu0)),
               paste0("alternative <- ",encodeString(inp$alternative,quote='"')))
    } else
      lines<-c(lines,paste0("confidence_level <- ",.ru_w4_code_number_literal(inp$confidence_level)))
  }
  if(family=="regression.simple_ols"){
    lines<-c(lines,paste0("x <- c(",.ru_w4_code_number_literal(inp$x),")"),
             paste0("y <- c(",.ru_w4_code_number_literal(inp$y),")"),
             "fit <- stats::lm(y ~ x)")
    if(!is.null(inp$prediction_x))
      lines<-c(lines,paste0("prediction_x <- ",.ru_w4_code_number_literal(inp$prediction_x)))
  }
  ids<-names(expressions)
  lines<-c(lines,
    paste0("w4_values <- c(",paste(expressions,collapse=", "),")"),
    paste0("w4_result <- data.frame(output_id = c(",
           paste(encodeString(ids,quote='"'),collapse=", "),"),"),
    paste0("  label = c(",paste(encodeString(ids,quote='"'),collapse=", "),"),"),
    "  value = as.double(w4_values), units = rep('', length(w4_values)),",
    "  stringsAsFactors = FALSE)",
    "w4_result")
  paste(lines,collapse="\n")
}
# Defense-in-depth independent of the A1 registry: reject a tampered
# nested event or untyped design even if a future parser changes field layout.
# Only plain, finite primitives and fixed named lists reach arithmetic.
.ru_w4_a3_plain <- function(x, depth=0L) {
  if (is.null(x)) return(TRUE) # Optional missing event; NULL is a pairlist in base R.
  if (depth>4L || length(x)>256L || is.object(x) ||
      is.environment(x) || is.language(x) || is.function(x) ||
      is.expression(x) || is.pairlist(x)) return(FALSE)
  if (is.list(x)) {
    if (!identical(class(x),"list") ||
        (length(x) && (is.null(names(x)) || anyNA(names(x)) ||
         anyDuplicated(names(x)) ||
         !all(grepl("^[a-z][a-z0-9_]{0,63}$",names(x))))))
      return(FALSE)
    return(all(vapply(x,.ru_w4_a3_plain,logical(1L),depth=depth+1L)))
  }
  if (is.numeric(x))
    return(!anyNA(x) && all(is.finite(x)) && all(abs(x)<=1e9))
  if (is.character(x))
    return(!anyNA(x) &&
      all(vapply(x,function(z)validUTF8(z) &&
                   nchar(z,type="bytes")<=256L,logical(1L))))
  if (is.logical(x)) return(!anyNA(x))
  is.null(x)
}
.ru_w4_a3_event_valid <- function(event, family) {
  if (is.null(event)) return(TRUE)
  if (!is.list(event) || !identical(class(event),"list") ||
      is.null(names(event)) || anyDuplicated(names(event)) ||
      !is.character(event$type) || length(event$type)!=1L ||
      is.na(event$type) || !.ru_w4_a3_plain(event)) return(FALSE)
  tp<-event$type
  count<-family%in%c("distribution.binomial","distribution.poisson")
  continuous<-family%in%c("distribution.normal","distribution.uniform_continuous")
  number<-function(x) (is.double(x)||is.integer(x)) &&
    !is.object(x) && length(x)==1L && !is.na(x) &&
    is.finite(x) && abs(x)<=1e9
  if(tp%in%c("exact","cdf","below","above","at_least")) {
    if(!setequal(names(event),c("type","k")) || !number(event$k))
      return(FALSE)
    return(if(count) event$k==trunc(event$k) else
      continuous && tp!="exact")
  }
  if(identical(tp,"interval"))
    return(continuous && setequal(names(event),c("type","lower","upper")) &&
      number(event$lower) && number(event$upper) &&
      event$lower<event$upper)
  if(identical(tp,"quantile"))
    return(identical(family,"distribution.normal") &&
      setequal(names(event),c("type","probability")) &&
      number(event$probability) && event$probability>0 &&
      event$probability<1)
  FALSE
}
.ru_w4_a3_solved_inputs_valid <- function(parsed) {
  if (!is.list(parsed$inputs) || !identical(class(parsed$inputs),"list") ||
      !.ru_w4_a3_plain(parsed$inputs)) return(FALSE)
  x<-parsed$inputs;family<-parsed$family_id
  fields<-switch(family,
    "descriptive.numeric"=c("values","convention","quantile_probability"),
    "probability.event_scalar"=c("p_a","p_b","p_intersection"),
    "distribution.binomial"=c("n","p","event"),
    "distribution.poisson"=c("lambda","event"),
    "distribution.normal"=c("mu","sigma","event"),
    "distribution.uniform_continuous"=c("a","b","event"),
    "inference.one_sample_t"=c("values","mode","mu0","alternative",
                                "confidence_level"),
    "regression.simple_ols"=c("x","y","prediction_x"),
    character())
  if(!length(fields) || !all(names(x)%in%fields) ||
     !length(parsed$requested_outputs) ||
     !all(vapply(parsed$requested_outputs,function(z)
       is.character(z)&&length(z)==1L&&!is.na(z)&&
       grepl("^[a-z][a-z0-9_]{0,63}$",z),logical(1L))))
    return(FALSE)
  if(family%in%c("distribution.binomial","distribution.poisson",
                 "distribution.normal","distribution.uniform_continuous")) {
    if(!.ru_w4_a3_event_valid(x$event,family))return(FALSE)
    if("probability"%in%parsed$requested_outputs && is.null(x$event))
      return(FALSE)
    if("quantile"%in%parsed$requested_outputs &&
       (is.null(x$event) || !identical(x$event$type,"quantile")))
      return(FALSE)
  }
  if(family=="descriptive.numeric") {
    if(!is.numeric(x$values) || length(x$values)<2L ||
       length(x$values)>256L) return(FALSE)
    if(!is.null(x$convention) &&
       !identical(x$convention,"sample") &&
       !identical(x$convention,"population")) return(FALSE)
    if(!is.null(x$quantile_probability) &&
       (!is.numeric(x$quantile_probability) ||
        length(x$quantile_probability)!=1L ||
        x$quantile_probability<0 || x$quantile_probability>1))return(FALSE)
  }
  if(family=="inference.one_sample_t") {
    if(!is.numeric(x$values) || length(x$values)<3L ||
       length(x$values)>256L || stats::sd(x$values)==0 ||
       !is.character(x$mode) || length(x$mode)!=1L ||
       !x$mode%in%c("test","interval") ||
       !is.character(x$alternative) || length(x$alternative)!=1L ||
       !x$alternative%in%c("two.sided","less","greater"))
      return(FALSE)
    if(x$mode=="test" &&
       (!is.numeric(x$mu0)||length(x$mu0)!=1L ||
        !is.null(x$confidence_level)))return(FALSE)
    if(x$mode=="interval" &&
       (!is.numeric(x$confidence_level)||length(x$confidence_level)!=1L ||
        x$confidence_level<=0||x$confidence_level>=1 ||
        !identical(x$alternative,"two.sided") || !is.null(x$mu0)))
      return(FALSE)
  }
  if(family=="regression.simple_ols" &&
     (!is.numeric(x$x)||!is.numeric(x$y)||length(x$x)<3L||
      length(x$x)>256L||length(x$x)!=length(x$y)||
      stats::var(x$x)<=0||stats::var(x$y)<=0))
    return(FALSE)
  TRUE
}
.ru_w4_compute <- function(parsed) {
  statuses<-c("SOLVED","GUIDED_REFERENCE","NEEDS_INPUT","UNSUPPORTED","INVALID")
  if(!is.list(parsed)||!identical(parsed$schema_version,"ru.guided.v1")||
     !is.character(parsed$status)||length(parsed$status)!=1L||
     is.na(parsed$status)||!parsed$status%in%statuses)
    return(.ru_w4_computed(parsed,"INVALID","PARSED_SCHEMA_INVALID"))
  if(!identical(parsed$status,"SOLVED"))
    return(.ru_w4_computed(parsed,parsed$status,parsed$reason_code))
  if(!identical(parsed$reason_code,"W4_INPUTS_VALID")||
     !is.character(parsed$original_question)||length(parsed$original_question)!=1L||
     !is.character(parsed$family_id)||length(parsed$family_id)!=1L)
    return(.ru_w4_computed(parsed,"INVALID","PARSED_SCHEMA_INVALID"))
  # Independent read-back of typed interpretation. Never trust a modified
  # parse result with forged events, operands or outputs.
  if(!.ru_w4_a3_solved_inputs_valid(parsed))
    return(.ru_w4_computed(parsed,"INVALID","PARSED_SCHEMA_INVALID"))
  reread<-tryCatch(.ru_w4_parse(parsed$original_question),error=function(e)NULL)
  if(is.null(reread)||!identical(reread$status,"SOLVED")||
     !identical(parsed$family_id,reread$family_id)||
     !identical(parsed$inputs,reread$inputs)||
     !identical(parsed$requested_outputs,reread$requested_outputs)||
     !identical(parsed$assumptions,reread$assumptions))
    return(.ru_w4_computed(parsed,"INVALID","PARSED_SCHEMA_INVALID"))
  f<-parsed$family_id;inp<-parsed$inputs;outs<-parsed$requested_outputs
  values<-numeric();expr<-character();checks<-list()
  add<-function(id,value,expression) {
    if(!is.numeric(value)||length(value)!=1L||!is.finite(value))
      stop("W4 numerical invariant",call.=FALSE)
    values[[id]]<<-as.double(value);expr[[id]]<<-expression
  }
  try_result<-tryCatch({
    if(f=="descriptive.numeric"){
      x<-inp$values;m<-mean(x);n<-length(x)
      s2<-sum((x-m)^2);sample_var<-s2/(n-1);pop_var<-s2/n
      if("mean"%in%outs)add("mean",m,"mean(values)")
      if("median"%in%outs)add("median",stats::median(x),"stats::median(values)")
      if("sample_variance"%in%outs)add("sample_variance",sample_var,"stats::var(values)")
      if("population_variance"%in%outs)add("population_variance",pop_var,
                                          "mean((values - mean(values))^2)")
      if("sample_sd"%in%outs)add("sample_sd",sqrt(sample_var),"stats::sd(values)")
      if("population_sd"%in%outs)add("population_sd",sqrt(pop_var),
                                    "sqrt(mean((values - mean(values))^2))")
      if("quantile"%in%outs){
        p<-inp$quantile_probability
        xsort<-sort(x);h<-1+(n-1)*p;i<-floor(h)
        q<-if(i>=n)xsort[[n]] else xsort[[i]]+(h-i)*(xsort[[i+1L]]-xsort[[i]])
        add("quantile",q,paste0("as.double(stats::quantile(values, probs = ",
                      .ru_w4_code_number_literal(p),", type = 7, names = FALSE))"))
        checks$quantile_parity<-isTRUE(all.equal(q,
          as.double(stats::quantile(x,p,type=7,names=FALSE)),tolerance=1e-10))
      }
      checks$variance_parity<-isTRUE(all.equal(sample_var,stats::var(x),tolerance=1e-10))
      checks$mean_parity<-isTRUE(all.equal(m,sum(x)/n,tolerance=1e-10))
    } else if(f=="probability.event_scalar") {
      a<-inp$p_a;b<-inp$p_b;j<-inp$p_intersection
      if("union"%in%outs)add("union",a+b-j,"p_a + p_b - p_intersection")
      if("conditional"%in%outs)add("conditional",j/b,"p_intersection / p_b")
      if("complement"%in%outs)add("complement",1-a,"1 - p_a")
      checks$probability_bounds<-all(values>=0&values<=1)
    } else if(f%in%c("distribution.binomial","distribution.poisson")) {
      ev<-inp$event
      if("expected_value"%in%outs)
        add("expected_value",if(f=="distribution.binomial")inp$n*inp$p else inp$lambda,
            if(f=="distribution.binomial")"n * p" else "lambda")
      if("variance"%in%outs)
        add("variance",if(f=="distribution.binomial")inp$n*inp$p*(1-inp$p) else inp$lambda,
            if(f=="distribution.binomial")"n * p * (1 - p)" else "lambda")
      if(!is.null(ev)) {
      k<-ev$k;tp<-ev$type
      if(f=="distribution.binomial"){
        n<-inp$n;p<-inp$p
        z<-switch(tp,exact=stats::dbinom(k,n,p),
          cdf=stats::pbinom(k,n,p),below=stats::pbinom(k-1,n,p),
          at_least=stats::pbinom(k-1,n,p,lower.tail=FALSE),
          above=stats::pbinom(k,n,p,lower.tail=FALSE))
        e<-switch(tp,exact="stats::dbinom(k, n, p)",
          cdf="stats::pbinom(k, n, p)",below="stats::pbinom(k - 1, n, p)",
          at_least="stats::pbinom(k - 1, n, p, lower.tail = FALSE)",
          above="stats::pbinom(k, n, p, lower.tail = FALSE)")
        independent<-if(tp=="exact"&&k>=0&&k<=n&&p>0&&p<1)
          exp(lchoose(n,k)+k*log(p)+(n-k)*log1p(-p)) else z
      } else {
        lam<-inp$lambda
        z<-switch(tp,exact=stats::dpois(k,lam),
          cdf=stats::ppois(k,lam),below=stats::ppois(k-1,lam),
          at_least=stats::ppois(k-1,lam,lower.tail=FALSE),
          above=stats::ppois(k,lam,lower.tail=FALSE))
        e<-switch(tp,exact="stats::dpois(k, lambda)",
          cdf="stats::ppois(k, lambda)",below="stats::ppois(k - 1, lambda)",
          at_least="stats::ppois(k - 1, lambda, lower.tail = FALSE)",
          above="stats::ppois(k, lambda, lower.tail = FALSE)")
        independent<-if(tp=="exact"&&k>=0&&lam>0)
          exp(-lam+k*log(lam)-lgamma(k+1)) else z
      }
      add("probability",z,e)
      checks$probability_bounds<-is.finite(z)&&z>=0&&z<=1
      checks$closed_mass_formula<-isTRUE(all.equal(z,independent,tolerance=1e-10))
      }
    } else if(f%in%c("distribution.normal","distribution.uniform_continuous")){
      ev<-inp$event
      if("expected_value"%in%outs)
        add("expected_value",if(f=="distribution.normal")inp$mu else (inp$a+inp$b)/2,
          if(f=="distribution.normal")"mu" else "(a + b) / 2")
      if("variance"%in%outs)
        add("variance",if(f=="distribution.normal")inp$sigma^2 else (inp$b-inp$a)^2/12,
          if(f=="distribution.normal")"sigma^2" else "(b - a)^2 / 12")
      if(!is.null(ev)) {
      tp<-ev$type
      if(f=="distribution.normal"){
        cdf<-function(q)stats::pnorm(q,inp$mu,inp$sigma)
        fun<-function(x)paste0("stats::pnorm(",x,", mu, sigma)")
      } else {
        cdf<-function(q)stats::punif(q,inp$a,inp$b)
        fun<-function(x)paste0("stats::punif(",x,", a, b)")
      }
      if(tp=="quantile"){
        z<-stats::qnorm(ev$probability,inp$mu,inp$sigma)
        e<-"stats::qnorm(quantile_p, mu, sigma)"
      } else if(tp=="interval"){
        z<-cdf(ev$upper)-cdf(ev$lower)
        e<-paste0(fun("upper")," - ",fun("lower"))
      } else if(tp%in%c("cdf","below")){
        z<-cdf(ev$k);e<-fun("k")
      } else {
        z<-1-cdf(ev$k);e<-paste0("1 - ",fun("k"))
      }
      add(if(tp=="quantile")"quantile" else "probability",z,e)
      checks$probability_bounds<-if(tp=="quantile") TRUE else
        all(z>=-1e-12&z<=1+1e-12)
      checks$cdf_monotonic<-if(tp=="interval") ev$upper>ev$lower else TRUE
      if(f=="distribution.uniform_continuous"&&tp=="interval")
        checks$uniform_geometry<-isTRUE(all.equal(z,
          max(0,min(ev$upper,inp$b)-max(ev$lower,inp$a))/(inp$b-inp$a),
          tolerance=1e-10)) || ev$upper<=inp$a || ev$lower>=inp$b
      }
    } else if(f=="inference.one_sample_t"){
      x<-inp$values;df<-length(x)-1;m<-mean(x)
      tval<-(m-if(inp$mode=="test")inp$mu0 else 0)/(stats::sd(x)/sqrt(length(x)))
      if(inp$mode=="test"){
        pval<-switch(inp$alternative,
          "two.sided"=2*stats::pt(-abs(tval),df),
          greater=stats::pt(tval,df,lower.tail=FALSE),
          less=stats::pt(tval,df))
        add("t_statistic",tval,
          "(mean(values) - mu0) / (stats::sd(values) / sqrt(length(values)))")
        add("degrees_freedom",df,"length(values) - 1")
        add("p_value",pval,
          switch(inp$alternative,
            "two.sided"="2 * stats::pt(-abs(w4_t), df = length(values) - 1)",
            greater="stats::pt(w4_t, length(values) - 1, lower.tail = FALSE)",
            less="stats::pt(w4_t, length(values) - 1)"))
        oracle<-stats::t.test(x,mu=inp$mu0,alternative=inp$alternative)
        checks$t_test_parity<-isTRUE(all.equal(tval,unname(oracle$statistic),tolerance=1e-10))&&
          isTRUE(all.equal(pval,oracle$p.value,tolerance=1e-10))
      } else {
        margin<-stats::qt((1+inp$confidence_level)/2,df)*stats::sd(x)/sqrt(length(x))
        add("ci_lower",m-margin,
            "mean(values) - stats::qt((1 + confidence_level)/2, length(values)-1) * stats::sd(values) / sqrt(length(values))")
        add("ci_upper",m+margin,
            "mean(values) + stats::qt((1 + confidence_level)/2, length(values)-1) * stats::sd(values) / sqrt(length(values))")
        oracle<-stats::t.test(x,conf.level=inp$confidence_level)$conf.int
        checks$t_interval_parity<-isTRUE(all.equal(c(m-margin,m+margin),
          as.double(oracle),tolerance=1e-10))
      }
    } else if(f=="regression.simple_ols"){
      x<-inp$x;y<-inp$y;xc<-x-mean(x);yc<-y-mean(y)
      slope<-sum(xc*yc)/sum(xc^2);intercept<-mean(y)-slope*mean(x)
      yhat<-intercept+slope*x;sse<-sum((y-yhat)^2);sst<-sum((y-mean(y))^2)
      if("intercept"%in%outs)add("intercept",intercept,"unname(stats::coef(fit)[[1L]])")
      if("slope"%in%outs)add("slope",slope,"unname(stats::coef(fit)[[2L]])")
      if("r_squared"%in%outs)add("r_squared",1-sse/sst,"summary(fit)$r.squared")
      if("prediction"%in%outs)add("prediction",intercept+slope*inp$prediction_x,
                                 "unname(stats::predict(fit, newdata = data.frame(x = prediction_x)))")
      oracle<-stats::lm(y~x)
      checks$ols_coef_parity<-isTRUE(all.equal(c(intercept,slope),
                    unname(stats::coef(oracle)),tolerance=1e-10))
      checks$ols_residual_identity<-abs(sum(y-yhat))<1e-9
    } else stop("W4 family not in fixed computation allowlist",call.=FALSE)
    TRUE
  },error=function(e)FALSE)
  if(!identical(try_result,TRUE)||!length(values)||any(!is.finite(values))||
     length(values)!=length(outs)||!setequal(names(values),outs)||
     !all(vapply(checks,isTRUE,logical(1L))))
    return(.ru_w4_computed(parsed,"INVALID","COMPUTATION_VALIDATION_FAILED",checks=checks))
  # Keep every requested output and forbid every unrequested extra.
  ord<-match(outs,names(values)); values<-values[ord];expr<-expr[ord]
  quantity<-data.frame(output_id=outs,label=gsub("_"," ",outs,fixed=TRUE),
                       value=unname(as.double(values)),
                       units=rep("",length(values)),stringsAsFactors=FALSE)
  answer<-list(schema_version="ru.w4.answer.v1",quantities=quantity,
               table=NULL,table_output_id=NA_character_,
               method_note=paste0("Deterministic locally calculated ",f,
                 "; assumptions declared, preview R source not executed."))
  checks$answer_rows_match<-identical(quantity$output_id,outs)
  checks$finite_values<-all(is.finite(quantity$value))
  checks$verified<-all(vapply(checks,isTRUE,logical(1L)))
  if(!checks$verified)
    return(.ru_w4_computed(parsed,"INVALID","COMPUTATION_VALIDATION_FAILED",checks=checks))
  # Fixed code expressions use only numeric literals and never question text.
  code<-.ru_w4_preview(parsed,expr)
  # t p-value code references the computed statistic, so supply a static
  # explanatory intermediate rather than re-evaluating user input.
  if(f=="inference.one_sample_t"&&inp$mode=="test")
    code<-sub("w4_values <- c(",
      "w4_t <- (mean(values) - mu0) / (stats::sd(values) / sqrt(length(values)))\nw4_values <- c(",
      code,fixed=TRUE)
  .ru_w4_computed(parsed,"SOLVED","W4_COMPUTATION_VERIFIED",answer,checks,code)
}