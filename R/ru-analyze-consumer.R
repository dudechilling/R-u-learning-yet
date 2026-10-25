# RU W2-R2 numeric Analyze consumer. The e3f4f42 engine remains the only
# statistical/identity/export authority. Opening this app never executes data.

.ru_an_consumer_data <- function(data) {
  if (is.null(data))
    return(list(frame=NULL, context=NULL,reason="CURRENT_DATA_REQUIRED"))
  if (is.data.frame(data))
    return(list(frame=data, context=NULL,reason=NULL))
  if (is.list(data) && identical(class(data),"list") &&
      setequal(names(data),c("data","source_context")) &&
      is.data.frame(data$data))
    return(list(frame=data$data,context=data$source_context,reason=NULL))
  list(frame=NULL,context=NULL,reason="INVALID_DATA_INPUT")
}
.ru_an_consumer_default <- function() {
  list(schema_version="1.1-draft.v2",method_id="describe.numeric",
    operation="summary.only",parameters=list(report_nonfinite=TRUE),
    objective="describe",estimand="empirical_sample_distribution",
    outcome=NULL,predictors=NULL,grouping=NULL,unit_id=NULL,
    dependence="unknown",design="descriptive",sampling="not_applicable",
    missingness_policy="report",inference_target="sample_only",
    confidence_level=NULL,user_attestations=list())
}
.ru_an_consumer_breaks <- function(s) {
  if (!.ru_an_scalar(s) || !nzchar(trimws(s))) return(NULL)
  pieces <- strsplit(s,",",fixed=TRUE)[[1L]]
  if (length(pieces)<2L || any(!nzchar(trimws(pieces))))
    return(c(NA_real_,NA_real_))
  suppressWarnings(as.numeric(trimws(pieces)))
}
.ru_an_consumer_prepare <- function(data,spec=NULL,
                                    data_choice="",question="",outcome="",
                                    missingness_policy="report",
                                    consent="undecided",histogram_breaks="",
                                    histogram_scale="count",
                                    interval_closure="left_closed_right_open",
                                    include_lowest=TRUE) {
  if (!identical(data_choice,"provided"))
    return(.ru_an_reply("NEEDS_INPUT","DATA_SELECTION_REQUIRED"))
  incoming <- .ru_an_consumer_data(data)
  if (!is.null(incoming$reason))
    return(.ru_an_reply(if (incoming$reason=="CURRENT_DATA_REQUIRED")
      "NEEDS_INPUT" else "INVALID",incoming$reason))
  if (!.ru_an_scalar(question) || !question %in% c("summary","histogram"))
    return(.ru_an_reply("NEEDS_INPUT","QUESTION_SELECTION_REQUIRED"))
  if (!.ru_an_scalar(outcome))
    return(.ru_an_reply("NEEDS_INPUT","OUTCOME_REQUIRED"))
  if (!outcome %in% names(incoming$frame))
    return(.ru_an_reply("INVALID","COLUMN_ROLE_NOT_FOUND"))
  if (!.ru_an_scalar(missingness_policy) ||
      !missingness_policy %in% c("report","fail","complete_case_with_consent"))
    return(.ru_an_reply("INVALID","INVALID_MISSINGNESS_POLICY"))
  if (!.ru_an_scalar(consent) ||
      !consent %in% c("undecided","grant","deny"))
    return(.ru_an_reply("INVALID","INVALID_CONSENT_SELECTION"))
  base <- if (is.null(spec)) .ru_an_consumer_default() else spec
  if (!is.list(base) || !identical(class(base),"list") ||
      !setequal(names(base),.ru_an_spec_fields))
    return(.ru_an_reply("INVALID","MALFORMED_SPEC"))
  if (!identical(base$method_id,"describe.numeric"))
    return(ru_analyze_plan(base,incoming$frame,incoming$context))
  base$outcome <- outcome
  base$operation <- if (question=="summary") "summary.only" else
    "summary.histogram"
  base$missingness_policy <- missingness_policy
  # User must make a fresh explicit exclusion decision in this consumer.
  # Pre-existing spec attestations are not silently treated as this consent.
  base$user_attestations <- list()
  if (missingness_policy=="complete_case_with_consent" &&
      consent!="undecided") {
    base$user_attestations$missingness_exclusion_consent <-
      list(value=identical(consent,"grant"),source="user",revision=1L,
           captured_at=format(Sys.time(),"%Y-%m-%dT%H:%M:%S%z"))
  }
  if (question=="summary")
    base$parameters <- list(report_nonfinite=TRUE)
  else {
    breaks <- .ru_an_consumer_breaks(histogram_breaks)
    if (is.null(breaks))
      return(.ru_an_reply("NEEDS_INPUT","HISTOGRAM_BREAKS_REQUIRED"))
    base$parameters <- list(breaks=breaks,histogram_scale=histogram_scale,
      density_curve="none",report_nonfinite=TRUE,
      interval_closure=interval_closure,include_lowest=include_lowest)
  }
  ru_analyze_plan(base,incoming$frame,incoming$context)
}
.ru_an_consumer_plan_text <- function(plan) {
  if (is.null(plan))
    return(paste("NEEDS_INPUT  -  select a question, data and outcome.",
      "Inspect a plan before requesting code or a calculation.",
      "Nothing has been executed."))
  label <- paste0(plan$status,"  -  ",plan$reason)
  if (!identical(plan$status,"READY"))
    return(paste(label,"No computation is authorized in this state."))
  n <- plan$checked
  unit <- if (is.null(plan$measurement_unit)) "NOT_DECLARED" else
    plan$measurement_unit
  paste(c(label,paste0("Method: describe.numeric / ",plan$spec$operation,
     ". Outcome: ",plan$spec$outcome,". Declared unit: ",unit,"."),
     paste0("Raw rows: ",n$n_raw,"; observed: ",n$n_observed,
            "; missing: ",n$n_missing,"."),
     paste0("Missingness policy: ",plan$exclusion$policy,
            "; consented observed-case omissions: ",
            plan$exclusion$excluded_n,". Source data unchanged."),
     "Descriptive sample only: no population inference, independence,",
     "sampling representativeness or causal claim.",
     "READY means eligible for confirmation, NOT_EXECUTED."),
     collapse="\n")
}
.ru_an_consumer_result_text <- function(result) {
  if (is.null(result))
    return("NOT_EXECUTED  -  no successful calculation exists.")
  label <- paste0(result$status,"  -  ",result$reason)
  if (!identical(result$status,"SUCCEEDED"))
    return(paste(label,"No successful numerical result exists."))
  v <- result$value
  unit <- if (is.null(result$measurement_unit)) "unit NOT_DECLARED" else
    result$measurement_unit
  lines <- c(label,
    paste0("Observed mean: ",format(v$mean,digits=15)," (",unit,")"),
    paste0("Observed median: ",format(v$median,digits=15),
           "; sample SD: ",format(v$sd,digits=15)),
    paste0("Raw n=",v$n_raw,"; observed n=",v$n_observed,
           "; missing n=",v$n_missing))
  if (!is.null(v$histogram))
    lines <- c(lines,paste0("Histogram counts: ",
        paste(v$histogram$counts,collapse=", "),
        "; closure: ",v$histogram$closure))
  paste(c(lines,"Observed sample only, not a population estimate."),
        collapse="\n")
}
.ru_an_consumer_dependency_status <- function() {
  names <- c("shiny","bslib","digest")
  present <- vapply(names,requireNamespace,logical(1L),quietly=TRUE)
  if (all(present)) return(NULL)
  list(status="UNAVAILABLE",reason="ANALYZE_DEPENDENCIES_MISSING",
       missing_dependencies=names[!present],
       detail=paste("Local package dependencies unavailable:",
          paste(names[!present],collapse=", "),
          "No packages were installed or downloaded."))
}

