# Standalone W3 A4 renderer acceptance: typed A2/A3 fixtures, no math engine.
if(!requireNamespace("rulearn",quietly=TRUE))
  stop("Install rulearn before lane4-w3.R")
ns <- asNamespace("rulearn")
render <- get(".ru_w3_render",ns)
html <- function(z) paste(readLines(z$html_path,warn=FALSE,encoding="UTF-8"),collapse="\n")
assert <- function(x,msg) if(!isTRUE(x)) stop(msg,call.=FALSE)
make <- function(a=6L,b=4L,output=c("pmf"),status="SOLVED",question=NULL) {
  sums <- as.integer(seq.int(2L,a+b))
  counts <- as.integer(tabulate(as.vector(outer(seq_len(a),seq_len(b),"+"))-1L,nbins=a+b-1L))
  # Fixture construction uses an independent exhaustive enumeration; renderer must not.
  pmf <- data.frame(sum=sums,count=counts,probability=counts/(a*b),cdf=cumsum(counts)/(a*b))
  question <- if(is.null(question)) sprintf("PMF of the sum of one %d-sided die and one %d-sided die",a,b) else question
  code <- sprintf("die1_faces <- %dL\ndie2_faces <- %dL\noutcomes <- outer(seq_len(die1_faces), seq_len(die2_faces), '+')",a,b)
  list(schema_version="ru.guided.v1",status=status,reason_code=if(status=="SOLVED") "COMPUTED" else "NOT_COMPUTED",
       title=paste("Guided",paste(output,collapse=" and ")) ,question=question,
       requested_outputs=output,explanation_sections=list(PMF="Probability for each sum.",CDF="Running total."),
       step_by_step=c(sprintf("Create %d by %d ordered outcomes.",a,b),"Count each possible sum.","Divide each count by the total."),
       runnable_code=code,
       expected_output=list(pmf=pmf,total_outcomes=a*b,expected_value=(a+b+2)/2,
                            variance=((a*a-1)+(b*b-1))/12),
       checks=list(mass=TRUE),interpretations="These are probabilities under the specified assumptions.",
       change_this=c("Edit die1_faces.","Edit die2_faces."),hints=list(H0="Identify the dice.",H1="List the ordered outcomes.",H2="Count equal sums.",H3="Divide counts by outcomes."),
       transfer_question=sprintf("Try %d-sided and %d-sided dice.",a+1L,b+1L),
       assumptions=list(fair="Each face equally likely.",independent="The rolls are independent."))
}
x <- make()
r <- render(x,FALSE)
assert(is.list(r) && identical(r$status,"SOLVED") && identical(r$opened,FALSE) &&
       identical(r$capability_status,"NOT_REQUESTED") && file.exists(r$html_path),
       "open=FALSE contract")
s <- html(r)
for(term in c("Your question","What we are trying to find","What this means",
              "The problem model","Step-by-step","Run this in R",
              "Expected output and visualization","Interpret your result","Help me get unstuck",
              "What to edit","Try it yourself","24","die1_faces","die2_faces",
              "H0","H1","H2","H3","<table>","<meter","<details","<summary",
              "tabindex='0'","focus-visible","viewport","not been executed"))
  assert(grepl(term,s,fixed=TRUE),paste("Missing",term))
assert(grepl("6L",s,fixed=TRUE)&&grepl("4L",s,fixed=TRUE),"6+4 operands")
r2 <- render(make(4,8),FALSE)
s2 <- html(r2)
assert(grepl("4L",s2,fixed=TRUE) && grepl("8L",s2,fixed=TRUE) &&
       grepl("32",s2,fixed=TRUE) && !identical(s,s2),"4+8 adapt")
r3 <- render(make(6,6),FALSE)
assert(grepl("36",html(r3),fixed=TRUE),"6+6 adapt")
rv <- render(make(output=c("expected_value","variance"),
  question="Determine expected value and variance of the 6+4 sum"),FALSE)
assert(grepl("expected value",html(rv),fixed=TRUE) &&
       grepl("variance",html(rv),fixed=TRUE),"composite intent")
