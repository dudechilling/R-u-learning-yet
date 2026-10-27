# W4-R2 A1: installed-package SUP51 correction, real-peer optional check.
# No A3/A2/A4 code or numerical implementation is substituted.
# Synthetic typed fixtures test validation, not claims of W4 computation.
suppressPackageStartupMessages(library(rulearn))
stopifnot(as.character(packageVersion("rulearn")) == "0.4.2.9001")

ns <- asNamespace("rulearn")
private <- function(name) get(name, envir = ns, inherits = FALSE)
registry <- private(".ru_w4_registry")
family <- private(".ru_w4_family")
enabled <- private(".ru_w4_family_enabled")
valid_registry <- private(".ru_w4_validate_registry")
valid_family <- private(".ru_w4_validate_family")
valid_parsed <- private(".ru_w4_validate_parsed")
valid_computed <- private(".ru_w4_validate_computed")
valid_answer <- private(".ru_w4_validate_answer")
valid_inputs <- private(".ru_w4_validate_typed_inputs")
dispatch_parsed <- private(".ru_w4_dispatch_parsed")
dispatch <- private(".ru_w4_dispatch")
peer <- private(".ru_w4_peer_function")
checked <- 0L
pass <- function(label, f) {
  force(f)
  checked <<- checked + 1L
  cat("W4_A1_PASS ", label, "\n", sep = "")
}
baseline <- "9be43f32110c871ca4170e1e41e39f8f160c5e0e"
ids <- c("descriptive.numeric", "probability.event_scalar",
         "distribution.binomial", "distribution.poisson",
         "distribution.normal", "distribution.uniform_continuous",
         "inference.one_sample_t", "regression.simple_ols")

pass("exact closed eight-family registry and 33 legacy public exports", {
  a <- registry()
  stopifnot(identical(names(a), ids), length(a) == 8L,
            valid_registry(a),
            all(vapply(a, valid_family, logical(1L))),
            all(vapply(a, function(x)
              identical(x$schema_version, "ru.family.v1") &&
              identical(x$execution_scope, "INLINE_LITERAL_ONLY") &&
              identical(x$qa_status, "CANDIDATE") &&
              identical(x$enabled, FALSE) &&
              identical(x$family_version, 1L), logical(1L))),
            identical(sort(names(a)), sort(ids)),
            length(getNamespaceExports("rulearn")) == 33L,
            "ru_solve" %in% getNamespaceExports("rulearn"),
            !any(grepl("^\\.ru_w4", getNamespaceExports("rulearn"))),
            identical(names(formals(ru_solve)),
                      c("question", "open", "level")),
            identical(names(formals(ru_find)),
                      c("query", "n", "type")))
  stopifnot(all(vapply(ids, function(x) identical(enabled(x), FALSE),
                       logical(1L))))
})

pass("all registered topic/curriculum crosswalks resolve to real indexes", {
  topic <- utils::read.csv(system.file("extdata", "coverage.csv",
                                        package = "rulearn"),
                           stringsAsFactors = FALSE)
  curriculum <- utils::read.csv(
    system.file("extdata", "ru-curriculum.csv", package = "rulearn"),
    stringsAsFactors = FALSE)
  stopifnot(nrow(topic) == 174L, nrow(curriculum) == 40L)
  for (entry in registry()) {
    stopifnot(all(entry$coverage_ids %in% topic$id),
              all(entry$curriculum_ids %in% curriculum$id),
              length(entry$coverage_ids) > 0L,
              length(entry$curriculum_ids) > 0L)
  }
})

