# W2 foundation — human Windows RStudio assessment and answer key

**Not automated learning evidence.** Content version ru-learning-foundation-v1;
outcomes ORI-01/02/03, R-01/02/03/04 and DAT-01. The shipped held-out
fixture is unfamiliar until assessment, not secured against inspection;
this is formative assessment, not a credential or examination.

## Before observation

Use Windows RStudio and a learner-created empty Project. Check that no
destination file will be overwritten. Explain that the learnr editor runs in
a separate environment and that its objects do NOT automatically exist in
the normal R Console or Source editor. Do not silently install packages,
source unknown files, upload student paths or inspect personal research data.

Record only lesson/content version, assessed outcome, attempted/assisted
status and a reviewer observation. H0 = no help. H1 = concept; H2 = location
or analogous problem; H3 = revealed solution. H1–H3 trials count as practice.
A learnr Check response or self-reported completion never certifies normal
IDE competence. Preserve student control over their project.

## Task A — genuine saved Source/Console reproducibility (ORI-03)

Have the learner create a new `.R` script in their Project (not in learnr).
Use an unfamiliar vector `c(4, 7, 10)`; calculate its mean using a function,
print it in ordinary RStudio Console. Observe the learner consciously save
the script, restart the **actual** R session using RStudio, then source
the saved file again without an object inherited from the former session.
Expected numeric result: **7**. Ask what persists (disk file) and what
does not (memory object) and why. Observe object creation AND modification
in an independent free-form assignment separate from guided blanks.
Accept `<-` and `=` for simple assignment. Neither an external Rscript
pass nor a learnr check proves the IDE save/restart interaction was observed.

## Task B — unfamiliar CSV import (DAT-01; supports R-03/04)

Use `sites-transfer-v1.csv` only after the guided trial, without revealing
its values, expected result or a complete import solution in advance.
The source card declares reading in **Fahrenheit**; record_code is a
text log-record identifier, not a person; location_group is a category
which can repeat; quality_flag is synthetic metadata. Empty reading is NA.
The learner must explicitly locate the read-only installed asset via
`system.file("tutorials","ru-learning-foundations","data",
             "sites-transfer-v1.csv",package="rulearn",mustWork=TRUE)`
or consciously copy it to a new, unused Project filename with
`file.copy(..., overwrite=FALSE)` after checking the path. No automatic
RU file copy is permitted.

Observe the learner writing a complete `.R` Source script that imports
a quote-aware CSV with explicit column classes, checks row/column shapes,
retains record_code as character, detects missingness, cites the
source-provided Fahrenheit unit and explains whether observed-case
exclusion is justified. Observe its output, real R restart and rerun.
The instructor can then confirm this separate oracle:

| Property | Expected |
|---|---|
| Number of log records / columns | 5 / 4 |
| First record_code | character "0007", not integer 7 |
| First location_group | "Bay, West" (quoted comma preserved) |
| Numeric readings | 64, 68, NA, 72, 76 |
| Observed readings | 4; one NA |
| Observed-case arithmetic mean after explicit exclusion | 70 Fahrenheit |
| Replacing NA by zero | 56 Fahrenheit (different decision) |

Do not infer independent subjects from unique log records, and do not
treat repeated site labels as unique subjects.

Score four separately visible dimensions: source provenance and units
(25%), schema/types and character identifiers (25%), missingness
identification and explicit decision (25%), transparent reproducible
interpretation and actual Source/Console transfer (25%). A correct
mean without the other dimensions is not independent DAT-01 evidence.

## Representative wrong-answer explanations

- Literal Console prompt `>` or `Rscript --version` pasted as R: show
  Console versus shell terminal.
- `scores == c(...)` does not assign; `mean("scores")` passes text;
  `median` or a hard-coded value is not a mean-function demonstration.
- `x == NA` returns unknown comparisons, not a missing-value detector.
- `as.numeric(factor(site_group))` yields arbitrary category codes,
  not temperature measurements.
- `d["reading"]` is a data frame; `d[["reading"]]` is the numeric vector.
- Wrong CSV separator or naive comma split loses quoted values.
- Default inference can convert code "0007" into 7, losing its meaning.
- Missing to zero changes the mean and denominator without a justified
  policy. No claim of 17 Celsius/70 Fahrenheit without its source card.
- learnr practice is not human observation of a restarted RStudio session.

## Evidence status

Record Windows GUI operations only if actually seen. Otherwise mark
`human_observed_real_ide=NOT_TESTED`, even if Linux Rscript, package
installation and embedded exercises all pass. No lesson in this wave
awards DAT-02/DAT-03, EXP-01/EXP-02 or histogram mastery.