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
mark("SUP61 unique probability-event inventory, not first-event success",{
  cases<-c(
    "For Poisson lambda=3, find P(X>4), then calculate P(X=2).",
    "Binomial(n=8,p=0.25); report P(X=3); also give P(X=2).",
    "Normal(mu=0,sigma=1) calculate P(X>2) then show P(X<=1).",
    "Continuous uniform U(2,8), find P(X>6); compute P(3<X<5).",
    "For Poisson lambda=3 calculate P(X=2) and P(X>4).",
    "For a Binomial n=8 p=0.25 calculate P(X=2) plus P(X=3).",
    "For Normal mu=0 sigma=1, compute P(X<=1), P(X>2), and variance.",
    "For continuous uniform U(2,8) find P(3<X<5) and P(X>6).")
  for(q in cases) {
    p<-assert_refusal(q,"UNSUPPORTED",
                      "MULTIPLE_PROBABILITY_EVENTS_UNSUPPORTED")
    stopifnot(p$family_id%in%c("distribution.poisson","distribution.binomial",
      "distribution.normal","distribution.uniform_continuous"))
  }
  # Repetition of the same event represents one distinct mathematical target.
  assert_answer("For Binomial(n=10,p=0.2), find P(X=2) and P(X=2).",
                "distribution.binomial",
                list(probability=choose(10,2)*(.2)^2*(.8)^8))
  assert_refusal(
    "For Normal(mu=0,sigma=1), find P(X<=1) and the 90th percentile.",
    "UNSUPPORTED","MULTIPLE_DISTRIBUTION_OPERATIONS_UNSUPPORTED")
})
mark("SUP61 separate inferential actions cannot disappear",{
  cases<-c(
    paste("For independent approximately normal sample",
          "x=[2,4,6,8,10] test mu0=5 two-sided AND construct a",
          "two-sided 95% Student t confidence interval."),
    paste("For independent approximately normal observations",
          "2,4,6,8,10 construct a two-sided 95% Student t",
          "confidence interval and test mu0=5 two-sided."),
    paste("For an independent approximately normal one-sample t-test",
          "of values=2,4,6,8,10 against mu0=5, two-sided calculate",
          "p-value and 95% confidence interval."),
    paste("For independent approximately normal one-sample t test",
          "of x=[2,4,6,8,10] test mu0=5 two-sided;",
          "also report a 95% confidence interval."))
  for(q in cases)
    assert_refusal(q,"UNSUPPORTED",
                   "MULTIPLE_INFERENCE_OPERATIONS_UNSUPPORTED")
  assert_answer(
    paste("For independent approximately normal sample x=[7,9,10,12,12]",
          "test mu0=8 with a two-sided one-sample t test."),
    "inference.one_sample_t",
    list(t_statistic=2.1081851067789197))
})
mark("SUP61 additional artifacts, data sources and unknown action clauses",{
  q<-c(
    "Compute mean of values=1,2,3 and generate a histogram.",
    "Generate a histogram and compute mean of values=1,2,3.",
    "For mean of values 1,2,3 calculate a histogram too.",
    "Normal mu=0 sigma=1 calculate P(X<=1) and output an unprovided workspace object x.",
    "For Normal(mu=0,sigma=1), show the current workspace variable and find P(X<=1).",
    "Binomial n=6 p=0.3 calculate P(X=1) and also compute an unrelated variance test.",
    "For Binomial n=6 p=0.3, run a test of variance; calculate P(X=1).",
    "For Poisson lambda=3 find P(X=2) and explain assumptions.",
    "For Normal(mu=0,sigma=1) calculate P(X<=1); determine an unknown metric.",
    "Find median of values 1,2,3 and summarize a source dataset.",
    "For simple OLS regression x=[1,2,3] y=[2,4,6] find a scatterplot.",
    "Compute mean of values 1,2,3; produce a graphic.",
    "Normal(mu=0,sigma=1) calculate P(X<=1) and create a CSV file.")
  for(x in q){
    p<-parse_w4(x)
    stopifnot(!is.null(p),p$status!="SOLVED",
              identical(p$original_question,x))
    res<-compute_w4(p)
    stopifnot(res$status!="SOLVED",identical(res$code_preview,""),
              identical(res$executed,FALSE),length(res$answer)==0L)
  }
})
mark("SUP61 true within-family compounds and benign and-clauses still solve",{
  assert_answer("Compute median and mean of values 1,2,3,4.",
                "descriptive.numeric",list(median=2.5,mean=2.5))
  assert_answer("Calculate mean of values 1,2,3,4 and sample variance.",
                "descriptive.numeric",list(mean=2.5,sample_variance=5/3))
  assert_answer("For Binomial(n=10,p=0.2), find P(X=2) and expected value.",
                "distribution.binomial",
                list(probability=choose(10,2)*.2^2*.8^8,
                     expected_value=2))
  assert_answer("For Poisson lambda=3, compute variance and expectation.",
                "distribution.poisson",list(variance=3,expected_value=3))
  assert_answer("Normal(mu=0,sigma=1) find P(X<=1) and report expected value and variance.",
                "distribution.normal",
                list(probability=stats::pnorm(1),expected_value=0,variance=1))
  assert_answer("Fit simple OLS regression x=[1,2,3,4] and y=[2,3,5,7], report slope intercept and r-squared.",
                "regression.simple_ols",
                list(intercept=0,slope=1.7,r_squared=0.979661016949153))
  # "and" joins model assumptions and explanatory data, not an action.
  assert_answer("For independent approximately normal sample x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test.",
                "inference.one_sample_t",
                list(degrees_freedom=4))
})

