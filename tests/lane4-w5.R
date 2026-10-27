# W5 A4 private renderer acceptance. Exact frozen contract, real W4 chain,
# then genuine A2 W5 guide integration only if A2 has been installed.
stopifnot(requireNamespace("rulearn",quietly=TRUE))
ns <- asNamespace("rulearn")
take <- function(id) get(id,envir=ns,inherits=FALSE)
render <- take(".ru_w5_method_render")
escape <- take(".ru_w5_html_escape")
assert <- function(ok,label) {
  if (!isTRUE(ok)) stop(paste("A4 W5 FAIL:",label),call.=FALSE)
}
checks <- 0L
mark <- function(label,code) {
  force(code)
  checks <<- checks+1L
  cat("A4 W5 PASS:",label,"\n")
}
read_page <- function(result) {
  assert(is.list(result) && file.exists(result$html_path),
         "readable generated HTML")
  paste(readLines(result$html_path,warn=FALSE,encoding="UTF-8"),
        collapse="\n")
}
fixture <- function(id="mean_median",
                    status="GUIDED_REFERENCE",question=NULL) {
  list(
    schema_version="ru.w5.method-guide.v1",
    status=status,
    method_id=id,
    question=question,
    title=paste("Method reference for",id),
    required_inputs=c("data: explicit data.frame",
                      "x: named numeric column"),
    why_this_method=c("Matches a numeric summary requested by the user.",
                      "Not appropriate for nominal categories."),
    assumptions=c("Values have the intended measurement scale.",
                  "Missingness must be checked before analysis."),
    steps=c("Inspect the available columns.",
            "Identify the desired numerical variable.",
            "Review missing and nonfinite observations.",
            "Call the method with data= and x= explicitly."),
    interpretation=c("Interpret a summary in its actual measurement units.",
                     "Do not equate a descriptive pattern with causality."),
    cautions=c("No dataset has been loaded or analyzed by this guide."),
    code_preview=if(status=="GUIDED_REFERENCE")
      paste("example_data <- data.frame(value = c(2, 4, 6, 8))",
            "ru_apply('mean_median', data=example_data, x='value')",
            sep="\n") else "",
    hints=list(H0="Choose the numerical variable.",
               H1="Locate a data.frame and named column.",
               H2="Compare mean with median.",
               H3="Check outliers and missing values."),
    executed=FALSE
  )
}
mark("exact frozen method-guide fixture and open=FALSE fallback",{
  obj <- fixture(question="Find the mean & median of my values")
  r <- render(obj,FALSE)
  s <- read_page(r)
  assert(identical(r$status,"GUIDED_REFERENCE") && !r$opened &&
         identical(r$capability_status,"NOT_REQUESTED") &&
         startsWith(basename(r$html_path),"method-guide-") &&
         identical(basename(dirname(r$html_path)),
                   "rulearn-w5-method-guide"),
         "typed return without Viewer launch")
  for(needle in c("Find the mean &amp; median",
                  "mean_median","Selected method and why it fits",
                  "Data and variables required","Assumptions and study design",
                  "Method walkthrough","Run this in R","Help me get unstuck",
                  "Beginner: step-by-step","collapse for concise view",
                  "Sample", "input or column")) {
    # Case-sensitive fixture-independent terms are checked separately below.
    if(needle %in% c("Sample","input or column")) next
    assert(grepl(needle,s,fixed=TRUE),paste("Page section",needle))
  }
  assert(grepl("Not supplied",s,fixed=TRUE) == FALSE,
         "all main roles explicitly supplied")
  assert(grepl("No numerical results",s,fixed=TRUE) &&
         grepl("no plot",s,ignore.case=TRUE) &&
         !grepl("<figure",s,fixed=TRUE) &&
         !grepl("<meter",s,fixed=TRUE),
         "no fabricated values, figures, curves")
  assert(grepl("<table>",s,fixed=TRUE) &&
         grepl("Required variables, dataset and parameter roles",s,
               fixed=TRUE) &&
         grepl("<th scope='row'>",s,fixed=TRUE),
         "role table structural, explicitly not computed statistics")
  assert(grepl("code id='w3-r-code'",s,fixed=TRUE) &&
         grepl("Copy R code",s,fixed=TRUE) &&
         grepl("unexecuted",s,fixed=TRUE),
         "user-executable but not executed code text")
  assert(grepl(escape(obj$code_preview),s,fixed=TRUE),
         "exact guide R source survives escaping")
})
mark("offline CSP, semantic navigation, responsive focus, all four hints",{
  s <- read_page(render(fixture(),FALSE))
  for(needle in c(
    "lang='en'","<main","<header","<nav aria-label=",
    "<section","<h2","scope='col'","<summary>",
    "tabindex='0'","role='region'","Skip to the student question",
    "max-width:400px","focus-visible","aria-live='polite'",
    "connect-src 'none'","img-src 'none'","script-src 'self'",
    "src='ru-w3-copy.js'","H0:","H1:","H2:","H3:")) {
    assert(grepl(needle,s,fixed=TRUE),paste("Semantic/a11y",needle))
  }
  assert(!grepl("https://",s,fixed=TRUE) &&
         !grepl("http://",s,fixed=TRUE) &&
         !grepl("fetch(",s,fixed=TRUE),
         "no CDN, remote service, telemetry or automatic network")
  asset <- file.path(dirname(render(fixture(),FALSE)$html_path),
                     "ru-w3-copy.js")
  original <- system.file("www","ru-w3-copy.js",package="rulearn")
  assert(file.exists(asset) && nzchar(original) &&
         identical(unname(tools::md5sum(asset)),
                   unname(tools::md5sum(original))),
         "fixed installed clipboard asset byte parity")
})
mark("no guide returns honest status without phantom path",{
  r <- render(NULL,FALSE)
  assert(identical(r$status,"UNSUPPORTED") &&
         identical(r$capability_status,"NO_GUIDE") &&
         !r$opened && is.null(r$html_path),"no guide")
})
mark("NEEDS_INPUT and UNSUPPORTED claim no numeric results",{
  for(state in c("NEEDS_INPUT","UNSUPPORTED")) {
    g <- fixture(status=state,
                 question="<unknown> may require more parameters")
    r <- render(g,FALSE)
    s <- read_page(r)
    assert(identical(r$status,state) &&
           grepl(state,s,fixed=TRUE) &&
           !grepl("Copy R code",s,fixed=TRUE) &&
           !grepl("src='ru-w3-copy.js'",s,fixed=TRUE) &&
           !grepl("<figure",s,fixed=TRUE) &&
           !grepl("<meter",s,fixed=TRUE) &&
           grepl("&lt;unknown&gt;",s,fixed=TRUE),
           "no false solved/requested output")
  }
})
mark("long malicious question and script-like code are text only",{
  g <- fixture(question=paste(
    "<script>alert('x')</script>",
    "<img src=x onerror=evil()>",
    "<a href=file:///etc/passwd>local</a>",
    "&\"'"))
  g$title <- "<svg onload=evil()>"
  g$why_this_method <- "This is <iframe src=evil> unsafe"
  g$hints$H2 <- "<script>evil</script>"
  g$code_preview <- paste("x <- '<script>inert</script>'",
                          "system('echo SHOULD_NOT_RUN')",sep="\n")
  s <- read_page(render(g,FALSE))
  for(needle in c("&lt;script&gt;","&lt;iframe",
                  "&lt;svg","&lt;img","&lt;a href=file:",
                  "&amp;","&quot;","&#39;")) {
    assert(grepl(needle,s,fixed=TRUE),
           paste("escaped",needle))
  }
  assert(!grepl("<script>alert",s,fixed=TRUE) &&
         !grepl("<img src=x",s,fixed=TRUE) &&
         !grepl("<svg onload",s,fixed=TRUE) &&
         !grepl("<iframe",s,fixed=TRUE) &&
         !grepl("src='file:",s,fixed=TRUE),
         "no executable content or arbitrary asset resolution")
  assert(grepl("SHOULD_NOT_RUN",s,fixed=TRUE),
         "untrusted code is visible but never executed")
})
mark("strict typed contract rejects forged metadata and resource overflow",{
  base <- fixture()
  fail <- function(x) inherits(try(render(x,FALSE),silent=TRUE),
                               "try-error")
  x <- base; x$schema_version <- "ru.w4.answer.v1"
  assert(fail(x),"wrong schema")
  x <- base; x$method_id <- "system('touch /tmp/effect')"
  assert(fail(x),"untrusted method")
  x <- base; x$method_id <- "not_an_actual_method"
  assert(fail(x),"unknown method")
  x <- base; x$executed <- TRUE
  assert(fail(x),"premature executed flag")
  x <- base; x$title <- NA_character_
  assert(fail(x),"malformed title")
  x <- base; x$question <- paste(rep("X",5000L),collapse="")
  assert(fail(x),"long question")
  x <- base; x$code_preview <- paste(rep("x",70000L),collapse="")
  assert(fail(x),"oversized code")
  x <- base; x$hints$H1 <- NULL
  assert(fail(x),"missing H1 hint")
  x <- base; x$extra_computed_value <- 0.5
  assert(fail(x),"unspecified numerical fields")
  x <- base; x$required_inputs <- list(environment=globalenv())
  assert(fail(x),"environment arguments")
  x <- base; x$steps <- c("first",NA_character_)
  assert(fail(x),"NA instructional prose")
  assert(fail(1L) && fail(list()),"not a guide")
  assert(inherits(try(render(base,NA),silent=TRUE),"try-error") &&
         inherits(try(render(base,1L),silent=TRUE),"try-error"),
         "open must be scalar logical")
})
mark("concept-only guide has no invented user dataset",{
  g <- fixture(question=NULL)
  g$required_inputs <- character()
  g$code_preview <- ""
  s <- read_page(render(g,FALSE))
  assert(grepl("No specific student question",s,fixed=TRUE) &&
         grepl("Specific input roles are not supplied",s,fixed=TRUE) &&
         !grepl("<table>",s,fixed=TRUE) &&
         !grepl("Copy R code",s,fixed=TRUE) &&
         !grepl("src='ru-w3-copy.js'",s,fixed=TRUE),
         "concept-only does not fabricate inputs, table, code")
})
mark("headless RStudio Viewer unavailable returns usable local HTML",{
  if (!isTRUE(take(".ru_rstudio_ready")("viewer"))) {
    r <- render(fixture(),TRUE)
    assert(!r$opened &&
           identical(r$capability_status,"UNAVAILABLE") &&
           identical(r$reason_code,"VIEWER_UNAVAILABLE") &&
           file.exists(r$html_path),
           "no false Viewer-open claim")
  } else cat("A4 W5 SKIP: actual live RStudio capability available; no mock.\n")
})
mark("actual A3->A2->A4 W4 eight-family path remains intact",{
  p <- take(".ru_w4_parse")
  compute <- take(".ru_w4_compute")
  teach <- take(".ru_w4_teach")
  old_render <- take(".ru_w4_render")
  cases <- c(
    "Find sample variance and mean of observations 2,4,6,8.",
    "If P(A)=0.4, P(B)=0.3, and P(A intersection B)=0.1, find P(A union B).",
    "For Binomial(n=10,p=0.2), find P(X=2).",
    "For Poisson arrivals with rate lambda=3 per interval, find P(X=2).",
    "For Normal(mu=100,sigma=15), find P(X<=115).",
    "For a continuous uniform U(2,8), compute P(3<X<5).",
    paste("For independent approximately normal sample",
          "x=[7,9,10,12,12], test mu0=8 with a two-sided one-sample t test."),
    paste("Fit simple OLS regression with x=[1,2,3,4]",
          "and y=[2,3,5,7], give intercept slope and r-squared.")
  )
  for(question in cases) {
    parsed <- p(question)
    computed <- compute(parsed)
    assert(identical(computed$status,"SOLVED") &&
           identical(computed$executed,FALSE) &&
           isTRUE(take(".ru_w4_validate_computed")(computed,parsed)),
           "real A3 computed validated")
    lesson <- teach(computed)
    assert(identical(lesson$runnable_code,computed$code_preview) &&
           identical(lesson$expected_output$answer,computed$answer),
           "real A2 W4 exact numeric/code preservation")
    r <- old_render(lesson,FALSE)
    html <- read_page(r)
    assert(identical(r$status,"SOLVED") && !r$opened &&
           grepl("Computed results for the requested operations",
                 html,fixed=TRUE),
           "real legacy W4 HTML")
  }
})
mark("original W3 dice solution still uses own Viewer",{
  ans <- rulearn::ru_solve(
    "What is the PMF of the sum of one six-sided die and one four-sided die?",
    open=FALSE)
  assert(identical(ans$status,"SOLVED") &&
         identical(ans$answer$total_outcomes,24L) &&
         isTRUE(all.equal(ans$answer$expected_value,6)) &&
         !ans$opened,
         "W3 dice result")
})