pass("registry is immutable to caller and rejects unauthorized metadata", {
  a <- registry()
  a[[1L]]$enabled <- TRUE
  a[[1L]]$qa_status <- "INDEPENDENT_QA_ACCEPTED"
  stopifnot(!valid_registry(a),
            identical(registry()[[1L]]$enabled, FALSE),
            !enabled(ids[[1L]]),
            is.null(family("../other")),
            is.null(family("unknown.family")),
            identical(family(ids[[2L]])$family_id, ids[[2L]]))
  b <- registry()
  b[[3L]]$adapter_ids[["compute"]] <- "system"
  stopifnot(!valid_family(b[[3L]]), !valid_registry(b))
  c <- registry()
  c[[4L]]$operations <- c("pmf", "pmf")
  stopifnot(!valid_family(c[[4L]]), !valid_registry(c))
  d <- registry()
  d[[5L]]$input_schema[["mu"]] <- "arbitrary_function"
  stopifnot(!valid_family(d[[5L]]), !valid_registry(d))
  e <- registry()
  e[[6L]]$model_id <- "untrusted_model"
  stopifnot(!valid_registry(e))
  f <- registry()
  f[[7L]]$qa_status <- c("CANDIDATE", "INDEPENDENT_QA_ACCEPTED")
  stopifnot(!valid_family(f[[7L]]))
})

pass("package-local adapters are fixed and cannot call untrusted functions", {
  stopifnot(is.null(peer("system")), is.null(peer("source")),
            is.null(peer("eval")), is.null(peer("unknown")),
            is.null(peer("print")), is.null(peer(NA_character_)),
            is.null(peer(c("parse", "compute"))))
  for (kind in c("parse", "compute", "teach", "render")) {
    out <- peer(kind)
    stopifnot(is.null(out) || is.function(out))
  }
})

pass("strict event, numeric, enum and optional typed input roles", {
  binom <- list(n=10L,p=.2,event=list(type="exact",k=2))
  stopifnot(valid_inputs(binom,"distribution.binomial","SOLVED",
                         "probability"),
            valid_inputs(list(values=c(2,4,6,8)),
                         "descriptive.numeric","SOLVED","mean"),
            valid_inputs(list(lambda=0,event=list(type="exact",k=0)),
                         "distribution.poisson","SOLVED","probability"),
            !valid_inputs(list(n=-1L,p=.2,event=list(type="exact",k=2)),
                          "distribution.binomial","SOLVED","probability"),
            !valid_inputs(list(n=10,p=1.2,event=list(type="exact",k=2)),
                          "distribution.binomial","SOLVED","probability"),
            !valid_inputs(list(n=1.5,p=.2,event=list(type="exact",k=2)),
                          "distribution.binomial","SOLVED","probability"),
            !valid_inputs(list(values=c(2,NA_real_)),
                          "descriptive.numeric","SOLVED","mean"),
            !valid_inputs(list(values=data.frame(secret=1:3)),
                          "descriptive.numeric","SOLVED","mean"),
            !valid_inputs(list(values=c(2,4),convention=NA_character_),
                          "descriptive.numeric","SOLVED","mean"),
            !valid_inputs(list(values=c(2,4),unknown_object="x"),
                          "descriptive.numeric","SOLVED","mean"),
            !valid_inputs(list(alternative="one.tailed"),
                          "inference.one_sample_t","NEEDS_INPUT"),
            !valid_inputs(list(values=rep(1,257L)),
                          "inference.one_sample_t","NEEDS_INPUT"))
})

make_parsed <- function(family_id="distribution.binomial",
                        status="SOLVED", reason="W4_INPUTS_VALID",
                        question="Binomial(n=10,p=0.2), P(X=2)",
                        inputs=list(n=10L,p=.2,event=list(type="exact",k=2)),
                        outputs="probability",
                        assumptions=list(model="IID fixed-trials model."),
                        missing=character()) {
  item<-family(family_id)
  list(schema_version="ru.guided.v1",
       status=status,reason_code=reason,original_question=question,
       family_id=family_id,inputs=inputs,requested_outputs=outputs,
       assumptions=assumptions,missing_inputs=missing,
       parser_rule_id="binomial_named_rule_v1",
       method_id=if(is.null(item))family_id else item$method_id,
       model_id=if(is.null(item))family_id else item$model_id,
       estimand=if(identical(family_id,"inference.one_sample_t"))
         "population_mean" else "model_quantity",
       study_design=if(identical(family_id,"inference.one_sample_t"))
         "one_sample" else if(identical(family_id,"regression.simple_ols"))
         "observed_pairs" else "theoretical",
       execution_scope="INLINE_LITERAL_ONLY")
}

