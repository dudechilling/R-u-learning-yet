# A3 W4-R1: independently authored positive/negative, parity and oracle checks.
# Run source: RU_A3_W4_SOURCE_DIR=/path Rscript --vanilla tests/lane3-w4.R
# Run installed: R_LIBS=<fresh-library> Rscript --vanilla tests/lane3-w4.R
src<-Sys.getenv("RU_A3_W4_SOURCE_DIR",unset="")
if(nzchar(src)){
  source(file.path(src,"R","ru-w4-parse.R"),local=FALSE)
  source(file.path(src,"R","ru-w4-compute.R"),local=FALSE)
  parse_w4<-.ru_w4_parse; compute_w4<-.ru_w4_compute
} else {
  suppressPackageStartupMessages(library(rulearn))
  ns<-asNamespace("rulearn")
  parse_w4<-get(".ru_w4_parse",envir=ns)
  compute_w4<-get(".ru_w4_compute",envir=ns)
}
count<-0L
mark<-function(label,statement){
  force(statement);count<<-count+1L
  cat("A3 W4 PASS:",label,"\n")
}
near<-function(actual,expected,tolerance=1e-10){
  stopifnot(isTRUE(all.equal(as.double(actual),as.double(expected),
                              tolerance=tolerance)))
}
w4<-function(q) {
  p<-parse_w4(q);stopifnot(!is.null(p))
  compute_w4(p)
}
getval<-function(answer,id){
  stopifnot(identical(answer$status,"SOLVED"),
            identical(answer$answer$schema_version,"ru.w4.answer.v1"))
  answer$answer$quantities$value[match(id,answer$answer$quantities$output_id)]
}
assert_answer<-function(q,family,expected){
  parsed<-parse_w4(q)
  stopifnot(is.list(parsed),identical(parsed$status,"SOLVED"),
            identical(parsed$family_id,family),
            identical(parsed$schema_version,"ru.guided.v1"),
            identical(parsed$original_question,q),
            identical(parsed$execution_scope,"INLINE_LITERAL_ONLY"))
  raw<-serialize(parsed,NULL,version=3L)
  computed<-compute_w4(parsed)
  stopifnot(identical(serialize(parsed,NULL,version=3L),raw),
            identical(computed$status,"SOLVED"),
            identical(computed$reason_code,"W4_COMPUTATION_VERIFIED"),
            isTRUE(computed$checks$verified),
            identical(computed$original_question,q),
            identical(computed$executed,FALSE),
            identical(computed$answer$schema_version,"ru.w4.answer.v1"),
            is.data.frame(computed$answer$quantities),
            identical(names(computed$answer$quantities),
                      c("output_id","label","value","units")),
            is.double(computed$answer$quantities$value),
            is.character(computed$answer$quantities$units),
            all(is.finite(computed$answer$quantities$value)),
            identical(computed$answer$table,NULL),
            identical(computed$answer$table_output_id,NA_character_),
            setequal(computed$requested_outputs,
                     computed$answer$quantities$output_id),
            !anyDuplicated(computed$answer$quantities$output_id),
            is.character(computed$code_preview),
            length(computed$code_preview)==1L,nzchar(computed$code_preview))
  for(id in names(expected))near(getval(computed,id),expected[[id]])
  # Run ONLY generated, static R source built from validated data.
  # NEVER parse/evaluate the question string.
  e<-new.env(parent=globalenv())
  c<-textConnection(computed$code_preview)
  on.exit(close(c),add=TRUE)
  replay<-source(c,local=e,echo=FALSE)$value
  stopifnot(identical(replay$output_id,computed$answer$quantities$output_id))
  near(replay$value,computed$answer$quantities$value)
  invisible(computed)
}
assert_refusal<-function(q,status,reason=NULL,missing=character()){
  parsed<-parse_w4(q)
  stopifnot(is.list(parsed),identical(parsed$status,status),
            identical(parsed$original_question,q),
            identical(parsed$schema_version,"ru.guided.v1"),
            all(missing%in%parsed$missing_inputs))
  if(!is.null(reason))stopifnot(identical(parsed$reason_code,reason))
  before<-serialize(parsed,NULL,version=3L)
  computed<-compute_w4(parsed)
  stopifnot(identical(serialize(parsed,NULL,version=3L),before),
            identical(computed$status,status),
            is.list(computed$answer),length(computed$answer)==0L,
            identical(computed$code_preview,""),
            identical(computed$executed,FALSE))
  invisible(parsed)
}

