# Lightweight question search without network calls or external packages.
.ru_db <- function(name) {
  dir <- system.file("extdata", package="rulearn")
  prefix <- sub("[.]csv$", "", name)
  files <- list.files(dir, pattern=paste0("^", prefix, "-[a-z]+[.]csv$"), full.names=TRUE)
  if (!length(files)) stop("Problem index unavailable.")
  tables <- lapply(files, function(path) {
    read.csv(path, stringsAsFactors=FALSE, na.strings=character(),
             check.names=FALSE, fileEncoding="UTF-8")
  })
  do.call(rbind,tables)
}
.ru_words <- function(x) {
  s <- tolower(gsub("[^[:alnum:]]+", " ", x))
  t <- strsplit(s, "[[:space:]]+")[[1]]
  unique(setdiff(t[nzchar(t)], c("how","do","i","the","a","an","to",
             "of","in","is","can","my","with","what","are","does",
             "on","by","and","from","using","for")))
}
.ru_score <- function(query, bank) {
  keys <- .ru_words(query)
  vapply(seq_len(nrow(bank)), function(i) {
    txt <- tolower(paste(bank$id[i], bank$question[i], bank$keywords[i]))
    terms <- .ru_words(txt)
    points <- sum(vapply(keys, function(k) {
      if (k %in% terms) 5L else if (grepl(k,txt,fixed=TRUE)) 2L else 0L
    }, integer(1)))
    if (query == bank$id[i]) points <- points+100L
    if (grepl(query,txt,fixed=TRUE)) points <- points+20L
    points
  }, integer(1))
}
ru_topics <- function() {
  x <- sort(table(.ru_db("problems.csv")$category), decreasing=TRUE)
  print(x); invisible(x)
}
ru_find <- function(query, n=10L) {
  if (missing(query) || length(query)!=1L || is.na(query) ||
      !nzchar(trimws(query))) {
    cat("Use ru_find('histogram') or ru_topics().\n")
    return(invisible(data.frame()))
  }
  bank <- .ru_db("problems.csv")
  scores <- .ru_score(tolower(trimws(query)),bank)
  ord <- order(-scores,bank$id)
  ord <- head(ord[scores[ord]>0], max(1L,min(as.integer(n),50L)))
  if (!length(ord)) {
    cat("No match. Try shorter search words.\n")
    return(invisible(data.frame()))
  }
  hits <- bank[ord,c("id","question","inputs"),drop=FALSE]
  rownames(hits) <- NULL
  print(hits,row.names=FALSE,right=FALSE)
  invisible(hits)
}
.ru_pick <- function(query) {
  bank <- .ru_db("problems.csv")
  q <- tolower(trimws(query))
  exact <- match(q,bank$id)
  if (!is.na(exact)) return(bank[exact,,drop=FALSE])
  score <- .ru_score(q,bank)
  if (!length(score) || max(score)==0L) {
    cat("No match. Try ru_find('keyword').\n")
    return(NULL)
  }
  ix <- which(score==max(score))
  if (length(ix)>1L) {
    cat("Several questions match. Use an exact ID:\n")
    print(bank[ix,c("id","question"),drop=FALSE],row.names=FALSE)
    return(NULL)
  }
  bank[ix,,drop=FALSE]
}
