# W4-R3 A4: installed, genuine A1+A3 computation -> W4 renderer.
# Before A2's committed teaching source is integrated, the minimal lesson
# constructed below is a STRUCTURAL PROJECTION of actual computed data.
# It is not an A2 teaching fixture, and it is NOT end-to-end A2+A4 acceptance.
stopifnot(requireNamespace("rulearn",quietly=TRUE))
ns <- asNamespace("rulearn")
take <- function(name) get(name,envir=ns,inherits=FALSE)
parse_w4 <- take(".ru_w4_parse")
compute_w4 <- take(".ru_w4_compute")
valid_parsed <- take(".ru_w4_validate_parsed")
valid_computed <- take(".ru_w4_validate_computed")
render <- take(".ru_w4_render")
escape <- take(".ru_w4_html_escape")
assert <- function(ok,label) {
  if (!isTRUE(ok)) stop(paste("A4 W4 FAIL:",label),call.=FALSE)
}
count <- 0L
mark <- function(name, expr) {
  force(expr)
  count <<- count+1L
  cat("A4 W4 PASS:",name,"\n")
}
read_page <- function(rendering) {
  assert(is.list(rendering) && file.exists(rendering$html_path),"HTML created")
  paste(readLines(rendering$html_path,warn=FALSE,encoding="UTF-8"),
        collapse="\n")
}
real_computed <- function(question) {
  parsed <- parse_w4(question)
  assert(is.list(parsed) && identical(parsed$schema_version,"ru.guided.v1"),
         "real A1+A3 parse result")
  assert(isTRUE(valid_parsed(parsed,question)),"A1 validated parsed")
  computed <- compute_w4(parsed)
  assert(isTRUE(valid_computed(computed,parsed)),"A1 validated computed")
  assert(identical(computed$original_question,question) &&
         identical(computed$executed,FALSE),"preserved question / unexecuted")
  computed
}
# Deliberately mechanical: no fabricated statistical explanation is passed
# off as an A2-authored lesson. These neutral placeholder strings exercise
# formatting; all numeric data and runnable R come from actual A3 computation.
projection <- function(computed,level="beginner") {
  assumptions <- if (length(computed$assumptions))
    unlist(computed$assumptions,use.names=FALSE) else character()
  if (!is.character(assumptions)) assumptions <- as.character(assumptions)
  solved <- identical(computed$status,"SOLVED")
  list(schema_version="ru.guided.v1",
       status=computed$status,reason_code=computed$reason_code,
       title=if(solved) paste("Method:",computed$family_id)
             else "Unavailable statistical method",
       question=computed$original_question,
       requested_outputs=computed$requested_outputs,
       presentation_level=level,
       explanation_sections=if(solved)
         c(paste("Computed family:",computed$family_id),
           paste("Declared model:",computed$model_id),
           "Numerical values shown here are identical to the validated computation.")
         else c("This problem has not received a validated numerical answer."),
       step_by_step=if(solved)
         c("Inspect the supplied method and assumptions.",
           "Read the original computed values and units.",
           "Review the generated but unexecuted R preview.")
         else c("Identify missing inputs or an approved supported model."),
       runnable_code=if(solved) computed$code_preview else "",
       expected_output=list(answer=if(solved) computed$answer else list(),
                            requested_outputs=computed$requested_outputs,
                            summary_lines=character()),
       assumptions=assumptions,
       checks=if(solved) "Numerical result was verified by A1/A3."
              else "Numerical computation not accepted as solved.",
       interpretations=if(solved)
         "These are the computed numerical values under the stated model."
         else "No statistical interpretation of a calculated answer is possible.",
       change_this="In the R preview, edit only the validated numeric input literals.",
       hints=list(H0="Identify the family.",
                  H1="Read the requested operation.",
                  H2="Use the stated model assumptions.",
                  H3="Verify the supplied computed result."),
       transfer_question="Choose another explicitly supported model and supply inputs.",
       links=character())
}
make <- function(question,level="beginner") {
  computed <- real_computed(question)
  lesson <- projection(computed,level)
  rendering <- render(lesson,open=FALSE)
  assert(identical(rendering$status,computed$status) &&
         identical(rendering$opened,FALSE) &&
         identical(rendering$capability_status,"NOT_REQUESTED"),
         "render return contract")
  list(computed=computed,lesson=lesson,rendering=rendering,
       page=read_page(rendering))
}
cases <- list(
  "descriptive.numeric"="Find sample variance and mean of observations 2,4,6,8.",
  "probability.event_scalar"=
    "If P(A)=0.4, P(B)=0.3, and P(A intersection B)=0.1, find P(A union B).",
  "distribution.binomial"="For Binomial(n=10,p=0.2), find P(X=2).",
  "distribution.poisson"=
    "For Poisson arrivals with rate lambda=3 per interval, find P(X=2).",
  "distribution.normal"=
    "For Normal(mu=100,sigma=15), find P(X<=115).",
  "distribution.uniform_continuous"=
    "For a continuous uniform U(2,8), compute P(3<X<5).",
  "inference.one_sample_t"=
    paste("For independent approximately normal sample",
          "x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test."),
  "regression.simple_ols"=
    paste("Fit simple OLS regression with x=[1,2,3,4]",
          "and y=[2,3,5,7], give intercept slope and r-squared.")
)
mark("exact eight fixed families disabled in original registry",{
  registry <- take(".ru_w4_registry")()
  assert(identical(sort(names(registry)),sort(names(cases))),
         "family identifiers match frozen allowlist")
  assert(all(vapply(registry,function(x)identical(x$enabled,FALSE),
                    logical(1L))),"no family enabled")
  assert(is.function(take(".ru_w4_peer_function")("render")),
         "fixed A4 renderer is registered")
})
rendered <- list()
for(family in names(cases)) {
  obj <- make(cases[[family]])
  rendered[[family]] <- obj
  mark(paste("real A3",family,"numeric/HTML/code parity"),{
    z <- obj$computed
    ans <- z$answer
    assert(identical(z$status,"SOLVED") &&
           identical(z$family_id,family) &&
           identical(ans$schema_version,"ru.w4.answer.v1"),
           "actual solved family")
    assert(grepl(escape(z$original_question),obj$page,fixed=TRUE),
           "exact escaped original question")
    assert(grepl(escape(z$code_preview),obj$page,fixed=TRUE),
           "exact unexecuted R code shown")
    assert(grepl("Computed results for the requested operations",
                 obj$page,fixed=TRUE) &&
           grepl("<th scope='row'>",obj$page,fixed=TRUE) &&
           grepl("scope='col'",obj$page,fixed=TRUE),
           "semantic exact answer table")
    for(i in seq_len(nrow(ans$quantities))) {
      q <- ans$quantities
      assert(grepl(escape(q$output_id[[i]]),obj$page,fixed=TRUE) &&
             grepl(escape(q$label[[i]]),obj$page,fixed=TRUE) &&
             grepl(escape(sprintf("%.17g",q$value[[i]])),
                   obj$page,fixed=TRUE),
             paste("no invented or rounded-away",q$output_id[[i]]))
    }
    assert(grepl("Copy R code",obj$page,fixed=TRUE) &&
           grepl("src='ru-w3-copy.js'",obj$page,fixed=TRUE) &&
           grepl("script-src 'self'",obj$page,fixed=TRUE) &&
           grepl("connect-src 'none'",obj$page,fixed=TRUE) &&
           grepl("aria-live='polite'",obj$page,fixed=TRUE) &&
           grepl("button:focus-visible",obj$page,fixed=TRUE) &&
           grepl("Skip to question",obj$page,fixed=TRUE) &&
           grepl("max-width:400px",obj$page,fixed=TRUE),
           "static accessibility and offline Copy structure")
    assert(grepl("H0",obj$page,fixed=TRUE) &&
           grepl("H1",obj$page,fixed=TRUE) &&
           grepl("H2",obj$page,fixed=TRUE) &&
           grepl("H3",obj$page,fixed=TRUE),
           "four keyboard-operable progressive hints")
    assert(length(parse(text=z$code_preview))>=1L,
           "A3 generated R code parses")
    script_env <- new.env(parent=globalenv())
    stream <- textConnection(z$code_preview)
    actual <- tryCatch(source(stream,local=script_env,echo=FALSE)$value,
      finally=close(stream))
    assert(is.data.frame(actual) &&
           identical(actual$output_id,ans$quantities$output_id) &&
           isTRUE(all.equal(actual$value,ans$quantities$value,
                            tolerance=1e-10)),
           "actual A3 R preview parity with own verified values")
    asset <- file.path(dirname(obj$rendering$html_path),"ru-w3-copy.js")
    installed <- system.file("www","ru-w3-copy.js",package="rulearn")
    assert(file.exists(asset) && nzchar(installed) &&
           identical(unname(tools::md5sum(asset)),
                     unname(tools::md5sum(installed))),
           "reuses installed unmodified offline clipboard asset")
  })
}
mark("probability plots use only verified 0-1 computed scalars",{
  for(id in c("probability.event_scalar","distribution.binomial",
              "distribution.poisson","distribution.normal",
              "distribution.uniform_continuous","inference.one_sample_t",
              "regression.simple_ols")) {
    assert(grepl("<meter",rendered[[id]]$page,fixed=TRUE),
           paste("verified 0-1 meter for",id))
  }
  assert(!grepl("<meter",rendered[["descriptive.numeric"]]$page,
                fixed=TRUE) &&
         grepl("No plot is shown",rendered[["descriptive.numeric"]]$page,
               fixed=TRUE),
         "never invent descriptive distribution")
})
mark("solved W4 answer has no fabricated distribution table",{
  for(y in rendered) {
    assert(identical(y$computed$answer$table,NULL) &&
           !grepl("Supplied computed table",y$page,fixed=TRUE),
           "A3 supplied no table; none invented")
  }
})
mark("concise and beginner preserve exact mathematical answers and code",{
  q <- cases[["inference.one_sample_t"]]
  a <- make(q,level="beginner")
  b <- make(q,level="concise")
  assert(identical(a$computed$answer,b$computed$answer) &&
         identical(a$computed$code_preview,b$computed$code_preview) &&
         !identical(a$page,b$page) &&
         grepl("Expand conceptual explanation",b$page,fixed=TRUE) &&
         !grepl("Expand conceptual explanation",a$page,fixed=TRUE),
         "conditional presentation only")
})
mark("refusals and missing input never display forged numbers or Copy",{
  for(q in c("Find Poisson probability without lambda.",
             "For Binomial(n=5), find P(X=2).",
             "Run logistic regression on my dataset.")) {
    z <- make(q)
    assert(z$computed$status %in% c("NEEDS_INPUT","UNSUPPORTED","INVALID") &&
           !grepl("Computed results for the requested",z$page,fixed=TRUE) &&
           !grepl("<meter",z$page,fixed=TRUE) &&
           !grepl("w3-copy-code",z$page,fixed=TRUE) &&
           !nzchar(z$computed$code_preview),
           "non-solved honest refusal")
  }
})
mark("malicious question, label and method note are safely escaped",{
  tampered <- projection(rendered[["distribution.normal"]]$computed)
  tampered$question <- "<script>alert('x')</script> & <img src=x onerror=evil()>"
  tampered$title <- "<svg onload=evil()>"
  tampered$expected_output$answer$method_note <- "<img src=evil>"
  tampered$expected_output$answer$quantities$label[[1L]] <-
    "<iframe src=file:///etc/passwd>"
  z <- read_page(render(tampered,FALSE))
  assert(grepl("&lt;script&gt;",z,fixed=TRUE) &&
         grepl("&lt;iframe",z,fixed=TRUE) &&
         grepl("&lt;svg",z,fixed=TRUE) &&
         !grepl("<script>alert",z,fixed=TRUE) &&
         !grepl("<iframe",z,fixed=TRUE) &&
         !grepl("<img src=evil",z,fixed=TRUE) &&
         !grepl("<svg onload",z,fixed=TRUE),
         "no dynamic HTML or filesystem injection")
})
mark("forged output identity, nonfinite number, HTML paths are rejected",{
  proto <- projection(rendered[["distribution.binomial"]]$computed)
  bad <- proto
  bad$requested_outputs <- "median"
  assert(inherits(try(render(bad,FALSE),silent=TRUE),"try-error"),
         "mismatched requested output rejected")
  bad <- proto
  bad$expected_output$answer$quantities$value[[1L]] <- Inf
  assert(inherits(try(render(bad,FALSE),silent=TRUE),"try-error"),
         "nonfinite numeric rejected")
  bad <- proto
  bad$expected_output$answer$quantities$output_id[[1L]] <- "variance"
  assert(inherits(try(render(bad,FALSE),silent=TRUE),"try-error"),
         "forged answer output rejected")
  bad <- proto
  bad$runnable_code <- ""
  assert(inherits(try(render(bad,FALSE),silent=TRUE),"try-error"),
         "solved without code refused")
  bad <- proto
  bad$question <- paste(rep("X",5000),collapse="")
  assert(inherits(try(render(bad,FALSE),silent=TRUE),"try-error"),
         "oversized question refused")
  assert(inherits(try(render(proto,NA),silent=TRUE),"try-error"),
         "invalid open rejected")
  f <- render(proto,FALSE)$html_path
  assert(startsWith(basename(f),"guided-w4-") &&
         identical(basename(dirname(f)),"rulearn-w4-guided"),
         "questions cannot control output file paths")
})
mark("optional typed numerical table is accessible (structural only)",{
  # A3 does not currently emit a table in any W4 family. This is an
  # isolated table-HTML test, not a claim of real A2 or A3 table acceptance.
  m <- projection(rendered[["distribution.normal"]]$computed)
  m$expected_output$answer$quantities <-
    m$expected_output$answer$quantities[FALSE,,drop=FALSE]
  m$expected_output$answer$table <- data.frame(probability=c(.25,.75))
  m$expected_output$answer$table_output_id <- "probability"
  h <- read_page(render(m,FALSE))
  assert(grepl("Supplied computed table",h,fixed=TRUE) &&
         grepl("<th scope='col'>probability</th>",h,fixed=TRUE) &&
         grepl("0.25",h,fixed=TRUE) && grepl("0.75",h,fixed=TRUE),
         "no duplicate or unlabeled table rendering")
  m$expected_output$answer$table$probability[[1L]] <- Inf
  assert(inherits(try(render(m,FALSE),silent=TRUE),"try-error"),
         "forged nonfinite table rejected")
})
mark("headless Viewer unavailable has useful HTML fallback",{
  if (!isTRUE(take(".ru_rstudio_ready")("viewer"))) {
    z <- render(projection(rendered[["distribution.binomial"]]$computed),
                open=TRUE)
    assert(!z$opened && identical(z$capability_status,"UNAVAILABLE") &&
           identical(z$reason_code,"VIEWER_UNAVAILABLE") &&
           file.exists(z$html_path),"truthful Viewer not available")
  } else cat("A4 W4 SKIP: viewer presence mock not performed in active RStudio.\n")
})
# Genuine A2 teaching acceptance occurs ONLY after the exact A2 source
# is committed and installed. Never use projection() as its substitute.
if (is.function(take(".ru_w4_peer_function")("teach"))) {
  mark("genuine installed A2 teaching to A4 Viewer (all eight)",{
    teach <- take(".ru_w4_peer_function")("teach")
    for(y in rendered) {
      lesson <- teach(y$computed)
      assert(identical(lesson$schema_version,"ru.guided.v1") &&
             identical(lesson$status,y$computed$status) &&
             identical(lesson$runnable_code,y$computed$code_preview) &&
             identical(lesson$expected_output$answer,y$computed$answer) &&
             identical(names(lesson$hints),paste0("H",0:3)) &&
             length(unique(unlist(lesson$hints,use.names=FALSE)))==4L &&
             length(lesson$explanation_sections)>1L &&
             length(lesson$step_by_step)>1L &&
             length(lesson$assumptions)>=1L,
             "genuine A2 content, H0-H3 and original A3 answers/code")
      r <- render(lesson,FALSE)
      s <- read_page(r)
      assert(grepl("Computed results for the requested operations",
                   s,fixed=TRUE) &&
             grepl(escape(y$computed$original_question),s,fixed=TRUE),
             "genuine A2 teaching shows question-specific result")
    }
  })
  mark("genuine installed A2 refusals contain no numerical answers",{
    for(q in c("Find Poisson probability without lambda.",
               "For Binomial(n=5), find P(X=2).",
               "Run logistic regression on my dataset.")) {
      computed <- real_computed(q)
      lesson <- take(".ru_w4_peer_function")("teach")(computed)
      assert(identical(lesson$status,computed$status) &&
             !identical(lesson$status,"SOLVED") &&
             identical(lesson$runnable_code,"") &&
             (if(is.list(lesson$expected_output))
                is.null(lesson$expected_output$answer) ||
                  !length(lesson$expected_output$answer)
              else
                is.character(lesson$expected_output) &&
                  !length(lesson$expected_output)),
             "real A2 refusal shape")
      s <- read_page(render(lesson,FALSE))
      assert(!grepl("<meter",s,fixed=TRUE) &&
             !grepl("Copy R code",s,fixed=TRUE) &&
             grepl(computed$status,s,fixed=TRUE),
             "real A2 non-solved Viewer honest")
    }
  })
} else {
  cat("A4 W4 BLOCKED: A2 .ru_w4_teach not installed; ",
      "A2+A4 final end-to-end acceptance NOT TESTED.\n",sep="")
}
cat("A4 W4-R3 real A1+A3 computed object rendering:",
    count,"checks PASS, 0 FAIL; ",
    if(is.function(take(".ru_w4_peer_function")("teach")))
      "genuine committed A2 teaching integration tested." else
      "A2 teaching integration NOT TESTED.", "\n")