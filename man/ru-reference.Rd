\name{ru_reference}
\alias{ru_reference}
\title{Search the Installed RU Reference Catalogue}
\description{
Inspect the offline RU reference index and available local representations
without silently opening the first search hit or executing example code.
}
\usage{
ru_reference(query = NULL, view = c("summary", "detail"), open = TRUE,
             representation = NULL)
}
\arguments{
\item{query}{Omit or supply \code{NULL} for the catalogue. Otherwise,
supply one nonblank character string containing an exact reference ID
or a search phrase. Missing values, vectors, and unsafe path-like
strings are invalid.}
\item{view}{Either \code{"summary"} or \code{"detail"}. Omission means
\code{"summary"}, despite the two-element formal default.
An explicitly supplied vector of both choices is invalid.}
\item{open}{One nonmissing logical. \code{FALSE} returns structured
metadata without attempting to launch any Viewer or native Help.}
\item{representation}{\code{NULL} for the registered default or one
explicit representation available for the selected surface, such as
\code{"compact_md"}, \code{"legacy_guide_qmd"}, or
\code{"rd_alias"}. A representation cannot be requested with a
\code{NULL} query. A representation that is invalid for the selected
surface raises \code{ru_invalid_argument}.}
}
\details{
Exact registered IDs take precedence over case-insensitive substring
matching of reference IDs and titles. A query matching more than one
distinct ID returns \code{MULTIPLE_MATCHES} with candidates and does not
choose one. A catalogue request returns \code{CATALOGUE}; an indexed
query without matches returns \code{NOT_FOUND}.

An exact result whose selected installed locator is available returns
\code{SINGLE_MATCH} when \code{open = FALSE}. An identified target with a
missing requested representation or unavailable capability returns
\code{UNAVAILABLE}, with a reason code. In this W1 implementation
\code{open = TRUE} does \emph{not} launch an independently verified
Viewer or native Help session: a resolvable single match instead reports
\code{UNAVAILABLE_CAPABILITY}, and \code{opened} remains \code{FALSE}.
An indexed entry or package source alone is not evidence that content
was displayed, reviewed, accessible, or cleared for redistribution.

For reference topics the default representation is \code{"compact_md"}.
The accepted G1 source indexed \code{"missing_values"} as a compact
reference but lacked that compact page. The W2 L4 source separately
authors \code{lessons/missing_values.md}. It becomes available as
\code{"compact_md"} only when actually installed and resolved from the
registered locator; the distinct legacy Quarto guide remains available
under \code{representation = "legacy_guide_qmd"}. Do not treat the
guide as a substitute compact page or infer installation from a registry
row alone. Native Help IDs such as
\code{"r_mean"} use \code{"rd_alias"}, not a fabricated compact page.
A single ID with several representations is not a multiple-ID search
match. The structured \code{resolution} differentiates requested
representation, installed source locator, capability, content review,
and rights declarations; rights declarations are not clearance.

Invalid arguments raise \code{ru_invalid_argument}, rather than returning
a successful result with an error label. The existing legacy
\code{ru_open()} route is not changed by this function.
}
\value{
A \code{ru_reference_result} list with \code{schema_version},
\code{status}, \code{reason_code}, \code{query}, \code{view},
\code{open_requested}, \code{opened}, \code{selected_id},
\code{requested_representation}, \code{selected_representation},
\code{available_representations}, \code{matches},
\code{resolution}, \code{capability_status}, and
\code{origin_return}. Status values include \code{CATALOGUE},
\code{SINGLE_MATCH}, \code{MULTIPLE_MATCHES}, \code{NOT_FOUND},
and \code{UNAVAILABLE}. \code{resolution}, when present, is a
\code{ru_content_resolution} list with distinct locator, source,
review, rights, and capability fields. Direct invalid arguments throw
a condition; they do not produce a sixth successful result status.
}
\seealso{\code{\link{ru_workspace}}, \code{\link{ru_capabilities}},
\code{\link{ru_open}}}
\examples{
catalogue <- ru_reference(open = FALSE)
catalogue$status
one <- ru_reference("mean", open = FALSE)
one$status
ambiguous <- ru_reference("hist", open = FALSE)
ambiguous$status
missing <- ru_reference("missing_values", open = FALSE)
missing$status
missing$selected_representation
guide <- ru_reference("missing_values",
                      representation = "legacy_guide_qmd", open = FALSE)
guide$selected_representation
}
