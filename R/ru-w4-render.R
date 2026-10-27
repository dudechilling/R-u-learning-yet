# W4 question-specific local Viewer; A1/A3 compute, A2 explains.
# This module never parses the student question as code or calculates statistics.

.ru_w4_html_escape <- function(x) {
  x <- paste(as.character(x), collapse = " ")
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  gsub("'", "&#39;", x, fixed = TRUE)
}

.ru_w4_html_scalar <- function(x, max_bytes = 65536L) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    validUTF8(x) && nchar(x, type = "bytes") <= max_bytes
}

.ru_w4_html_id <- function(x) {
  .ru_w4_html_scalar(x, 64L) &&
    grepl("^[a-z][a-z0-9_]{0,63}$", x)
}

.ru_w4_html_strings <- function(x, depth = 0L) {
  if (is.null(x) || !length(x)) return(character())
  if (depth > 4L || is.data.frame(x) || is.function(x) ||
      is.environment(x) || is.language(x) || is.object(x))
    stop("Invalid W4 instructional text.", call. = FALSE)
  if (is.list(x))
    return(unlist(lapply(x, .ru_w4_html_strings, depth = depth + 1L),
                  use.names = FALSE))
  if (!(is.character(x) || is.logical(x) || is.numeric(x)) ||
      anyNA(x))
    stop("Invalid W4 instructional text.", call. = FALSE)
  z <- as.character(x)
  if (!all(vapply(z, .ru_w4_html_scalar, logical(1L),
                  max_bytes = 65536L)))
    stop("Invalid W4 instructional text.", call. = FALSE)
  z[nzchar(trimws(z))]
}

.ru_w4_html_paragraphs <- function(x, fallback = "Not supplied for this question.") {
  v <- .ru_w4_html_strings(x)
  if (!length(v)) v <- fallback
  paste0("<p>", vapply(v, .ru_w4_html_escape, character(1L)),
         "</p>", collapse = "\n")
}

.ru_w4_html_list <- function(x, ordered = FALSE,
                             fallback = "Not supplied for this question.") {
  v <- .ru_w4_html_strings(x)
  if (!length(v)) return(.ru_w4_html_paragraphs(fallback))
  tag <- if (ordered) "ol" else "ul"
  paste0("<", tag, ">", paste0("<li>",
    vapply(v, .ru_w4_html_escape, character(1L)),
    "</li>", collapse = ""), "</", tag, ">")
}

.ru_w4_html_section <- function(id, title, body) {
  paste0("<section id='", id, "' aria-labelledby='", id,
         "-title'><h2 id='", id, "-title'>",
         .ru_w4_html_escape(title), "</h2>", body, "</section>")
}

.ru_w4_html_number <- function(x) {
  # Round-trip representation of the already calculated IEEE-754 double.
  # No recomputation or arbitrary invented display units.
  sprintf("%.17g", x)
}

