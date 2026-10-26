# Question-specific, offline, noncomputing presentation of ru.guided.v1 lessons.
# A3 owns numerical results; A2 owns pedagogical material.
.ru_w3_escape <- function(x) {
  x <- paste(as.character(x), collapse = " ")
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  gsub("'", "&#39;", x, fixed = TRUE)
}
.ru_w3_text <- function(x) {
  if(is.null(x) || length(x) == 0L) return(character())
  if(is.data.frame(x)) return(character())
  if(is.list(x)) return(unlist(lapply(x, .ru_w3_text), use.names = FALSE))
  x <- as.character(x)
  x[!is.na(x) & nzchar(trimws(x))]
}
.ru_w3_paras <- function(x) {
  x <- .ru_w3_text(x)
  if(!length(x)) return("<p>Not provided for this question.</p>")
  paste0("<p>", vapply(x, .ru_w3_escape, character(1)), "</p>", collapse = "\n")
}
.ru_w3_items <- function(x, numbered = FALSE) {
  x <- .ru_w3_text(x)
  if(!length(x)) return("<p>Not provided for this question.</p>")
  tag <- if(numbered) "ol" else "ul"
  paste0("<",tag,">",paste0("<li>",vapply(x,.ru_w3_escape,character(1)),"</li>",collapse=""),
         "</",tag,">")
}
.ru_w3_section <- function(id, title, content) {
  paste0("<section id='",id,"' aria-labelledby='",id,"-title'><h2 id='",id,
         "-title'>",.ru_w3_escape(title),"</h2>",content,"</section>")
}
.ru_w3_pmf <- function(lesson) {
  out <- lesson$expected_output
  if(!is.list(out)) return(NULL)
  pmf <- out$pmf
  if(is.null(pmf) && is.list(out$answer)) pmf <- out$answer$pmf
  if(!is.data.frame(pmf) || !all(c("sum","count","probability","cdf") %in% names(pmf)))
    return(NULL)
  if(!nrow(pmf) || nrow(pmf)>1001L ||
     !is.numeric(pmf$probability) || any(!is.finite(pmf$probability)) ||
     any(pmf$probability<0 | pmf$probability>1)) return(NULL)
  pmf
}
.ru_w3_pmf_html <- function(pmf) {
  if(is.null(pmf)) return("<p>No numerical distribution table is available for this guide.</p>")
  rows <- vapply(seq_len(nrow(pmf)), function(i) {
    cells <- c(as.character(pmf$sum[i]), as.character(pmf$count[i]),
               format(pmf$probability[i],digits=8,trim=TRUE,scientific=FALSE),
               format(pmf$cdf[i],digits=8,trim=TRUE,scientific=FALSE))
    paste0("<tr><th scope='row'>",.ru_w3_escape(cells[1L]),"</th>",
           paste0("<td>",vapply(cells[-1L],.ru_w3_escape,character(1)),"</td>",collapse=""),"</tr>")
  }, character(1))
  bars <- vapply(seq_len(nrow(pmf)),function(i) {
    p <- format(pmf$probability[i],digits=8,scientific=FALSE,trim=TRUE)
    paste0("<li><span class='w3-bar-label'>",.ru_w3_escape(pmf$sum[i]),"</span>",
           "<meter min='0' max='1' value='",.ru_w3_escape(p),
           "' aria-label='Probability for sum ",.ru_w3_escape(pmf$sum[i]),"'>",
           .ru_w3_escape(p),"</meter><span class='w3-bar-value'>",.ru_w3_escape(p),
           "</span></li>")
  },character(1))
  paste0("<div class='w3-scroll' tabindex='0' role='region' aria-label='Probability mass function table'>",
         "<table><caption>Computed theoretical probability mass function and cumulative probability</caption>",
         "<thead><tr><th scope='col'>Sum</th><th scope='col'>Ordered outcomes</th>",
         "<th scope='col'>Probability</th><th scope='col'>CDF</th></tr></thead><tbody>",
         paste(rows,collapse=""),"</tbody></table></div>",
         "<figure role='group' aria-labelledby='w3-graph-caption'>",
         "<figcaption id='w3-graph-caption'>Probability by sum. Each bar encodes the numerical probability also shown in the table; scale 0 to 1.</figcaption>",
         "<ul class='w3-bars'>",paste(bars,collapse=""),"</ul></figure>")
}
.ru_w3_explain_sections <- function(x) {
  if(is.null(x) || !length(x)) return(.ru_w3_paras("Read the requested operation and the stated model assumptions before using code."))
  if(is.list(x) && !is.null(names(x)) && any(nzchar(names(x)))) {
    return(paste(vapply(seq_along(x),function(i) {
      name <- names(x)[i]
      paste0("<h3>",.ru_w3_escape(if(nzchar(name)) gsub("_"," ",name,fixed=TRUE) else paste("Concept",i)),
             "</h3>",.ru_w3_paras(x[[i]]))
    },character(1)),collapse=""))
  }
  .ru_w3_paras(x)
}
.ru_w3_html <- function(lesson) {
  status <- lesson$status
  question <- lesson$question
  if(!is.character(question) || length(question)!=1L || is.na(question)) question <- ""
  ttl <- if(is.character(lesson$title) && length(lesson$title)==1L &&
            !is.na(lesson$title) && nzchar(lesson$title)) lesson$title else "Guided statistics question"
  pmf <- .ru_w3_pmf(lesson)
  outputs <- lesson$requested_outputs
  if(is.null(outputs) && is.list(lesson$expected_output)) outputs <- lesson$expected_output$requested_outputs
  if(is.null(outputs)) outputs <- lesson$what_to_find
  what <- if(length(.ru_w3_text(outputs))) .ru_w3_items(gsub("_"," ",.ru_w3_text(outputs),fixed=TRUE))
          else .ru_w3_paras(lesson$goal)
  if(identical(what,"<p>Not provided for this question.</p>"))
    what <- .ru_w3_paras("Use the question and the following explanation to identify the requested operation.")
  code <- .ru_w3_text(lesson$runnable_code)
  code <- if(length(code)) paste(code,collapse="\n") else ""
  hints <- lesson$hints
  if(is.list(hints) && !is.null(names(hints))) hints <- hints[c("H0","H1","H2","H3")]
  hints <- if(is.list(hints)) hints else as.list(hints)
  hint_html <- paste(vapply(seq_along(hints),function(i) {
    h <- if(!is.null(names(hints)) && nzchar(names(hints)[i])) names(hints)[i] else paste0("H",i-1L)
    paste0("<details><summary>",.ru_w3_escape(h)," \u2014 ",c("First direction","Model clue","Calculation help","Worked reasoning")[min(i,4L)],
           "</summary>",.ru_w3_paras(hints[[i]]),"</details>")
  },character(1)),collapse="")
  interpret <- .ru_w3_paras(lesson$interpretations)
  limitation <- if(status=="SOLVED")
    "These results are computed theoretical mathematics under the stated assumptions. The R code below is a preview and has not been executed by the student."
    else if(status=="GUIDED_REFERENCE")
      "This is conceptual guidance, not a numerical solution. No unstated data or parameters have been supplied."
    else paste("No solved numerical answer is claimed. Status:",status,"; reason:",
               paste(.ru_w3_text(lesson$reason_code),collapse=" "))
  css <- ".w3-wrap{max-width:1020px;margin:auto;padding:clamp(12px,3vw,34px);font:16px/1.6 system-ui,sans-serif;color:#182936;background:#fafcfd}.w3-wrap h1{font-size:clamp(1.55rem,4vw,2.6rem);line-height:1.2}.w3-wrap h2{font-size:1.3rem;margin-top:1.2rem}.w3-wrap section{background:white;padding:clamp(12px,2vw,24px);border:1px solid #c6d4da;border-radius:12px;margin:16px 0}.w3-wrap .w3-status{font-weight:bold;border-left:5px solid #4c7489;padding:9px 13px;background:#edf3f5}.w3-wrap button:focus-visible,.w3-wrap a:focus-visible,.w3-wrap summary:focus-visible,.w3-wrap pre:focus-visible,.w3-wrap .w3-scroll:focus-visible{outline:3px solid #a44d09;outline-offset:3px}.w3-wrap nav{display:flex;flex-wrap:wrap;gap:8px}.w3-wrap nav a{color:#12517a}.w3-wrap pre{white-space:pre;overflow:auto;padding:16px;background:#172732;color:#fff;border-radius:8px}.w3-wrap table{border-collapse:collapse;width:100%;font-variant-numeric:tabular-nums}.w3-wrap th,.w3-wrap td{padding:8px;text-align:left;border-bottom:1px solid #d7e2e6}.w3-wrap th{background:#e9f0f3}.w3-wrap .w3-scroll{overflow-x:auto}.w3-wrap details{border:1px solid #a9bec9;padding:10px;margin:10px 0;border-radius:7px}.w3-wrap summary{cursor:pointer;font-weight:600}.w3-wrap .w3-bars{list-style:none;padding:0}.w3-wrap .w3-bars li{display:grid;grid-template-columns:3rem minmax(5rem,1fr) 5rem;gap:10px;align-items:center;margin:6px 0}.w3-wrap meter{width:100%;height:1.1rem}.w3-wrap figure{margin:16px 0}.w3-wrap .w3-note{font-size:.93rem;color:#355164}.w3-wrap .w3-code-tools{display:flex;align-items:center;gap:12px;flex-wrap:wrap;margin:12px 0}.w3-wrap button{background:#16577d;color:white;border:2px solid #16577d;border-radius:5px;font:inherit;padding:7px 14px;cursor:pointer}.w3-wrap button:hover{background:#103c57}.w3-wrap .w3-copy-status{font-size:.9rem}@media(max-width:400px){.w3-wrap{font-size:15px}.w3-wrap section{padding:12px}.w3-wrap .w3-bars li{grid-template-columns:2rem minmax(3rem,1fr) 4rem;gap:5px}.w3-wrap th,.w3-wrap td{padding:4px}.w3-wrap table{font-size:.84rem}}"
  nav <- paste0("<nav aria-label='Sections in this lesson'><a href='#w3-goal'>Goal</a><a href='#w3-meaning'>Meaning</a><a href='#w3-model'>Model</a>",
                "<a href='#w3-method'>Steps</a><a href='#w3-code'>R code</a><a href='#w3-results'>Results</a><a href='#w3-hints'>Hints</a><a href='#w3-practice'>Practice</a></nav>")
  requested_values <- any(outputs %in% c("expected_value","variance","events"))
  model_values <- .ru_w3_other_results(lesson$expected_output,outputs)
  results_body <- if(requested_values) paste0(
    "<h3>Requested results</h3>",model_values,
    "<h3>Supporting PMF and CDF</h3>",.ru_w3_pmf_html(pmf))
  else paste0(.ru_w3_pmf_html(pmf),
    if(identical(status,"SOLVED")) paste0("<h3>Model size</h3>",model_values) else "")
  sections <- paste0(
    .ru_w3_section("w3-question","Your question",paste0("<blockquote>",.ru_w3_escape(question),"</blockquote>")),
    .ru_w3_section("w3-goal","What we are trying to find",what),
    .ru_w3_section("w3-meaning","What this means",.ru_w3_explain_sections(lesson$explanation_sections)),
    .ru_w3_section("w3-model","The problem model and assumptions",
                   .ru_w3_items(lesson$assumptions)),
    .ru_w3_section("w3-method","Step-by-step method",.ru_w3_items(lesson$step_by_step,TRUE)),
    .ru_w3_section("w3-code","Run this in R",
      if(nzchar(code)) paste0("<p class='w3-note'>Code preview \u2014 not executed. Copying this text never runs R code.</p>",
            "<div class='w3-code-tools'><button id='w3-copy-code' type='button' aria-describedby='w3-copy-status'>Copy R code</button>",
            "<span id='w3-copy-status' class='w3-copy-status' role='status' aria-live='polite'></span></div>",
            "<pre tabindex='0' aria-label='Selectable R source code'><code id='w3-r-code'>",
            .ru_w3_escape(code),"</code></pre>")
      else "<p>No executable R code can be supplied from the available information.</p>"),
    .ru_w3_section("w3-results","Expected output and visualization",results_body),
    .ru_w3_section("w3-interpret","Interpret your result",paste0(interpret,"<p class='w3-note'>",.ru_w3_escape(limitation),"</p>")),
    .ru_w3_section("w3-hints","Help me get unstuck",
      if(nzchar(hint_html)) hint_html else "<p>No targeted hints are available for this question.</p>"),
    .ru_w3_section("w3-edit","What to edit",.ru_w3_items(lesson$change_this)),
    .ru_w3_section("w3-practice","Try it yourself",.ru_w3_paras(lesson$transfer_question)))
  paste0("<!doctype html><html lang='en'><head><meta charset='UTF-8'>",
         "<meta name='viewport' content='width=device-width,initial-scale=1'>",
         "<meta http-equiv='Content-Security-Policy' content=\"default-src 'none'; style-src 'unsafe-inline'; img-src 'none'; connect-src 'none'; script-src 'self'; object-src 'none'; base-uri 'none'; form-action 'none'\">",
         "<title>",.ru_w3_escape(ttl)," \u2014 RU</title><style>",css,"</style></head><body>",
         "<main class='w3-wrap'><a href='#w3-question'>Skip to student question</a>",
         "<header><p>R-u-learning-yet \u00b7 Offline guided learning</p><h1>",.ru_w3_escape(ttl),"</h1>",
         "<p class='w3-status' role='status'>",.ru_w3_escape(status),"</p>",nav,"</header>",
         sections,"<footer><p>All content is generated locally. R code must be run by the student. No automatic export or network request occurs.</p></footer>",
         "</main><script defer src='ru-w3-copy.js'></script></body></html>")
}
.ru_w3_other_results <- function(out, requested=NULL) {
  if(!is.list(out)) return(.ru_w3_paras(out))
  if(is.list(out$answer)) out <- out$answer
  keys <- intersect(c("total_outcomes","expected_value","variance","events"),names(out))
  if(length(requested)) keys <- intersect(keys, c("total_outcomes", requested))
  if(!length(keys)) return("<p>See the explanation above for the expected output.</p>")
  paste(vapply(keys,function(key) {
    val <- out[[key]]
    if(is.data.frame(val)) {
      if(!all(c("label","probability") %in% names(val))) return("")
      return(paste0("<h4>",.ru_w3_escape(key),"</h4>",
         "<ul>",paste0("<li>",vapply(seq_len(nrow(val)),function(i)
           paste0(.ru_w3_escape(val$label[i]),": ",.ru_w3_escape(val$probability[i])),
         character(1)),"</li>",collapse=""),"</ul>"))
    }
    paste0("<p><strong>",.ru_w3_escape(gsub("_"," ",key,fixed=TRUE)),":</strong> ",
           .ru_w3_escape(val),"</p>")
  },character(1)),collapse="")
}
.ru_w3_render <- function(lesson, open = TRUE) {
  if(!is.list(lesson) || !identical(lesson$schema_version,"ru.guided.v1"))
    stop("Expected a ru.guided.v1 teaching object.",call.=FALSE)
  statuses <- c("SOLVED","GUIDED_REFERENCE","NEEDS_INPUT","UNSUPPORTED","INVALID")
  if(!is.character(lesson$status) || length(lesson$status)!=1L ||
     is.na(lesson$status) || !lesson$status %in% statuses)
    stop("Unsupported guided lesson status.",call.=FALSE)
  if(!is.logical(open) || length(open)!=1L || is.na(open))
    stop("'open' must be TRUE or FALSE.",call.=FALSE)
  html <- .ru_w3_html(lesson)
  folder <- file.path(tempdir(),"rulearn-guided")
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  # The only script is a fixed, installed, local clipboard-only asset.
  asset <- system.file("www","ru-w3-copy.js",package="rulearn")
  if(!nzchar(asset) || !file.exists(asset) ||
     !isTRUE(file.copy(asset,file.path(folder,"ru-w3-copy.js"),overwrite=TRUE)))
    stop("Installed local copy-button asset is unavailable.",call.=FALSE)
  # A fixed basename prevents a question from controlling paths.
  path <- tempfile(pattern="guided-",tmpdir=folder,fileext=".html")
  writeLines(html,path,useBytes=TRUE)
  capability <- "NOT_REQUESTED"
  opened <- FALSE
  reason <- lesson$reason_code
  if(isTRUE(open)) {
    ready <- tryCatch(isTRUE(.ru_rstudio_ready("viewer")),error=function(e) FALSE)
    capability <- if(ready) "AVAILABLE" else "UNAVAILABLE"
    if(ready) {
      opened <- tryCatch({
        rstudioapi::viewer(path)
        TRUE
      },error=function(e) FALSE)
      if(!opened) {
        capability <- "VIEWER_FAILED"
        reason <- "VIEWER_LAUNCH_FAILED"
      }
    } else reason <- "VIEWER_UNAVAILABLE"
  }
  list(status=lesson$status,opened=opened,capability_status=capability,
       reason_code=reason,html_path=path)
}