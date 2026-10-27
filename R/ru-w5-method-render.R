# W5 method selection -> offline RStudio teaching page.
# The frozen ru.w5.method-guide.v1 carries NO computed values or plots:
# never manufacture them, load user data, or evaluate the displayed code.

.ru_w5_html_escape <- function(x) {
  x <- paste(as.character(x), collapse = " ")
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  gsub("'", "&#39;", x, fixed = TRUE)
}

.ru_w5_html_scalar <- function(x, max_bytes = 4096L,
                               empty = FALSE) {
  is.character(x) && length(x) == 1L && !is.na(x) &&
    validUTF8(x) && nchar(x, type = "bytes") <= max_bytes &&
    (empty || nzchar(trimws(x)))
}

.ru_w5_html_text <- function(x, max_items = 32L, max_bytes = 4096L,
                             empty = TRUE) {
  is.character(x) && length(x) <= max_items && !anyNA(x) &&
    all(vapply(x, .ru_w5_html_scalar, logical(1L),
               max_bytes = max_bytes, empty = empty))
}

.ru_w5_html_validate <- function(guide) {
  required <- c(
    "schema_version", "status", "method_id", "question", "title",
    "required_inputs", "why_this_method", "assumptions", "steps",
    "interpretation", "cautions", "code_preview", "hints", "executed")
  if (!is.list(guide) ||
      !identical(class(guide), "list") ||
      !setequal(names(guide), required) ||
      anyDuplicated(names(guide)) ||
      !identical(guide$schema_version, "ru.w5.method-guide.v1") ||
      !.ru_w5_html_scalar(guide$status, 32L) ||
      !guide$status %in% c("GUIDED_REFERENCE","NEEDS_INPUT","UNSUPPORTED") ||
      !.ru_w5_html_scalar(guide$method_id, 80L) ||
      !grepl("^[a-z][a-z0-9_]{0,79}$", guide$method_id) ||
      !.ru_w5_html_scalar(guide$title, 256L) ||
      !(is.null(guide$question) ||
        .ru_w5_html_scalar(guide$question, 4096L, empty = TRUE)) ||
      !.ru_w5_html_text(guide$required_inputs, max_items = 32L,
                        max_bytes = 512L, empty = FALSE) ||
      !.ru_w5_html_text(guide$why_this_method, max_items = 12L,
                        max_bytes = 4096L) ||
      !.ru_w5_html_text(guide$assumptions, max_items = 32L,
                        max_bytes = 4096L) ||
      !.ru_w5_html_text(guide$steps, max_items = 32L,
                        max_bytes = 4096L) ||
      !.ru_w5_html_text(guide$interpretation, max_items = 16L,
                        max_bytes = 4096L) ||
      !.ru_w5_html_text(guide$cautions, max_items = 24L,
                        max_bytes = 4096L) ||
      !.ru_w5_html_scalar(guide$code_preview, 65536L, empty = TRUE) ||
      !identical(guide$executed, FALSE) ||
      !is.list(guide$hints) ||
      !identical(class(guide$hints), "list") ||
      !identical(names(guide$hints), paste0("H", 0:3)) ||
      !all(vapply(guide$hints, .ru_w5_html_scalar, logical(1L),
                  max_bytes = 4096L))) {
    stop("Expected the exact bounded ru.w5.method-guide.v1 contract.",
         call. = FALSE)
  }
  # Only a method in the fixed ru_apply dispatch can receive a method guide.
  # This is a fixed switch, never a callback from a question or R expression.
  allowed <- tryCatch(.ru_allowed_arguments(guide$method_id),
                      error = function(e) NULL)
  if (!is.character(allowed))
    stop("Method ID is not an installed ru_apply contract.", call. = FALSE)
  invisible(TRUE)
}

.ru_w5_html_paragraphs <- function(x, fallback) {
  if (!length(x) || !any(nzchar(trimws(x))))
    x <- fallback
  x <- x[nzchar(trimws(x))]
  paste0("<p>", vapply(x, .ru_w5_html_escape, character(1L)),
         "</p>", collapse = "\n")
}