.ru_w4_html_payload <- function(lesson) {
  status <- lesson$status
  if (!identical(status, "SOLVED")) {
    code <- lesson$runnable_code
    if (!is.null(code) &&
        (length(.ru_w4_html_strings(code)) > 0L))
      stop("Non-solved W4 lessons cannot contain executable code.", call. = FALSE)
    output <- lesson$expected_output
    if (is.list(output) && is.list(output$answer) &&
        length(output$answer))
      stop("Non-solved W4 lessons cannot contain numerical answers.", call. = FALSE)
    return(NULL)
  }
  out <- lesson$expected_output
  if (!is.list(out) || !is.list(out$answer) ||
      !identical(out$answer$schema_version, "ru.w4.answer.v1") ||
      !is.character(out$requested_outputs) ||
      length(out$requested_outputs) < 1L ||
      anyNA(out$requested_outputs) ||
      anyDuplicated(out$requested_outputs) ||
      !all(vapply(out$requested_outputs, .ru_w4_html_id, logical(1L))))
    stop("W4 lesson lacks an exact typed solved answer.", call. = FALSE)
  if (!is.null(lesson$requested_outputs) &&
      !identical(lesson$requested_outputs, out$requested_outputs))
    stop("W4 requested outputs disagree with computed results.", call. = FALSE)
  ans <- out$answer
  required <- c("schema_version","quantities","table",
                "table_output_id","method_note")
  if (!setequal(names(ans), required) || anyDuplicated(names(ans)) ||
      !.ru_w4_html_scalar(ans$method_note, 2048L))
    stop("Invalid W4 answer contract.", call. = FALSE)
  q <- ans$quantities
  if (!is.data.frame(q) ||
      !identical(class(q), "data.frame") ||
      !identical(names(q), c("output_id","label","value","units")) ||
      nrow(q) > 1024L ||
      !is.character(q$output_id) || !is.character(q$label) ||
      !is.double(q$value) || !is.character(q$units) ||
      anyNA(q) || any(!is.finite(q$value)) ||
      anyDuplicated(q$output_id) ||
      !all(vapply(q$output_id, .ru_w4_html_id, logical(1L))) ||
      !all(nzchar(q$label)) ||
      !all(vapply(q$label, .ru_w4_html_scalar, logical(1L), max_bytes=256L)) ||
      !all(vapply(q$units, .ru_w4_html_scalar, logical(1L), max_bytes=128L)))
    stop("Invalid W4 numerical quantities.", call. = FALSE)
  tab <- ans$table
  tab_id <- ans$table_output_id
  if (!is.character(tab_id) || length(tab_id) != 1L)
    stop("Invalid W4 table identifier.", call. = FALSE)
  if (is.null(tab)) {
    if (!identical(tab_id, NA_character_))
      stop("Invalid W4 absent-table contract.", call. = FALSE)
    tab_id <- character()
  } else {
    if (!.ru_w4_html_id(tab_id) ||
        !is.data.frame(tab) || !identical(class(tab), "data.frame") ||
        nrow(tab) > 20000L || ncol(tab) < 1L || ncol(tab) > 64L ||
        nrow(tab) * ncol(tab) > 200000L ||
        is.null(names(tab)) || anyDuplicated(names(tab)) ||
        !all(vapply(names(tab), .ru_w4_html_id, logical(1L))) ||
        !all(vapply(tab, function(col)
          (is.double(col) || is.integer(col)) && !is.object(col) &&
          !anyNA(col) && all(is.finite(col)), logical(1L))))
      stop("Invalid W4 finite numerical table.", call. = FALSE)
  }
  all_ids <- c(q$output_id, tab_id)
  if (anyDuplicated(all_ids) ||
      !setequal(all_ids, out$requested_outputs) ||
      length(all_ids) != length(out$requested_outputs))
    stop("W4 numeric outputs do not match requested operations.", call. = FALSE)
  if (!.ru_w4_html_scalar(lesson$runnable_code) ||
      !nzchar(lesson$runnable_code))
    stop("Solved W4 lesson must contain its unexecuted R source.", call. = FALSE)
  ans
}

.ru_w4_html_quantities <- function(ans) {
  q <- ans$quantities
  if (!nrow(q)) return("<p>No scalar outputs were requested.</p>")
  rows <- vapply(seq_len(nrow(q)), function(i) {
    id <- q$output_id[[i]]
    label <- q$label[[i]]
    v <- .ru_w4_html_number(q$value[[i]])
    units <- if (nzchar(q$units[[i]])) q$units[[i]] else
      "Not specified by computation"
    paste0("<tr><th scope='row'>", .ru_w4_html_escape(label),
           "</th><td><code>", .ru_w4_html_escape(id),
           "</code></td><td class='w4-value'>",
           .ru_w4_html_escape(v), "</td><td>",
           .ru_w4_html_escape(units), "</td></tr>")
  }, character(1L))
  paste0("<div class='w4-table-scroll' role='region' tabindex='0' ",
         "aria-label='Verified numerical results table'>",
         "<table><caption>Computed results for the requested operations</caption>",
         "<thead><tr><th scope='col'>Quantity</th><th scope='col'>Output ID</th>",
         "<th scope='col'>Verified value</th><th scope='col'>Units</th></tr></thead>",
         "<tbody>", paste(rows, collapse = ""), "</tbody></table></div>")
}

.ru_w4_html_data_table <- function(ans) {
  if (is.null(ans$table)) return("")
  tab <- ans$table
  shown <- min(nrow(tab), 200L)
  head_txt <- paste0("<thead><tr>", paste0("<th scope='col'>",
                vapply(names(tab), .ru_w4_html_escape, character(1L)),
                "</th>", collapse=""), "</tr></thead>")
  rows <- if (!shown) "" else paste(vapply(seq_len(shown), function(i) {
    paste0("<tr>", paste0("<td class='w4-value'>",
      vapply(tab, function(col) .ru_w4_html_escape(
        .ru_w4_html_number(col[[i]])), character(1L)),
      "</td>", collapse=""), "</tr>")
  }, character(1L)), collapse="")
  note <- if (nrow(tab)>shown) {
    paste0("<p>Displaying the first ",shown," of ",
           nrow(tab)," supplied rows. The complete computed data ",
           "remain in the typed answer; this preview is explicitly truncated.</p>")
  } else ""
  paste0("<h3>Supplied computed table</h3>",
         "<div class='w4-table-scroll' role='region' tabindex='0' ",
         "aria-label='Computed output table'>",
         "<table><caption>",.ru_w4_html_escape(
           gsub("_"," ",ans$table_output_id,fixed=TRUE)),
         " (from the verified computation)</caption>",
         head_txt,"<tbody>",rows,"</tbody></table></div>",note)
}