pass("method model and input evidence are exact and immutable", {
  x<-make_parsed()
  stopifnot(valid_parsed(x,x$original_question))
  for(key in c("method_id","model_id","estimand","study_design",
               "execution_scope")){
    bad<-x;bad[[key]]<-"forged"
    stopifnot(!valid_parsed(bad,x$original_question))
    bad<-x;bad[[key]]<-NULL
    stopifnot(!valid_parsed(bad,x$original_question))
  }
  for(bad_p in list(1.5,NA_real_,Inf,-.5)){
    bad<-x;bad$inputs$p<-bad_p
    stopifnot(!valid_parsed(bad,x$original_question))
  }
  bad<-x;bad$inputs<-list(n=quote(system("id")))
  stopifnot(!valid_parsed(bad,x$original_question))
  bad<-x;bad$original_question<-"substituted"
  stopifnot(!valid_parsed(bad,x$original_question))
  bad<-x;bad$requested_outputs<-c("probability","p_value")
  stopifnot(!valid_parsed(bad,x$original_question))
  bad<-x;bad$requested_outputs<-c("probability","probability")
  stopifnot(!valid_parsed(bad,x$original_question))
  bad<-x;bad$extra_callback<-"system"
  stopifnot(!valid_parsed(bad,x$original_question))
  bad<-x;bad$inputs$event<-list(type="arbitrary",k=2)
  stopifnot(!valid_parsed(bad,x$original_question))
  unknown<-make_parsed(family_id="unimplemented.geog",
    status="UNSUPPORTED",reason="STATISTICAL_METHOD_NOT_IMPLEMENTED",
    inputs=list(),outputs=character(),assumptions=list())
  stopifnot(valid_parsed(unknown,unknown$original_question))
  unknown$inputs<-list(secret=c(2,3))
  stopifnot(!valid_parsed(unknown,unknown$original_question))
})

pass("SOLVED requires complete exact outputs and validated answer shape", {
  p<-make_parsed()
  ans<-list(schema_version="ru.w4.answer.v1",
    quantities=data.frame(output_id="probability",label="P(X=2)",
       value=as.double(.301989888),units="",stringsAsFactors=FALSE),
    table=NULL,table_output_id=NA_character_,
    method_note="Fixed bounded theoretical calculation.")
  out<-p[c("schema_version","original_question","family_id","inputs",
           "requested_outputs","assumptions","missing_inputs","method_id",
           "model_id","estimand","study_design","execution_scope")]
  out$status<-"SOLVED";out$reason_code<-"W4_COMPUTATION_VERIFIED"
  out$answer<-ans;out$checks<-list(verified=TRUE,parity=TRUE)
  out$code_preview<-"stats::dbinom(2L,10L,.2)";out$executed<-FALSE
  stopifnot(valid_answer(ans,p$requested_outputs,p$family_id),
            valid_computed(out,p))
  bad<-out;bad$requested_outputs<-c("probability","variance")
  stopifnot(!valid_computed(bad,p))
  req<-p;req$requested_outputs<-c("probability","variance")
  stopifnot(!valid_computed(out,req),
            !valid_answer(ans,req$requested_outputs,req$family_id))
  bad<-out;bad$answer$quantities<-rbind(bad$answer$quantities,
                                         bad$answer$quantities)
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$answer$quantities$output_id<-"unrequested_extra"
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$answer$quantities$value<-2.0
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$answer$quantities$value<-1L
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$answer$table<-data.frame(raw="secret")
  bad$answer$table_output_id<-"probability"
  stopifnot(!valid_computed(bad,p))
  for(key in c("method_id","model_id","estimand","study_design",
               "execution_scope")){
    bad<-out;bad[[key]]<-"forged"
    stopifnot(!valid_computed(bad,p))
  }
  bad<-out;bad$checks$parity<-FALSE
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$executed<-TRUE
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$code_preview<-""
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$answer<-list()
  stopifnot(!valid_computed(bad,p))
  bad<-out;bad$reason_code<-"ASSERTED_ONLY"
  stopifnot(!valid_computed(bad,p))
})

