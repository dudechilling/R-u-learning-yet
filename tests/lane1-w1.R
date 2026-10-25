# W1 independent installed-package entry, resolver, state and metadata checks.
library(rulearn)
old_exports <- c("ru","ru_find","ru_plan","ru_run","ru_code","ru_topics",
 "ru_inputs","ru_hist","ru_bar","ru_box","ru_scatter","ru_data",
 "ru_datasets","ru_columns","ru_apply","ru_guide","ru_edit","ru_open",
 "ru_text","ru_palette","ru_home")
stopifnot(all(old_exports %in% getNamespaceExports("rulearn")),
  identical(names(formals(ru_plan)), c("query","have","missing")),
  !is.null(formals(ru_home)$open))
new_exports <- c("ru_workspace","ru_reference","ru_capabilities",
                 "ru_progress","ru_source_context")
stopifnot(all(new_exports %in% getNamespaceExports("rulearn")))

ns <- function(name) getFromNamespace(name,"rulearn")
expect_condition <- function(expr, kind) {
  caught <- tryCatch(force(expr), error = identity)
  stopifnot(inherits(caught, kind))
  invisible(TRUE)
}
selection <- ru_workspace()
stopifnot(inherits(selection,"ru_workspace_result"),selection$status=="SELECTOR",
  identical(selection$choices,c("learn","analyze","reference")),
  is.null(selection$consumer), !selection$opened)
reference <- ru_workspace("reference")
stopifnot(reference$status=="CATALOGUE",reference$consumer$status=="CATALOGUE")
for(mode in c("learn","analyze"))
  stopifnot(ru_workspace(mode)$status=="UNAVAILABLE",
            ru_workspace(mode)$reason_code=="NOT_IMPLEMENTED")
for(value in list(NULL,NA_character_,"","ref","other",
                  c("learn","analyze"),c("learn","analyze","reference")))
  expect_condition(ru_workspace(mode=value),"ru_invalid_argument")

caps <- ru_capabilities()
stopifnot(caps$schema_version==1L,all(c("shiny","bslib","learnr","filelock") %in%
            caps$packages$package),
  caps$routes$status[caps$routes$mode=="learn"]=="UNAVAILABLE",
  !caps$rstudio_detected)
catalogue <- ru_reference(open=FALSE)
stopifnot(catalogue$status=="CATALOGUE",length(catalogue$matches)>3L,
          is.null(catalogue$selected_id),!catalogue$opened)
mean <- ru_reference("mean",open=FALSE)
stopifnot(mean$status=="SINGLE_MATCH",mean$resolution$locator_status=="AVAILABLE",
          mean$resolution$source_status=="INSTALLED_VALIDATED",
          file.exists(mean$resolution$validated_locator),!mean$opened)
missing <- ru_reference("missing_values",open=FALSE)
stopifnot(missing$status=="UNAVAILABLE",missing$reason_code=="MISSING_ASSET",
          missing$resolution$representation_resolved=="compact_md",
          identical(unlist(missing$available_representations),
                    "legacy_guide_qmd"),
          missing$resolution$alternatives[[1L]]$locator_status=="UNAVAILABLE",
          missing$resolution$alternatives[[2L]]$locator_status=="AVAILABLE")
stopifnot(all(vapply(catalogue$matches, function(x)
  all(c("source_status","review_status","rights_status",
        "capability_status") %in% names(x)), logical(1L))))
legacy <- ru_reference("missing_values",representation="legacy_guide_qmd",open=FALSE)
stopifnot(legacy$status=="SINGLE_MATCH",
          file.exists(legacy$resolution$validated_locator),
          !identical(legacy$resolution$validated_locator,
                     mean$resolution$validated_locator))
multi <- ru_reference("hist",open=FALSE)
stopifnot(multi$status=="MULTIPLE_MATCHES",is.null(multi$selected_id),
          length(multi$matches)>=2L)
stopifnot(ru_reference("this phrase is absent",open=FALSE)$status=="NOT_FOUND")
help <- ru_reference("r_mean",representation="rd_alias",open=FALSE)
stopifnot(help$status=="SINGLE_MATCH",
          identical(help$resolution$validated_locator$topic,"mean"))
no_viewer <- ru_reference("mean")
stopifnot(no_viewer$status=="UNAVAILABLE",
          no_viewer$reason_code=="UNAVAILABLE_CAPABILITY",
          no_viewer$resolution$locator_status=="AVAILABLE",!no_viewer$opened)
for(query in list("","../etc/passwd","%2Fescape"))
  expect_condition(ru_reference(query,open=FALSE),"ru_invalid_argument")