.ru_w4_html_plot <- function(ans) {
  q <- ans$quantities
  # Only verified scalars already defined on a 0-1 scale may be visualized.
  # A mean, coefficient, variance or entire distribution cannot be
  # reconstructed from a single computed scalar.
  permitted <- c("probability","union","conditional","complement",
                 "p_value","r_squared")
  keep <- which(q$output_id %in% permitted & q$value >= 0 &
                q$value <= 1)
  if (!length(keep))
    return(paste0("<p>No plot is shown: the computation did not supply a verified ",
           "probability-scale result or a plot-ready distribution. ",
           "No numerical curve or data points were invented.</p>"))
  lines <- vapply(keep, function(i) {
    val <- .ru_w4_html_number(q$value[[i]])
    what <- q$label[[i]]
    id <- q$output_id[[i]]
    suffix <- if (id == "p_value")
      " (tail area under the stated null model, not the probability that the null is true)"
    else if (id == "r_squared")
      " (coefficient of determination, not evidence of causation)"
    else " (probability on the interval zero to one)"
    phrase <- paste0(what, suffix)
    paste0("<li><label>", .ru_w4_html_escape(phrase),
      "<meter min='0' max='1' value='", .ru_w4_html_escape(val),
      "' aria-label='", .ru_w4_html_escape(paste0(phrase,
      ": ",val," out of one")), "'>", .ru_w4_html_escape(val),
      "</meter></label><span class='w4-value'>",.ru_w4_html_escape(val),
      "</span></li>")
  },character(1L))
  paste0("<figure aria-labelledby='w4-meter-caption'><figcaption ",
         "id='w4-meter-caption'>Scale of supplied verified 0-1 ",
         "quantities. Numerical labels provide a complete text alternative.",
         "</figcaption><ul class='w4-probability-bars'>",
         paste(lines,collapse=""),"</ul></figure>")
}

.ru_w4_html_hints <- function(x) {
  if (!is.list(x) || !identical(names(x),paste0("H",0:3)))
    stop("W4 lesson must supply all H0-H3 hints.",call.=FALSE)
  paste(vapply(seq_along(x),function(i) {
    label <- names(x)[[i]]
    paste0("<details><summary>",label," - ",
      c("First direction","Model clue","Calculation guidance",
        "Worked reasoning")[[i]],"</summary>",
      .ru_w4_html_paragraphs(x[[i]]),"</details>")
  },character(1L)),collapse="")
}