pass("candidate dispatch refuses SOLVED without A2/A3/A4 qualification", {
  p <- make_parsed()
  z <- dispatch_parsed(p, p$original_question)
  stopifnot(identical(z$status, "UNSUPPORTED"),
            identical(z$reason_code, "FAMILY_NOT_QUALIFIED"),
            identical(z$family_id, "distribution.binomial"),
            identical(z$executed, FALSE),
            identical(z$code_preview, ""),
            is.list(z$answer), length(z$answer) == 0L,
            identical(z$checks$verified, FALSE))
  x <- make_parsed("distribution.unknown")
  a <- dispatch_parsed(x, x$original_question)
  stopifnot(identical(a$status, "INVALID"),
            identical(a$reason_code, "W4_PARSED_SCHEMA_INVALID"))
  x <- make_parsed()
  x$inputs$p <- NA_real_
  a <- dispatch_parsed(x, x$original_question)
  stopifnot(identical(a$status, "INVALID"),
            identical(a$reason_code, "W4_PARSED_SCHEMA_INVALID"))
})

pass("typed negative and incomplete W4 states preserve reason and never solve", {
  for (status in c("NEEDS_INPUT", "UNSUPPORTED", "INVALID",
                   "GUIDED_REFERENCE")) {
    p <- make_parsed(status = status,
                     reason = paste0("EXPLICIT_", status))
    z <- dispatch_parsed(p, p$original_question)
    stopifnot(identical(z$status, status),
              identical(z$reason_code, p$reason_code),
              identical(z$code_preview, ""), identical(z$executed, FALSE),
              identical(z$answer, list()),
              all(vapply(c("method_id", "model_id", "estimand",
                           "study_design", "execution_scope"),
                         function(key) identical(z[[key]], p[[key]]),
                         logical(1L))),
              valid_computed(z,p))
  }
})

pass("eight-family actual A3 field roles and output IDs are accepted", {
  specs <- list(
    list(id="descriptive.numeric",
      inp=list(values=c(2,4,6,8)),
      out="mean", asm=list(missing="No observations missing.")),
    list(id="probability.event_scalar",
      inp=list(p_a=NULL,p_b=.5,p_intersection=.2),
      out="conditional",asm=list(model="Consistent probability space.")),
    list(id="distribution.binomial",
      inp=list(n=5L,p=.5,event=list(type="at_least",k=3)),
      out="probability",asm=list(model="IID fixed trials.")),
    list(id="distribution.poisson",
      inp=list(lambda=0,event=list(type="exact",k=0)),
      out="probability",asm=list(model="Poisson count rate.")),
    list(id="distribution.normal",
      inp=list(mu=100,sigma=15,
        event=list(type="interval",lower=90,upper=115)),
      out="probability",asm=list(model="Continuous normal model.")),
    list(id="distribution.uniform_continuous",
      inp=list(a=2,b=8,event=list(type="interval",lower=3,upper=5)),
      out="probability",asm=list(model="Continuous uniform model.")),
    list(id="inference.one_sample_t",
      inp=list(values=c(7,9,10,12,12),mode="test",
        mu0=8,alternative="two.sided"),
      out=c("t_statistic","degrees_freedom","p_value"),
      asm=list(independence="Declared independent sampling.",
        normality="Assumed approximately normal.")),
    list(id="regression.simple_ols",
      inp=list(x=1:4,y=c(2,3,5,7),prediction_x=2),
      out=c("intercept","slope","prediction"),
      asm=list(model="Descriptive simple OLS.",
        inference="No causal claim."))
  )
  stopifnot(identical(vapply(specs,function(z) z$id,character(1L)),ids))
  for(spec in specs) {
    p <- make_parsed(spec$id,inputs=spec$inp,outputs=spec$out,
                     assumptions=spec$asm)
    stopifnot(valid_inputs(p$inputs,p$family_id,p$status,
                          p$requested_outputs))
    if (!valid_parsed(p,p$original_question))
      stop(paste("Rejected legitimate typed fixture:", spec$id),
           call.=FALSE)
  }
  variant <- make_parsed("descriptive.numeric",
    inputs=list(values=c(2,4,6,8),convention="sample"),
    outputs="sample_sd",
    assumptions=list(convention="sample",missing="No missing data."))
  stopifnot(valid_parsed(variant,variant$original_question))
  variant$inputs$convention <- "population"
  variant$assumptions$convention <- "population"
  variant$requested_outputs <- "population_variance"
  stopifnot(valid_parsed(variant,variant$original_question))
  normal <- make_parsed("distribution.normal",
    inputs=list(mu=100,sigma=15,
      event=list(type="quantile",probability=.975)),
    outputs="quantile",assumptions=list(model="Normal model."))
  stopifnot(valid_parsed(normal,normal$original_question))
  tci <- make_parsed("inference.one_sample_t",
    inputs=list(values=1:5,mode="interval",confidence_level=.95,
      alternative="two.sided"),
    outputs=c("ci_lower","ci_upper"),
    assumptions=list(independence="Declared sampling.",
                     normality="Approximate normality."))
  stopifnot(valid_parsed(tci,tci$original_question))
})