concept <- make(status="GUIDED_REFERENCE",question="PMF")
concept$expected_output <- list()
concept$runnable_code <- ""
concept$requested_outputs <- "pmf"
sc <- html(render(concept,FALSE))
assert(grepl("PMF",sc,fixed=TRUE) && !grepl("24 ordered",sc,fixed=TRUE) &&
       grepl("No numerical distribution table",sc,fixed=TRUE),
       "concept-only must not invent data")
for(st in c("NEEDS_INPUT","UNSUPPORTED","INVALID")) {
  z <- make(status=st,question="Loaded die without probabilities")
  z$expected_output <- list()
  z$runnable_code <- ""
  t <- html(render(z,FALSE))
  assert(grepl(st,t,fixed=TRUE) && !grepl("<table>",t,fixed=TRUE),
         paste("Refusal",st))
}
bad <- make(question="<script>alert('x')</script> & <img src=x onerror=evil()>")
sb <- html(render(bad,FALSE))
assert(!grepl("<script>alert",sb,fixed=TRUE) && !grepl("<img",sb,fixed=TRUE) &&
       grepl("&lt;script&gt;",sb,fixed=TRUE) &&
       !grepl("onerror=evil()></",sb,fixed=TRUE),"escaped text")
long <- make(question=paste(rep("<a&'\"x>",1000L),collapse=""))
assert(nchar(html(render(long,FALSE)))>nchar(long$question),"long escaped input")
assert(inherits(try(render(make(),NA),silent=TRUE),"try-error"),"invalid open")
assert(inherits(try(render(list(schema_version="wrong"),FALSE),silent=TRUE),"try-error"),"invalid schema")
# Capability test must not infer 'opened' from HTML creation.
old <- get(".ru_rstudio_ready",ns)
unlockBinding(".ru_rstudio_ready",ns)
assign(".ru_rstudio_ready",function(which) FALSE,envir=ns)
lockBinding(".ru_rstudio_ready",ns)
on.exit <- NULL
rf <- tryCatch(render(make(),TRUE),finally={
  unlockBinding(".ru_rstudio_ready",ns)
  assign(".ru_rstudio_ready",old,envir=ns)
  lockBinding(".ru_rstudio_ready",ns)
})
assert(!rf$opened && identical(rf$capability_status,"UNAVAILABLE") &&
       identical(rf$reason_code,"VIEWER_UNAVAILABLE") && file.exists(rf$html_path),
       "unavailable Viewer fallback")
cat("lane4-w3: PASS typed adaptive HTML, statuses, escaping, accessibility structure, Viewer mock\n")# W3-R3 real installed-source integration; this block cannot pass with typed mocks
# or with any peer implementation missing from the installed rulearn namespace.
assert("ru_solve" %in% getNamespaceExports("rulearn"),
       "Real A1 ru_solve is required for W3-R3 integration")
assert(identical(names(formals(rulearn::ru_solve)),
                 c("question","open","level")),"Public Rd/formals mismatch")