.ru_w4_html <- function(lesson) {
  if (!is.list(lesson) || !identical(lesson$schema_version,"ru.guided.v1") ||
      !.ru_w4_html_scalar(lesson$status,32L) ||
      !lesson$status %in% c("SOLVED","GUIDED_REFERENCE","NEEDS_INPUT",
                            "UNSUPPORTED","INVALID") ||
      !.ru_w4_html_scalar(lesson$question,4096L))
    stop("Expected a bounded ru.guided.v1 W4 teaching object.",call.=FALSE)
  ans <- .ru_w4_html_payload(lesson)
  solved <- identical(lesson$status,"SOLVED")
  title <- if (.ru_w4_html_scalar(lesson$title,256L) &&
               nzchar(lesson$title)) lesson$title else
    "Question-specific statistics guide"
  level <- if (identical(lesson$presentation_level,"concise"))
    "concise" else "beginner"
  outputs <- if (solved) lesson$expected_output$requested_outputs else
    lesson$requested_outputs
  if (is.null(outputs)) outputs <- character()
  if (!is.character(outputs) || anyNA(outputs) ||
      !all(vapply(outputs,.ru_w4_html_id,logical(1L))))
    stop("Invalid W4 requested outputs.",call.=FALSE)
  goal <- if (length(outputs))
    .ru_w4_html_list(gsub("_"," ",outputs,fixed=TRUE)) else
    .ru_w4_html_paragraphs("Determine what information and model are needed before calculating.")
  details <- .ru_w4_html_paragraphs(lesson$explanation_sections)
  if (identical(level,"concise"))
    details <- paste0("<details><summary>Expand conceptual explanation</summary>",
                      details,"</details>")
  code <- if (solved) paste0(
      "<p>R code preview: not executed. The Copy button only transfers text.",
      " Paste it into your own R session to run after reviewing assumptions.</p>",
      "<div class='w4-code-tools'><button type='button' id='w3-copy-code' ",
      "aria-describedby='w3-copy-status'>Copy R code</button>",
      "<span role='status' aria-live='polite' id='w3-copy-status'></span></div>",
      "<pre tabindex='0' aria-label='Copyable unexecuted R code'>",
      "<code id='w3-r-code'>",.ru_w4_html_escape(lesson$runnable_code),
      "</code></pre>") else
    "<p>No validated numerical R code is available for this question.</p>"
  results <- if(solved)
    paste0(.ru_w4_html_quantities(ans), .ru_w4_html_data_table(ans),
           "<h3>Result visualization</h3>",.ru_w4_html_plot(ans),
           "<h3>Method note from the computation</h3>",
           .ru_w4_html_paragraphs(ans$method_note)) else
    "<p>No verified numerical answer is available. No chart or computed result is claimed.</p>"
  limitation <- if(solved)
    "These are locally computed results under the stated conditions. R source remains unexecuted in the student's session. Assumptions are not established empirical facts."
  else paste0("Status ",lesson$status,"; reason ",
              if (.ru_w4_html_scalar(lesson$reason_code,128L))
                lesson$reason_code else "NOT_AVAILABLE",
              ". This question has not been solved numerically.")
  css <- paste0(
    "*{box-sizing:border-box}body{margin:0;background:#f6f9fb;color:#17303e;",
    "font:16px/1.55 system-ui,sans-serif}",
    ".w4-wrap{max-width:1050px;margin:auto;padding:clamp(12px,3vw,32px)}",
    "header{padding:12px 0}h1{font-size:clamp(1.5rem,3vw,2.4rem);line-height:1.2}",
    "h2{font-size:1.3rem}h3{font-size:1.1rem}section{background:white;",
    "border:1px solid #bfced5;border-radius:10px;padding:clamp(12px,2vw,24px);",
    "margin:14px 0}nav{display:flex;flex-wrap:wrap;gap:10px}",
    "a{color:#09567c}a:focus-visible,button:focus-visible,summary:focus-visible,",
    "pre:focus-visible,.w4-table-scroll:focus-visible{outline:3px solid #b35404;",
    "outline-offset:3px}blockquote{margin-left:0;padding:10px 16px;",
    "border-left:4px solid #267492;background:#edf4f7;overflow-wrap:anywhere}",
    ".w4-status{font-weight:700;padding:10px;border-left:5px solid #375e73;",
    "background:#e8f0f5}table{border-collapse:collapse;width:100%;",
    "font-variant-numeric:tabular-nums}th,td{padding:9px;text-align:left;",
    "border-bottom:1px solid #d4e0e5}thead th{background:#e9eff3}",
    ".w4-value{font-variant-numeric:tabular-nums;overflow-wrap:anywhere}",
    ".w4-table-scroll{overflow:auto}pre{white-space:pre;overflow:auto;",
    "background:#172936;color:#f7f9fa;border-radius:6px;padding:14px}",
    "button{font:inherit;padding:8px 14px;background:#17567b;color:white;",
    "border:2px solid #17567b;border-radius:6px;cursor:pointer}",
    "button:hover{background:#0e3e5d}.w4-code-tools{display:flex;",
    "align-items:center;gap:12px;flex-wrap:wrap;margin:12px 0}",
    "details{padding:9px;border:1px solid #c0cbd0;border-radius:6px;margin:8px 0}",
    "summary{cursor:pointer;font-weight:600}",
    ".w4-probability-bars{list-style:none;padding:0}",
    ".w4-probability-bars li{display:flex;gap:12px;align-items:center;",
    "flex-wrap:wrap;margin:9px 0}.w4-probability-bars label{flex:1;min-width:0}",
    ".w4-probability-bars meter{display:block;width:100%;height:1.1rem}",
    "@media(max-width:400px){body{font-size:15px}th,td{padding:5px}",
    "table{font-size:.82rem}section{padding:12px}}")
  sections <- paste0(
    .ru_w4_html_section("w4-question","Your question",
      paste0("<blockquote>",.ru_w4_html_escape(lesson$question),"</blockquote>")),
    .ru_w4_html_section("w4-goal","What we are trying to find",goal),
    .ru_w4_html_section("w4-concepts","What this means",details),
    .ru_w4_html_section("w4-assumptions","Model and assumptions",
                        .ru_w4_html_list(lesson$assumptions)),
    .ru_w4_html_section("w4-steps","Step-by-step method",
                        .ru_w4_html_list(lesson$step_by_step,ordered=TRUE)),
    .ru_w4_html_section("w4-results","Computed results and visualization",results),
    .ru_w4_html_section("w4-code","Run this in R",code),
    .ru_w4_html_section("w4-interpretation","Interpret your result",
                        paste0(.ru_w4_html_paragraphs(lesson$interpretations),
                          "<p>",.ru_w4_html_escape(limitation),"</p>")),
    .ru_w4_html_section("w4-checks","Verification and limitations",
                        .ru_w4_html_list(lesson$checks)),
    .ru_w4_html_section("w4-hints","Help me get unstuck",
                        .ru_w4_html_hints(lesson$hints)),
    .ru_w4_html_section("w4-edit","What to edit",
                        .ru_w4_html_list(lesson$change_this)),
    .ru_w4_html_section("w4-transfer","Try it yourself",
                        .ru_w4_html_paragraphs(lesson$transfer_question)))
  paste0("<!doctype html><html lang='en'><head>",
         "<meta charset='UTF-8'><meta name='viewport' ",
         "content='width=device-width,initial-scale=1'>",
         "<meta http-equiv='Content-Security-Policy' content=\"",
         "default-src 'none'; style-src 'unsafe-inline'; script-src 'self'; ",
         "connect-src 'none'; img-src 'none'; object-src 'none'; ",
         "base-uri 'none'; form-action 'none'\">",
         "<title>",.ru_w4_html_escape(title)," - RU</title>",
         "<style>",css,"</style></head><body>",
         "<main class='w4-wrap'><a href='#w4-question'>Skip to question</a>",
         "<header><p>R-u-learning-yet | Local ",level,
         " statistics guide</p><h1>",.ru_w4_html_escape(title),"</h1>",
         "<p class='w4-status' role='status'>",
         .ru_w4_html_escape(lesson$status),"</p>",
         "<nav aria-label='Sections in this lesson'>",
         "<a href='#w4-goal'>Goal</a><a href='#w4-concepts'>Concepts</a>",
         "<a href='#w4-steps'>Method</a><a href='#w4-results'>Results</a>",
         "<a href='#w4-code'>R code</a><a href='#w4-hints'>Hints</a>",
         "<a href='#w4-transfer'>Practice</a></nav></header>",
         sections,
         "<footer><p>All content stays local to this R session. No remote ",
         "service, automatic publication or student-code execution.</p></footer>",
         "</main><script defer src='ru-w3-copy.js'></script></body></html>")
}