pass("nested event payloads and model forgeries are rejected", {
  for(bad in list(list(k=2), list(type="exact"),
    list(type="exact",k=2,execute="system"),
    list(type="arbitrary",k=2),
    list(type="interval",lower=5,upper=3),
    list(type="quantile",probability=NA_real_),
    list(type="quantile",probability=1.5),
    list(type="exact",k=quote(system("id"))))) {
    p <- make_parsed()
    p$inputs$event <- bad
    stopifnot(!valid_parsed(p,p$original_question))
  }
  p <- make_parsed()
  p$inputs$event<-list(type="interval",lower=2,upper=5)
  stopifnot(!valid_parsed(p,p$original_question))
  p <- make_parsed("distribution.normal",
    inputs=list(mu=0,sigma=1,event=list(type="exact",k=2)),
    assumptions=list(model="Normal model."))
  stopifnot(!valid_parsed(p,p$original_question))
  p <- make_parsed("probability.event_scalar",
    inputs=list(p_a=.01,p_b=.5,p_intersection=.2),
    outputs="conditional",assumptions=list(model="Consistent model."))
  stopifnot(!valid_parsed(p,p$original_question))
  p$inputs$p_a<-NULL;p$inputs$p_b<-0
  stopifnot(!valid_parsed(p,p$original_question))
  p <- make_parsed("inference.one_sample_t",
    inputs=list(values=1:5,mode="test",mu0=2,
                alternative="two.sided"),
    outputs=c("t_statistic","degrees_freedom","p_value"),
    assumptions=list(independence="Declared.",normality="Assumed."))
  p$inputs$mode<-"paired"
  stopifnot(!valid_parsed(p,p$original_question))
  p <- make_parsed()
  p$inputs$unexpected_object<-"get('private')"
  stopifnot(!valid_parsed(p,p$original_question))
  p <- make_parsed()
  p$inputs$event$k<-NA_real_
  stopifnot(!valid_parsed(p,p$original_question))
  p <- make_parsed("distribution.poisson",
    inputs=list(lambda=-1,event=list(type="exact",k=0)),
    assumptions=list(model="Poisson model."))
  stopifnot(!valid_parsed(p,p$original_question))
})