for(value in list(NULL,NA_character_,"",c("summary","detail"),"sum"))
  expect_condition(ru_reference("mean",view=value,open=FALSE),"ru_invalid_argument")
expect_condition(ru_reference(NULL,representation="compact_md",open=FALSE),
                 "ru_invalid_argument")
expect_condition(ru_reference("mean",representation="r_script",open=FALSE),
                 "ru_invalid_argument")
resolved <- ns(".ru_content_resolve")
asset <- resolved("histogram-bins.svg","asset",representation="svg")
stopifnot(asset$locator_status=="AVAILABLE",file.exists(asset$validated_locator))
future <- resolved("ru.learning.foundation.03.sites-intro-v1","asset",
                   representation="csv")
stopifnot(future$locator_status=="UNAVAILABLE",
          future$reason_code=="NOT_IMPLEMENTED")
wrong_version <- resolved("mean","reference",content_version="old-version")
stopifnot(wrong_version$reason_code=="INCOMPATIBLE_CONTENT_VERSION")
dotted <- resolved("ru.learning.foundation.03.bridge","learn")
stopifnot(dotted$reason_code=="NOT_IMPLEMENTED")
expect_condition(resolved("../mean","reference"),"ru_invalid_argument")

# State is isolated to an explicit test directory, not learner storage.
state_dir <- tempfile("ru-state-test-")
stopifnot(ns(".ru_state_read")(state_dir)$revision==0L)
rows <- data.frame(competency_id="ru.learning.foundation.01",
 content_version="ru-learning-foundation-v1",status="introduced",
 evidence_kind="exposure",last_attempt="2026-10-24T00:00:00Z",
 review_recommended=FALSE,stringsAsFactors=FALSE)
if (requireNamespace("filelock",quietly=TRUE)) {
 stopifnot(identical(ns(".ru_state_write")(rows,0L,dir=state_dir),1L))
 stopifnot(ns(".ru_state_read")(state_dir)$revision==1L)
 expect_condition(ns(".ru_state_write")(rows,0L,dir=state_dir),
                  "ru_state_stale_revision")
 rows$status <- "practised";rows$evidence_kind <- "guided_attempt"
 stopifnot(identical(ns(".ru_state_write")(rows,1L,dir=state_dir),2L))
 files <- ns(".ru_state_files")(state_dir)
 stopifnot(length(files)==2L)
 writeLines("corrupted-generation",files[2L])
 expect_condition(ns(".ru_state_read")(state_dir),"ru_state_corrupt")
 stopifnot(ns(".ru_state_recover")(state_dir)$recovered_revision==1L)
 stopifnot(ns(".ru_state_read")(state_dir)$revision==1L)
} else {
 expect_condition(ns(".ru_state_write")(rows,0L,dir=state_dir),
                  "ru_unavailable_dependency")
}
rows$status <- "performed_independently"
expect_condition(ns(".ru_progress_validate")(rows),"ru_invalid_argument")

# Metadata contract: declared source file is not current in-memory data.
source_sha <- paste(rep("a",64L),collapse="")
record <- list(
 schema_version="ru.source_context.v1",
 source=list(kind="authored_installed_csv",
   source_id="ru.learning.foundation.03.sites-intro-v1",
   content_version="ru-learning-foundation-v1",source_file_sha256=source_sha,
   source_provenance=list(author="synthetic",declaration_sha256=source_sha,
     verification_state="SOURCE_BYTES_CHECKED",installed=FALSE)),
 parse=list(format="csv",encoding="UTF-8",has_header=TRUE,delimiter=",",
   na_strings=c("","NA"),column_classes=c("character","character","double"),
   parser_contract="utils::read.csv explicit classes"),
 bindings=list(
   list(original_name="row_key",storage_type="character",analytic_role="record_key",
        measurement_unit=NULL),
   list(original_name="site_group",storage_type="character",
        analytic_role="grouping_category",measurement_unit=NULL),
   list(original_name="reading",storage_type="double",analytic_role="outcome",
        measurement_unit=list(declared_code="degree_Celsius",
          canonical_code="degree_Celsius",unit_vocab_version="ru-units-v1",
          declaration_evidence="L2-R3-source-card"))),
 snapshot=list(encoder_id="RU-ANALYSIS-CANONICAL-R3-v1-proposal/B-frame",
   sha256=source_sha,row_count=4L,column_count=3L,
   column_order=c("row_key","site_group","reading"),row_names_kind="automatic",
   missingness_by_column=c(row_key=0,site_group=0,reading=1),data_revision=1L),
 identity_contract=list(source_context_version="ru.source_context.v1",
   method_dictionary_version="1.1-draft.v2",
   identity_codec_id="RU-ANALYSIS-CANONICAL-R4-PROPOSAL",
   source_context_binding="SOURCE_AND_FULL_TYPED_FRAME"),
 review=list(editorial="NOT_REVIEWED",statistical="NOT_REVIEWED",
   instructional="NOT_REVIEWED",accessibility="NOT_REVIEWED",
   rights="NOT_CLEARED",release="NOT_REVIEWED"))
