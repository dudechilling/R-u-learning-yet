# Search installed local references and worked questions; no network or LLM.
.ru_db <- function(name) {
  dir <- system.file("extdata",package="rulearn")
  prefix <- sub("[.]csv$","",name)
  files <- list.files(dir,pattern=paste0("^",prefix,"-[a-z]+[.]csv$"),
                      full.names=TRUE)
  if (!length(files)) stop("Problem index unavailable.",call.=FALSE)
  do.call(rbind,lapply(files,function(path)
    utils::read.csv(path,stringsAsFactors=FALSE,na.strings=character(),
             check.names=FALSE,fileEncoding="UTF-8")))
}
.ru_words <- function(x) {
  s <- tolower(gsub("p[- ]?values?", "pvalue", x, perl=TRUE))
  s <- gsub("[^[:alnum:]]+"," ",s)
  t <- strsplit(s,"[[:space:]]+")[[1]]
  unique(setdiff(t[nzchar(t)],c(
    "how","do","i","the","a","an","to","of","in","is","can","my",
    "with","what","are","does","on","by","and","from","using","for",
    "define","definition","does","work","works","function","between",
    "make","create","calculate","find","show","draw","have",
    "different","two","me","please","tell","about")))
}

# Deterministic, conservative spelling repair using the words already
# indexed by the reference library. Never send text outside the machine.
.ru_correct_tokens <- function(tokens,catalog) {
  words <- c(catalog$id,catalog$title,catalog$keywords)
  vocabulary <- unique(unlist(lapply(words,.ru_words),use.names=FALSE))
  vocabulary <- vocabulary[nchar(vocabulary)>=4L]
  changed <- character()
  if (!length(vocabulary)) return(list(words=tokens,changes=changed))
  for(i in seq_along(tokens)) {
    term <- tokens[i]
    if (nchar(term)<5L || term %in% vocabulary) next
    choices <- vocabulary[abs(nchar(vocabulary)-nchar(term))<=2L]
    if (!length(choices)) next
    distances <- as.integer(utils::adist(term,choices))
    best <- min(distances)
    threshold <- if(nchar(term)>=8L) 2L else 1L
    winners <- unique(choices[distances==best])
    if(best<=threshold && length(winners)==1L) {
      changed <- c(changed,paste(term,"->",winners))
      tokens[i] <- winners
    }
  }
  list(words=unique(tokens),changes=changed)
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

.ru_catalog <- function() {
  path <- system.file("extdata","reference.csv",package="rulearn")
  if (!nzchar(path)) stop("The reference index is not installed.",call.=FALSE)
  refs <- utils::read.csv(path,stringsAsFactors=FALSE,
                          na.strings=character(),fileEncoding="UTF-8")
  refs$question <- refs$title
  refs$inputs <- ""
  guide <- .ru_db("problems.csv")
  guide <- data.frame(
    id=guide$id,type="walkthrough",
    title=guide$question,keywords=guide$keywords,
    topic=guide$id,package="rulearn",
    question=guide$question,inputs=guide$inputs,
    stringsAsFactors=FALSE)
  data <- rbind(refs[,names(guide)],guide)
  data$path <- vapply(seq_len(nrow(data)), function(i) {
    item <- data[i,]
    if(item$type=="walkthrough")
      paste0("ru_guide('",item$id,"')")
    else
      paste0("ru_open('",item$id,"')")
  },character(1))
  data
}
.ru_search_results <- function(query,n=10L,type=NULL) {
  if(!is.character(query) || length(query)!=1L || is.na(query) ||
     !nzchar(trimws(query))) return(.ru_catalog()[FALSE,,drop=FALSE])
  catalog <- .ru_catalog()
  if (!is.null(type)) {
    if (length(type)!=1L || !(type %in% c("concept","function","walkthrough")))
      stop("type must be 'concept', 'function' or 'walkthrough'.",call.=FALSE)
    catalog <- catalog[catalog$type==type,,drop=FALSE]
  }
  q <- tolower(trimws(query))
  # "What does a p-value mean?" is asking for the term "p-value",
  # not arithmetic mean. Preserve "mean" for queries about averages.
  q <- sub("^what does (a |the )?(.+) mean[?]?$","\\2",q)
  corrected <- .ru_correct_tokens(.ru_words(q),catalog)
  tokens <- corrected$words
  intent_concept <- grepl(
    "^(what is|what are|define|definition|meaning of|explain|when is|can i use|should i use)\\b",
    tolower(trimws(query)),perl=TRUE) ||
    grepl("\\bmean[?]?$",tolower(trimws(query)),perl=TRUE)
  intent_function <- grepl(
    "\\b(function|syntax|arguments?|returns?|code for)\\b",
    tolower(query),perl=TRUE) ||
    grepl("^(how does|how do)\\b.*\\b(sd|mean|median|hist|cor|acf|quantile|table|t[.]test)\\b",
          tolower(query),perl=TRUE)
  intent_walkthrough <- grepl(
    "^(how do i|how can i|how to|steps to|when should|create|import|inspect|calculate|investigate|compare|plot|draw|make)\\b",
    tolower(trimws(query)),perl=TRUE)
  score <- vapply(seq_len(nrow(catalog)),function(i) {
    item <- catalog[i,]
    heading <- tolower(paste(item$id,item$title))
    title_words <- .ru_words(heading)
    keys <- .ru_words(paste(item$keywords,item$question,item$id))
    # Exact token matches, rather than accidental matches inside words such
    # as "not" in "cannot". Corrected search tokens are shown to the learner.
    hit <- sum(vapply(tokens,function(t) {
      if(t %in% title_words) 10L
      else if(t %in% keys) 5L
      else 0L
    },integer(1)))
    if(q==tolower(item$id) ||
       (item$type=="function" &&
          q==sub("^r_","",tolower(item$id))))
      hit <- hit + 100L
    if(nzchar(q) && grepl(q,tolower(item$title),fixed=TRUE))
      hit <- hit + 22L
    if(nzchar(q) && grepl(q,tolower(item$keywords),fixed=TRUE))
      hit <- hit + 18L
    if(intent_concept && item$type=="concept") hit <- hit + 17L
    if(intent_function && item$type=="function") hit <- hit + 20L
    if(intent_walkthrough && item$type=="walkthrough") hit <- hit + 8L
    # Intent alone is not evidence of a topical match.
    if (!length(tokens) || !any(vapply(tokens,function(k)
      k %in% keys,logical(1))))
      hit <- 0L
    hit
  },integer(1))
  ord <- order(-score,match(catalog$type,c("concept","function","walkthrough")),
               catalog$id)
  n <- if (length(n)!=1L || is.na(n) || !is.finite(n))
    10L else max(1L,min(as.integer(n),50L))
  ord <- head(ord[score[ord]>0L],n)
  out <- catalog[ord,,drop=FALSE]
  rownames(out) <- NULL
  attr(out,"corrected_terms") <- corrected$changes
  out
}
ru_topics <- function() {
  cat("Reference collection:\n")
  print(table(.ru_catalog()$type))
  cat("\nWalkthrough categories:\n")
  categories <- sort(table(.ru_db("problems.csv")$category),decreasing=TRUE)
  print(categories)
  invisible(categories)
}
ru_find <- function(query,n=10L,type=NULL) {
  if(missing(query) || !is.character(query) || length(query)!=1L ||
     is.na(query) || !nzchar(trimws(query))) {
    cat("Try ru_find('stationarity'), ru_find('sd function'), ",
        "or ru_topics().\n",sep="")
    return(invisible(.ru_catalog()[FALSE,,drop=FALSE]))
  }
  hits <- .ru_search_results(query,n=n,type=type)
  changes <- attr(hits,"corrected_terms")
  if (length(changes))
    cat("Spelling suggestion: ",paste(changes,collapse=", "),".\n",sep="")
  if(!nrow(hits)) {
    cat("No local reference found. Try fewer words or ru_topics().\n")
    return(invisible(hits))
  }
  for(i in seq_len(nrow(hits))) {
    prefix <- paste0(i,". [",
                     toupper(substring(hits$type[i],1L,1L)),
                     substring(hits$type[i],2L),"] ")
    limit <- max(25L,as.integer(getOption("width",80L))-nchar(prefix)-1L)
    wrapped <- strwrap(hits$title[i],width=limit)
    cat(prefix,wrapped[1L],"\n",sep="")
    if(length(wrapped)>1L)
      for(line in wrapped[-1L]) cat("   ",line,"\n",sep="")
    cat("   ID: ",hits$id[i],"\n",sep="")
    cat("   Open: ",hits$path[i],"\n",sep="")
    if(hits$type[i]=="walkthrough")
      cat("   Check: ",hits$inputs[i],"\n",sep="")
  }
  invisible(hits)
}
ru_open <- function(query,type=NULL) {
  if(!is.character(query) || length(query)!=1L || is.na(query))
    stop("Provide one search phrase or reference ID.",call.=FALSE)
  result <- .ru_search_results(query,n=1L,type=type)
  if(!nrow(result)) {
    cat("No matching entry. Use ru_find('keywords') for choices.\n")
    return(invisible(NULL))
  }
  item <- result[1L,]
  if(item$type=="walkthrough")
    return(ru_guide(item$id))
  utils::help(item$topic,package=item$package)
}

# Internal method lookup remains restricted to walkthroughs for compatibility.
.ru_pick <- function(query) {
  bank <- .ru_db("problems.csv")
  q <- tolower(trimws(query))
  exact <- match(q,bank$id)
  if(!is.na(exact)) return(bank[exact,,drop=FALSE])
  scores <- .ru_score(q,bank)
  if(!length(scores) || max(scores)==0L) {
    cat("No matching method. Try ru_find('keyword').\n")
    return(NULL)
  }
  ix <- which(scores==max(scores))
  if(length(ix)>1L) {
    cat("Several methods match. Use an exact walkthrough ID:\n")
    print(bank[ix,c("id","question"),drop=FALSE],row.names=FALSE)
    return(NULL)
  }
  bank[ix,,drop=FALSE]
}