pass("closed operations exclude unimplemented aliases", {
  expected <- list(
    "descriptive.numeric"=c("mean","median","sample_variance",
      "population_variance","sample_sd","population_sd","quantile"),
    "probability.event_scalar"=c("complement","union","conditional"),
    "distribution.binomial"=c("probability","expected_value","variance"),
    "distribution.poisson"=c("probability","expected_value","variance"),
    "distribution.normal"=c("probability","quantile",
      "expected_value","variance"),
    "distribution.uniform_continuous"=
      c("probability","expected_value","variance"),
    "inference.one_sample_t"=
      c("t_statistic","degrees_freedom","p_value","ci_lower","ci_upper"),
    "regression.simple_ols"=
      c("intercept","slope","r_squared","prediction"))
  for (id in ids)
    stopifnot(identical(family(id)$operations,expected[[id]]))
  for (unimplemented in c("pmf","cdf","interval_probability",
                          "upper_strict","confidence_interval",
                          "fitted_values","conditional_probability")) {
    stopifnot(!unimplemented %in%
      unique(unlist(lapply(registry(),function(x)x$operations))))
  }
})
pass("installed W3 dice and conceptual PMF CDF routes stay unchanged", {
  stopifnot(is.null(dispatch("PMF of the sum of a d6 and d4")))
  q <- "Find PMF CDF expected value and variance for the sum of a d6 and d4."
  ans <- ru_solve(q, open = FALSE)
  stopifnot(inherits(ans, "ru_solution"),
            identical(ans$schema_version, "ru.guided.v1"),
            identical(ans$status, "SOLVED"),
            identical(ans$family_id, "dice_sum_independent_fair"),
            identical(ans$answer$total_outcomes, 24L),
            identical(ans$answer$pmf$count,
                      as.integer(c(1,2,3,4,4,4,3,2,1))),
            isTRUE(all.equal(ans$answer$expected_value, 6)),
            isTRUE(all.equal(ans$answer$variance, 25/6)),
            identical(ans$code_status, "NOT_EXECUTED"),
            identical(ans$executed, FALSE), identical(ans$opened, FALSE),
            identical(ans$capability_status, "NOT_REQUESTED"))
  for (q in c("PMF", "CDF", "What is a PMF?",
              "What is a CDF?", "Explain the PMF",
              "Define the CDF")) {
    z <- ru_solve(q, open = FALSE)
    stopifnot(identical(z$status, "GUIDED_REFERENCE"),
              identical(z$executed, FALSE),
              identical(z$opened, FALSE))
  }
  for (ab in list(c(4,8), c(6,6))) {
    q <- sprintf("PMF, expectation and variance of sum of d%d and d%d.",
                 ab[1], ab[2])
    z <- ru_solve(q, open = FALSE)
    stopifnot(identical(z$status, "SOLVED"),
              identical(z$answer$total_outcomes,
                        as.integer(prod(ab))))
  }
})

pass("W3 refusal gate preserves known false-positive challenges", {
  questions <- c(
    "PMF of sum of two six-sided dice and one four-sided die",
    "PMF of one six-sided die and two four-sided dice",
    "PMF of d6 and d4 plus a coin toss",
    "PMF of d6 and d4 shifted by 2",
    "PMF of d6 and d4 and one extra spinner",
    "PMF of two dependent dice",
    "Probability model for two biased six-sided dice",
    "What is the sample variance of an unfair die plus a d4?")
  for (q in questions) {
    z <- ru_solve(q, open = FALSE)
    stopifnot(!identical(z$status, "SOLVED"),
              identical(z$executed, FALSE),
              identical(z$code_preview, ""),
              identical(z$opened, FALSE))
  }
  # The A3 W4 parser will repair these current W3 misleading refusal
  # diagnostics. A1 must not falsely reclassify either as solved.
  for (q in c("Uniform U(2,8), P(3<X<5)",
              "Permutation test A=[1,2], B=[3,4]")) {
    z <- ru_solve(q, open = FALSE)
    stopifnot(!identical(z$status, "SOLVED"),
              identical(z$executed, FALSE))
  }
})

pass("original public search, filters, structure and ordinary invalid inputs", {
  for (q in c("PMF", "CDF", "linear regression", "one sample t test")) {
    got <- withVisible(ru_find(q))
    stopifnot(is.data.frame(got$value), !got$visible,
              all(c("id", "type") %in% names(got$value)))
  }
  filt <- withVisible(ru_find("PMF", n = 1L, type = "concept"))
  stopifnot(is.data.frame(filt$value), !filt$visible,
            nrow(filt$value) <= 1L,
            all(filt$value$type == "concept"))
  for (x in list(NA_character_, "", "   ", 1, character(), c("a","b"))) {
    got <- ru_solve(x, open = FALSE)
    stopifnot(identical(got$status, "INVALID"),
              identical(got$executed, FALSE),
              identical(got$code_status, "NOT_EXECUTED"))
  }
  stopifnot(identical(ru_solve(strrep("x", 4097), open = FALSE)$reason_code,
                      "QUESTION_TOO_LONG"),
            inherits(try(ru_solve("PMF", open = NA), silent = TRUE),
                     "try-error"))
})