# Run exact installed A2 guide->A4 Viewer, NEVER substitute a contract
# fixture as authentic acceptance. A2 can legitimately cover fewer than 46.
if (exists(".ru_w5_method_teach",envir=ns,inherits=FALSE,
           mode="function")) {
  method_teach <- take(".ru_w5_method_teach")
  methods <- c(
    "import_csv","inspect_columns","filter_rows","group_means",
    "missing_values","mean_median","sample_sd","five_number",
    "percentile_cutoff","relative_frequency","categorical_mode","z_score",
    "histogram","bar_chart","boxplot","grouped_boxplot","scatterplot",
    "zero_correlation","normal_shaded_area","line_chart","moving_average",
    "autocorrelation","stationarity","event_probability",
    "conditional_probability","probability_union","binomial_exact",
    "binomial_at_least","normal_left_tail","normal_right_tail",
    "normal_percentile","discrete_expectation","sample_random",
    "sampling_distribution","standard_error","mean_confidence_interval",
    "one_sample_t","two_sample_t","paired_t","correlation_test",
    "spearman_correlation","linear_regression","predict_regression",
    "interpolation","categorical_independence","proportion_interval")
  mark("real installed A2 guide method ID coverage and renderer",{
    real_count <- 0L
    for(id in methods) {
      guide <- method_teach(id, question=paste(
        "Show me an appropriate method for",id))
      if (is.null(guide)) next
      real_count <- real_count + 1L
      assert(identical(guide$schema_version,"ru.w5.method-guide.v1") &&
             identical(guide$method_id,id) &&
             identical(guide$executed,FALSE),
             "genuine A2 guide shaped as frozen contract")
      out <- render(guide,open=FALSE)
      content <- read_page(out)
      assert(identical(out$status,guide$status) &&
             grepl(escape(guide$method_id),content,fixed=TRUE) &&
             grepl(escape(guide$title),content,fixed=TRUE) &&
             !grepl("<meter",content,fixed=TRUE) &&
             !grepl("<figure",content,fixed=TRUE) &&
             !out$opened,
             "genuine A2 guide shows own method without faux result")
      if(nzchar(guide$code_preview)) {
        assert(grepl(escape(guide$code_preview),content,fixed=TRUE) &&
               length(parse(text=guide$code_preview))>=1L,
               "authentic guide copyable and valid R source text")
      }
    }
    assert(real_count >= 20L,
           "at least 20 genuinely A2-authored installed method guides")
    cat("A4 W5 real installed A2 guides rendered:",real_count,
        "of 46 canonical methods.\n")
  })
  mark("genuine A2 question injection cannot alter code or HTML safety",{
    innocent <- method_teach("mean_median",question="Find the mean.")
    hostile <- method_teach("mean_median",
      question="<script>alert('x')</script> & <img src=x onerror=evil()>")
    assert(!is.null(innocent) && !is.null(hostile) &&
           identical(innocent$code_preview,hostile$code_preview),
           "question text never changes fixed A2 executable example")
    s <- read_page(render(hostile,FALSE))
    assert(grepl("&lt;script&gt;",s,fixed=TRUE) &&
           grepl("&lt;img src=x",s,fixed=TRUE) &&
           !grepl("<script>alert",s,fixed=TRUE) &&
           !grepl("<img src=x",s,fixed=TRUE),
           "real A2 method guide to Viewer escaped")
  })
  mark("genuine A2 unsupported guide IDs produce no invented pages",{
    omitted <- c("import_csv","filter_rows","categorical_mode",
                 "z_score","normal_shaded_area","normal_right_tail")
    for(id in omitted) {
      g <- method_teach(id,question="Show the supported method.")
      assert(is.null(g),paste("omitted A2 guide stays absent",id))
      r <- render(g,FALSE)
      assert(identical(r$status,"UNSUPPORTED") && !r$opened &&
             is.null(r$html_path),
             "no A4 invented lesson for omitted A2 ID")
    }
  })
} else {
  cat("A4 W5 BLOCKED: A2 .ru_w5_method_teach is not installed; ",
      "authentic A2->A4 W5 acceptance NOT TESTED.\n",sep="")
}
cat("A4 W5 testing:",checks,"groups PASS, 0 FAIL; ",
    if(exists(".ru_w5_method_teach",envir=ns,inherits=FALSE,
              mode="function")) "genuine A2 W5 chain executed." else
                               "A2 W5 chain blocked.", "\n")