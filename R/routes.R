# Routes require evidence of availability or absence: unknown is not absent.
.ru_list <- function(s) {
  if (length(s)==0L || is.na(s) || !nzchar(s)) return(character())
  x <- trimws(strsplit(s,";",fixed=TRUE)[[1]])
  tolower(x[nzchar(x)])
}
.ru_inputs_clean <- function(x) {
  if (is.null(x)) return(character())
  x <- tolower(gsub("[[:space:]-]+","_",trimws(as.character(x))))
  synonyms <- c(values="numeric",numbers="numeric",measurements="numeric",
                category="categories",labels="categories",
                group="groups",dates="time",timestamp="time")
  unique(vapply(x[nzchar(x)],function(w) {
    if (w %in% names(synonyms)) synonyms[[w]] else w
  },character(1)))
}
ru_inputs <- function() {
  cat("Use: numeric, categories, counts, groups, pairs, time, mean, sd,\n",
      "n, probability, threshold, table, file, reference, confidence,\n",
      "population, paired, independent, units, sample.\n",
      "Unmentioned inputs remain unknown.\n",sep="")
  invisible(TRUE)
}
ru_plan <- function(query,have=NULL,missing=NULL) {
  if (!is.character(query) || length(query)!=1L ||
      is.na(query) || !nzchar(trimws(query)))
    stop("Provide one problem ID or question.")
  item <- .ru_pick(query)
  if (is.null(item)) return(invisible(NULL))
  have <- .ru_inputs_clean(have)
  missing <- .ru_inputs_clean(missing)
  overlap <- intersect(have,missing)
  if (length(overlap))
    stop("Contradictory inputs: ",paste(overlap,collapse=", "))
  paths <- .ru_db("routes.csv")
  paths <- paths[paths$id == item$id,,drop=FALSE]
  cat("\n",item$question,"\n",strrep("-",nchar(item$question)),
      "\nProblem ID: ",item$id,
      "\nLook for: ",item$inputs,
      "\nWhy: ",item$interpretation,"\n",sep="")
  if (!length(have) && !length(missing)) {
    cat("\nPossible routes (check inputs first):\n")
    for (i in seq_len(nrow(paths))) {
      p <- paths[i,]
      cat("\nIF available [",gsub(";",", ",p$have,fixed=TRUE),
          "] AND absent [",gsub(";",", ",p$missing,fixed=TRUE),
          "]: ",p$route,"\n",sep="")
      cat(gsub(" ~ ","\n",p$steps,fixed=TRUE),"\n")
    }
  } else {
    ok <- which(vapply(seq_len(nrow(paths)),function(i) {
      all(.ru_list(paths$have[i]) %in% have) &&
        all(.ru_list(paths$missing[i]) %in% missing)
    },logical(1)))
    if (!length(ok)) {
      cat("\nNo route matches all confirmed inputs.\n",
          "Available: ",paste(have,collapse=", "),
          "\nAbsent: ",paste(missing,collapse=", "),
          "\nUnmentioned inputs stay unknown. Run ru_plan('",
          item$id,"') to inspect routes.\n",sep="")
    } else {
      weight <- vapply(ok,function(i)
        length(.ru_list(paths$have[i]))+length(.ru_list(paths$missing[i])),integer(1))
      p <- paths[ok[which.max(weight)],]
      cat("\nSelected route: ",p$route,"\n",
          gsub(" ~ ","\n",p$steps,fixed=TRUE),"\n",sep="")
    }
  }
  cat("\nCheck: ",item$check,
      "\nRead code: ru_code('",item$id,
      "') | Run independent example: ru_run('",item$id,"')\n",sep="")
  invisible(list(problem=item$id,have=have,missing=missing))
}
ru <- function(query,have=NULL,missing=NULL) {
  if (missing(query)) return(ru_topics())
  ru_plan(query,have=have,missing=missing)
}