pass("installed assets, reference preservation and no new dependencies", {
  root <- system.file("lessons", package = "rulearn")
  stopifnot(nzchar(root),
            length(list.files(root, pattern = "[.]md$")) == 84L,
            nzchar(system.file("extdata", "coverage.csv",
                               package = "rulearn")),
            nzchar(system.file("extdata", "ru-curriculum.csv",
                               package = "rulearn")),
            nzchar(system.file("www", "ru-w3-copy.js",
                               package = "rulearn")),
            length(getNamespaceExports("rulearn")) == 33L,
            is.null(dispatch("Completely unrelated question")),
            all(!vapply(registry(), function(x) x$enabled, logical(1L))))
})
# Cross-lane validation against exact externally verified A3 committed files.
# Without RU_A3_W4_SOURCE_DIR, this is an A1-only installed-package check.
peer_source <- Sys.getenv("RU_A3_W4_SOURCE_DIR", unset="")
if (nzchar(peer_source)) {
  pass("actual pinned A3 source passes all eight contracts and refusals", {
    files <- file.path(peer_source, "R",
                       c("ru-w4-parse.R","ru-w4-compute.R"))
    stopifnot(all(file.exists(files)))
    env <- new.env(parent=ns)
    for (f in files) sys.source(f, envir=env)
    overlap <- intersect(ls(env,all.names=TRUE),ls(ns,all.names=TRUE))
    stopifnot(!(".ru_w4_literal" %in% overlap),
              is.function(env$.ru_w4_parse),
              is.function(env$.ru_w4_compute))
    questions <- c(
      "Find mean of numbers 2,4,6,8.",
      "Given P(A intersection B)=0.2 and P(B)=0.5, compute P(A given B).",
      "For Binomial(n=10,p=0.2), find P(X=2).",
      "For Poisson(lambda=2), find P(X=0).",
      "For Normal(mu=100,sigma=15), find P(X<=115).",
      "For a continuous uniform U(2,8), compute P(3<X<5).",
      paste("For independent approximately normal sample",
        "x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test."),
      paste("Fit simple OLS regression with x=[1,2,3,4] and",
        "y=[2,3,5,7], give intercept slope and r-squared."))
    for (i in seq_along(questions)) {
      q <- questions[[i]]
      actual <- env$.ru_w4_parse(q)
      stopifnot(identical(actual$status,"SOLVED"),
                identical(actual$family_id,ids[[i]]),
                valid_parsed(actual,q))
      result <- env$.ru_w4_compute(actual)
      stopifnot(identical(result$status,"SOLVED"),
                valid_computed(result,actual),
                identical(result$answer$quantities$output_id,
                          actual$requested_outputs))
      refused <- dispatch_parsed(actual,q)
      stopifnot(identical(refused$status,"UNSUPPORTED"),
                identical(refused$reason_code,"FAMILY_NOT_QUALIFIED"))
    }
    for (q in c(
      "For groups A=[1,2] and B=[3,4], calculate exact two-sided permutation probability of absolute mean difference >=2 over six label allocations.",
      "Fit multiple regression with x=[1,2,3] and y=[4,5,6].",
      "For Binomial(n=5,p=.3) without replacement, P(X=2)?",
      "Find a normal variance using a known-sigma t test.")) {
      actual <- env$.ru_w4_parse(q)
      stopifnot(!is.null(actual),!identical(actual$status,"SOLVED"))
      refused <- dispatch_parsed(actual,q)
      stopifnot(!identical(refused$status,"SOLVED"))
    }
  })
}
cat("W4_A1_REGISTRY_AND_W3_COMPATIBILITY_PASS ",checked," groups\n",sep="")
