# A1 public facade contract test with typed temporary peer-function fixtures.
# Run against an INSTALLED package, without sourcing any development R files.
library(rulearn)
ns <- asNamespace("rulearn")
assert <- function(ok, label) if (!isTRUE(ok)) stop(label, call. = FALSE)
make_parsed <- function(q) {
  concept <- identical(tolower(trimws(q)), "pmf")
  dice <- grepl("die|dice", q, ignore.case = TRUE)
  list(schema_version = "ru.guided.v1",
       status = if (dice) "SOLVED" else if (concept) "GUIDED_REFERENCE" else "UNSUPPORTED",
       reason_code = if (dice) "FAIR_DICE_SUM" else if (concept) "PMF_CONCEPT" else "NOT_SUPPORTED",
       original_question = q, family_id = if (dice) "dice_sum_independent_fair" else "reference",
       inputs = if (dice) list(die1_faces = 6L, die2_faces = 4L) else list(),
       requested_outputs = if (dice) c("pmf","expected_value","variance") else character(),
       assumptions = list(fair = TRUE, independent = TRUE),
       missing_inputs = character(), parser_rule_id = "fixture")
}
parse_mock <- function(q) make_parsed(q)
compute_mock <- function(p) {
  c(p[c("schema_version","status","reason_code","original_question",
        "family_id","inputs","requested_outputs","assumptions")],
    list(answer = if (identical(p$status,"SOLVED"))
      list(total_outcomes = 24L, expected_value = 6, variance = 25/6) else list(),
      checks = list(mass_one = TRUE),
      code_preview = if (identical(p$status,"SOLVED"))
        "die1_faces <- 6L; die2_faces <- 4L" else "",
      executed = FALSE))
}
teach_mock <- function(c) {
  list(schema_version="ru.guided.v1",status=c$status,reason_code=c$reason_code,
       title="Guided lesson",question=c$original_question,
       explanation_sections="Explanation", step_by_step=c("Step 1","Step 2"),
       runnable_code=c$code_preview,expected_output=c$answer,checks=c$checks,
       interpretations="Conditional theoretical calculation",
       change_this="die1_faces, die2_faces",
       hints=list(H0="Goal",H1="Hint",H2="Method",H3="Worked step"),
       transfer_question="Change the dice",links=character(),
       assumptions=c$assumptions)
}
render_mock <- function(lesson,open=TRUE)
  list(status=lesson$status,opened=FALSE,
       capability_status=if(open)"VIEWER_UNAVAILABLE" else "NOT_REQUESTED")
mocks <- list(.ru_w3_parse=parse_mock,.ru_w3_compute=compute_mock,
              .ru_w3_teach=teach_mock,.ru_w3_render=render_mock)
saved <- list()
for (name in names(mocks)) {
  if (exists(name,envir=ns,inherits=FALSE)) {
    saved[[name]] <- get(name,envir=ns,inherits=FALSE)
    unlockBinding(name,ns)
  }
  assign(name,mocks[[name]],envir=ns)
  lockBinding(name,ns)
}
on.exit <- NULL
restore <- function() {
  for (name in names(mocks)) {
    unlockBinding(name,ns)
    if (name %in% names(saved)) assign(name,saved[[name]],envir=ns)
    else rm(list=name,envir=ns)
    if (exists(name,envir=ns,inherits=FALSE)) lockBinding(name,ns)
  }
}
tryCatch({
  q <- "What is the probability distribution PMF of the sum of one six-sided die and one four-sided die?"
  s <- ru_solve(q,open=FALSE)
  assert(inherits(s,"ru_solution"),"class")
  assert(identical(s$status,"SOLVED"),"solved status")
  assert(identical(s$reason_code,"FAIR_DICE_SUM"),"reason preserved")
  assert(identical(s$schema_version,"ru.guided.v1"),"schema")
  assert(identical(s$question,q),"question")
  assert(identical(s$answer$variance,25/6),"variance")
  assert(identical(s$code_status,"NOT_EXECUTED") && identical(s$executed,FALSE),
         "code execution truthfulness")
  assert(!s$opened && identical(s$capability_status,"NOT_REQUESTED"),"no viewer")
  assert(identical(s$requested_outputs,c("pmf","expected_value","variance")),"composite")
  assert(is.list(s$guide) && is.list(s$guide$hints),"lesson")
  concept <- ru_solve("PMF",open=FALSE)
  assert(identical(concept$status,"GUIDED_REFERENCE"),"concept-only")
  assert(length(concept$inputs)==0L,"no invented dice")
  unsupported <- ru_solve("Analyze my private survey",open=FALSE)
  assert(identical(unsupported$status,"UNSUPPORTED"),"unsupported")
  for (bad in list(NA_character_,"", "  ",1,character(),rep("x",4097L))) {
    v <- ru_solve(bad,open=FALSE)
    assert(identical(v$status,"INVALID"),"invalid case")
  }
  large <- ru_solve(paste(rep("x",4097),collapse=""),open=FALSE)
  assert(identical(large$reason_code,"QUESTION_TOO_LONG"),"bounded input")
  assert(!ru_solve(q,open=TRUE)$opened,"viewer unavailable")
  assert(identical(formals(ru_find)$n,10L) &&
         identical(formals(ru_find)$type,NULL),"old signature")
  f <- ru_find("PMF")
  assert(is.data.frame(f) && nrow(f)>=1L &&
         "discrete_pmf" %in% f$id,"PMF compatibility")
  assert(is.data.frame(ru_find(q)),"guided search return type")
  assert(!("ru_solve" %in% setdiff(getNamespaceExports("rulearn"),"ru_solve")),
         "export consistency")
  assert(length(unique(getNamespaceExports("rulearn")))==33L,"33 exports")
  cat("A1 W3 INSTALLED FACADE MOCKS PASS\n")
}, finally=restore())