.ru_w4_render <- function(lesson, open = TRUE) {
  if (!is.logical(open) || length(open) != 1L || is.na(open))
    stop("'open' must be TRUE or FALSE.",call.=FALSE)
  # Generate bounded local content, independent of RStudio availability.
  markup <- .ru_w4_html(lesson)
  folder <- file.path(tempdir(),"rulearn-w4-guided")
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  asset <- system.file("www","ru-w3-copy.js",package="rulearn")
  if (!nzchar(asset) || !file.exists(asset) ||
      !isTRUE(file.copy(asset,file.path(folder,"ru-w3-copy.js"),
                        overwrite=TRUE)))
    stop("Verified installed offline Copy asset is unavailable.",call.=FALSE)
  path <- tempfile(pattern="guided-w4-",tmpdir=folder,fileext=".html")
  writeLines(markup,path,useBytes=TRUE)
  capability <- "NOT_REQUESTED"
  opened <- FALSE
  reason <- if (.ru_w4_html_scalar(lesson$reason_code,128L))
    lesson$reason_code else "NOT_AVAILABLE"
  if (isTRUE(open)) {
    ready <- tryCatch(isTRUE(.ru_rstudio_ready("viewer")),
                      error=function(e) FALSE)
    capability <- if (ready) "AVAILABLE" else "UNAVAILABLE"
    if (ready) {
      opened <- tryCatch({
        rstudioapi::viewer(path)
        TRUE
      }, error=function(e) FALSE)
      if (!opened) {
        capability <- "VIEWER_FAILED"
        reason <- "VIEWER_LAUNCH_FAILED"
      }
    } else reason <- "VIEWER_UNAVAILABLE"
  }
  list(status=lesson$status,opened=opened,
       capability_status=capability,reason_code=reason,
       html_path=path)
}