mark("SUP67 atomic requested outputs and unknown coordinated products",{
  questions<-c(
    "Calculate the mean of values=3,7,9,11 and an ecological footprint index.",
    "Compute mean of values=2,4,6,8; derive a novel dispersion score.",
    "For values=2,4,6,8, calculate the mean, report an unexplained index.",
    "Find the union if P(A)=0.45 P(B)=0.25 P(A intersection B)=0.1 and an unknown dependency metric.",
    "Binomial n=8 p=0.4 find P(X=2) plus the chance of four or more successes.",
    "Poisson lambda=3 calculate P(X=1) and the probability of no arrivals.",
    "For Normal(mu=0,sigma=1) calculate P(X<=1) and an unknown index.",
    "Continuous uniform U(2,9) calculate P(3<X<6) together with the chance of X greater than 7.",
    paste("For independent approximately normal one-sample t-test of",
          "values=2,4,6,8,10 versus mu0=5 two-sided, report p-value",
          "along with an unspecified diagnostic."),
    paste("Fit simple OLS regression x=[1,2,3,4] and y=[2,5,7,9],",
          "report the slope; derive a novel influence measure."),
    "For binomial n=10 p=0.2, calculate P(X=3) and the entropy of outcomes.",
    "Normal(mu=2,sigma=3) calculate P(X>4) and its standardized effect.")
  for(q in questions) {
    p<-parse_w4(q)
    stopifnot(!is.null(p),p$status!="SOLVED",
              identical(p$original_question,q))
    a<-compute_w4(p)
    stopifnot(identical(a$status,p$status),
              identical(a$executed,FALSE),
              identical(a$code_preview,""),
              is.list(a$answer),length(a$answer)==0L)
  }
  # Every atomic request has a bounded source span and a known output ID
  # or an explicit unsupported identifier. The parsed object is unchanged.
  atom_fn<-if(nzchar(src)) .ru_w4_result_atoms else
    getFromNamespace(".ru_w4_result_atoms","rulearn")
  q<-"For Binomial(n=9,p=0.4), calculate expected value and variance."
  norm_fn<-if(nzchar(src)) .ru_w4_norm else
    getFromNamespace(".ru_w4_norm","rulearn")
  entries<-atom_fn(norm_fn(q),"distribution.binomial")$atoms
  stopifnot(length(entries)==2L,
            setequal(vapply(entries,function(e)e$output,character(1)),
                     c("expected_value","variance")),
            all(vapply(entries,function(e)e$start>=1L &&
              e$end>=e$start && e$end<=nchar(q),logical(1L))))
})
mark("SUP67 full-list comma-to-verb grammar without prefix truncation",{
  assert_answer("For values=5,10,15,20, compute the mean and median.",
                "descriptive.numeric",list(mean=12.5,median=12.5))
  assert_answer("For values=7,9,11,13, calculate the median and mean.",
                "descriptive.numeric",list(mean=10,median=10))
  assert_answer("For numbers=4,8,12,16, report the mean.",
                "descriptive.numeric",list(mean=10))
  for(q in c(
    "For values=5,10,15,NA, compute mean and median.",
    "For values=5,10,15,Inf, compute mean.",
    "For values=5,10,15,, compute mean.",
    "For values=5,10,15, compute mean,2.",
    "For values=5,10,15,foo, compute mean.",
    "For values=5,10,15, compute mean; system('whoami').")) {
    p<-parse_w4(q)
    stopifnot(!is.null(p),p$status!="SOLVED")
    a<-compute_w4(p)
    stopifnot(a$status!="SOLVED",identical(a$executed,FALSE),
              identical(a$code_preview,""),length(a$answer)==0L)
  }
})
mark("SUP67 legitimate multi-output and input conjunctions remain correct",{
  assert_answer("For Binomial(n=6,p=0.3) find expected value and variance.",
                "distribution.binomial",
                list(expected_value=1.8,variance=1.26))
  assert_answer("For Poisson lambda=3 calculate expectation and variance.",
                "distribution.poisson",list(expected_value=3,variance=3))
  assert_answer("Normal mu=0 sigma=1 calculate P(X<=1) and expected value.",
                "distribution.normal",
                list(probability=stats::pnorm(1),expected_value=0))
  assert_answer("Given P(A)=0.5 and P(B)=0.4 and P(A intersection B)=0.1, find the union.",
                "probability.event_scalar",list(union=0.8))
  assert_answer("Fit simple OLS regression x=[1,2,3,4] and y=[2,4,6,9], report slope and r-squared.",
                "regression.simple_ols",list(slope=2.3,r_squared=1-.3/26.75))
  assert_answer("For values=3,5,7,9, compute the median and mean.",
                "descriptive.numeric",list(mean=6,median=6))
  assert_answer("Normal mu=0 sigma=1 calculate P(X<=1) with mean=0 and standard deviation=1.",
                "distribution.normal",list(probability=stats::pnorm(1)))

})
# The independent A5 R6 corpus is NEVER copied into source; activate only
# against its sealed read-only directory supplied through an environment var.
a5_r6_dir<-Sys.getenv("RU_A3_W5_R2_A5_R6_DIR",unset="")
if(nzchar(a5_r6_dir)){
  mark("SUP67 all 70 independent A5 R6 questions and clean refusals",{
    d<-utils::read.csv(file.path(a5_r6_dir,"A5-R6-genuinely-unseen.csv"),
                       stringsAsFactors=FALSE)
    stopifnot(nrow(d)==70L,
              sum(d$risk=="NEGATIVE")==48L,
              sum(d$risk=="POSITIVE")==16L,
              sum(d$risk=="MISSING")==6L,
              identical(d$id[[49L]],"A5R6-N049"),
              !anyDuplicated(d$id))
    for(i in seq_len(nrow(d))){
      q<-d$question[[i]];p<-parse_w4(q)
      if(d$family_hint[[i]]=="dice"){
        # W3 owns dice dispatch and the W4 statistical adapter must not
        # masquerade as a second dice solver.
        stopifnot(is.null(p)||p$status!="SOLVED")
        next
      }
      stopifnot(is.list(p),identical(p$original_question,q),
                identical(p$schema_version,"ru.guided.v1"))
      if(d$risk[[i]]=="POSITIVE"){
        stopifnot(identical(p$status,"SOLVED"))
        a<-compute_w4(p)
        stopifnot(identical(a$status,"SOLVED"),
                  isTRUE(a$checks$verified),
                  identical(a$executed,FALSE),
                  setequal(p$requested_outputs,
                           a$answer$quantities$output_id))
        con<-textConnection(a$code_preview)
        value<-source(con,local=new.env(parent=globalenv()))$value
        close(con)
        stopifnot(identical(value$output_id,
                            a$answer$quantities$output_id))
        near(value$value,a$answer$quantities$value)
      } else {
        stopifnot(p$status!="SOLVED",nzchar(p$reason_code))
        if(d$risk[[i]]=="MISSING")
          stopifnot(identical(p$status,"NEEDS_INPUT"))
        a<-compute_w4(p)
        stopifnot(identical(a$status,p$status),
                  identical(a$code_preview,""),
                  identical(a$executed,FALSE),
                  length(a$answer)==0L)
      }
    }
    stopifnot(identical(parse_w4(d$question[[49L]])$status,"SOLVED"))
  })
}