.ru_w5_html_items <- function(x, ordered = FALSE, fallback) {
  if (!length(x) || !any(nzchar(trimws(x))))
    return(.ru_w5_html_paragraphs(fallback, fallback))
  x <- x[nzchar(trimws(x))]
  tag <- if (ordered) "ol" else "ul"
  paste0("<",tag,">",paste0("<li>",
         vapply(x, .ru_w5_html_escape, character(1L)),
         "</li>",collapse=""),"</",tag,">")
}

.ru_w5_html_section <- function(id, heading, body) {
  paste0("<section id='",id,"' aria-labelledby='",id,
         "-heading'><h2 id='",id,"-heading'>",
         .ru_w5_html_escape(heading),"</h2>",body,"</section>")
}

.ru_w5_html_inputs <- function(items) {
  if (!length(items)) {
    return(paste0("<p>Specific input roles are not supplied by this guide. ",
           "Verify required arguments in the installed method documentation ",
           "before running an example.</p>"))
  }
  rows <- vapply(seq_along(items), function(i) {
    paste0("<tr><th scope='row'>", i,"</th><td>",
           .ru_w5_html_escape(items[[i]]),"</td></tr>")
  }, character(1L))
  paste0("<div class='w5-scroll' role='region' tabindex='0' ",
         "aria-label='Required data and argument roles'>",
         "<table><caption>Required variables, dataset and parameter roles ",
         "(descriptions only; no data were loaded)</caption>",
         "<thead><tr><th scope='col'>Role</th><th scope='col'>",
         "Required input or column</th></tr></thead><tbody>",
         paste(rows,collapse=""),"</tbody></table></div>")
}

.ru_w5_html_hints <- function(hints) {
  paste(vapply(seq_along(hints), function(i) {
    label <- names(hints)[[i]]
    hint_title <- c("Start here","Identify the data roles",
                    "Choose the operation","Check and interpret")[[i]]
    paste0("<details><summary>",label,": ",hint_title,
           "</summary><p>",.ru_w5_html_escape(hints[[i]]),
           "</p></details>")
  }, character(1L)),collapse="")
}

