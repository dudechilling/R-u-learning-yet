# W2 three connected foundations: installed assets, formative checking, transfer boundary.
library(rulearn)
stopifnot(requireNamespace("learnr",quietly=TRUE),
          requireNamespace("digest",quietly=TRUE))
root <- system.file(package="rulearn",mustWork=TRUE)
catalogue <- system.file("extdata","ru-curriculum.csv",
                         package="rulearn",mustWork=TRUE)
x <- utils::read.csv(catalogue,stringsAsFactors=FALSE)
stopifnot(nrow(x)==40L,length(unique(x$block))==10L,!anyDuplicated(x$id))
lessons <- getFromNamespace(".ru_learning_foundations","rulearn")()
stopifnot(identical(lessons$id,c("ru.learning.foundation.01",
 "ru.learning.foundation.02","ru.learning.foundation.03")))
launch <- getFromNamespace("ru_learn","rulearn")
chooser <- launch()
stopifnot(identical(chooser$status,"SELECTOR"),
          nrow(chooser$lessons)==3L,!chooser$opened,
          !chooser$resume_verified)
for(id in lessons$id) {
  result <- launch(lesson=id)
  stopifnot(result$status=="READY_TO_LAUNCH",!result$opened,
            !result$resume_verified)
}
for(bad in list(NA_character_,"ru.learning.foundation.99","../../bad",c("x","y"))) {
  result <- tryCatch(launch(lesson=bad),error=identity)
  stopifnot(inherits(result,"ru_invalid_argument"))
}
for(bad in list(NA,1,c(TRUE,FALSE))) {
  result <- tryCatch(launch(resume=bad),error=identity)
  stopifnot(inherits(result,"ru_invalid_argument"))
}
file_root <- system.file("tutorials",package="rulearn",mustWork=TRUE)
for (i in seq_len(nrow(lessons))) {
  name <- lessons$tutorial[[i]]
  file <- system.file("tutorials",name,paste0(name,".Rmd"),
                      package="rulearn",mustWork=TRUE)
  source <- paste(readLines(file,warn=FALSE,encoding="UTF-8"),collapse="\n")
  stopifnot(grepl("runtime: shiny_prerendered",source,fixed=TRUE),
            grepl("learnr::tutorial:",source,fixed=TRUE),
            grepl(lessons$id[[i]],source,fixed=TRUE),
            grepl("H1",source,fixed=TRUE),
            grepl("H2",source,fixed=TRUE),
            grepl("H3",source,fixed=TRUE),
            grepl("practice",source,ignore.case=TRUE))
}
guided <- system.file("tutorials","ru-learning-foundations","data",
  "sites-intro-v1.csv",package="rulearn",mustWork=TRUE)
transfer <- system.file("tutorials","ru-learning-foundations","data",
  "sites-transfer-v1.csv",package="rulearn",mustWork=TRUE)
stopifnot(file.info(guided)$size==81L,file.info(transfer)$size==162L,
 digest::digest(guided,algo="sha256",file=TRUE) ==
 "3166dcb4137ce10342f5bed98004c71e28e3aace1a0c088c7fa7c33da8f3834a",
 digest::digest(transfer,algo="sha256",file=TRUE) ==
 "45879c7bc71dc297f5b862f090931637f9d0ddfb718c4107baed1ca7c773c26a")
g <- read.csv(guided,colClasses=c("character","character","numeric"),
              na.strings=c("","NA"),stringsAsFactors=FALSE)
t <- read.csv(transfer,colClasses=c("character","character","numeric","character"),
              na.strings=c("","NA"),stringsAsFactors=FALSE)
stopifnot(nrow(g)==4L,nrow(t)==5L,ncol(t)==4L,
 identical(g$reading,c(13,NA_real_,18,20)),
 identical(t$record_code,c("0007","0008","0009","0010","0011")),
 identical(t$location_group[1],"Bay, West"),
 sum(is.na(g$reading))==1L,sum(is.na(t$reading))==1L,
 mean(g$reading,na.rm=TRUE)==17,mean(t$reading,na.rm=TRUE)==70,
 mean(replace(g$reading,is.na(g$reading),0))==12.75,
 mean(replace(t$reading,is.na(t$reading),0))==56)
