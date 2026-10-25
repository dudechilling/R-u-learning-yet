\name{ru_source_context}
\alias{ru_source_context}
\title{Validate Source Context and Optionally Fingerprint Current R Data}
\description{
Validate a versioned source metadata record, optionally check an
exact data frame against its declared schema, and produce local
R serialization fingerprints. This is not a statistical engine or
a portable canonical analysis-plan identity.
}
\usage{
ru_source_context(record, data = NULL)
}
\arguments{
\item{record}{A named list satisfying the
\code{"ru.source_context.v1"} schema: \code{schema_version},
\code{source}, \code{parse}, \code{bindings}, \code{snapshot},
\code{identity_contract}, and \code{review}. Source information
includes its kind, exact source ID/version, source-file digest where
applicable, and declared provenance. Bindings identify one outcome
and exact column roles and optional declared physical units. The
snapshot supplies row/column counts, column order, automatic row-name
semantics, per-column missing counts, and a data revision.}
\item{data}{\code{NULL} to validate metadata without checking current
observations; otherwise a plain data frame with the exact declared
column names and order, primitive storage types, number of rows,
missingness counts, and automatic row names. Other object classes are
not supported. A local \pkg{digest} installation is required when
fingerprinting data.}
}
\details{
Record validation checks the named schema, source kind, parser
declarations, one outcome binding, column identities/types, declared
unit codes and versioned provenance, snapshot dimensions and
missingness, identity fields, and distinct review/rights declarations.
It checks the \emph{structure and consistency of declarations}; it
does not fetch source files, confirm an asserted license, adjudicate
study design, or prove that a source was installed.

With \code{data = NULL} the returned record's
\code{snapshot$fingerprint_status} is \code{"DECLARED_NOT_CHECKED"};
no fresh observations are hashed. With a matching data frame and
\pkg{digest} available, two SHA-256 strings are added:
\code{raw_snapshot_sha256}, for actual data and R attributes, and
\code{contextual_snapshot_sha256}, for that local digest plus source,
parsing, binding, revision, and identity declarations. The status is
\code{"LOCAL_R_SERIALIZE_V3_ONLY"}. These use
\code{digest::digest(..., serialize = TRUE, serializeVersion = 3L)}:
they are \strong{local R fingerprints}, not L3's frozen
cross-platform canonical frame/plan hashes or proof of scientific
suitability. The declared \code{snapshot$sha256} is not replaced by
these newly computed fields.

The function copies the record before adding its fingerprint fields
and does not return or save the input data rows. Neither identical
numeric values from different sources nor unit labels can silently
substitute for the exact source/column/frame identity. For example,
an authored \code{degree_Celsius} declaration and a versioned
legacy \code{degC} alias are different source declarations despite
a shared canonical physical-unit meaning. Unit handling here is
validation of the declared codes, not measurement conversion.

Malformed records raise a \code{ru_invalid_argument} condition.
With a valid record, unsupported list, vector, matrix, and other
non-data-frame \code{data} inputs raise \code{ru_invalid_argument}
before row-name inspection. An otherwise plain data frame with
explicit row names inconsistent with the automatic-row-name contract
also raises this condition. A missing \pkg{digest} dependency for
otherwise matching data raises \code{ru_unavailable_dependency}.
}
\value{
A named list with class \code{ru_source_context}, containing the
validated and copied \code{record} fields. The \code{snapshot}
contains \code{fingerprint_status}; when matching \code{data}
are supplied and \pkg{digest} is present it also contains local
\code{raw_snapshot_sha256} and
\code{contextual_snapshot_sha256} strings. It contains no
data-frame observations, executable analysis, verified competence,
or portable statistical plan identity.
}
\seealso{\code{\link{ru_reference}}, \code{\link{ru_capabilities}}}
\examples{
# A constructed demonstration; the repeated digest string is a
# schema-valid placeholder, not a verified source or plan fingerprint.
placeholder <- paste(rep("a", 64L), collapse = "")
sample_data <- data.frame(reading = c(13, 18))
record <- list(
  schema_version = "ru.source_context.v1",
  source = list(
    kind = "constructed_in_memory", source_id = "ru.analysis.example",
    content_version = "example-v1", source_file_sha256 = NULL,
    source_provenance = list(
      author = "Synthetic example", declaration_sha256 = placeholder,
      verification_state = "DECLARED_ONLY", installed = FALSE)),
  parse = NULL,
  bindings = list(list(
    original_name = "reading", storage_type = "double",
    analytic_role = "outcome", measurement_unit = NULL)),
  snapshot = list(
    encoder_id = "example-only", sha256 = placeholder,
    row_count = 2L, column_count = 1L,
    column_order = "reading", row_names_kind = "automatic",
    missingness_by_column = c(reading = 0), data_revision = 1L),
  identity_contract = list(
    source_context_version = "ru.source_context.v1",
    method_dictionary_version = "example-v1",
    identity_codec_id = "example-only",
    source_context_binding = "SOURCE_AND_FULL_TYPED_FRAME"),
  review = list(
    editorial = "NOT_REVIEWED", statistical = "NOT_REVIEWED",
    instructional = "NOT_REVIEWED", accessibility = "NOT_REVIEWED",
    rights = "NOT_CLEARED", release = "NOT_REVIEWED"))
declared <- ru_source_context(record)
declared$snapshot$fingerprint_status
if (requireNamespace("digest", quietly = TRUE)) {
  local <- ru_source_context(record, sample_data)
  local$snapshot$fingerprint_status
}
}