.ru_w5_method_html <- function(guide) {
  .ru_w5_html_validate(guide)
  question <- if (is.null(guide$question) ||
                  !nzchar(trimws(guide$question))) {
    "<p>No specific student question was supplied; this is a method reference.</p>"
  } else {
    paste0("<blockquote>",.ru_w5_html_escape(guide$question),
           "</blockquote>")
  }
  status_note <- switch(guide$status,
    GUIDED_REFERENCE = paste0(
      "This method is a guide, not a completed analysis. No data were ",
      "loaded or computed and no plot was generated."),
    NEEDS_INPUT = paste0(
      "Additional data, named columns, parameters or design decisions ",
      "are required before calculating a result."),
    UNSUPPORTED = paste0(
      "This request is not an approved numerical workflow here. ",
      "No solved result or plot is claimed."))
  method_summary <- paste0(
    "<p class='w5-method-name'><strong>Selected canonical method: </strong>",
    "<code>",.ru_w5_html_escape(guide$method_id),"</code></p>",
    .ru_w5_html_paragraphs(guide$why_this_method,
          "No selection rationale is supplied. Confirm compatibility before use."))
  code_available <- nzchar(trimws(guide$code_preview))
  code_block <- if (code_available) {
    paste0("<p class='w5-note'>Example R source from the installed method guide. ",
           "This is not output for the submitted question. The source has ",
           "<strong>not been executed</strong>. Copying does not run R.</p>",
           "<div class='w5-copy-toolbar'><button type='button' ",
           "id='w3-copy-code' aria-describedby='w3-copy-status'>",
           "Copy R code</button><span id='w3-copy-status' role='status' ",
           "aria-live='polite'></span></div>",
           "<pre tabindex='0' aria-label='Selectable unexecuted R source'>",
           "<code id='w3-r-code'>",
           .ru_w5_html_escape(guide$code_preview),"</code></pre>")
  } else {
    paste0("<p>No verified R code example is provided for this ",
           "method and request.</p>")
  }
  visual_note <- paste0(
    "<p>No numerical results, units, statistical tables or figures are ",
    "available in this method-selection guide. The display deliberately ",
    "does not invent sample data, units, significance values, distributions ",
    "or chart points. Run the appropriate method on explicitly supplied ",
    "data and check the returned values before interpreting them.</p>")
  nav <- paste0(
    "<nav aria-label='Guide sections'>",
    "<a href='#w5-method'>Method choice</a>",
    "<a href='#w5-inputs'>Required data</a>",
    "<a href='#w5-assumptions'>Assumptions</a>",
    "<a href='#w5-steps'>Steps</a>",
    "<a href='#w5-code'>R example</a>",
    "<a href='#w5-meaning'>Interpretation</a>",
    "<a href='#w5-hints'>Hints</a></nav>")
  css <- paste0(
    "*{box-sizing:border-box}",
    "body{margin:0;color:#18313e;background:#f4f8fa;",
    "font:16px/1.6 system-ui,-apple-system,sans-serif}",
    ".w5-wrap{max-width:1020px;margin:auto;padding:clamp(12px,3vw,32px)}",
    "h1{font-size:clamp(1.5rem,4vw,2.5rem);line-height:1.2}",
    "h2{font-size:1.3rem;line-height:1.3}",
    "section{background:#fff;border:1px solid #bbcdd6;border-radius:10px;",
    "padding:clamp(12px,2.5vw,24px);margin:16px 0}",
    "nav{display:flex;flex-wrap:wrap;gap:8px}",
    "nav a{color:#13547a}",
    "a:focus-visible,button:focus-visible,summary:focus-visible,",
    "pre:focus-visible,.w5-scroll:focus-visible{outline:3px solid #ad4c03;",
    "outline-offset:3px}",
    "blockquote{border-left:4px solid #326a83;background:#eaf2f6;",
    "padding:10px 16px;margin:10px 0;overflow-wrap:anywhere}",
    ".w5-status{border-left:5px solid #3f687b;background:#e6f0f4;",
    "padding:12px;font-weight:650}",
    ".w5-method-name code{overflow-wrap:anywhere}",
    "table{width:100%;border-collapse:collapse;",
    "font-variant-numeric:tabular-nums}",
    "th,td{padding:8px;text-align:left;border-bottom:1px solid #d2e0e8}",
    "thead th{background:#e5eef2}",
    ".w5-scroll{overflow-x:auto}",
    ".w5-note{color:#304e5d}",
    ".w5-copy-toolbar{display:flex;gap:12px;align-items:center;",
    "flex-wrap:wrap;margin:10px 0}",
    "button{font:inherit;border:2px solid #16577a;border-radius:5px;",
    "padding:8px 16px;color:#fff;background:#16577a;cursor:pointer}",
    "button:hover{background:#0e3a54}",
    "pre{white-space:pre;overflow:auto;background:#172a35;",
    "color:#f5f9fb;border-radius:7px;padding:16px}",
    "details{border:1px solid #b9cad3;border-radius:7px;",
    "margin:9px 0;padding:9px}",
    "summary{cursor:pointer;font-weight:650}",
    "@media(max-width:400px){body{font-size:15px}",
    "section{padding:12px}th,td{padding:5px}",
    "table{font-size:.85rem}}")
  sections <- paste0(
    .ru_w5_html_section("w5-question","Your question",question),
    .ru_w5_html_section("w5-method","Selected method and why it fits",
      method_summary),
    .ru_w5_html_section("w5-inputs","Data and variables required",
      paste0(.ru_w5_html_inputs(guide$required_inputs),
             "<p>No dataset or column is selected automatically.",
             " Supply the actual data.frame and column roles explicitly ",
             "when you decide to execute the method.</p>")),
    .ru_w5_html_section("w5-assumptions","Assumptions and study design",
      .ru_w5_html_items(guide$assumptions,fallback=
        "No assumption details supplied; do not assume the design is verified.")),
    .ru_w5_html_section("w5-steps","Method walkthrough",
      paste0("<p>Concise direction: review the selected method, its required ",
        "inputs, and assumptions above.</p>",
        "<details open><summary>Beginner: step-by-step instructions ",
        "(collapse for concise view)</summary>",
        .ru_w5_html_items(guide$steps, ordered=TRUE,
          fallback="No detailed steps are supplied for this method."),
        "</details>")),
    .ru_w5_html_section("w5-code","Run this in R",code_block),
    .ru_w5_html_section("w5-output","Computed results and visualizations",
      visual_note),
    .ru_w5_html_section("w5-meaning","How to interpret a result",
      .ru_w5_html_paragraphs(guide$interpretation,
        "Interpret only after the method has been run on verified data.")),
    .ru_w5_html_section("w5-cautions","Limitations and cautions",
      .ru_w5_html_items(guide$cautions,
        fallback="Check the model and the validity of your data before use.")),
    .ru_w5_html_section("w5-hints","Help me get unstuck",
      .ru_w5_html_hints(guide$hints)))
  paste0("<!doctype html><html lang='en'><head>",
         "<meta charset='UTF-8'><meta name='viewport' ",
         "content='width=device-width,initial-scale=1'>",
         "<meta http-equiv='Content-Security-Policy' content=\"",
         "default-src 'none'; style-src 'unsafe-inline'; script-src 'self'; ",
         "connect-src 'none'; img-src 'none'; object-src 'none'; ",
         "base-uri 'none'; form-action 'none'\">",
         "<title>",.ru_w5_html_escape(guide$title),
         " - RU method guide</title>",
         "<style>",css,"</style></head><body>",
         "<main class='w5-wrap' id='main-content'>",
         "<a href='#w5-question'>Skip to the student question</a>",
         "<header><p>R-u-learning-yet | Offline statistics and geography</p>",
         "<h1>",.ru_w5_html_escape(guide$title),"</h1>",
         "<p class='w5-status' role='status'>",
         .ru_w5_html_escape(guide$status),": ",
         .ru_w5_html_escape(status_note),"</p>",nav,"</header>",
         sections,
         "<footer><p>Guide only; no method executed and no remote requests. ",
         "Use the Copy control to transfer source, or select it manually. ",
         "Verify dataset, units, design, and permissions before running.</p>",
         "</footer></main>",
         if (code_available)
           "<script defer src='ru-w3-copy.js'></script>" else "",
         "</body></html>")
}