wrong_sep <- try(read.csv(transfer,sep=";"),silent=TRUE)
stopifnot(inherits(wrong_sep,"try-error") || ncol(wrong_sep)!=4L)
stopifnot(!identical(read.csv(transfer)$record_code,t$record_code))
# Checker outcomes measure the submitted semantic operation, not just a number.
check <- getFromNamespace(".ru_learning_checker","rulearn")
judge <- function(label,code,env=new.env(parent=emptyenv()),value=NULL)
  check(label=label,user_code=code,envir_result=env,last_value=value)$correct
e <- new.env(parent=emptyenv())
stopifnot(judge("ru-f01-guided","7 - 2",value=5),
          !judge("ru-f01-guided","5",value=5),
          judge("ru-f01-repair","3*(4-2)",value=6),
          !judge("ru-f01-repair","3*(4-2",value=NULL),
          judge("ru-f01-transfer","(18-6)/4",value=3),
          !judge("ru-f01-transfer","3",value=3))
e$scores <- c(6,8,10)
stopifnot(judge("ru-f02-assignment","scores <- c(6,8,10)",e),
          !judge("ru-f02-assignment","scores == c(6,8,10)",e),
          judge("ru-f02-average","mean(scores)",e,8),
          judge("ru-f02-average","base::mean(scores)",e,8),
          judge("ru-f02-average","sum(scores)/length(scores)",e,8),
          !judge("ru-f02-average","median(scores)",e,8),
          !judge("ru-f02-average","mean(8)",e,8),
          !judge("ru-f02-average","mean(c(6,8,10))",e,8),
          !judge("ru-f02-average","8",e,8),
          !judge("ru-f02-average",'mean("scores")',e,NA_real_))
e$scores <- c(2,4,6)
stopifnot(judge("ru-f02-assign-create","scores = c(2,4,6)",e),
          judge("ru-f02-assign-create","scores <- c(2,4,6)",e),
          !judge("ru-f02-assign-create","scores == c(2,4,6)",e))
e$scores <- c(2,5,6)
stopifnot(judge("ru-f02-assign-modify","scores <- c(2,5,6)",e),
          !judge("ru-f02-assign-modify","scores == c(2,5,6)",e))
e$x <- c(13,NA_real_,18,20)
stopifnot(judge("ru-f03-index","sum(is.na(x))",e,1),
          judge("ru-f03-index","length(which(is.na(x)))",e,1),
          !judge("ru-f03-index","x == NA",e,NA_real_),
          !judge("ru-f03-index","sum(is.na(c(NA)))",e,1),
          !judge("ru-f03-index","1",e,1))
e$d <- data.frame(site_group=c("North","North","South","South"),reading=e$x)
stopifnot(judge("ru-f03-frame","d <- data.frame(site_group=c('North','North','South','South'),reading=x)",e))
e$group <- factor(e$d$site_group)
e$parts <- list(group=e$group,observed=e$d$reading[!is.na(e$d$reading)])
stopifnot(judge("ru-f03-types","group <- factor(d$site_group); parts <- list(group=group,observed=d$reading[!is.na(d$reading)])",e))
e$guided <- g
stopifnot(judge("ru-f03-csv","guided <- read.csv(source_path)",e))
e$exclude_missing <- FALSE;e$average <- 17
stopifnot(!judge("ru-f03-summary","exclude_missing <- FALSE; average <- mean(guided$reading,na.rm=TRUE)",e))
e$exclude_missing <- TRUE
stopifnot(judge("ru-f03-summary","exclude_missing <- TRUE; average <- mean(guided$reading,na.rm=exclude_missing)",e),
          !judge("ru-f03-summary","exclude_missing <- TRUE; average <- 17",e),
          !judge("ru-f03-summary","exclude_missing <- TRUE; average <- mean(c(13,18,20))",e),
          !judge("ru-f03-summary","exclude_missing <- TRUE; average <- mean(replace(guided$reading,is.na(guided$reading),0))",e))
# learnr rebinds the checker closure into its exercise environment.
# Namespace-qualified internal helpers must remain reachable after rebind.
rebound <- check
environment(rebound) <- new.env(parent=baseenv())
stopifnot(identical(rebound(label="ru-f01-guided",user_code="7 - 2",
                           last_value=5,stage="check",engine="r")$correct,TRUE),
          identical(rebound(label="ru-f01-guided",user_code="5",
                           last_value=5,stage="check",engine="r")$correct,FALSE))
# No test claims to observe a Windows GUI, persisted progress or real learner.
cat("L2 W2 foundations PASS: 3 tutorials, 40 outcomes, exact 81/162-byte CSV assets, evaluator negatives and practise-only feedback.\n")