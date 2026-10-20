# Search the installed question index without network access.
.ru_db <- function(name) {
  dir <- system.file("extdata", package="rulearn")
  prefix <- sub("[.]csv$","",name)
  files <- list.files(dir,pattern=paste0("^",prefix,"-[a-z]+[.]csv$"),full.names=TRUE)
  if (!length(files)) stop("Problem index unavailable.")
  do.call(rbind,lapply(files,function(path)
    read.csv(path,stringsAsFactors=FALSE,na.strings=character(),
             check.names=FALSE,fileEncoding="UTF-8")))
}
.ru_words <- function(x) {
  s <- tolower(gsub("[^[:alnum:]]+"," ",x))
  t <- strsplit(s,"[[:space:]]+")[[1]]
  unique(setdiff(t[nzchar(t)],c("how","do","i","the","a","an","to",
             "of","in","is","can","my","with","what","are","does",
             "on","by","and","from","using","for")))
}
.ru_score <- function(query,bank) {
  keys <- .ru_words(query)
  vapply(seq_len(nrow(bank)),function(i) {
    txt <- tolower(paste(bank$id[i],bank$question[i],bank$keywords[i]))
    terms <- .ru_words(txt)
    points <- sum(vapply(keys,function(k) {
      if(k %in% terms) 5L else if(grepl(k,txt,fixed=TRUE)) 2L else 0L
    },integer(1)))
    if(query==bank$id[i]) points <- points+100L
    if(grepl(query,txt,fixed=TRUE)) points <- points+20L
    points
  },integer(1))
}
ru_topics <- function() {
  x <- sort(table(.ru_db("problems.csv")$category),decreasing=TRUE)
  print(x); invisible(x)
}
ru_find <- function(query,n=10L) {
  if(missing(query) || length(query)!=1L || is.na(query) ||
     !nzchar(trimws(query))) {
    cat("Use ru_find('histogram') or ru_topics().\n")
    return(invisible(data.frame()))
  }
  bank <- .ru_db("problems.csv")
  scores <- .ru_score(tolower(trimws(query)),bank)
  ord <- order(-scores,bank$id)
  ord <- head(ord[scores[ord]>0],max(1L,min(as.integer(n),50L)))
  if(!length(ord)) {
    cat("No match. Try shorter search words.\n")
    return(invisible(data.frame()))
  }
  hits <- bank[ord,c("id","question","inputs"),drop=FALSE]
  rownames(hits) <- NULL
  for(i in seq_len(nrow(hits))) {
    width <- max(36L,as.integer(getOption("width",80L))-5L)
    lines <- strwrap(hits$question[i],width=width)
    cat(i,". ",lines[1L],"\n",sep="")
    if(length(lines)>1L) for(line in lines[-1L])
      cat("   ",line,"\n",sep="")
    cat("   ID: ",hits$id[i]," | Inputs: ",hits$inputs[i],"\n",sep="")
  }
  invisible(hits)
}
.ru_pick <- function(query) {
  bank <- .ru_db("problems.csv")
  q <- tolower(trimws(query))
  exact <- match(q,bank$id)
  if(!is.na(exact)) return(bank[exact,,drop=FALSE])
  scores <- .ru_score(q,bank)
  if(!length(scores) || max(scores)==0L) {
    cat("No match. Try ru_find('keyword').\n")
    return(NULL)
  }
  ix <- which(scores==max(scores))
  if(length(ix)>1L) {
    cat("Several questions match. Use an exact ID:\n")
    print(bank[ix,c("id","question"),drop=FALSE],row.names=FALSE)
    return(NULL)
  }
  bank[ix,,drop=FALSE]
}