escape_real <- get(".ru_w3_escape",ns)
real <- function(question, level="beginner") {
  obj <- rulearn::ru_solve(question,open=FALSE,level=level)
  page <- render(obj$guide,FALSE)
  assert(identical(obj$status,page$status) && !page$opened &&
         file.exists(page$html_path),"real public-to-renderer contract")
  asset <- file.path(dirname(page$html_path),"ru-w3-copy.js")
  source <- system.file("www","ru-w3-copy.js",package="rulearn")
  assert(file.exists(asset) && nzchar(source) &&
         identical(readBin(asset,"raw",n=file.info(asset)$size),
                   readBin(source,"raw",n=file.info(source)$size)),
         "exact offline clipboard asset staged")
  list(object=obj,page=page,html=html(page))
}
q64 <- "What is the probability distribution (PMF) of the sum of one six-sided die and one four-sided die [1-4]?"
q48 <- "PMF of the sum of one four-sided die and one eight-sided die"
q66 <- "PMF of the sum of two six-sided dice"
p64 <- real(q64)
p48 <- real(q48)
p66 <- real(q66)
for(y in list(p64,p48,p66)) {
  z <- y$object
  assert(identical(z$status,"SOLVED") && !z$opened &&
         identical(z$executed,FALSE) &&
         identical(z$code_status,"NOT_EXECUTED"),"theory distinct from student execution")
  assert(grepl("<table>",y$html,fixed=TRUE) &&
         grepl("<meter",y$html,fixed=TRUE) &&
         grepl("<th scope='row'>",y$html,fixed=TRUE) &&
         grepl("aria-label='Probability for sum",y$html,fixed=TRUE) &&
         grepl("CDF",y$html,fixed=TRUE),
         "actual PMF/CDF accessible table and graph")
  assert(grepl(escape_real(z$code_preview),y$html,fixed=TRUE) &&
         grepl("id='w3-copy-code'",y$html,fixed=TRUE) &&
         grepl("id='w3-r-code'",y$html,fixed=TRUE) &&
         grepl("aria-live='polite'",y$html,fixed=TRUE) &&
         grepl("src='ru-w3-copy.js'",y$html,fixed=TRUE) &&
         grepl("script-src 'self'",y$html,fixed=TRUE) &&
         grepl("connect-src 'none'",y$html,fixed=TRUE) &&
         grepl("button:focus-visible",y$html,fixed=TRUE) &&
         grepl("max-width:400px",y$html,fixed=TRUE),
         "offline copy control, focus, responsive CSS")
  assert(all(vapply(paste0("H",0:3),grepl,logical(1),x=y$html,fixed=TRUE)) &&
         grepl("die1_faces",y$html,fixed=TRUE) &&
         grepl("die2_faces",y$html,fixed=TRUE) &&
         grepl("fair",y$html,ignore.case=TRUE) &&
         grepl("independent",y$html,ignore.case=TRUE),
         "question-specific hints, parameters, assumptions")
  assert(length(parse(text=z$code_preview))>=3L,"generated R syntax")
  # This explicit R check is not a Viewer action. The Copy control never runs R.
  executed <- new.env(parent=baseenv())
  suppressWarnings(eval(parse(text=z$code_preview),envir=executed))
  assert(is.data.frame(executed$pmf) &&
         isTRUE(all.equal(executed$pmf,z$answer$pmf,tolerance=1e-12)) &&
         isTRUE(all.equal(executed$expected_value,z$answer$expected_value)) &&
         isTRUE(all.equal(executed$variance,z$answer$variance,tolerance=1e-12)),
         "locally executed R preview matches A3 output")
}
assert(identical(p64$object$answer$total_outcomes,24L) &&
       identical(as.integer(p64$object$answer$pmf$count),
                 c(1L,2L,3L,4L,4L,4L,3L,2L,1L)) &&
       isTRUE(all.equal(p64$object$answer$expected_value,6)) &&
       isTRUE(all.equal(p64$object$answer$variance,25/6)) &&
       isTRUE(all.equal(p64$object$answer$pmf$cdf[p64$object$answer$pmf$sum==6L],7/12)),
       "6+4 count, expectation, variance, F(6)")
assert(identical(p48$object$answer$total_outcomes,32L) &&
       isTRUE(all.equal(p48$object$answer$expected_value,7)) &&
       isTRUE(all.equal(p48$object$answer$variance,6.5)) &&
       grepl("4L",p48$html,fixed=TRUE) && grepl("8L",p48$html,fixed=TRUE) &&
       !grepl("die1_faces &lt;- 6L",p48$html,fixed=TRUE),
       "4+8 values with no stale 6+4 parameters")
assert(identical(p66$object$answer$total_outcomes,36L) &&
       isTRUE(all.equal(p66$object$answer$expected_value,7)) &&
       isTRUE(all.equal(p66$object$answer$variance,35/6)) &&
       !identical(p64$html,p48$html) &&
       !identical(p48$html,p66$html),"6+6 and distinct displays")
qe <- "Find expected value and variance for the sum of one six-sided die and one four-sided die"
e64 <- real(qe)
assert(all(c("expected_value","variance") %in% e64$object$requested_outputs) &&
       grepl("<h3>Requested results</h3>",e64$html,fixed=TRUE) &&
       grepl("<h3>Supporting PMF and CDF</h3>",e64$html,fixed=TRUE) &&
       grepl("4.1666",e64$html,fixed=TRUE) &&
       regexpr("<h3>Requested results</h3>",e64$html,fixed=TRUE)[1L] <
       regexpr("<table>",e64$html,fixed=TRUE)[1L],
       "expectation/variance first; PMF supporting")
