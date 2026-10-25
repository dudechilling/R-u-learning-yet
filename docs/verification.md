# RU — independent W2 pilot verification / future human target-platform gates

This L5-owned procedure is not Windows, human, accessibility, statistical-specialist or rights acceptance. Bind every observation to an exact supervisor-designated candidate Git SHA, tree SHA, package archive SHA-256, installed path, tester, timestamp, platform and version. The L1 G1 staging candidate is not a W2 implementation.

## 1. Windows installation and provenance

**Frozen Windows G2 target:** Windows 11 x86_64; R 4.5.2; RStudio Desktop 2026.10.0 build 233. Different actual versions require explicit supervisory approval or a BLOCKED profile-mismatch record. Linux headless certification is not Windows qualification; macOS remains outside G1-tested scope.

In **PowerShell** (not the R Console), independently run:

    Get-FileHash -Algorithm SHA256 -Path "<exact-approved-package-archive>.tar.gz"
    where.exe Rscript

Compare the digest with the independently approved manifest BEFORE installation. Obtain all released dependencies and their versions/hashes before a planned offline session. Restart RStudio before switching installed candidates. Install the exact package archive in an isolated user-owned private R library; never modify system-wide R libraries, the installed package's own teaching assets, or another person's learner state.

In the actual **R Console**, record:

    R.version.string
    R.version$platform
    sessionInfo()
    rstudioapi::versionInfo()  # only if supported and available
    find.package("rulearn")
    packageVersion("rulearn")
    getNamespaceExports("rulearn")
    tools::R_user_dir("rulearn", "data")

The package version string alone is not source identity. Confirm the library really contains the exact archive. Record RStudio's About screen/version separately when rstudioapi cannot report it.

## 2. Automated QA profiles

From a terminal using the same R library as the pilot, with an absolute evidence directory OUTSIDE the source repository:

    Rscript --vanilla scripts/verify-ru.R --profile core --evidence "<external-dir>"
    Rscript --vanilla scripts/verify-ru.R --profile ui --evidence "<external-dir>"
    Rscript --vanilla scripts/verify-ru.R --profile offline --evidence "<external-dir>"
    Rscript --vanilla scripts/verify-ru.R --profile artifact --archive "<source.tar.gz>" --expected-sha256 "<approved-sha256>" --evidence "<external-dir>"
    Rscript --vanilla scripts/verify-ru.R --profile all --archive "<source.tar.gz>" --expected-sha256 "<approved-sha256>" --evidence "<external-dir>"

The profiles return exit 0 only for completed automated PASS; 1 for FAIL; 2 for BLOCKED mandatory capabilities/evidence; 3 for invalid arguments/location. Human review/rights remain separate. These profiles supplement rather than replace unchanged scripts/ci-check.R. A missing UI browser journey, network-off packet evidence, three lessons, statistical engine or expected archive identity is not an automatic PASS. Do not require an operator to suppress checks or install a dependency into the global R environment.

## 3. Three actual learnr foundation lessons and Source/Console transfer

With the exact W2 installed, invoke RU's no-argument workspace selector, explicitly select Learn and record the three actual installed lesson IDs. Verify instruction covers Source vs Console, R objects/vectors, functions, indexing, NA, data frames and CSV import in connected progression. For each lesson, test H0–H3 hints, correct response, an independently legitimate correct alternative, a plausible wrong response, blank input, R error feedback, back/reset/resume and actual focus restoration. Do not equate a guided answer with independent competence.

Save a learner-created R script into a writable **project** directory via RStudio Source; run that exact file via the RStudio Console/Source action. Test the same operation independently with a held-out file/object name and without hints. Record the actual Source text, execution path, Console output and whether code was editable; do not edit installed assets. Confirm character IDs (including "0007") retain leading zeros and grouping by site is not evidence of unique independent participants.

Locate the actual installed guided and held-out CSVs using system.file(..., package="rulearn"), record exact basename, file size, SHA, copied project path, import parser arguments, names, str, row count, NA counts and source declaration. Missing installed CSV means BLOCKED, not a fabricated success. The independent synthetic G2 guided oracle is four rows (13, NA, 18, 20), 3 numeric observed cases, mean 17, median 18, sample variance 13 and SD sqrt(13), with explicitly declared degree_Celsius. The held-out source is Fahrenheit; never silently convert units or NA to zero. Test retrieval/resumption across RStudio restart with no unearned performed_independently status.