data <- data.frame(row_key=c("G001","G002","G003","G004"),
 site_group=c("North","North","South","South"),
 reading=c(13,NA_real_,18,20),stringsAsFactors=FALSE)
# The input boundary must return an RU typed error before calling base
# row-name internals on a list, vector, matrix, or unsupported subclass.
# Rejected inputs and the source record must remain byte-for-byte unchanged.
reject_data_unchanged <- function(candidate) {
  record_before <- serialize(record, NULL, version=3L)
  data_before <- serialize(candidate, NULL, version=3L)
  expect_condition(ru_source_context(record,candidate),"ru_invalid_argument")
  stopifnot(identical(serialize(record,NULL,version=3L),record_before),
            identical(serialize(candidate,NULL,version=3L),data_before))
  invisible(TRUE)
}
reject_data_unchanged(list(row_key=data$row_key,site_group=data$site_group,
                           reading=data$reading))
reject_data_unchanged(c(13,NA_real_,18,20))
reject_data_unchanged(as.matrix(data))
reject_data_unchanged(structure(data,class=c("unsupported_frame","data.frame")))
reject_data_unchanged(structure(as.list(data),class="data.frame"))
for (new_names in list(c("subject-a","subject-b","subject-c","subject-d"),
                       as.character(seq_len(nrow(data))),
                       sprintf("%04d",seq_len(nrow(data))))) {
  with_names <- data
  row.names(with_names) <- new_names
  reject_data_unchanged(with_names)
}
missing_changed <- data
missing_changed$reading[2L] <- 15
reject_data_unchanged(missing_changed)
columns_changed <- data[,c("site_group","row_key","reading")]
reject_data_unchanged(columns_changed)
metadata_only <- ru_source_context(record,data=NULL)
stopifnot(inherits(metadata_only,"ru_source_context"),
          identical(metadata_only$snapshot$fingerprint_status,
                    "DECLARED_NOT_CHECKED"),
          is.null(metadata_only$snapshot$raw_snapshot_sha256),
          is.null(metadata_only$snapshot$contextual_snapshot_sha256))
if (requireNamespace("digest",quietly=TRUE)) {
 before <- serialize(data,NULL,version=3L)
 ctx <- ru_source_context(record,data)
 stopifnot(identical(before,serialize(data,NULL,version=3L)),
   inherits(ctx,"ru_source_context"),
   ctx$snapshot$fingerprint_status=="LOCAL_R_SERIALIZE_V3_ONLY",
   nchar(ctx$snapshot$raw_snapshot_sha256)==64L,
   ctx$snapshot$raw_snapshot_sha256!=ctx$snapshot$contextual_snapshot_sha256,
   !("data" %in% names(ctx)),!is.data.frame(ctx))
 other <- data
 row.names(other) <- c("subject-a","subject-b","subject-c","subject-d")
 expect_condition(ru_source_context(record,other),"ru_invalid_argument")
 other <- data
 row.names(other) <- as.character(seq_len(nrow(other)))
 expect_condition(ru_source_context(record,other),"ru_invalid_argument")
 other <- data;other$reading[1L] <- 14
 stopifnot(ru_source_context(record,other)$snapshot$raw_snapshot_sha256!=
           ctx$snapshot$raw_snapshot_sha256)
 other <- data[,c("site_group","row_key","reading")]
 expect_condition(ru_source_context(record,other),"ru_invalid_argument")
} else {
 expect_condition(ru_source_context(record,data),"ru_unavailable_dependency")
}
copy <- record
copy$bindings[[3L]]$measurement_unit$canonical_code <- "degree_Fahrenheit"
expect_condition(ru_source_context(copy),"ru_invalid_argument")
copy <- record;copy$source$source_file_sha256 <- NULL
expect_condition(ru_source_context(copy),"ru_invalid_argument")
cat("W1 lane1 installed entry/resolver/capability/progress/source-context regression PASS; GUI, R portability and statistical engine remain untested.\n")