.ru_w5_method_render <- function(guide, open = TRUE) {
  if (!is.logical(open) || length(open) != 1L || is.na(open))
    stop("'open' must be TRUE or FALSE.", call. = FALSE)
  if (is.null(guide))
    return(list(status="UNSUPPORTED",opened=FALSE,
                capability_status="NO_GUIDE",
                html_path=NULL,reason_code="NO_METHOD_GUIDE"))
  html <- .ru_w5_method_html(guide)
  folder <- file.path(tempdir(),"rulearn-w5-method-guide")
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  if (nzchar(trimws(guide$code_preview))) {
    asset <- system.file("www","ru-w3-copy.js",package="rulearn")
    if (!nzchar(asset) || !file.exists(asset) ||
        !isTRUE(file.copy(asset,file.path(folder,"ru-w3-copy.js"),
                          overwrite=TRUE)))
      stop("The installed offline clipboard asset is unavailable.",
           call. = FALSE)
  }
  # The question and method ID never control a filesystem path.
  path <- tempfile(pattern="method-guide-",tmpdir=folder,
                   fileext=".html")
  writeLines(html,path,useBytes=TRUE)
  cap <- "NOT_REQUESTED"
  opened <- FALSE
  reason <- if (guide$status=="GUIDED_REFERENCE")
    "GUIDE_ONLY_NOT_EXECUTED" else guide$status
  if (isTRUE(open)) {
    ready <- tryCatch(isTRUE(.ru_rstudio_ready("viewer")),
                      error=function(e) FALSE)
    cap <- if (ready) "AVAILABLE" else "UNAVAILABLE"
    if (ready) {
      opened <- tryCatch({
        rstudioapi::viewer(path)
        TRUE
      },error=function(e) FALSE)
      if (!opened) {
        cap <- "VIEWER_FAILED"
        reason <- "VIEWER_LAUNCH_FAILED"
      }
    } else reason <- "VIEWER_UNAVAILABLE"
  }
  list(status=guide$status,opened=opened,
       capability_status=cap,html_path=path,
       reason_code=reason)
}