mark("bounded repeated deterministic parsing",{
  q<-"For a continuous uniform U(2,8), compute P(3<X<5)."
  first<-serialize(parse_w4(q),NULL,version=3L)
  for(i in seq_len(40L))
    stopifnot(identical(serialize(parse_w4(q),NULL,version=3L),first))
  stopwatch<-system.time(for(i in seq_len(100L))parse_w4(q))[["elapsed"]]
  stopifnot(is.finite(stopwatch),stopwatch<20)
})
# A5's independent files are optional fixtures supplied at execution time.
# Never copy/modify an independently frozen challenge corpus in source Git.
a5_r5_dir<-Sys.getenv("RU_A3_W4_A5_R5_DIR",unset="")
if(nzchar(a5_r5_dir)){
  mark("SUP61 independent A5 R5 all 30 unseen cases",{
    file<-file.path(a5_r5_dir,"A5-new-unseen-holdouts.csv")
    stopifnot(file.exists(file))
    b<-utils::read.csv(file,stringsAsFactors=FALSE)
    stopifnot(nrow(b)==30L,setequal(names(b),c("id","risk","question")),
              sum(b$risk=="NEGATIVE")==24L,
              sum(b$risk=="POSITIVE")==4L,
              sum(b$risk=="MISSING")==2L)
    for(i in seq_len(nrow(b))){
      q<-b$question[[i]]
      p<-parse_w4(q)
      status<-if(is.null(p))"NOT_RECOGNIZED" else p$status
      if(b$risk[[i]]=="POSITIVE"){
        stopifnot(identical(status,"SOLVED"))
        a<-compute_w4(p)
        stopifnot(identical(a$status,"SOLVED"),
                  isTRUE(a$checks$verified),
                  identical(a$executed,FALSE))
      } else if(b$risk[[i]]=="MISSING"){
        stopifnot(identical(status,"NEEDS_INPUT"))
      } else stopifnot(!identical(status,"SOLVED"))
      if(!is.null(p)){
        stopifnot(identical(p$original_question,q))
        if(!identical(status,"SOLVED")){
          r<-compute_w4(p)
          stopifnot(!identical(r$status,"SOLVED"),
                    identical(r$code_preview,""),
                    identical(r$executed,FALSE),
                    is.list(r$answer),length(r$answer)==0L)
        }
      }
    }
    for(j in c("U001","U002","U003","U004","U006","U007","U022","U024")){
      i<-match(paste0("A5R5-",j),b$id)
      p<-parse_w4(b$question[[i]])
      stopifnot(!is.null(p),identical(p$status,"UNSUPPORTED"),
                nzchar(p$reason_code))
    }
  })
}
a5_r3_dir<-Sys.getenv("RU_A3_W4_A5_R3_DIR",unset="")
if(nzchar(a5_r3_dir)){
  mark("SUP61 independent frozen A5 104 plus previous 70 cases",{
    a<-utils::read.csv(file.path(a5_r3_dir,"A5-frozen104.csv"),
                       stringsAsFactors=FALSE)
    b<-utils::read.csv(file.path(a5_r3_dir,"A5-holdouts.csv"),
                       stringsAsFactors=FALSE)
    stopifnot(nrow(a)==104L,nrow(b)==70L,
              sum(a$risk!="NONE")==45L,
              sum(b$risk=="NEGATIVE")==34L,
              sum(b$risk=="POSITIVE")==28L)
    ps<-lapply(c(a$question,b$question),parse_w4)
    st<-vapply(ps,function(p)if(is.null(p))"NOT_RECOGNIZED" else p$status,
               character(1L))
    stopifnot(!any(st[which(a$risk!="NONE")]=="SOLVED"),
              !any(tail(st,nrow(b))[b$risk=="NEGATIVE"]=="SOLVED"),
              all(tail(st,nrow(b))[b$risk=="POSITIVE"]=="SOLVED"))
    for(i in which(st=="SOLVED")){
      r<-compute_w4(ps[[i]])
      stopifnot(identical(r$status,"SOLVED"),
                isTRUE(r$checks$verified),
                identical(r$executed,FALSE))
    }
  })
}
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