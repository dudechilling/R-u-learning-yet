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
    "different","two","me","please","tell","about","as",
    "this","that","something","anything","library","not","cover",
    "whether","causes")))
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
    if (nchar(term)<6L || term %in% vocabulary) next
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
  # Programming requests need assignment/extraction, not statistical models.
  # Inspect the original query before punctuation tokenization removes <- and $.
  intent_objects <- grepl(paste0(
    "\\b(create|make|assign|store|save|declare|copy|extract|select|pull)\\b.*\\b(variables?|varibles|objects?|columns?|fields?)\\b|",
    "\\b(add|new)\\b.*\\bcolumns?\\b|",
    "\\bassignment\\s+(operator|arrow)\\b|",
    "df[$][[:alnum:]_.]+|",
    "<-|",
    "\\b(select|extract)\\b.*\\b(csv|data[ -]?frame)\\b"
    ),tolower(trimws(query)),perl=TRUE)
  # A named scatter display or plotting a pair of measurements is a
  # visualization question, not a paired hypothesis-test question.
  intent_scatter <- grepl(
    "\\bscatter\\b|\\b(plot|draw|graph)\\b.*\\b(two|paired|relationship)\\b",
    tolower(trimws(query)),perl=TRUE) &&
    !grepl("\\b(over time|time series)\\b",tolower(query),perl=TRUE)
  out_of_scope_explanation <- grepl(
    "^what causes\\b",tolower(trimws(query)),perl=TRUE) &&
    !grepl(
      "\\b(data|statistics?|sampling|sample|population|probability|correlation|autocorrelation|stationarity|variance|hypothesis|pvalue|trend|model)\\b",
      tolower(query),perl=TRUE)
  intent_statistical_variable <- grepl(paste0(
    "\\b(statistical|statistics|measured|observed)\\b.*\\bvariables?\\b|",
    "\\bvariables?\\b.*\\b(statistical|statistics)\\b"
    ),tolower(trimws(query)),perl=TRUE)
  intent_concept <- grepl(
    "^(what is|what are|define|definition|meaning of|when is|can i use|should i use)\\b",
    tolower(trimws(query)),perl=TRUE) ||
    grepl("\\bmean[?]?$",tolower(trimws(query)),perl=TRUE)
  intent_function <- grepl(
    "\\b(function|syntax|arguments?|returns?|code for)\\b",
    tolower(query),perl=TRUE) ||
    grepl("^(how does|how do)\\s+(sd|mean|median|hist|cor|acf|quantile|table|t[.]test)\\b",
          tolower(query),perl=TRUE)
  intent_walkthrough <- grepl(
    "^(how do i|how can i|how to|steps to|when should|create|import|inspect|calculate|investigate|compare|plot|draw|make)\\b",
    tolower(trimws(query)),perl=TRUE)
  intent_error <- grepl(
    "\\b(wrong|error|failed|cannot|invalid|troubleshoot)\\b|not found",
    tolower(query),perl=TRUE) &&
    !grepl(
      "\\b(standard error|sampling error|margin of error|type [i1] error)\\b",
      tolower(query),perl=TRUE)
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
    # When the learner names an R method explicitly, favor references to
    # that named method over a generic nearby task such as grouped means.
    method_terms <- intersect(tokens,c(
      "boxplot","histogram","barplot","scatterplot","stem","quantile",
      "median","sd","acf","csv"))
    if(length(method_terms) &&
       any(method_terms %in% title_words))
      hit <- hit + 18L
    # A request for both mean AND median needs their combined reference,
    # not the histogram article that happens to demonstrate both markers.
    # Only use this disambiguation when no plot method was requested.
    if (all(c("mean","median") %in% tokens) &&
        !any(c("histogram","boxplot","plot","graph","chart") %in% tokens) &&
        item$id=="mean_median")
      hit <- hit + 30L
    # Variables alone are not evidence of correlation or plotting.
    # This is a topic-specific disambiguation, not a new calculation system.
    if(intent_objects) {
      hit <- if(item$id=="r_objects_columns") 350L else 0L
    } else if(intent_statistical_variable) {
      hit <- if(item$id=="statistical_variable") 350L else 0L
    } else {
      meaningful <- setdiff(tokens,c("variable","variables","varibles",
                                     "numeric","numerical","data"))
      if(!length(meaningful) || !any(meaningful %in% keys))
        hit <- 0L
    }
    if(intent_scatter && item$id=="scatterplot") hit <- hit + 115L
    if(intent_concept && item$type=="concept") hit <- hit + 17L
    if(intent_function && item$type=="function") hit <- hit + 20L
    if(intent_walkthrough && item$type=="walkthrough") hit <- hit + 8L
    if(intent_error && item$id=="r_errors") hit <- hit + 21L
    # Do not revive unrelated hits via an intent bonus alone.
    valid <- if(intent_objects) item$id=="r_objects_columns"
      else if(intent_statistical_variable) item$id=="statistical_variable"
      else {
        meaningful <- setdiff(tokens,c("variable","variables","varibles",
                                       "numeric","numerical","data"))
        length(meaningful)>0L && any(meaningful %in% keys)
      }
    if (!valid || out_of_scope_explanation) hit <- 0L
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
    cat("Try ru_find('create variables'), ru_find('stationarity'), ",
        "or ru_topics().\n",sep="")
    return(invisible(.ru_catalog()[FALSE,,drop=FALSE]))
  }
  hits <- .ru_search_results(query,n=n,type=type)
  changes <- attr(hits,"corrected_terms")
  if(length(changes))
    cat("Spelling suggestion: ",paste(changes,collapse=", "),".\n",sep="")
  if(!nrow(hits)) {
    cat("No local reference found for that question. ",
        "Try a more specific term or ru_topics().\n",sep="")
    return(invisible(hits))
  }
  top <- hits[1L,]
  if(.ru_rstudio_ready()) {
    # One relevant native article/walkthrough in the Help pane, not
    # a verbose list or raw Quarto printed into the Console.
    if(top$type=="walkthrough") ru_guide(top$id)
    else .ru_help_page(top$topic,package=top$package)
  } else {
    cat("Best match: [",top$type,"] ",top$title,"\n",
        "Open: ",top$path,"\n",sep="")
    if(nrow(hits)>1L)
      cat("Other relevant results: ",
          paste(head(hits$id[-1L],2L),collapse=", "),".\n",sep="")
  }
  invisible(hits)
}
ru_open <- function(query,type=NULL) {
  if(!is.character(query) || length(query)!=1L || is.na(query))
    stop("Provide one search phrase or reference ID.",call.=FALSE)
  result <- .ru_search_results(query,n=1L,type=type)
  if(!nrow(result)) {
    cat("No matching reference. Try ru_find('keywords').\n")
    return(invisible(NULL))
  }
  item <- result[1L,]
  if(item$type=="walkthrough")
    return(ru_guide(item$id))
  .ru_help_page(item$topic,package=item$package)
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