event <- real("For the sum of one six-sided die and one four-sided die, find P(X=4) and P(X=12).")
assert(identical(event$object$status,"SOLVED") &&
       identical(as.character(event$object$answer$events$label),
                 c("P(X=4)","P(X=12)")) &&
       isTRUE(all.equal(event$object$answer$events$probability,c(.125,0))) &&
       grepl("<h3>Requested results</h3>",event$html,fixed=TRUE) &&
       grepl("P(X=4)",event$html,fixed=TRUE) &&
       grepl("0.125",event$html,fixed=TRUE) &&
       grepl("P(X=12)",event$html,fixed=TRUE),
       "actual event calculation and HTML")
for(k in c("PMF","CDF")) {
  z <- real(k)
  assert(identical(z$object$status,"GUIDED_REFERENCE") &&
         is.null(z$object$answer$pmf) &&
         !nzchar(z$object$code_preview) &&
         !grepl("<table>",z$html,fixed=TRUE) &&
         !grepl("<meter",z$html,fixed=TRUE) &&
         !grepl("w3-copy-code",z$html,fixed=TRUE),
         paste("no made-up numeric",k))
  if(k=="CDF") assert(grepl("cumulative distribution function",z$html,
                          ignore.case=TRUE),"accurate CDF concept")
}
for(q in c("PMF of the sum of two dice",
           "PMF of the sum of two six-sided dice and one four-sided die",
           "PMF of the sum of a six-sided die and a four-sided die plus a coin toss",
           "What is the normal CDF with unknown model parameters?",
           "PMF of the sum of a loaded six-sided die and a four-sided die")) {
  z <- real(q)
  assert(z$object$status %in% c("NEEDS_INPUT","UNSUPPORTED","INVALID") &&
         !nzchar(z$object$code_preview) &&
         !grepl("<table>",z$html,fixed=TRUE) &&
         !grepl("<meter",z$html,fixed=TRUE),
         paste("refused without fabricated graph",q))
}
begin <- real(qe,"beginner")
brief <- real(qe,"concise")
assert(identical(begin$object$answer,brief$object$answer) &&
       identical(begin$object$code_preview,brief$object$code_preview) &&
       !identical(begin$html,brief$html) &&
       !identical(begin$object$guide$step_by_step,
                  brief$object$guide$step_by_step),
       "concise changes presentation, never math or code")
bad <- real("PMF of sum of one six-sided die and one four-sided die <script>alert('evil')</script> & <img src=x onerror=boom()>")
assert(grepl("&lt;script&gt;",bad$html,fixed=TRUE) &&
       !grepl("<script>alert(",bad$html,fixed=TRUE) &&
       !grepl("<img src=x",bad$html,fixed=TRUE) &&
       !grepl("onerror=boom()>",bad$html,fixed=TRUE),
       "prompt injection remains HTML-escaped")
js <- paste(readLines(system.file("www","ru-w3-copy.js",package="rulearn"),
                      warn=FALSE),collapse="\n")
assert(grepl('addEventListener("click"',js,fixed=TRUE) &&
       grepl("navigator.clipboard.writeText(sourceText)",js,fixed=TRUE) &&
       grepl('document.execCommand("copy")',js,fixed=TRUE) &&
       !grepl("eval(",js,fixed=TRUE) &&
       !grepl("new Function(",js,fixed=TRUE) &&
       !grepl("fetch(",js,fixed=TRUE),
       "no R execution/network in clipboard-only JS")
if(!interactive() && !isTRUE(get(".ru_rstudio_ready",ns)("viewer"))) {
  z <- rulearn::ru_solve(q64,open=TRUE)
  assert(!z$opened && identical(z$capability_status,"UNAVAILABLE"),
         "headless Viewer capability is honestly unavailable")
}
cat("lane4-w3 R3 real A1/A2/A3 installed integration: PASS\n")