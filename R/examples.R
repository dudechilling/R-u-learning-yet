# Scripts execute in a separate environment and never load user datasets.
.ru_example <- function(query) {
  item <- .ru_pick(query)
  if (is.null(item)) return(NULL)
  file <- system.file("examples",paste0(item$id,".R"),package="rulearn")
  if (!nzchar(file)) stop("Example script not installed.")
  file
}
ru_code <- function(query) {
  file <- .ru_example(query)
  if (is.null(file)) return(invisible(NULL))
  cat(paste(readLines(file,warn=FALSE),collapse="\n"),"\n")
  invisible(file)
}
ru_run <- function(query) {
  file <- .ru_example(query)
  if (is.null(file)) return(invisible(NULL))
  cat("Running with illustrative data, not your current workspace.\n")
  had_seed <- exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  if (had_seed) original_seed <- get(".Random.seed",envir=.GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed",original_seed,envir=.GlobalEnv)
    } else if (exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)) {
      rm(list=".Random.seed",envir=.GlobalEnv)
    }
  },add=TRUE)
  local_env <- new.env(parent=globalenv())
  sys.source(file,envir=local_env,keep.source=TRUE)
  invisible(local_env)
}