## 4. One real describe.numeric workflow

Use only the W2-approved first describe.numeric workflow, not the 17 later method families. With the actual parsed data and separately reported source context, compare these independent **status and reason** expectations before execution:

- Complete-case exclusion decision missing: NEEDS_INPUT / EXCLUSION_CONSENT_REQUIRED.
- Same exclusion explicitly denied: UNSUPPORTED / CONSENT_DENIED.
- Fail-on-missing with observed NA: INVALID / MISSINGNESS_POLICY_VIOLATION.
- Report-only missingness with center/spread requested: NEEDS_INPUT / MISSINGNESS_TREATMENT_REQUIRED.
- Scoped affirmative exclusion: READY / ELIGIBLE_SUBJECT_TO_RECORDED_DESIGN.
- Clustered site descriptions may be descriptive-READY after exclusion consent; clustered sites do not establish independent units or inferential assumptions.

For the approved synthetic reading vector (13,NA,18,20), expected calculations: n_raw=4, n_observed=3, n_missing=1, sum=51, mean=17, median=18, sample variance=13, sample SD=sqrt(13), min=13, Q1=15.5, Q3=19, max=20. Review ordinary generated R code without running it first. Opening Analyze or constructing a READY plan must not execute data. Test execution requires an explicit user confirmation, a current data/schema/snapshot/attestation match and an inspectable result.

Adversarial replay: change one reading, site label, row order, attestation revision or parser/measurement unit. Prior execute and result-bound export permission must be revoked. No research rows in plan, routine logs or default diagnostics. Missing CURRENT data blocks result export; prior cancelled/failed execution cannot be exported as a successful result; existing path rejects overwrites; include_data=TRUE requires distinct reviewed disclosure consent. Code-only exports before execution must be labelled NOT_EXECUTED/current-data-not-verified, never a successful analysis.

## 5. References, Viewer, keyboard and accessibility

Navigate all six resolver surfaces: learn, analyze, reference, example, asset, native_help. NULL query opens catalogue, MULTIPLE_MATCHES demands explicit ID, multiple representations of one ID are not separate search results, missing compact content never silently becomes a legacy page. Test an explicitly selected legacy guide, installed native Help, available compact numeric description and unavailable version. Verify unsafe path and symlink escapes remain rejected. Record separately (a) resolved local content and (b) actual Viewer opened; catalogue metadata alone is not a displayed page.

On **actual** RStudio Desktop record the real 960, 400 and 320 CSS-pixel viewport dimensions (not guessed window widths), zoom/text scaling, visible focus and focus restoration after close/back. Navigate using Tab, Shift+Tab, Enter and Escape plus RStudio Source/Console focus controls actually listed by that installed IDE. For each exercise/reference/figure record accessible label, meaningful alternative text, histogram closure and correct data/unit notation. A screenshot, browser automation or WCAG heuristic is not screen-reader or keyboard-human evidence. Record actual screen-reader software/version and independent observation before accepting WCAG 2.2 AA target.

## 6. Offline, state, cancellation and resumed work

Install all required local packages/assets **before** disconnecting. Establish actual network-disabled state with independent OS evidence and observe attempted outbound requests using controlled firewall/packet/process traces bound to the tested process. Record trace tool, interval, process identity and redaction; being disconnected without attempted-request observation is insufficient. Run all three lessons, Source/Console import, local reference, the numeric workflow, export and reopening in this condition. Avoid transmitting raw learner/research records in screenshots or logs.

In an isolated pilot state, create a guided attempt and a versioned progress generation; close/cancel and reopen RStudio and inspect which exact state survived. Attempt a stale revision and verify a typed refusal rather than silent overwrite; corrupt newest state in disposable QA only, not a real learner's directory. Cancel an in-flight analysis and verify no false SUCCESS, no export, no orphan localhost process and no reusable one-shot confirmation. Rerun a new, explicit confirmation using unchanged current data if appropriate. If any process cannot be tested, mark BLOCKED/NOT_TESTED.

## 7. Human, rights and supervisor separation

Human novice learning and held-out transfer, faculty review, statistical specialist audit, Windows target GUI, real keyboard/screen reader, privacy/offline, release operations and source-by-source redistribution rights are distinct gates. Linux headless R CMD check proves none of them. Permission labels do not establish redistribution clearance. L5 records exact candidate/observation and gives an advisory; only the supervisor can approve G2, main integration or publication. Do not change independent expected outputs to make product code pass.