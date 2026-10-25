# L5 independently asserted installed/golden W2 CSV import boundary.
# This checks exact authored synthetic fixture bytes; it does not prove
# students can import in an actual RStudio Source/Console environment.
root <- Sys.getenv("RU_L2_ASSET_ROOT", unset="")
if (!nzchar(root))
  root <- system.file("tutorials","ru-learning-foundations","data",
                      package="rulearn",mustWork=FALSE)
stopifnot(nzchar(root),dir.exists(root))
if (!requireNamespace("digest",quietly=TRUE))
  stop("BLOCKED: digest is required for SHA-256 byte identity")
audit <- function(name,hash,size,types,expected_rows) {
 path<-file.path(root,name)
 stopifnot(file.exists(path),!dir.exists(path),
   as.integer(file.info(path)$size)==as.integer(size),
   identical(digest::digest(path,algo="sha256",serialize=FALSE,file=TRUE),hash))
 d<-utils::read.csv(path,stringsAsFactors=FALSE,
                     colClasses=unname(types),na.strings=c("","NA"),
                     check.names=FALSE,fileEncoding="UTF-8")
 stopifnot(nrow(d)==expected_rows,
   identical(names(d),names(types)),
   identical(unname(vapply(d,typeof,character(1L))),unname(types)))
 cat("L5_W2_CSV_EXACT_BYTES_AND_R_IMPORT_PASS ",name," ",hash,
     " rows=",nrow(d),"\n",sep="")
 d
}
guided<-audit("sites-intro-v1.csv",
 "3166dcb4137ce10342f5bed98004c71e28e3aace1a0c088c7fa7c33da8f3834a",
 81L,c(row_key="character",site_group="character",reading="double"),4L)
stopifnot(
 identical(guided$row_key,c("G001","G002","G003","G004")),
 identical(guided$site_group,c("North","North","South","South")),
 identical(guided$reading,c(13,NA_real_,18,20)),
 sum(is.na(guided$reading))==1L,
 sum(guided$reading[!is.na(guided$reading)])==51,
 mean(guided$reading,na.rm=TRUE)==17,
 mean(replace(guided$reading,is.na(guided$reading),0))==12.75
)
transfer<-audit("sites-transfer-v1.csv",
 "45879c7bc71dc297f5b862f090931637f9d0ddfb718c4107baed1ca7c773c26a",
 162L,c(record_code="character",location_group="character",
       reading="double",quality_flag="character"),5L)
stopifnot(
 identical(transfer$record_code,c("0007","0008","0009","0010","0011")),
 identical(transfer$location_group,c("Bay, West","Bay, West","Hill","Hill","Bay, West")),
 identical(transfer$reading,c(64,68,NA_real_,72,76)),
 identical(transfer$quality_flag,c("ok","ok","missing","ok","ok")),
 sum(is.na(transfer$reading))==1L,
 mean(transfer$reading,na.rm=TRUE)==70,
 mean(replace(transfer$reading,is.na(transfer$reading),0))==56,
 !identical(transfer$record_code[[1L]],as.character(as.integer(transfer$record_code[[1L]])))
)
# Distinct sample sources are not interchangeable. Neither source says
# physical unit in the CSV itself: require authored source card evidence.
cat("L5_W2_CSV_VALIDATED_81_AND_162_BYTES_NO_UNIT_INFERENCE_NO_HUMAN_CREDIT\n")