mark("sample and population convention, sample n-1 oracle",{
  assert_answer("Calculate the sample standard deviation of 2, 4, 6, 8 (denominator n-1).",
                "descriptive.numeric",list(sample_sd=sqrt(20/3)))
  assert_answer("Find sample variance and mean of observations 2,4,6,8.",
                "descriptive.numeric",list(sample_variance=20/3,mean=5))
  assert_answer("Find population variance and mean of values 1,2,3.",
                "descriptive.numeric",list(population_variance=2/3,mean=2))
  assert_answer("Find median of numbers 1,2,2,9,100.",
                "descriptive.numeric",list(median=2))
  assert_answer("Find 25th percentile of observations 1,2,3,4,5 using R type-7 quantiles.",
                "descriptive.numeric",list(quantile=2))
})
mark("independent descriptive reparameterization oracles",{
  x<-c(-5,0,1,8,9)
  # Sum and sum-of-squares oracles, not stats::mean/var/sd.
  mu<-sum(x)/length(x);ss<-sum(x*x)-sum(x)^2/length(x)
  res<-assert_answer("Find sample standard deviation of values -5,0,1,8,9.",
                     "descriptive.numeric",list(sample_sd=sqrt(ss/4)))
  stopifnot(identical(length(res$inputs$values),5L))
  assert_answer("Find population variance of values -5,0,1,8,9.",
                "descriptive.numeric",list(population_variance=ss/5))
  near(mu,13/5)
})
mark("set union, conditioning and complements with probability axioms",{
  assert_answer("If P(A)=0.4, P(B)=0.3, and P(A intersection B)=0.1, find P(A union B).",
                "probability.event_scalar",list(union=0.6))
  assert_answer("Given P(A intersection B)=0.2 and P(B)=0.5, compute P(A given B).",
                "probability.event_scalar",list(conditional=0.4))
  assert_answer("Given P(A)=0.45 find the complement probability of A.",
                "probability.event_scalar",list(complement=0.55))
})
mark("binomial analytical combination and all integer event boundaries",{
  p<-0.2;n<-10;k<-2
  independent<-choose(n,k)*p^k*(1-p)^(n-k)
  assert_answer("For Binomial(n=10,p=0.2), find P(X=2).",
                "distribution.binomial",list(probability=independent))
  assert_answer("For Binomial(n=5,p=0.5), find P(X at least 3).",
                "distribution.binomial",list(probability=0.5))
  assert_answer("For Binomial(n=4,p=0.25), find P(X<=1).",
                "distribution.binomial",list(probability=(3/4)^4+4*(1/4)*(3/4)^3))
  assert_answer("For Binomial(n=10,p=0.2), find P(X=2) and expected value.",
                "distribution.binomial",list(probability=independent,expected_value=2))
  assert_answer("For Binomial(n=20,p=0.3), find expected value and variance.",
                "distribution.binomial",list(expected_value=6,variance=4.2))
})
mark("Poisson factorial/exponential oracle and moments",{
  oracle<-exp(-3)*3^2/factorial(2)
  assert_answer("For Poisson arrivals with rate lambda=3 per interval, find P(X=2).",
                "distribution.poisson",list(probability=oracle))
  assert_answer("For Poisson(lambda=2), find P(X=0).",
                "distribution.poisson",list(probability=exp(-2)))
  assert_answer("For Poisson(lambda=3), find expected value and variance.",
                "distribution.poisson",list(expected_value=3,variance=3))
})
mark("normal integrated density oracle, normal quantile and moments",{
  phi<-stats::integrate(function(z) exp(-z*z/2)/sqrt(2*pi),-Inf,1.96)$value
  assert_answer("Under the standard normal model find P(Z<=1.96).",
                "distribution.normal",list(probability=phi))
  assert_answer("For Normal(mu=100,sigma=15), find P(X<=115).",
                "distribution.normal",list(probability=stats::pnorm(1)))
  assert_answer("For Normal(mu=100,sigma=15), find 97.5th percentile.",
                "distribution.normal",list(quantile=129.399459768101))
  assert_answer("For Normal(mu=100,sigma=15), find expected value and variance.",
                "distribution.normal",list(expected_value=100,variance=225))
})
mark("uniform geometric oracle and legitimate unescaped inequality",{
  assert_answer("For a continuous uniform U(2,8), compute P(3<X<5).",
                "distribution.uniform_continuous",list(probability=2/6))
  assert_answer("For continuous uniform U(2,8), find P(X<=6).",
                "distribution.uniform_continuous",list(probability=4/6))
  assert_answer("For continuous uniform U(2,8), find variance.",
                "distribution.uniform_continuous",list(variance=3))
})
mark("one-sample t manual statistic and two-sided test oracle",{
  x<-c(7,9,10,12,12);m<-sum(x)/length(x)
  v<-sum((x-m)^2)/(length(x)-1)
  t<-(m-8)/sqrt(v/length(x))
  assert_answer(paste("For independent approximately normal sample",
       "x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test."),
       "inference.one_sample_t",
       list(t_statistic=t,degrees_freedom=4,p_value=0.102700427495512))
})
mark("Student t CI tabulated critical-value oracle",{
  critical<-2.7764451051977996
  x<-1:5;s<-sqrt(2.5)
  margin<-critical*s/sqrt(5)
  assert_answer(paste("For independent approximately normal observations",
    "1,2,3,4,5 construct a two-sided 95% Student t confidence interval."),
    "inference.one_sample_t",
    list(ci_lower=3-margin,ci_upper=3+margin))
})
mark("simple OLS closed-form slope intercept and R2 oracle",{
  x<-1:4;y<-c(2,3,5,7)
  slope<-sum((x-mean(x))*(y-mean(y)))/sum((x-mean(x))^2)
  intercept<-sum(y)/length(y)-slope*sum(x)/length(x)
  residual<-y-intercept-slope*x
  r2<-1-sum(residual^2)/sum((y-mean(y))^2)
  assert_answer("Fit simple OLS regression with x=[1,2,3,4] and y=[2,3,5,7], give intercept slope and r-squared.",
                "regression.simple_ols",
                list(intercept=0,slope=1.7,r_squared=0.979661016949153))
  assert_answer("Fit simple OLS regression with x=[-1,0,2,4] and y=[-1,1,5,9], find intercept slope.",
                "regression.simple_ols",list(intercept=1,slope=2))
  assert_answer("Predict y at x=2 using a simple fitted OLS model from (0,1),(1,3),(2,5),(3,7).",
                "regression.simple_ols",list(prediction=5))
})
mark("A5 benchmark critical regression P(3<X<5) is not HTML",{
  q<-"For a continuous uniform U(2,8), compute P(3<X<5)."
  p<-parse_w4(q);stopifnot(identical(p$status,"SOLVED"),
                         identical(p$inputs$event$type,"interval"))
  near(getval(compute_w4(p),"probability"),1/3)
})
mark("A5 numeric group arrays do not imply dice",{
  q<-"For groups A=[1,2] and B=[3,4], calculate exact two-sided permutation probability of absolute mean difference >=2 over six label allocations."
  x<-assert_refusal(q,"UNSUPPORTED","STATISTICAL_METHOD_NOT_IMPLEMENTED")
  stopifnot(!identical(x$family_id,"dice_sum_independent_fair"),
            !("die1_faces"%in%x$missing_inputs))
})
mark("non-dice methods never demand dice faces",{
  questions<-c("Calculate a Poisson expectation without lambda.",
    "Compute normal variance with unspecified parameters.",
    "Moran I for these census tracts.",
    "Bootstrap the mean of these numbers [0,2].",
    "Calculate a geographic spatial interpolation.",
    "Run chi-square on my table.")
  for(q in questions){
    x<-parse_w4(q)
    stopifnot(!is.null(x),x$status!="SOLVED",
              !identical(x$reason_code,"DISTRIBUTION_MODEL_REQUIRED"),
              !("die1_faces"%in%x$missing_inputs))
  }
})
mark("missing inputs and incompatible model/design guards",{
  assert_refusal("Find variance of 1,2,3.", "NEEDS_INPUT","VARIANCE_CONVENTION_REQUIRED")
  assert_refusal("Compute sample variance of my dataset column x.",
                 "NEEDS_INPUT","INLINE_DATA_REQUIRED")
  assert_refusal("Binomial distribution n=10 p=0.3: compute P(X=).",
                 "NEEDS_INPUT","EVENT_THRESHOLD_REQUIRED")
  assert_refusal("Poisson P(X<=5) with no given rate.",
                 "NEEDS_INPUT","POISSON_RATE_REQUIRED","lambda")
  assert_refusal("Calculate normal P(X<=3) without specifying mu or sigma.",
                 "NEEDS_INPUT","NORMAL_PARAMETERS_REQUIRED",c("mu","sigma"))
  assert_refusal("Compute one-sample t test for x=[1,2,3,4] mu0=2 two-sided.",
                 "NEEDS_INPUT","T_DESIGN_ASSUMPTIONS_REQUIRED",
                 c("independent_sampling","normality_assumption"))
  assert_refusal("Fit simple OLS regression for x=[1,2,3] without y.",
                 "NEEDS_INPUT","PAIRED_NUMERIC_DATA_REQUIRED",c("y"))
  assert_refusal("For Binomial(n=5,p=.3) without replacement, P(X=2)?",
                 "UNSUPPORTED")
  assert_refusal("Fit multiple regression with x=[1,2,3] and y=[4,5,6].",
                 "UNSUPPORTED")
  assert_refusal("Fit simple OLS regression x=[1,1,1] and y=[2,3,4].",
                 "INVALID","OLS_DESIGN_INVALID")
  assert_refusal("Find P(X=4) from a continuous normal distribution mu=0 sigma=1.",
                 "UNSUPPORTED","CONTINUOUS_POINT_EVENT_UNSUPPORTED")
  assert_refusal("Find a normal variance using a known-sigma t test.",
                 "INVALID")
})
mark("adversarial code/HTML and malformed input cause no side effects",{
  filename<-tempfile("ru-w4-injection-")
  bad<-sprintf("For Normal(mu=0,sigma=1), find P(X<3); system('touch %s')",filename)
  assert_refusal(bad,"INVALID","UNSAFE_QUESTION_CONTENT")
  assert_refusal("For a continuous uniform U(2,8), P(3<X<5)<script>alert(1)</script>",
                 "INVALID","UNSAFE_QUESTION_CONTENT")
  stopifnot(!file.exists(filename))
  for(bad in list(NULL,NA_character_,character(),5,list("mean"),"",
                  paste(rep("A",4200),collapse=""))) {
    a<-parse_w4(bad)
    stopifnot(!is.null(a),identical(a$status,"INVALID"),
              identical(compute_w4(a)$status,"INVALID"))
  }
})
mark("tampered parsed operands cannot forge a computation",{
  q<-"For Binomial(n=10,p=0.2), find P(X=2)."
  p<-parse_w4(q)
  p$inputs$p<-0.9
  x<-compute_w4(p)
  stopifnot(identical(x$status,"INVALID"),
            identical(x$reason_code,"PARSED_SCHEMA_INVALID"),
            is.list(x$answer),length(x$answer)==0L,
            identical(x$executed,FALSE))
})
mark("hard numeric input caps and invalid probability parameters",{
  huge<-paste0("Calculate mean of ",paste(seq_len(300L),collapse=","),".")
  assert_refusal(huge,"UNSUPPORTED","INPUT_CAP_EXCEEDED")
  assert_refusal("For Binomial(n=-4,p=0.2), find P(X=2).",
                 "INVALID","BINOMIAL_TRIALS_INVALID")
  assert_refusal("For Binomial(n=10,p=1.2), find P(X=2).",
                 "INVALID","PROBABILITY_OUT_OF_RANGE")
  assert_refusal("For Poisson(lambda=-3), find P(X=2).",
                 "INVALID","POISSON_RATE_INVALID")
  assert_refusal("For Normal(mu=0,sigma=0), find P(X<2).",
                 "INVALID","NORMAL_SD_INVALID")
  assert_refusal("Given P(A)=1.3 find the complement probability of A.",
                 "INVALID","PROBABILITY_OUT_OF_RANGE")
})
mark("A5 H028 Poisson counts are not continuous waiting times",{
  waiting<-c(
    "Poisson lambda=3 calculate continuous waiting time P(X>2).",
    "For a Poisson process lambda=3, find P(X>2) for the interarrival time.",
    "Poisson lambda=3 find the exponential waiting-time probability P(X>2).",
    "With Poisson lambda=2, find the time until the next arrival P(X>3).",
    "Poisson lambda=3 calculate waiting time.")
  for(q in waiting) {
    p<-assert_refusal(q,"UNSUPPORTED",
                      "POISSON_WAITING_TIME_MODEL_INCOMPATIBLE")
    stopifnot(identical(p$family_id,"distribution.poisson"),
              identical(p$original_question,q),
              identical(p$method_id,"poisson_exact"),
              identical(p$model_id,"poisson_count_fixed_exposure"))
  }
  # Identical event syntax with an explicitly COUNT-valued random variable
  # remains legitimately solvable and must preserve its R-code parity.
  prob<-1-exp(-3)*(1+3+9/2)
  assert_answer("For Poisson arrivals with lambda=3 per interval, compute P(X>2).",
                "distribution.poisson",list(probability=prob))
})
mark("A5 H062/H063 and malformed vectors cannot silently truncate",{
  exact<-c(
    "Compute mean of values = 1,2,NA.",
    "Compute mean of values = 1,2,Inf.")
  malformed<-c(exact,
    "Find median of values=1,2,NaN.",
    "Calculate mean of values = NA,1,2.",
    "Calculate mean of values = 1,2,NA,4.",
    "Compute mean of values = [1,2,Inf].",
    "Compute mean of values = c(1,2,NA).",
    "Compute mean of values = 1,2,.",
    "Compute mean of values = [1,2,3.",
    "Compute mean of values = [1,2,3,",
    "Compute mean of values = 1,2,3,",
    "Compute mean of values = 1,2,3,4,",
    "Compute mean of values = 1,2,3abc.",
    "Compute mean of values = 1,2,3 4.",
    "Compute mean of values = 1,2,3+4.",
    "Compute mean of values = 1,2,3;4.",
    "Compute mean of values = 1,2,3,4,not_a_number.",
    "Calculate mean of values=[1,2,3] and 4.",
    "Compute mean of values = [1,2,3] ]",
    "Compute mean of NA and 1,2,3.",
    "Compute mean of Inf and 1,2,3.",
    "Find mean of 1,2,3 or 4,5,6.",
    "Compute mean of values=1,2,3 or 4,5,6.",
    "Compute mean of values=[1,2,3] or [4,5,6].")
  for(q in malformed) {
    p<-assert_refusal(q,"INVALID","NUMERIC_DATA_INVALID")
    stopifnot(identical(p$family_id,"descriptive.numeric"),
              !("values"%in%names(p$inputs)))
  }
  for(token in c("NA","Inf","NaN","undefined","NULL","FALSE",
                 "missing","1e309","3foo","-Inf","NA_real_")) {
    q<-paste0("Compute mean of values = 1,2,",token,".")
    p<-parse_w4(q)
    stopifnot(!is.null(p),p$status!="SOLVED",
              identical(p$original_question,q),
              compute_w4(p)$status!="SOLVED")
  }
})
mark("invalid inline numeric tokens reject t and paired OLS too",{
  assert_refusal(
    paste("For independent approximately normal sample x=[1,2,NA],",
          "test mu0=2 with a two-sided one-sample t test."),
    "INVALID","SAMPLE_VALUES_INVALID")
  assert_refusal(
    "Fit simple OLS regression with x=[1,2,3] and y=[2,3,Inf], give slope.",
    "INVALID","OLS_DESIGN_INVALID")
  assert_refusal(
    "Fit simple OLS regression with x=[1,2,NA] and y=[2,3,4], give slope.",
    "INVALID","OLS_DESIGN_INVALID")
  huge<-paste0("Compute mean of values = ",paste(seq_len(257L),collapse=","))
  assert_refusal(huge,"UNSUPPORTED","INPUT_CAP_EXCEEDED")
})
mark("complete numeric literals preserve supported math and code parity",{
  assert_answer("Calculate mean of values = 1,2,3.",
                "descriptive.numeric",list(mean=2))
  assert_answer("Calculate mean of values = [1,2,3].",
                "descriptive.numeric",list(mean=2))
  assert_answer("Calculate mean of values=c(1,2,3).",
                "descriptive.numeric",list(mean=2))
  assert_answer("Calculate mean of values=1e-3,2e-3,3e-3.",
                "descriptive.numeric",list(mean=2e-3))
  assert_answer(paste0("Calculate mean of values = ",
                       paste(seq_len(256L),collapse=","),"."),
                "descriptive.numeric",list(mean=128.5))
})
mark("A5 H034 honest normal SD refusal retains exact reason",{
  q<-"Normal mu=0 sigma=0 calculate P(X<=1)."
  p<-assert_refusal(q,"INVALID","NORMAL_SD_INVALID")
  stopifnot(identical(p$family_id,"distribution.normal"),
            identical(p$method_id,"normal_between"),
            identical(p$model_id,"normal_continuous_measurement"),
            isTRUE(all.equal(p$inputs$sigma,0)),
            isTRUE(all.equal(p$inputs$mu,0)),
            identical(p$inputs$event$type,"cdf"),
            identical(p$requested_outputs,"probability"))
})
mark("bounded repeated deterministic parsing",{
  q<-"For a continuous uniform U(2,8), compute P(3<X<5)."
  first<-serialize(parse_w4(q),NULL,version=3L)
  for(i in seq_len(40L))
    stopifnot(identical(serialize(parse_w4(q),NULL,version=3L),first))
  stopwatch<-system.time(for(i in seq_len(100L))parse_w4(q))[["elapsed"]]
  stopifnot(is.finite(stopwatch),stopwatch<20)
})
# Integration contract probe is opt-in because A1 owns a separate worktree
# and the committed A1-only installation deliberately lacks these A3 helpers.
# Never modify A1 files or silently accept its pre-correction registry.
a1_source_dir<-Sys.getenv("RU_A3_W4_A1_DIR",unset="")
if(nzchar(a1_source_dir)){
  mark("SUP51 exact A1 validator cross-family and malicious-input contract",{
    stopifnot(file.exists(file.path(a1_source_dir,"R","ru-w4-registry.R")),
              file.exists(file.path(a1_source_dir,"R","ru-w4-dispatch.R")))
    env<-new.env(parent=globalenv())
    source(file.path(a1_source_dir,"R","ru-w4-registry.R"),local=env)
    source(file.path(a1_source_dir,"R","ru-w4-dispatch.R"),local=env)
    if(nzchar(src)){
      source(file.path(src,"R","ru-w4-parse.R"),local=env)
      source(file.path(src,"R","ru-w4-compute.R"),local=env)
    } else {
      env$.ru_w4_parse<-parse_w4
      env$.ru_w4_compute<-compute_w4
    }
    stopifnot(isTRUE(env$.ru_w4_literal(list(typed=c(1,2,3),
                                           event=list(type="cdf",k=2)))),
              is.function(env$.ru_w4_code_number_literal) ||
                is.function(get(".ru_w4_code_number_literal",
                                envir=asNamespace("rulearn"))),
              isTRUE(env$.ru_w4_validate_registry()))
    cases<-c(
      "Mean of four observed values 2, 4, 6, 8.",
      "Calculate the sample standard deviation of 2, 4, 6, 8 (denominator n-1).",
      "Given P(A intersection B)=0.2 and P(B)=0.5, compute P(A given B).",
      "For Binomial(n=10,p=0.2), find P(X=2).",
      "For Binomial(n=20,p=0.3), find expected value and variance.",
      "For Poisson arrivals with rate lambda=3 per interval, find P(X=2).",
      "For Poisson(lambda=3), find expected value and variance.",
      "Under the standard normal model find P(Z<=1.96).",
      "For Normal(mu=100,sigma=15), find expected value and variance.",
      "For a continuous uniform U(2,8), compute P(3<X<5).",
      "For continuous uniform U(2,8), find variance.",
      paste("For independent approximately normal sample",
            "x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test."),
      paste("For independent approximately normal observations",
            "1,2,3,4,5 construct a two-sided 95% Student t confidence interval."),
      "Fit simple OLS regression with x=[1,2,3,4] and y=[2,3,5,7], give intercept slope and r-squared.",
      "Predict y at x=2 using a simple fitted OLS model from (0,1),(1,3),(2,5),(3,7).")
    for(q in cases){
      p<-env$.ru_w4_parse(q)
      if(!identical(p$status,"SOLVED") ||
         !isTRUE(env$.ru_w4_validate_parsed(p,q)))
        stop("A1 PARSED contract: ",q,call.=FALSE)
      family<-env$.ru_w4_family(p$family_id)
      stopifnot(identical(p$method_id,family$method_id),
                identical(p$model_id,family$model_id),
                identical(p$execution_scope,"INLINE_LITERAL_ONLY"))
      a<-env$.ru_w4_compute(p)
      if(!identical(a$status,"SOLVED") ||
         !isTRUE(env$.ru_w4_validate_computed(a,p)) ||
         !isTRUE(a$checks$verified) ||
         !identical(a$answer$quantities$output_id,p$requested_outputs))
        stop("A1 COMPUTED contract: ",q,call.=FALSE)
      # All W4 families are candidates only; these tests do not promote them.
      stopifnot(!isTRUE(family$enabled))
    }
    refusals<-c(
      "Compute normal variance with unspecified parameters.",
      "For Binomial(n=5,p=0.5) without replacement, find P(X=2).",
      "For groups A=[1,2] and B=[3,4], calculate exact two-sided permutation probability.",
      "For a continuous uniform U(2,8), P(3<X<5)<script>alert(1)</script>",
      "For Binomial(n=-4,p=0.2), find P(X=2).",
      "For a sample of independent approximately normal values x=[1,2,3], test a known-sigma z-test.")
    for(q in refusals){
      p<-env$.ru_w4_parse(q)
      stopifnot(!is.null(p),!identical(p$status,"SOLVED"),
                isTRUE(env$.ru_w4_validate_parsed(p,q)))
      computed<-env$.ru_w4_compute(p)
      stopifnot(!identical(computed$status,"SOLVED"),
                isTRUE(env$.ru_w4_validate_computed(computed,p)),
                identical(computed$code_preview,""),
                identical(computed$executed,FALSE))
    }
    # SUP56: the A1 R4 trust boundary must preserve precise refusal
    # reasons, especially the invalid-but-finite sigma=0 case (H034).
    if(identical(Sys.getenv("RU_A3_W4_A1_R4",unset=""),"1")){
      for(q in c("Poisson lambda=3 calculate continuous waiting time P(X>2).",
                 "Compute mean of values = 1,2,NA.",
                 "Compute mean of values = 1,2,Inf.",
                 "Normal mu=0 sigma=0 calculate P(X<=1).")){
        p<-env$.ru_w4_parse(q)
        r<-env$.ru_w4_compute(p)
        stopifnot(p$status!="SOLVED",
                  identical(p$status,r$status),
                  identical(p$reason_code,r$reason_code),
                  isTRUE(env$.ru_w4_validate_parsed(p,q)),
                  isTRUE(env$.ru_w4_validate_computed(r,p)),
                  is.list(r$answer),length(r$answer)==0L,
                  identical(r$code_preview,""),
                  identical(r$executed,FALSE))
      }
    }
    p<-env$.ru_w4_parse("For Binomial(n=10,p=0.2), find P(X=2).")
    corrupt<-p
    corrupt$method_id<-"wrong_method"
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)))
    corrupt<-p
    corrupt$model_id<-"wrong_model"
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)))
    corrupt<-p
    corrupt$inputs$event$type<-"execute_arbitrary_command"
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)),
              identical(env$.ru_w4_compute(corrupt)$status,"INVALID"))
    corrupt<-p
    corrupt$inputs$event$k<-Inf
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)),
              identical(env$.ru_w4_compute(corrupt)$status,"INVALID"))
    corrupt<-p
    corrupt$inputs$event$type<-NULL
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)))
    corrupt<-p
    corrupt$inputs$unknown_operation<-1
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)))
    corrupt<-p
    corrupt$inputs$event$hacker<-1
    stopifnot(!isTRUE(env$.ru_w4_validate_parsed(corrupt,p$original_question)))
    valid<-env$.ru_w4_compute(p)
    incomplete<-valid
    incomplete$answer$quantities<-incomplete$answer$quantities[0,,drop=FALSE]
    stopifnot(!isTRUE(env$.ru_w4_validate_computed(incomplete,p)))
    # D1 negative control: no accidental capture of A1's boolean validator.
    declined<-env$.ru_w4_refusal(p)
    stopifnot(isTRUE(env$.ru_w4_literal(list(foo=1.5))),
              identical(declined$status,"UNSUPPORTED"),
              identical(declined$reason_code,"FAMILY_NOT_QUALIFIED"),
              identical(declined$executed,FALSE),
              identical(declined$code_preview,""),
              is.list(declined$answer),length(declined$answer)==0L)
    # A1 currently omits parsed optional metadata from its refusal; that
    # validator-contract defect is peer-owned and logged in A1 Core.

  })
}

cat("A3 W4 source/installed exact suite PASS:",count,"groups.\n")