#' Construct the question-first RU Analyze app (one descriptive family).
#' @param data A local ordinary data.frame or list(data=...,source_context=...).
#' @param spec Optional closed planner spec; incompatible methods refused.
#' @return A Shiny application object, not an automatically started server.
ru_analyze <- function(data=NULL,spec=NULL) {
  unavailable <- .ru_an_consumer_dependency_status()
  if (!is.null(unavailable)) return(unavailable)
  incoming <- .ru_an_consumer_data(data)
  columns <- if (!is.null(incoming$frame))
    names(incoming$frame) else character()
  outcome_choices <- c("Select outcome"="")
  if (length(columns))
    outcome_choices <- c(outcome_choices,stats::setNames(columns,columns))
  data_choices <- c("Select supplied data"="")
  if (!is.null(data))
    data_choices <- c(data_choices,"Use supplied local data"="provided")
  else data_choices <- c(data_choices,"No data attached"="none")

  ui <- bslib::page_sidebar(
    title="RU | Analyze a numeric question",
    theme=bslib::bs_theme(version=5),
    sidebar=bslib::sidebar(
      title="Question-first, observed sample only",
      shiny::selectInput("question_choice","1. What is your question?",
        choices=c("Choose question"="",
          "What is the typical observed value?"="summary",
          "How are observed readings distributed?"="histogram"),
        selected=""),
      shiny::selectInput("data_choice","2. Which data?",
        choices=data_choices,selected=""),
      shiny::selectInput("outcome_choice","3. Which numeric outcome?",
        choices=outcome_choices,selected=""),
      shiny::selectInput("missing_choice","4. Missing readings?",
        choices=c("Report missingness without exclusions"="report",
          "Fail if any outcome missing"="fail",
          "Complete cases only with my consent"="complete_case_with_consent"),
        selected="report"),
      shiny::selectInput("consent_choice",
        "5. Consent to omit missing outcomes?",
        choices=c("No decision"="undecided",
          "Yes, omit missing outcomes for this sample description"="grant",
          "No, do not exclude missing readings"="deny"),
        selected="undecided"),
      shiny::conditionalPanel("input.question_choice == 'histogram'",
        shiny::textInput("histogram_breaks",
          "Explicit histogram breaks (comma-separated)",value="",
          placeholder="e.g. 0,10,20,30"),
        shiny::selectInput("histogram_scale","Bin scale",
          choices=c("Count"="count","Density"="density")),
        shiny::selectInput("interval_closure","Bin boundaries",
          choices=c("Left closed"="left_closed_right_open",
                    "Right closed"="right_closed_left_open")),
        shiny::checkboxInput("include_lowest","Include extreme endpoint",TRUE)),
      shiny::actionButton("plan_btn","Inspect analysis plan",
                          class="btn-primary"),
      shiny::tags$p("No calculation starts when Analyze is opened."),
      width=330
    ),
    bslib::card(bslib::card_header("Current data and method"),
      shiny::tags$div(shiny::textOutput("data_info"),
          role="status","aria-live"="polite"),
      shiny::tags$div(shiny::verbatimTextOutput("plan_info"),
          role="status","aria-live"="polite")),
    bslib::card(bslib::card_header("Inspect code, not execution"),
      shiny::actionButton("preview_btn","Preview ordinary R code"),
      shiny::verbatimTextOutput("preview_info"),
      shiny::tags$div(shiny::verbatimTextOutput("code_info"),
          tabindex="0")),
    bslib::card(bslib::card_header("Execute only after confirmation"),
      shiny::checkboxInput("run_confirm",
        "I reviewed the method, exclusions and limitations. Run.",FALSE),
      shiny::actionButton("run_btn","Run confirmed calculation"),
      shiny::tags$div(shiny::verbatimTextOutput("result_info"),
          role="status","aria-live"="polite")),
    bslib::card(bslib::card_header("One-shot local export"),
      shiny::selectInput("export_kind","Export which artifact?",
        choices=c("Executed result"="result",
                  "Guarded code preview, NOT_EXECUTED"="code")),
      shiny::textInput("export_path",
        "New local file path; existing files are refused",value=""),
      shiny::checkboxInput("export_consent",
        "I authorize one export to this destination.",FALSE),
      shiny::actionButton("export_btn","Export with revalidation"),
      shiny::tags$div(shiny::verbatimTextOutput("export_info"),
          role="status","aria-live"="polite"),
      shiny::tags$p("Raw research rows cannot be exported through Analyze.")),
    shiny::tags$p("Only describe.numeric is implemented.",
       "Other families and population inference are unsupported.")
  )
  server <- function(input,output,session) {
    current_plan <- shiny::reactiveVal(NULL)
    code_preview <- shiny::reactiveVal(NULL)
    execution_result <- shiny::reactiveVal(NULL)
    export_receipt <- shiny::reactiveVal(NULL)
    export_scope <- shiny::reactiveVal(NULL)

    current_export_scope <- function() {
      p <- current_plan()
      r <- execution_result()
      list(path=input$export_path,kind=input$export_kind,
        plan_id=if (is.list(p)) p$plan_id else NULL,
        result_sha256=if (is.list(r)) r$result_sha256 else NULL)
    }
    # A consent checkbox is valid only for the exact destination, export type,
    # plan and result present when it was affirmatively checked.
    shiny::observeEvent(list(input$export_path,input$export_kind), {
      export_scope(NULL)
      shiny::updateCheckboxInput(session,"export_consent",value=FALSE)
    },ignoreInit=TRUE,priority=300)
    shiny::observeEvent(input$export_consent,{
      if (isTRUE(input$export_consent))
        export_scope(current_export_scope())
      else export_scope(NULL)
    },ignoreInit=TRUE,priority=100)

    current_input <- function() {
      if (!identical(input$data_choice,"provided")) return(NULL)
      if (!is.null(incoming$context))
        return(list(data=incoming$frame,source_context=incoming$context))
      incoming$frame
    }
    choices <- shiny::reactive(list(input$question_choice,
      input$data_choice,input$outcome_choice,input$missing_choice,
      input$consent_choice,input$histogram_breaks,input$histogram_scale,
      input$interval_closure,input$include_lowest))
    shiny::observeEvent(choices(),{
      current_plan(NULL)
      code_preview(NULL)
      execution_result(NULL)
      export_receipt(NULL)
      export_scope(NULL)
      shiny::updateCheckboxInput(session,"export_consent",value=FALSE)
    },ignoreInit=TRUE,priority=200)

    shiny::observeEvent(input$plan_btn,{
      plan <- tryCatch(.ru_an_consumer_prepare(data,spec,
         data_choice=input$data_choice,
         question=input$question_choice,
         outcome=input$outcome_choice,
         missingness_policy=input$missing_choice,
         consent=input$consent_choice,
         histogram_breaks=input$histogram_breaks,
         histogram_scale=input$histogram_scale,
         interval_closure=input$interval_closure,
         include_lowest=input$include_lowest),
         error=function(e) .ru_an_reply("INVALID","CONSUMER_INPUT_VALIDATION_FAILED"))
      current_plan(plan)
      code_preview(NULL)
      execution_result(NULL)
      export_receipt(NULL)
      export_scope(NULL)
      shiny::updateCheckboxInput(session,"export_consent",value=FALSE)
    },ignoreInit=TRUE)

    shiny::observeEvent(input$preview_btn,{
      plan <- current_plan()
      code_preview(if (is.null(plan))
        list(status="UNAVAILABLE",reason="PLAN_REQUIRED",code=NULL)
        else ru_analyze_code(plan))
    },ignoreInit=TRUE)

    shiny::observeEvent(input$run_btn,{
      plan <- current_plan()
      execution_result(if (is.null(plan) ||
        !identical(plan$status,"READY"))
        .ru_an_result("FAILED","PLAN_NOT_READY")
        else ru_analyze_execute(plan,current_input(),
          confirm=isTRUE(input$run_confirm)))
      export_receipt(NULL)
      export_scope(NULL)
      shiny::updateCheckboxInput(session,"export_consent",value=FALSE)
    },ignoreInit=TRUE)

    shiny::observeEvent(input$export_btn,{
      plan <- current_plan()
      kind <- input$export_kind
      result <- if (identical(kind,"result")) execution_result() else NULL
      response <- if (!isTRUE(input$export_consent))
        list(status="REFUSED",reason="EXPLICIT_EXPORT_CONSENT_REQUIRED")
      else if (is.null(export_scope()) ||
               !identical(export_scope(),current_export_scope()))
        list(status="REFUSED",reason="FRESH_DESTINATION_CONSENT_REQUIRED")
      else if (is.null(plan) || !identical(plan$status,"READY"))
        list(status="REFUSED",reason="PLAN_NOT_READY")
      else if (!.ru_an_scalar(input$export_path))
        list(status="REFUSED",reason="EXPORT_DESTINATION_REQUIRED")
      else if (is.null(kind) || !kind %in% c("code","result"))
        list(status="REFUSED",reason="EXPORT_TYPE_INVALID")
      else if (identical(kind,"result") &&
               (is.null(result) || !identical(result$status,"SUCCEEDED")))
        list(status="REFUSED",reason="SUCCESSFUL_RESULT_REQUIRED")
      else tryCatch({
        target <- .ru_an_authorize_export(input$export_path,plan,result,
                  include_data=FALSE,consent=TRUE)
        ru_analyze_export(plan,result,path=target,include_data=FALSE,
                          data=current_input())
      },error=function(e)
        list(status="REFUSED",reason="EXPORT_AUTHORIZATION_FAILED"))
      export_receipt(response)
      export_scope(NULL)
      shiny::updateCheckboxInput(session,"export_consent",value=FALSE)
    },ignoreInit=TRUE)

    output$data_info <- shiny::renderText({
      if (!identical(input$data_choice,"provided"))
        return("NEEDS_INPUT  -  choose the locally supplied dataset.")
      if (!is.null(incoming$reason))
        return(paste("INVALID",incoming$reason))
      d <- incoming$frame
      paste0("Selected local table: ",nrow(d)," rows, ",ncol(d),
        " columns. Typed columns: ",
        paste(paste(names(d),vapply(d,typeof,character(1L)),sep=": "),
              collapse="; "),
        ". Unit labels require explicit source declaration, not guesses.")
    })
    output$plan_info <- shiny::renderText(
      .ru_an_consumer_plan_text(current_plan()))
    output$preview_info <- shiny::renderText({
      p <- code_preview()
      if (is.null(p)) return("NOT_EXECUTED  -  request preview after a READY plan.")
      paste(p$status,p$reason,sep="  -  ")
    })
    output$code_info <- shiny::renderText({
      p <- code_preview()
      if (is.null(p) || !identical(p$status,"PREVIEW_ONLY"))
        return("Code unavailable until a READY plan is previewed.")
      p$code
    })
    output$result_info <- shiny::renderText(
      .ru_an_consumer_result_text(execution_result()))
    output$export_info <- shiny::renderText({
      x <- export_receipt()
      if (is.null(x)) return("NOT_EXPORTED  -  authorize a specific destination.")
      paste(x$status,x$reason,
        if (identical(x$status,"EXPORTED")) x$path else "",sep="  -  ")
    })
  }
  shiny::shinyApp(ui=ui,server=server)
}