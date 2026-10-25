# L2 owns the real learnr tutorials. L1 owns NAMESPACE and ru_workspace wiring.
.ru_learning_foundations <- function() data.frame(
  id=c("ru.learning.foundation.01","ru.learning.foundation.02",
       "ru.learning.foundation.03"),
  tutorial=c("ru-foundation-01","ru-foundation-02","ru-foundation-03"),
  title=c("Where R runs","Saved R and reproducible scripts",
          "Inspect data and import a CSV"),stringsAsFactors=FALSE
)
.ru_learning_invalid <- function(field,message) {
  stop(structure(list(message=message,call=NULL,field=field),
       class=c("ru_invalid_argument","ru_error","error","condition")))
}
ru_learn <- function(path=NULL,lesson=NULL,resume=TRUE) {
  if (!is.logical(resume) || length(resume)!=1L || is.na(resume))
    .ru_learning_invalid("resume","resume must be TRUE or FALSE.")
  if (!is.null(path) && (!is.character(path) || length(path)!=1L ||
                         is.na(path) || !identical(path,"foundation")))
    .ru_learning_invalid("path","Only the foundation path is installed in W2.")
  catalogue <- .ru_learning_foundations()
  if (is.null(lesson)) return(structure(list(
    status="SELECTOR",path="foundation",lessons=catalogue,
    opened=FALSE,resume_requested=resume,resume_verified=FALSE,
    progress_claim="NONE"),class="ru_learning_route"))
  if (!is.character(lesson) || length(lesson)!=1L || is.na(lesson) ||
      !lesson %in% catalogue$id)
    .ru_learning_invalid("lesson","Choose one of three exact registered lesson IDs.")
  name <- catalogue$tutorial[match(lesson,catalogue$id)]
  path <- system.file("tutorials",name,paste0(name,".Rmd"),package="rulearn")
  out <- structure(list(
    status=if(nzchar(path))"READY_TO_LAUNCH" else "UNAVAILABLE",
    reason_code=if(nzchar(path))NULL else "MISSING_ASSET",
    lesson_id=lesson,tutorial=name,path="foundation",opened=FALSE,
    resume_requested=resume,resume_verified=FALSE,
    capability_status="UNTESTED",progress_claim="NONE"),
    class="ru_learning_route")
  if (!nzchar(path) || !interactive()) return(out)
  if (!requireNamespace("learnr",quietly=TRUE)) {
    out$status <- "UNAVAILABLE";out$reason_code <- "UNAVAILABLE_CAPABILITY"
    return(out)
  }
  # The learner explicitly selected the installed package tutorial.
  # Exercises do not write independent evidence to ru_progress().
  learnr::run_tutorial(name,package="rulearn",clean=FALSE)
  out$opened <- TRUE
  out$capability_status <- "LAUNCH_REQUESTED"
  out
}