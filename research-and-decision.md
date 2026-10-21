# R-u-learning-yet: competitive research, accessibility, and decision record

**Project:** R-u-learning-yet — offline RStudio statistics reference
**Review date:** 2026-10-20 (UTC; some documentation may have newer revisions)
**Authoring basis:** `R-u-learning-yet_Correction_and_Research_Spec.md`, read in full before this work
**Default-branch baseline:** `c4f0dc48f7013bcbb4a7441ad0205a324ea030b1`
**Development:** `steward/f3f86112/research-correction` in an isolated m710 worktree; no push or merge authorized
**Primary objectives, equal weight:** rapid **correct** application; delayed independent reuse

This document is the **one canonical** record of what was examined, the evidence, the decision, and what remains unverified. The program itself uses its normal `README.md` and `methodology.md` to explain how to install and maintain the package; neither substitutes for the research record.

## Phase 0 — Baseline: complete

### Source, revision, and inspection

The baseline is the actual public `origin/main` at `c4f0dc48`, **not** the pre-existing dirty development checkout. It was exported read-only using:

```sh
git archive origin/main | tar -xf - -C /tmp/ru-competitive-baseline-20261020
R CMD INSTALL --library=/tmp/ru-baseline-lib-20261020 \
  /tmp/ru-competitive-baseline-20261020
```

The installed baseline identifies itself as `rulearn 0.2.0`. It has 46 problem scripts, 46 corresponding Quarto guides, 101 decision routes (historical count from the initial review), publicly exported search and statistical wrapper functions, base-R plotting helpers, and two test scripts. There are no full native-R concept help articles. `LICENSE` explicitly declares **no selected redistribution license**; public visibility is not permission to copy third-party material. The optional `palmerpenguins` data dependency remains optional; named `datasets` tables can be used offline.

The worktree inspected under `<PRESERVED_PRIOR_WORKTREE>` already contained substantial **uncommitted** implementation by another actor; it was inspected without rewriting or committing that work. Its content was copied via a read-only Git patch into a separate task-owned worktree after Phase 3, not conflated with the baseline.

### Representative observed baseline workflows

| Learner task | Actual baseline command / result | Consequence |
|---|---|---|
| Look up “What is stationarity?” | `ru_find("What is stationarity?")` returns the `stationarity` calculation walkthrough; `help("stationarity",package="rulearn")` returns zero help entries | No installed concept definition |
| Understand `sd()` | `ru_find("How does sd function work?")` returns unrelated normal-tail calculation first, then a standard-deviation method | Poor discovery of R syntax |
| Find a histogram | `ru_find("How do I make a histogram?")` ranks a bar-chart guide ahead of the correct guide | Wrong method can be reached first |
| Inspect executable code | `ru_code("histogram")` prints `ru_apply("histogram", data=d, x="eruptions")` | Conceals the commands the student needs to learn |
| Get an editable source file | No exported `ru_edit()` in baseline | Requires manual copying |
| Use wrong column | `ru_apply("mean_median",ru_data("iris"),x="unknown_column")` throws a clear “Column not found” error | An existing safeguard worth preserving |
| Return to concept later | `ru_find()` can be used again, but native `?stationarity` is absent | Search can find a task, not an explanation |

Do not assign a numerical time to these workflows: no RStudio user timing or human comprehension observation was taken. The number of console commands to reach a title is not equivalent to the time needed to understand it, adapt code, or recover from a mistake.

### Baseline deficiencies

1. Search indexes tasks, not distinct **concept / R function / walkthrough** content types.
2. The scripts use `ru_apply()` rather than ordinary R commands. The underlying native steps cannot be learned from those short scripts alone.
3. The Quarto guides are excluded from the baseline installed package by `.Rbuildignore`.
4. There is no built-in path from a definition to related functions, editable examples, and the next appropriate method.
5. The previous review identified silently ignored weights, one-sided alternatives, plot suppression, irregular time lags, and an unreachable route. These defects were explicitly regression-tested during the subsequent development, not assumed fixed from static inspection.
6. No published evidence exists that users solve a novel problem more quickly or remember the method a week later.

**Phase 0 decision:** Retain the installable R package and its real datasets, statistical safeguards and existing tutorials. Do not retain opaque wrappers as the principal learning experience.

**Phase 0 unknown:** No Windows RStudio, screen-reader, narrow-Help-pane, or human learner test was performed.

## Phase 1 — Competitive capability audit: complete for official sources; execution coverage explicitly limited

**Methods:** official documentation and public code/release notes were read in independent product passes; selected R packages were installed in an isolated library; common discovery, definition, data-application and error-recovery tasks were compared to baseline. The installed machine supports R 4.5.2. Package listings and web release notes were checked on 2026-10-20. Native R console behaviour was executed, but the RStudio graphical IDE and interactive websites were not controlled as a participant would use them.

| Candidate and inspected revision | Observed or directly documented capability | Relevant limitation / uncertainty | Extension point, licensing |
|---|---|---|---|
| **Native R and Posit RStudio IDE** | `?`, `help()` and `help.search()` already index packaged topics; RStudio shows help in its Help pane; native `.Rd` topics, R scripts, keyboard execution, accessible IDE guidance | Search terminology can be overly technical. RStudio UI keyboard and screen-reader use were documented, not operated here | Extend native `man/*.Rd` and package indexing; no new runtime needed. https://docs.posit.co/ide/ |
| **Posit `learnr` 0.11.6** (installed) | `learnr::available_tutorials("learnr")` listed 11 packaged sample tutorials including data basics, filtering and quiz questions; official docs confirm exercises, hints, checkers, local Shiny tutorials and saved progress | Interactive Shiny UX, progress persistence and screen-reader flow were **not** exercised here. A full tutorial is unnecessary overhead for a quick definition | Apache-2.0. Adopt later only for a demonstrated optional practice need. https://rstudio.github.io/learnr/ |
| **Project MOSAIC / `mosaic`**, current official reference | Formula-aware summaries including `mean()` and `sd()`, `favstats()`, `tally()`, teaching formula patterns. Official code shows how formulas support statistics with data | Full `mosaic` and `ggformula` were **not executable** in this environment: `ggiraph` dependency failed compilation; no comparative runtime timing | `mosaic` GPL-compatible open teaching project; do not duplicate its formula/calculation functions. https://www.mosaic-web.org/mosaic/ |
| **`mosaicData` 0.20.4** (installed) | `data("Weather",package="mosaicData")` loaded 3,655 rows and 25 columns; authentic ready-made teaching data | A teaching dataset is not a guide to choosing a method or interpreting model assumptions | GPL >=2 from installed DESCRIPTION; can reference sources and depend optionally if needed; no dataset copying. https://www.mosaic-web.org/mosaic/ |
| **`ggformula` 2.0.0** (official documentation) | Formula-based plotting and statistics; appropriate for consistent syntax | Installed build **not completed** due to dependency compilation; cannot claim local plot success | Keep existing base R plotting; add `ggformula` only if a benchmark justifies a new dependency |
| **ModernDive, second edition v2.9.0 release** | Public online book has webR edit-and-run blocks, 115 quick checks, 511 exercises, glossary, source examples, misconception warnings, progressive chapters and visualizations | WebR and browser accessibility marketing were **not independently tested**. Book content is primarily an online/reading experience, not an installed console command | CC BY-NC-SA 4.0 book; **do not copy text or assets** into this repository. https://moderndive.com/v2/ and https://github.com/moderndive/ModernDive_book/releases |
| **`swirl` 2.4.5** (installed) | Guided interactive learning through the R console; actual installed exports and suggested course directory inspected | Courses were not installed or run. Sequential guided course selection differs from a two-command help lookup | MIT + LICENSE per installed DESCRIPTION. Refer learners to it for structured practice, not as an imposed step. https://swirlstats.com/ |
| **OpenIntro** | Public introductory statistics text, worked R labs, figures, exercises | No local course execution or license clearance for redistributing book content | Adopt by citation/link, not copying. https://www.openintro.org/ |
| **R for Data Science, second edition** | Clear data-handling workflow, named datasets, native editable R syntax, chapter-level progression | Broad data-science progression is longer than a quick unfamiliar statistical-term lookup | Link to relevant established chapters. https://r4ds.hadley.nz/ |

### Common-task analysis

The same question categories were considered for each candidate: definitions (`population`, `sample`, `stationarity`, `standard deviation`, `p-value`); method choices (histogram vs bar chart, SD vs SE, paired groups); applications (CSV, names, grouped means, histogram, missing data, comparison); and errors (object not found, wrong column, numeric data parsed as text, invalid assumptions). Competitor evidence is uneven: definitions and interfaces were documented from their real materials; install-and-run was done for native R, `learnr` discovery, `mosaicData` data, and `swirl` exports; **full equal-task human-in-UI competitive timing was not performed**.

Best known capability by need:

- **RStudio and base R:** installed Help, editable commands, plots, keyboard shortcuts, local usage.
- **ModernDive:** polished narrative progression, misconceptions, interactive R examples and optional quick checks.
- **MOSAIC:** consistent formula syntax for many teaching operations and authentic datasets.
- **learnr / swirl:** interactive, guided practice and hints, with different time/flow costs.
- **R-u-learning-yet** only has a justified niche if unfamiliar everyday phrasing connects **directly** to offline native R help and an editable method without forcing an interactive course.

**Licensing boundary:** reuse ideas, native R APIs and public URLs; never import book chapters, commercial illustrations, private lessons, or unlicensed data into `rulearn`. The repository license decision remains unchanged.

**Phase 1 decision:** Native R documentation and code editing are primary. Posit `learnr` remains a future optional instruction format; MOSAIC and ModernDive are external resources, **not engines to rebuild**.

**Phase 1 unknown:** GUI-only accessibility behaviour, product usability, offline browser execution of ModernDive, relative human task speed, and the uninstalled MOSAIC plotting functions.



## Phase 2 — Evidence-ranked learning and accessibility gaps: complete literature and task review, human verification pending

**Do not equate diagnoses.** These are task-level barriers, not a rule about what any student with dyscalculia, dyslexia, ADHD or mathematical anxiety must need. The assignment-transfer issue can occur in learners without diagnoses. Classifications below describe the strength and scope of **external** evidence, not tested performance of this package.

| Barrier observed or defined | Evidence and classification | Smallest instructional response | What remains uncertain |
|---|---|---|---|
| Search fails when a student knows “average” but not “mean”; spelling is uncertain | **Direct baseline observation**; W3C cognitive accessibility guidance recommends clear terms and consistent navigation (**practitioner guidance**) | Local synonym and conservative typo handling, labels for concept/function/walkthrough, direct open command | Whether the vocabulary covers real assignment wording; false corrections must be monitored |
| Translating symbols, numbers and percentages into R arguments; distinguishing SD from SE | Mathematics/numeracy reviews and CAST UDL recommend multiple representations and explicit notation (**research + practitioner guidance**, not diagnosis-specific proof for this package) | Name data, units, observed values, model parameters and formula roles in words; show a labelled graph alongside native code | Individual mathematical needs and impact on computational reasoning |
| Tracking many steps while switching Console, Help, assignment and script | W3C cognitive guidance on clear steps and consistent positioning, executive-function literature (**practitioner guidance and heterogeneous research**) | Two-command discover/open path; predictable headings; editable script with comments; no compulsory lesson; clear first action | Actual interruption recovery times, pane behaviour and preferred amount of detail |
| Reading fatigue from dense unfamiliar text or terminology | W3C WCAG 2.2 structural criteria and additional cognitive guidance (**normative web criteria vs informative recommendations**) | Meaningful headings, short sections, no decorative clutter, selectable code, ordinary language, adjustable native RStudio display | Screen-reader and real resizing/reflow not tested with assistive technology |
| Knowing which chart to select and how to read bars and axes | Research on graph interpretation and worked examples; concept confusion is well documented (**education evidence**) | Histogram/bar chart comparison, units, count denominator, graph alternative text, step-by-step native example | Whether graph alt text and annotation improve interpretation for diverse learners |
| Copying code successfully without transferring to a new dataset | Studies/reviews of worked examples, worked-step fading and programming support (**research, not direct proof here**) | Native editable scripts, field substitution instructions, guided adaptation, explain why and when a method is wrong | The learner might still copy the code; independent transfer requires testing |
| Remembering a method next day or one week later | Distributed practice and retrieval-practice reviews (**broad support**) but specific problem-solving evidence mixed, including non-benefits in some mathematical tasks | Optional “Remember it” prompts and changed-dataset practice, without gating immediate access | Actual delayed retention effects; whether this user's pacing differs |
| Request for special dyslexia fonts, visual-only instruction, rewards or mandatory quizzes | Evidence for dyslexia-specific fonts is mixed/weak; no universal benefit established (**unsupported universal claims**) | Keep system typography, provide text alternatives and native controls; do not prescribe fonts or gamification | Individual user preferences must be tested rather than inferred |

Key evidence references:

1. W3C normative WCAG 2.2 specification and understanding: https://www.w3.org/TR/WCAG22/ and https://www.w3.org/WAI/WCAG22/Understanding/
2. W3C COGA supporting **informative** practices: https://www.w3.org/WAI/cognitive/ and https://www.w3.org/WAI/WCAG2/supplemental/patterns/o1p03-consistent-design/ ; these are NOT additional mandatory WCAG success criteria.
3. CAST Universal Design for Learning Guidelines 3.0: https://udlguidelines.cast.org/
4. Posit accessibility and IDE help: https://docs.posit.co/ide/
5. Dunlosky et al., 2013, utility of learning techniques (practice testing and distributed practice): https://doi.org/10.1177/1529100612453266
6. Muldner, Jennings and Chiarelli, 2023, *A Review of Worked Examples in Programming Activities*: https://eric.ed.gov/?id=EJ1381113
7. Barbieri et al., 2023, meta-analysis of worked examples and mathematics performance: https://doi.org/10.1007/s10648-023-09745-1
8. Mathematical word-problem retrieval-practice results are not uniformly positive: https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2023.1093653/full
9. WCAG 2.2 *Resize Text*, *Reflow*, *Keyboard*, *Non-text Content*, *Labels or Instructions*, *Error Identification* and *Focus Appearance* must be considered separately, not inferred from one successful render.

### Concrete task-level audit

The current reference design must pass these **without invented data or assistance**:

1. “What is a sample?” → select concept, not a sampling calculation.
2. “What does a p-value mean?” → correct definition before a t-test.
3. “How does sd work?” → explain the actual `sd()` function, sample denominator and missing values.
4. “stasionarity”, “histgram” → conservative spelling suggestion, not an unrelated operation.
5. “Object not found”, “numeric data imported as text” → inspect the data/object, not a statistics calculation.
6. “I have category names, not measured numeric values” → bar chart, not histogram.
7. “Same people measured twice” → paired procedure, not independent-groups test.
8. “I stopped halfway through” → persistent printed guide, unchanged source script, repeatable console commands.
9. “I can follow this example but not adapt it” → change to a second named dataset and explain what changed.
10. “I can reproduce a chart but cannot explain it” → describe axes, mark, comparison, units, exclusions and limitations.

**Phase 2 decision:** Favor a clear searchable reference with deep, optional worked examples and optional later retrieval. Do not implement diagnoses, hidden adaptation, auto-generated answers, learner profiling, mandatory progression or reminders.

**Phase 2 unknown:** No consented participant interviews, real assistive-technology sessions, instrumented interruption task, or delayed recall results.

## Phase 3 — Adopt / extend / build gate: complete

**Decision: B with the minimum compatible D** — use native R reference infrastructure and existing educational materials; keep `rulearn` only as a focused offline extension for question translation, novice-oriented native documentation and editable examples.

| Proposed feature | Barrier | Existing capability / insufficiency | Evidence and proposed measure | Maintenance |
|---|---|---|---|---|
| Deterministic question search / synonyms / conservative typos | Does not know formal term or makes a spelling error | `help.search()` already works for known terms; baseline indexed only operations and ranked bar chart over histogram | 22 pre-declared query benchmark: top-ranked relevant result and false-correction rate; future in-class trials | Maintain a small local index and tests; no network, vector database or LLM |
| Native `.Rd` concept and function references | Can run a formula but cannot define or interpret it | R already provides installed searchable help; baseline has no concept page | Native `help("stationarity",package="rulearn")` and direct source/related links; read-and-explain task | Source review as statistical guidance changes; avoid duplicated copies |
| `ru_guide()` and `ru_edit()` | Example can't be read offline and script is opaque | Existing Quarto and R source editor already solve display/edit; baseline package excluded guides, no safe copy command | One installed guide and one editable script, no overwrite; compile/run with changed dataset | Small package file-access functions, tests only |
| Canonical native-R flagship worked examples | Learner learns wrapper instead of `hist()`, `table()`, `t.test()` | R function docs accurate but often not novice-contextual; ModernDive offers strong online pedagogy | Actual native code in HTML and editable file, interpretation and mistakes, optional transfer task | Maintain scripts as only canonical executable source and render them into Quarto |
| Error-recovery help topic | “object not found” search found an unrelated method | Native R errors exist but are not indexed by assignment-level words here | Keyword search should return concrete steps; user must locate cause in alternate dataset | One help entry; no error-catching system or telemetry |
| Optional retrieval/transfer prompts | Recall fades when example is copied | `learnr` and `swirl` already support guided practice | Embedded optional questions first; later adoption of `learnr` only if users request and benchmark warrants | Near-zero extra runtime; no state tracking |
| New custom calculation engine, GUI, RStudio addin, analytics backend | No distinct evidence-gated need | Posit, base R, MOSAIC, ModernDive already provide substantial alternatives | No established extra outcome or benefit | **REJECT**: unnecessary maintenance and accessibility burden |

**Architecture gate:** No material replacement is warranted by the available evidence. Retain the installable package, `man/`, `R/`, `inst/guides/` and `inst/examples/`, Quarto as an optional rendering route, and ordinary base-R commands. Preserve existing public `ru_apply()` for compatibility but stop expanding its operation list. Retain explicit statistical safeguards. Keep the licensing question with the author.

**What would reverse this decision?** If a consented comparator evaluation finds no practical time/retention advantage of this extension over the strongest native/ModernDive approach, recommend adoption and stop unnecessary custom development. If evidence later requires replacing RStudio with a new application shell, obtain explicit human review before implementing.

## Phase 4 — Experience design: implemented for the reference core; remaining guides not yet equally revised

**Moment A, apply now:**

1. Enter `ru_find("How do I make a histogram?")` in the RStudio Console.
2. Search shows type, title and direct opening command; copy it or use `ru_open("histogram")`.
3. See the quick answer, what inputs and assumptions matter, and native R steps.
4. Run `ru_edit("histogram")` to create a safe editable copy in the current project. The installed copy remains untouched.
5. Replace the dataset variable and axis units; execute normal R code and interpret the graph before claiming any inference.

**Moment B, remember later:** On the same article, optionally hide the worked answer, use another authentic dataset, recreate the command and explain its output in words. Suggested checks immediately, 24 hours and seven days are **a trial protocol, not product-proven learning effects**. The prompts are not compulsory and store no user information.

Native R references provide the definition independently of code execution and link to related concepts, statistical limitations and official R functions. In the full walkthroughs, Quarto references the same installed example script used by the editor: there is no second independently maintained code copy for the fully revised flagship lessons.

**Phase 4 unknown:** Full Windows RStudio UI design, screen reader navigation, font/contrast preference, low-distraction and actual recovery after switching tasks remain untested.

## Phase 5 — Implementation: small incremental extension, with preserved existing assets

Changes reused from previously reviewed uncommitted work and isolated on this task's branch:

- Native `.Rd` concept and function help, indexed for local search, with direct `help()`, `?` and `??` access.
- Local query search `ru_find()` returning concept, function and walkthrough types, `ru_open()` for a direct result, and `ru_guide()`/`ru_edit()` for portable content.
- 46 question-led walkthroughs preserved in `inst/guides/` and runnable example scripts in `inst/examples/`.
- Flagship examples for histogram, grouped boxplot and Welch independent-groups t-test using authentic datasets and ordinary R.
- Existing weighted-probability, alternatives, nonplot, irregular-time and route-reachability safeguards retained and tested.
- R help for common errors, deterministic typo correction, explicit suggestions rather than silently inventing a command or datum.
- Quarto renderable local reference navigation plus a light GitHub Actions check pipeline.
- No new statistical calculation functions, external runtime server, learner tracking, proprietary search service or license changes.

**Further accessibility improvement:** Flagship guides use explicit quick answers, question/data/method, one canonical commented R script (loaded with `knitr::read_chunk()`), interpretation, mistakes, alternative decision, related R Help, descriptive plot alt text, and optional independent transfer prompts.

**Phase 5 unknown:** The other 39 guides remain primarily convenience-wrapper demonstrations until they are carefully converted in place; this limitation is deliberate rather than disguised by a larger article count.



## Phase 6 — Separate operational retrieval from learner outcomes

### Mechanical search benchmark (executed, not a user study)

Against the same 22 **pre-specified-for-this-comparison task questions**, with target ID and content type recorded before each benchmark run (not externally preregistered), the result was:

| Installed candidate | First returned correct item | Correct item in top ten |
|---|---:|---:|
| Baseline `rulearn 0.2.0` at `c4f0dc48` | 7 / 22 | 7 / 22 |
| Draft reference `rulearn 0.3.0`, after conservative typo/error fix | 22 / 22 | 22 / 22 |

Execution used separate R library paths and `ru_find(query,n=10L)` for each version. The queries included population/sample, stationarity, standard deviation, p-values, histogram/bar chart selection, SD versus SE, paired groups, import, column names, grouped means, customize histogram, missing data, `sd()`, three misspellings, two R error descriptions, “function not found”, and “Can I use a paired t test?”. Output was kept in **temporary** `/tmp` CSV/log files, not committed to the repository. The newer index contains the exact target topics and fixes those ranking errors by construction. This benchmark measures **search ranking under these specific questions**, not open-ended question accuracy, real time savings, accessibility or learning.

The single benchmark must not be claimed as a 20% human-speed improvement. Tests with unexpected wording and unknown spelling variants may still fail or retrieve a poor match; no semantic LLM search is used.

### Application-speed study protocol — not yet run with participants

**Comparator:** RStudio's native `?`/`help.search()` plus the best directly relevant ModernDive/MOSAIC learning resources accessible in the participant's actual setup. **Intervention:** installed `rulearn` reference with the same starting RStudio state and datasets. Use a within-subject counterbalanced order when appropriate, or equivalent task sets; provide the same permitted references in each condition. Ask participants to locate a concept, find correct native R code, adapt it to a differently named data column and interpret results without arbitrary hidden scaffolds.

Instrument **(a)** search result rank, **(b)** number of meaningful navigation interactions, **(c)** time to defensible method, **(d)** time to correctly executed adapted code, **(e)** error count and help needed, **(f)** time to recover from interruption. Wrong methods are failures regardless of speed. Median time to correctly adapted code at least 20% faster is a **provisional design target**, not an observed outcome.

### Retention and transfer protocol — effectiveness UNVERIFIED

Measure accuracy of explaining concept and assumptions, selecting appropriate vs inappropriate methods, writing native R from memory, identifying/repairing an error, and using a new dataset:

- **0 hours:** immediately after the learning encounter.
- **Approximately 24 hours:** without showing the worked example first.
- **Approximately seven days:** equivalent novel task, different field names and dataset.

Record correctness and explanation quality separately from task time; comparisons should be blind-scored against a stated rubric when practical. Success requires **no reduction in delayed independent performance** while application speed improves, ideally gains in both. No participant sample, delayed measures, or causal learning result exists yet.

### Consent, privacy, and accessibility

Participation must be voluntary and informed. Do not solicit diagnoses; invite description of task-level needs instead. Do not store student assignment contents, private account data, telemetry, or medical information. Use local anonymous results only with explicit consent.

For WCAG 2.2 AA, conduct manual keyboard-only navigation, visible focus, reflow and 200%-zoom, reading order/landmarks, code copying, non-colour chart interpretation, and screen-reader tasks in the real target browser and RStudio. Test Windows RStudio's narrow Help pane and a low-distraction theme. Cross-check W3C's **informative** COGA guidance separately. HTML output existing and plot alt text are positive artifacts, **not WCAG conformance**.

**Phase 6 status:** deterministic retrieval benchmark complete; consented user performance, delayed retention, real GUI accessibility and device-specific tests **UNVERIFIED**.

## Phase 7 — Verification and release controls

Acceptance requires actual execution, not planned commands. Verification in the isolated development worktree is recorded here only after a run completes.

| Check | Command or method | Result |
|---|---|---|
| Package build | `cd /tmp; R CMD build <TASK_WORKTREE>` | **PASS**: `rulearn_0.3.0.tar.gz`; Git worktree metadata excluded |
| Package check | `R CMD check --no-manual rulearn_0.3.0.tar.gz` | **PASS**: zero errors, warnings or notes, R 4.5.2 / Ubuntu 26.04.1 |
| Existing + regression suites | `R CMD check` runs `consistency.R`, `data-adaptation.R`, `reference.R`, `review-regressions.R` and `smoke.R` | **PASS**: all five suites |
| Concept and search retrieval | Installed `help()` for 16 concepts and nine function introductions; `tests/reference.R` and the 22-query local benchmark | **PASS**: direct native help resolves, spelling/error queries resolve, 22/22 expected top results |
| Native code | `ru_edit()` copies three scripts; native execution; adapt to alternate authentic datasets | **PASS**: `airquality$Wind`, `ToothGrowth$len` by supplement, and `PlantGrowth` control vs treatment 2 |
| Offline reference | `LD_PRELOAD=/tmp/ru-ref-no-network.so Rscript ...` blocked outgoing IPv4/IPv6 socket connections in the R process | **PASS**: native help, console search and editable script creation worked under socket restriction; not a whole-machine network-disconnection test |
| Quarto / links | Quarto CLI `1.10.19`: `quarto render`, Python `html.parser` link and asset inspection | **PASS**: 51 HTML pages, zero broken local links or assets, three rendered flagship plots |
| Accessibility prerequisites | Static HTML: all 51 pages have page language and an H1, all three non-decorative figures have alt text; code blocks are selectable/copyable | **PASS static only**. WCAG 2.2 AA, real keyboard traversal, screen reader and RStudio GUI **UNVERIFIED** |
| Release | Isolated `steward/f3f86112/research-correction` branch | **Local commit only** after verification; no push, merge, default-branch update or website deploy authorized |

The complete implementation does not claim improved **human** application speed or delayed retention. The 22-query comparison measures only deterministic search rank in this tailored query set. No consented study, NVDA/VoiceOver run, keyboard-only walkthrough or UI contrast/reflow audit was completed.

The repository license is deliberately unchanged; no external instructional book is copied into the project. A single light CI workflow may re-execute build/check/Quarto; automated green results do not demonstrate learning retention.

## Decisions and unknowns requiring human review

1. **Go:** Keep the existing R package and deliver the offline reference/keyboard-compatible native R material; it fixes an observed gap with minimal new machinery.
2. **No-go:** Do not add an RStudio GUI addin, custom statistical operation list, AI chatbot, learner profile, mandatory interactive course, generated duplicated article collection, telemetry, or automatic student assignment solver.
3. **Deferred:** Convert 43 older scripts to transparent base R incrementally, but only after the three flagship methods are measured and refined.
4. **Deferred:** Optional `learnr` practice could be adopted if ordinary worked examples do not suffice for delayed transfer.
5. **Blocked by evidence:** The 20% human-speed target, noninferior delayed performance, reliable accessibility conformance and independent user reuse are **unverified** until real tests.
6. **Blocked by authorization:** No push/merge/deployment/default-branch change was approved in the latest specification. Keep changes on the isolated development branch and present the evidence before any release.

The core test remains whether a student can **locate, understand, adapt, execute, interpret and later reproduce** ordinary R code without depending on `ru_apply()`. Feature count is not a substitute for that outcome.
---

## Private undergraduate statistics replay — 2026-10-20

**Purpose:** Test whether a novice can get from real, unfamiliar assessment wording to an appropriate native R function, editable code, and a defensible explanation. This follow-up revisits the prior `2ba9861` review candidate rather than assuming that software success already proves learning.

**Evidence boundary:** The user authorized read-only examination of a private course folder on a mapped drive. That folder contained one **graded, nonstatistical orientation response**; one **completed-looking numerical/statistical analysis PDF** in a submission/feedback folder alongside a later-edited Quarto draft and CSV; and seminar worksheets, starter projects, and source files labeled “Filled.” The seminar READMEs explicitly identify “Filled” materials as instructor examples. **No separate student-completed seminar lab or instructor evaluation of the numerical report could be confirmed.** Folder placement is not evidence of a Moodle submission or grade. The later Quarto draft is not necessarily identical to the earlier PDF.

The original assignment prompts, student identity, submitted text, instructor-authored source material and complete student datasets were read **in place only**, and were not placed in this repository. Below, original task types are **paraphrased** into general educational language, not quoted or reproduced. Embedded AI-directed fragments in source materials were treated as untrusted input, not followed as instructions. Source/answer separation was implemented in the scripted method-selection test, which used task wording and a pre-selected topic mapping; this was **not** a blinded human study.

### Authentic question inventory and reference mapping

| Private case | Paraphrased real task from the available material | Source classification | Best reference or native R command | Trial outcome / limitation |
|---|---|---|---|---|
| A01 | Distinguish describing recorded data from making a population inference | Learner report | `descriptive_inferential`, `population_sample` | Correct native help now found |
| A02 | Say why researchers sample a defined population | Learner report | `population_sample` | Correct first result after search indexing fix |
| A03 | Contrast ordered category sizes with numeric measurements | Learner report | `measurement_scales` | Plain-language and technical distinction available |
| A04 | Define a probability experiment, full outcome space, complement and events | Learner report | `probability_events` | New native help; simple independent demonstration |
| A05 | Differentiate independent events, mutually exclusive events and conditional probabilities | Learner report | `conditional_independence` | New help corrects the conceptual confusion without using a solver |
| A06 | Inspect the rows, columns, types and numeric variable of a built-in dataset | Learner report | `inspect_columns`, `names()`, `str()` | Native inspection executed |
| A07 | Make and interpret a stem-and-leaf display of a numerical measurement | Learner report | `r_stem`, `stem()` | Added native function introduction; code executed |
| A08 | Create an individual boxplot, histogram, and category-separated boxplots | Learner report | `boxplot`, `histogram`, `grouped_boxplot` | Plots executed on the actual specified variables |
| A09 | Load a CSV, inspect a numeric measurement and summarize its distribution | Learner report | `import_csv`, `r_errors`, `histogram` | Real CSV imported; four extra empty columns noticed |
| A10 | Calculate a mean, median, quartiles, trimmed mean, variance and standard deviation | Learner report | `mean_median`, `percentiles_quantiles`, `variance_sd`, `r_mean`, `r_sd` | Native summaries independently reproduced |
| A11 | Plot categorical frequencies and sample proportions | Learner report | `bar_chart`, `r_table`; native `table()`, `prop.table()`, `barplot()` | Older wrapper-only walkthrough revised in place |
| A12 | Determine probabilities for combined chance events, including draws without replacement | Learner report | `probability_events`, `conditional_independence` | Event arithmetic checked against independently enumerated classical models |
| S01 | Draw numerical and category summaries of wage and occupation records | Instructor worksheet, **not verified student-completed** | `histogram`, `bar_chart`, `grouped_boxplot` | R replay executed against its existing input file |
| S02 | Compare dependent/independent events and classify discrete probability models | Instructor worksheet, **not verified student-completed** | `conditional_independence`, `probability_distributions` | Concept coverage audited, no student result available |

The built-in dataset used for the first visual tasks contained 150 rows, four numeric flower measurements, and one categorical species label. The private CSV used for the second analysis contained 333 actual records with seven substantive columns and four extra, entirely empty columns created by import. Computations from the saved input gave mean body mass **4,207.057 g**, median **4,050 g**, 10% trimmed mean **4,159.457 g**, and category shares approximately **43.8%, 20.4%, 35.7%**. Numeric R calculations agreed with those parts of the saved report. The actual minimum and maximum flipper measurements were **172 and 231 mm**; the report used a looser approximately **170–235 mm** statement, apparently read from plot limits. That difference motivates the distinction between observed extrema and an axis range. It is **not** an instructor-graded finding.

A response about conditional probability suggested that conditioning requires two events to overlap. The corrected reference now states the actual rule: the chance of A given B equals `P(A and B) / P(B)` when `P(B)>0`. An empty intersection yields a conditional probability of zero; no “mutually inclusive” requirement is imposed. This finding is a **reviewed conceptual mismatch**, not a reported faculty deduction. Compound chances were independently reproduced under the questions’ stated fair/equally likely and without-replacement assumptions. No probabilistic calculations were added to the package's `ru_apply()` catalogue.

### Trial A — Historical replay results

1. Source classification: the orientation assessment has a verifiable passing grade; the analysis report is authored and rendered but a grade and actual submission state are **unconfirmed**; instructor-filled seminar materials are **not** proof of learner completion.
2. Search baseline: native `help.search(full_sentence, package=c("base","stats","graphics","utils","datasets"))` returned no results for the 22 full natural-language trial phrasings. This does **not** measure native help's performance when the learner knows a function name (e.g., `?hist`), and external online guides were **not timed or operated** in this replay.
3. Review candidate `rulearn 0.3.0` from before this correction: **11/22** task phrasings returned the predefined relevant topic first.
4. Corrected local package: **22/22** selected trial phrasings returned the predefined relevant topic first. Ranking was deterministic and local. This is a small task-derived test set and can overfit; it is **not** a general language-understanding score or a human usability finding.
5. Native R replay: dataset inspection, stem display, histogram, boxplots, descriptive numeric statistics, proportions, and model-event arithmetic **executed successfully** against available files or established built-in R datasets. The original learner answers were used only later to identify agreements and interpretation differences; no instructor solution or grading result was invented.

**Verified correction failure:** In the original detailed histogram script, changing only the stated interval width from 0.5 to 5 left the interval endpoints calculated in half-unit increments, producing the R error that some values could not be counted. The corrected script derives **both** endpoints and bin steps from one adjustable `bin_width` value, including cases where all usable observations are identical. It rejects empty observations and an excessive number of bins with explicit messages. The corrected 5 mm example counts all 333 recorded observations.

### Corrections to the learning experience

- The three previously revised flagship guides now begin with **Immediate answer** containing a short, executable native R example; then **What to change**, **What to check**, and an explicitly **optional complete walkthrough**, interpretation, and optional retention practice.
- Short and detailed examples continue to come from **one canonical R source file** per guide through existing Quarto chunk support. `ru_guide()` expands both for offline console reading; it no longer shows an empty or duplicated help section.
- `ru_edit(topic, mode="quick")` copies only the immediate answer. The default `ru_edit(topic)` copies only the detailed code (as before the fast-answer section was introduced); `mode="both"` is available. A learner no longer has to edit two copies of the dataset reference to run one approach.
- The detailed grouped-boxplot script now has explicit, editable measurement-unit, axis and title variables so a changed dataset does not silently retain “cm” labels.
- Four additional native concept references address **descriptive versus inferential statistics**, **measurement scales**, **event/sample-space/complement definitions**, and **conditional probability versus independent/mutually exclusive events**. One introductory function reference addresses `stem()`. The opening lines of the standard-deviation and sampling-distribution definitions now introduce the plain meaning before the formal description. Mathematical caveats remain.
- The existing `bar_chart` reference has been upgraded in place: native `table()`, `prop.table()`, `barplot()`, labeled units and category percentages, instead of making `ru_apply()` compulsory. No statistical operation catalogue was expanded.
- The existing error reference now explains `getwd()`, `file.exists()`, imported field names, extra empty CSV columns, and why `?some_imported_dataframe` does not magically create installed package documentation. Search ranking distinguishes “wrong CSV path” from a request to import a file and a graph-selection question from a question about a population.

No new package framework, GUI shell, calculator, background service, telemetry or mandatory learning gate was added. The earlier 46 walkthroughs remain indexed; full native-code conversion of the other legacy wrapper-based guides remains future work only where trials justify it.

### Trial B — Verified changed-task transfer

| Variation | Relevant statistical task | Executed result |
|---|---|---|
| A different built-in weather dataset and measurement column | Histogram distribution and adjustable intervals | Passed; actual observations retained in bins |
| A different built-in biological dataset with two groups | Grouped boxplot with changed numeric measurement, categories and units | Passed; checked group totals, counts and labels |
| A different comparison group within an existing plant-growth dataset | Welch's independent two-sample test | Passed R calculations; still not an inferential method taught by the available completed report |
| A different built-in automobile dataset with numerically coded categories | Native frequency table, proportions and bar chart | Passed; treating category codes as groups rather than continuous measurements |
| The user's existing penguin CSV | Short and full histogram + grouped-boxplot methods, with real variable substitutions | Passed all four copied native scripts; corrected bin width and gram/mm labels |

A successful script demonstrates *software transfer*, not a student's independent ability to transfer what was learned.

### Trial C — Windows RStudio supervised application and retention protocol (not yet run)

**Preparation:** Human evaluator uses a copy of the authorized task wording and verified dataset locally. Keep prior answers and rubrics hidden during the attempt. Prepare two matched sets of problems that cover definitions, choosing the appropriate graph or calculation, interpreting units/output and recovering from an error. Use only data the learner is allowed to access. Use built-in datasets for the transformed set; document the expected method and verify calculations in advance.

**Candidate installation:** Obtain the approved local `rulearn_0.3.0.tar.gz` source package from the review environment, not the older `main` release on GitHub. In RStudio on Windows, select a trial-only package library and run `install.packages("C:/path/to/rulearn_0.3.0.tar.gz", repos=NULL, type="source", lib=trial_library)`, then `library(rulearn, lib.loc=trial_library)`. Confirm `help("measurement_scales",package="rulearn")` and `ru_find("What is a sample space?")` work without internet. Windows installation and Help-pane interaction remain **unverified** until the learner/evaluator performs them.

**Session 1, application:** Randomize or alternate which matched tasks start with condition A (native RStudio Help + established available online resources) or condition B (the candidate library). Start each question at identical RStudio Console state with dataset supplied and no prior answer shown. Record the learner's exact initial search wording, whether the first retrieved result is appropriate, help pages/commands opened, time to defensible method, time to working adapted R code, R errors and recovery steps, number of prompts/help requests, and whether the learner explains axes/units/assumptions correctly. Record both successful and unsuccessful attempts. Unnecessary clicks and interruptions matter, but **a fast incorrect answer is a failure**.

**Session 2, about 24 hours later:** Present a matched question with different column names/data. First request an **independent attempt without the worked example**. Score method choice, code recalled, interpretation and identification of a wrong method. After scoring, allow access to the reference to complete the exercise. Record what assistance was required.

**Session 3, about seven days later:** Repeat with another verified novel dataset/question, balancing order and previous exposure. Score independent concept explanation, method selection, correct R command, dataset adaptation and limits of inference. Compare delayed performance to the baseline condition, rather than using the post-example quiz alone.

**Privacy and accessibility:** Participation is voluntary and consented. Record task barriers such as losing the place after switching panes, difficulty identifying numerical units, dense text, or confusion over formula symbols; do **not** assume a diagnosis determines a response format. No diagnoses, student IDs, raw assignments, medical information, cloud telemetry or personal learner activity logs belong in the Git repository. Confirm usability in real Windows RStudio with adjustable font size, narrow Help pane, keyboard navigation and optional assistive technology separately. A passed static HTML check is not WCAG 2.2 AA conformance.

**Outcome status:** No learner has completed these supervised sessions in the current execution. Application-time advantage, independence after 24 hours, seven-day retention, actual Windows RStudio accessibility and real-world preference remain **UNVERIFIED**. The earlier 20% time-reduction target remains a provisional target only.

### Acceptance and release gate for this follow-up

- **RLY-01:** **PARTIAL** — the private folder and student report were located; instructor-filled lab answers were not wrongly treated as completed student labs. No separate student-completed seminar lab could be verified.
- **RLY-02:** **PASS for available authentic material** — real question types were mapped to explicit references without copying original questions; student-completed lab status is incomplete.
- **RLY-03:** **PASS** — three required guides present immediate native R before optional detail, with their quick chunks verified.
- **RLY-04:** **PASS** — dataset, column, group, unit, title, and bin-width substitutions are identified and tested.
- **RLY-05:** **PASS for reviewed definitions** — novice-first explanations and technical/assumption sections are installed and searchable.
- **RLY-06:** **PARTIAL** — the completed-looking submitted-answer report was replayed and independently checked; student-completed lab artifacts and grading corrections were not available.
- **RLY-07:** **PASS** — verified built-in and privately available transfer datasets ran using native code.
- **RLY-08/RLY-09/RLY-10:** R CMD build/check, existing tests, offline and site results must be recorded against the **final** committed revision; see final verification below.
- **RLY-11:** **PASS as a reporting safeguard** — human outcomes explicitly UNVERIFIED.
- **RLY-12:** To be checked by staged-file audit and the absence of academic sources/history in Git before committing.

**Release recommendation:** Continue review. Software fixes are justified by the authentic replay, but do not claim validated learning speed or retention. Do not merge, push, deploy, add unpublished academic records or change the repository license without explicit authorization.

## Follow-up: authentic undergraduate assignment replay and instructional correction (2026-10-20)

### Evidence, scope and completion status

The actual Fall 2026 undergraduate statistics materials were located on the user's mounted **private course share**, including instructions, one rendered multi-question response, its editable Quarto source, a real class-provided CSV, and instructor seminar files. Originals remained read-only. Their titles, names, grades, student numbers, precise paths, worksheet text and datasets have **not** been committed. The temporary private replay and search scripts remain outside the repository.

- A **separate upload-practice exercise** has a graded submission record: 1/1. It contains no substantive statistical analysis and was excluded from method trials.
- The **first substantial statistical assignment** has a complete-looking editable answer and rendered PDF in a folder named for submissions. **Moodle submission status, a numerical grade and instructor feedback were not independently verified.** File placement alone proves none of these.
- Later seminar worksheets and files labeled *Filled* were inspected as **instructor materials**. Their availability does not establish the student's completion. Their questions were used only to identify possible future coverage.

Only the original statistical prompts were used when selecting methods for the historical replay. Existing answers were compared **after** selection. This was an automated investigator-run replay, not a blind human experiment. Embedded AI-directed canary text in the assignment source was treated as untrusted data and ignored as directions.

### Compact historical task inventory (paraphrased, not copied from course documents)

| Task | Original statistical need, paraphrased | Reference / native commands | Historical check and decision |
|---|---|---|---|
| H1 | Distinguish data description from population inference; explain why samples are used | `descriptive_inferential`, `population_sample` | Retrieval now works; inferential claims still depend on study design |
| H2 | Select meaningful measurement scales for categories versus physical measurements | `measurement_scales`; `factor()` and numerical help | Concept article added; storage type is not identical to scientific measurement scale |
| H3 | Define a chance experiment, sample space, complement, conditional probability and event independence | `probability_events`, `conditional_independence` | Native definitions and fair-outcome worked arithmetic added; dependence distinguished from exclusivity |
| H4 | Describe a recorded flower table, identify exact columns and show numerical distributions | `inspect_columns`, `r_stem`, `histogram`, `boxplot`; `names()`, `str()`, `stem()`, `hist()` | Original data successfully reproduced; stem-and-leaf lookup was repaired |
| H5 | Compare a measurement across recorded categories | `grouped_boxplot`; `boxplot(measurement ~ category, data=d)` | Full executable native example; query explicitly naming a comparative boxplot now outranks grouped means |
| H6 | Import an unfamiliar CSV and inspect its records, types and missingness | `import_csv`, `r_errors`; `read.csv()`, `names()`, `str()` | Historical input imported, but some surplus blank fields warranted verification; guide now teaches inspection rather than assuming correctness |
| H7 | Find center, trimmed center, quartiles, range, variance and standard deviation | `mean_median`, `sample_sd`, `percentiles_quantiles`, `variance_sd`; `mean()`, `median()`, `quantile()`, `range()`, `var()`, `sd()` | Demonstration scripts now expose the actual R operations and state the units; correct numerical outputs alone do not prove interpretation |
| H8 | Count categories, report proportions and compare distributions by category | `bar_chart` and `grouped_boxplot`; `table()`, `prop.table()`, `barplot()`, `boxplot()` | Checked against original recorded data without copying source rows into tests |
| H9 | Combine chance events, including successive selections without replacement | `probability_events` and `conditional_independence`; base R arithmetic | Original calculated probabilities independently verified under the given equally likely model; conditional denominator explained |
| H10 | Format and render a document in the usual RStudio workflow | Existing RStudio/Quarto tools, **not a `rulearn` calculation or lesson** | Explicit out-of-scope case; do not create a duplicate Quarto system |

**Numerical replay details (not stored as public fixtures):** the original flower measurements, imported animal-measurement CSV and basic chance-event models were independently recomputed with base R. Recorded numerical summaries and categorical proportions were reproducible. A narrative range in the rendered response resembled histogram-scale endpoints rather than exact recorded extrema, motivating the added `range(values)` check. A prompt requested additional spread statistics whose results were not located in that rendered response; **no grading judgment is inferred**. One imported file had surplus fully missing columns, motivating `names()`/`str()`/`colSums(is.na())` and explicit delimiter checks.

Inference tests were **not** introduced as historic assignment tasks because the verified completed statistical assignment did not cover them. The existing independent two-sample t-test example was retained and checked solely as a product regression.

### Trial A: method retrieval from original question wording

A private 19-question replay used actual problem wording with instructions to coding agents removed. The expected reference or intentional out-of-scope destination was recorded for each question.

| Mechanical comparison | Executed outcome |
|---|---:|
| In-scope original questions with the relevant first `rulearn` result | **18 / 18** |
| Explicitly out-of-scope document-rendering question correctly returning no `rulearn` result | **1 / 1** |
| Native R `help.search()` using the entire natural-language sentence as-is | **0 / 19** with a match |
| Native R `help.search()` using a suitable technical keyword chosen by the investigator | **19 / 19** with one or more matches |

**Caution:** these are search-return counts, not observed learner success, comprehension, navigational effort or historical completion speed. The index was revised after examining these prompts, so the 18/18 is an **in-sample development check** rather than performance on unseen questions. Native `help.search()` can be effective once the correct term is known; the chosen short-keyword comparison demonstrates this. ModernDive, MOSAIC and live external-web search were not operated against the same 19 private questions and cannot be assigned comparative accuracy or times.

Three historically observed instructional barriers were targeted: the first result selecting grouped means instead of grouped boxplots, interpreting “standard error” as an R programming error, and retrieving a misleading answer for out-of-scope Quarto tasks. Regression checks now distinguish these requests. Generalization beyond the observed phrases is still uncertain.

### Trial B: changed-data transfer (automated, executed)

The new **`tests/transfer.R`** contains no student data or copied assignment wording. It checks alternative public R datasets and a clearly labeled constructed equally likely model:

- `airquality$Ozone`: numeric histogram, 37 missing observations excluded and 116 finite values correctly counted.
- `ToothGrowth$len` by `supp`: two genuinely different grouping levels, 30 usable observations each, appropriate grouped boxplot and ordered numeric summaries.
- `mtcars$cyl`: categorical counts and proportions, despite numeric storage of group codes.
- A constructed six-sided die plus fair-coin outcome space: intersections, unions, complements and conditional probabilities computed by native logical operations; a second constructed deck example distinguishes drawing with and without replacement.
- Direct help and search for the applicable concepts/functions, plus valid native R stem-and-leaf output.

This establishes that **the verified commands and test cases execute on other data**, not that a learner could independently choose and reproduce them after a delay. The separate package regression suite tests edited versions of the flagship scripts with other named R datasets.

### What was corrected after authentic replay

The original `rulearn 0.3.0` local review commit had 16 concept and nine function references, and three flagship plots/tests. This continuation:

- Added **four concise native concept articles** and a beginner-oriented native `stem()` function reference, bringing the installed collection to **20 concepts, 10 function references and 46 retained guides/scripts**. No new statistical calculation wrappers.
- Reworked the three required flagship guides — histogram, grouped boxplot and independent two-sample test — with short native code first, followed by what to change, what to check, complete optional implementation, interpretation, and optional independent transfer.
- Converted three additional high-use legacy `ru_apply()` guide/script pairs — CSV import, mean/median, and sample spread — to immediate native commands plus optional full workflows. The previously corrected categorical bar-chart guide remains native too. **Seven guides are now substantially native-code-first; 39 remain for staged correction.**
- Reused the native R Help infrastructure and the existing executable Quarto guide source. An editable `ru_edit(..., mode="quick")` script can be requested for the supported guides; full mode preserves the checks. No custom tutorial, calculator or GUI was added.
- Fixed deterministic search ranking for explicit named methods, sampling reasons, common probability wording and statistical-versus-programming errors; unsupported external-document questions return no inappropriate help match.
- Added generic regression tests for immediate/full example execution, help lookup, retrieval choices, and changed-dataset methods.

The principal instructional finding is practical: **an answer and even a correct plot do not show that the learner knows which command to change or what the plotted labels mean.** Shortest valid commands must appear before optional detail, and assumptions must remain visible beside or immediately after that quick answer.

### Trial C: supervised Windows RStudio procedure — prepared, NOT executed

This protocol tests real application and retention once the user chooses to participate. Use the actual locally reviewed candidate, **not the older package from public GitHub main**. A trusted copy of the local source archive must first be made available on the Windows computer; installation and UI behavior on that computer are presently unverified.

**Set up:** In RStudio, install the authorized local `rulearn_0.3.0.tar.gz` candidate (e.g. `install.packages("C:/path/rulearn_0.3.0.tar.gz",repos=NULL,type="source")`, with suitable Windows build tooling if required). Confirm `packageVersion("rulearn")` is `0.3.0` and read `ru_find("sample space")`. Keep the source worktree, any private coursework and participant responses separate. Do **not** install from the current GitHub default branch for this trial.

**Session 1 — application:** Use two equivalent task sets and vary the order of conditions A and B to reduce practice effects. Condition A allows native RStudio Help, standard R documentation, and pre-agreed accessible public references without the package. Condition B allows `ru_find()`, `help(...,package="rulearn")`, `ru_guide()` and `ru_edit()`. If internet sites are permitted, keep that rule consistent in both conditions or analyze website use separately.

Task pair examples (all public or constructed, not drawn verbatim from coursework):
- Explain what a sample can establish, using a recorded dataset; compare a different sample/population context in the other condition.
- Plot an appropriate numeric distribution for `airquality$Ozone` after checking missing values, versus `faithful$waiting` in the alternate condition.
- Compare numeric distributions between `ToothGrowth` supplement categories, versus the built-in `iris` species categories.
- Count categorical records with `factor(mtcars$cyl)` versus a different recorded category; explain why a histogram differs from a bar chart.
- Explain a fair-outcome sample space and one dependent selection sequence without relying on a solver.

Record the question shown, condition/order, search phrase typed, actual reference opened, time to **defensible method**, time to **correctly adapted code**, errors, recovery, any assistance, and whether an explanation identifies axes/units and limits. A fast wrong answer is a failed application, not a speed gain. Do not take timings from the previously completed coursework.

**Session 2 — approximately 24 hours:** Use matched but unpracticed data and variable names. Request an independent first attempt **before** revealing the guide; then allow the reference as needed. Record independent method choice, code adaptation and explanation accuracy separately from assistance and time.

**Session 3 — approximately seven days:** Repeat with another equivalent task set and a changed order. Ask the learner to explain why the method fits, execute native R without `ru_apply()`, and state what the result cannot establish. After the independent attempt, allow all normal learning resources so the exercise can be completed.

**Scoring:** Record method choice (0 inappropriate / 1 partial / 2 defensible), executable native code (0 broken / 1 corrected with help / 2 independent), interpretation (0 false / 1 partial / 2 accurate with limits), independent delayed method reuse (same scale) and time-to-correct-result in seconds. Record omissions and hints, rather than giving a single opaque achievement score. Application and retention carry equal weight in the release decision. Keep all responses private with the participant's consent; do not collect diagnoses or hidden telemetry.

**Limits:** One student's experience cannot establish benefit for all learners with dyslexia, dyscalculia or ADHD. A mechanical terminal test cannot verify screen-reader focus order, Windows Help pane readability, keyboard-only use, or reduced task-switching burden. **Human speed, 24-hour recall, seven-day retention, user independence and assistive-technology conformance remain UNVERIFIED.**

### Follow-up acceptance status

| Requirement | Status and evidence |
|---|---|
| RLY-01, genuine lab sources and completion status | **PARTIAL**: source materials and a completed-looking substantial statistical response were found; submission/grading of that work and completion of individual seminar labs could not be verified. A separate upload-practice exercise was graded 1/1 |
| RLY-02, authentic question-to-topic mapping | **PASS**: task inventory above; no copyrighted question files redistributed |
| RLY-03/04, immediate native answer and adaptable inputs | **PASS**: three flagship guides plus targeted native-source improvements; quick/full code is executable |
| RLY-05, understandable and technically defensible definitions | **PASS for inspected concepts**: 20 installed local concept articles, including corrected foundational and probability distinctions. Human comprehension **UNVERIFIED** |
| RLY-06, replay without fabricated measurements | **PASS for selected work**: original recorded data and event assumptions verified; no invented answers treated as instructor feedback |
| RLY-07, transferred method execution | **PASS**: alternate authentic datasets and constructed discrete model, via `tests/transfer.R` and existing regression scripts |
| RLY-08/09/10, offline access and clean package verification | **PASS**: R CMD build and check, six executable test suites, site rendering and offline socket-blocked reference checks |
| RLY-11, truthful human trial status | **PASS labeling**: human application and retention outcomes **UNVERIFIED** |
| RLY-12, no academic material committed | **PASS**: 169 tracked/untracked source files and 34 staged change files inspected; no private academic documents or specified identifiers staged |

### Executed follow-up software verification (local candidate)

- `HOME=<USER_HOME> R CMD build <TASK_WORKTREE>` from `/tmp`: **PASS**, producing `rulearn_0.3.0.tar.gz` with no build warnings.
- `HOME=<USER_HOME> R CMD check --no-manual rulearn_0.3.0.tar.gz`: **PASS**, `Status: OK` with zero errors, warnings or notes. Six tests ran: `consistency.R`, `data-adaptation.R`, `reference.R`, `review-regressions.R`, `smoke.R` and `transfer.R`.
- `quarto render` using local Quarto 1.10.19: **PASS**, 51 pages. Static parser: 51/51 pages include page language and an H1, zero broken local assets/links, zero missing or empty alt descriptions on eight image references. Static checks are **not** a WCAG 2.2 conformance certificate.
- Reinstalled candidate into an isolated test R library. With outgoing IPv4/IPv6 socket calls blocked by a temporary preload shim, `help()`, `ru_find()`, `ru_guide()` and `ru_edit(...,mode="quick")`: **PASS**.
- Historical numerical replay from private source folders: **PASS for the audited data and event calculations**; original input files were not modified. Query-retrieval comparison: **18/18 expected in-scope top results**, plus one deliberate out-of-scope no-match; the method index was fitted during the review, so the results are not independent generalization evidence.
- Generic transfer on R's packaged data and constructed chance experiments: **PASS**, no assessment questions, individual answers, source files, grades or third-party slides copied into public fixtures.
- Source and staged privacy audits: **PASS**, 169 tracked/untracked working-tree files and 34 staged changes inspected. No course codes, student identifiers, original assignment texts, restricted files or generated outputs staged for the local commit.

These checks replace the earlier preliminary implementation's 16-concept/nine-function snapshot. The current candidate has **20 concept references, 10 function introductions, 46 guides, seven native-code-first lessons and 39 older guides**. The package's public calculation catalogue was not enlarged.

**Review recommendation:** Hold release until the consented user trials are complete. The targeted improvements justify continued testing, **not a claim that application became faster or that retention improved**. No default-branch merge, push, deployment or public course-material publication is authorized.

## Candidate reconciliation and QA freeze — 2026-10-20

This is a **local, human-QA-only** release candidate. The existing reference
collection is preserved, not redesigned. GitHub main remains on the older
commit, and no remote branch has been published.

- Candidate **A** (`c4c48b1d9e2d7d14bf5daa1c9a00ea0e6dce45a4`) and
  **B** (`b2e6561e11958a0ac4e6a7b21496081dfa4f654d`) both descend from
  `2ba986164556d756f7498592e995b3e96084d5f5`.
- A versus B differs on 13 paths; B deletes none of A's files. B preserves
  A's four native-code-first guides and improves three more: CSV import,
  mean/median and sample variance/standard deviation. The original 46 guides
  and examples remain, with 20 concept and 10 function references.
- Both candidates installed in separate temporary R libraries. A/B search
  checks found 21/22 versus 22/22 correct top results on a 22-question
  reference benchmark and 17/19 versus 18/19 on a task-derived benchmark.
  The last task was out of scope (rendering Quarto PDF documents) and should
  produce no misleading statistics result. These are **not** human usability
  outcomes and are in-sample checks.
- A separate post-installation test uncovered a **shared flaw** in the exact
  question "How do I calculate mean and median?". Both variants favored a
  single-function or histogram result above the relevant combined guide.
  The task-owned `steward/f3f86112/qa-reconcile` branch descends from B and
  fixes only local search disambiguation and its regression test.
- The corrected local search preserved the 22/22 and 18/19 benchmarks, and
  returned the combined walkthrough for both "mean and median" and "mean,
  median and quartiles". It did not add functions, datasets or a tutorial
  framework.
- The exact release-source archive, the supervised Windows RStudio learner
  test, and the evaluator's expected results are **outside this Git
  repository** on the owner's private shared RStudio drive. They must not
  be added to public Git history.

**Reconciliation decision:** Use the QA branch for subsequent supervised
testing; preserve A and B as unchanged earlier candidates. Do not push, merge,
delete either worktree, or deploy without explicit authorization. The
package's LICENSE still does not grant redistribution rights; a public
distribution decision requires the author's explicit action.

**Human evidence remains outstanding:** actual Windows installation and
Help-pane interaction, initial application time and accuracy, error-recovery
difficulty, independent 24-hour transfer, seven-day retention, keyboard and
assistive-technology accessibility. Software checks cannot satisfy these.

## Manual Windows QA failure: basic R variables and Help-pane presentation (2026-10-20)

**Observed by learner:** `ru_find("How do I create variables?")` returned correlation and scatterplot references, and `ru_guide("correlation_test")` printed raw ```{r}` fences, `#| eval: false`, wrapper-based code and irrelevant explanation. The learner described it as "kind of chunky and not helpful". An earlier Windows package reinstall printed "package 'rulearn' is in use and will not be installed", so the installed Windows revision was **never independently established**.

**Independent reproduction:** Exported local SHA `4c94ae5ba6b4cf17843b176807db934e30adaec0` by `git archive`, installed into a clean R library on m710, and executed the two original calls exactly. Both failures were reproduced. This establishes a real source defect at that SHA, **not** that the source was running in the learner's Windows session.

**Confirmed root causes:**

1. Search accepted generic "variables" from statistical-method titles without evidence of the verb "create" or the R programming operation. No reference for R assignment and column extraction was indexed.
2. The Console-facing guide function read installed `.qmd` lines directly; only specially labeled short/detailed code chunks were expanded. Legacy ```{r}` chunks retained raw Quarto directives and `ru_apply()`. This was a representation defect, not necessarily a numerical-statistics defect.
3. The search correction proposed in the prior candidate did not include basic R object creation, so a statistics-only topic index could not answer the immediate task.

**Targeted changes (no new computation engine):**

- Add one installed Rd beginner reference `r_objects_columns`. The immediate example uses `mpg <- df$mpg` and `weight <- df$weight` for a data frame with those actual columns. Explain `<-`, `$`, name checking, object-versus-column distinctions, and adding a derived data-frame column. Do not embed the learner's vehicle CSV or infer its data values. The built-in `mtcars` dataset verifies executable syntax; its weight column is `wt`, not `weight`.
- Add a distinct `statistical_variable` concept to explain variables, observations and measurement types without confusing those with R assignment.
- Add deterministic classification for assignment/column requests, distinguish statistical-variable definitions from programming instructions, and prevent generic "variables" alone from ranking unrelated correlations or plots. Ensure an explicit scatter/paired-number plot still finds `scatterplot`. Tighten conservative spelling and no-match behavior for unrelated requests.
- In RStudio, `ru_find()` opens the best matching native R help article or rendered walkthrough instead of printing lists. `ru_open()` uses native R Help. `ru_guide()` converts its existing installed canonical `.qmd` plus editable source-code chunks to **temporary Rd**, then uses `rstudioapi::previewRd()` in the Help pane if available. No persistent duplicate guide pages are generated. The non-RStudio fallback displays plain text with no Quarto fences or printer backspaces.
- All legacy wrapper-based guides remain available, visibly labeled as compatibility examples. `ru_edit()` continues to refuse overwrites and now uses RStudio's existing `navigateToFile()` API to open a copied script in the Source editor when available. `rstudioapi` is suggested for IDE integration, not required for offline statistics reference. The package version is incremented to `0.3.1` to distinguish the installer from prior `0.3.0` QA packages.

**Software observations before human retest:**

- With a clean local package installation, all requested programming/search cases routed to the assignment reference, statistical-variable concept, scatterplot, or explicit no-match as intended; conservative misspelling `varibles` found the right reference.
- Additional unseen paraphrases verified extraction/assignment, plotting, statistical definitions, and out-of-domain false-positive handling. The package's prior 22-query and historical question benchmarks remained at `22/22` and `18/19` respectively, with the final historical case correctly outside its scope. These are adapted, **in-sample** scripted retrieval checks, not human timing or comprehension measurements.
- All 46 indexed worked guides converted to syntactically valid Rd and plain text without raw Quarto execution directives. The older correlation guide remained clearly marked as a wrapper example. Both quick and detailed canonical R examples remained available.
- **RStudio Help pane and Source editor behavior are UNVERIFIED in a Windows GUI**. Headless output and inspection of the official `rstudioapi` interface cannot substitute for that manual check. Student speed, 24-hour recall and seven-day retention also remain UNVERIFIED.
- A build-time source-commit marker and source archive SHA-256 will be included in the **private QA package** to verify the installed revision, rather than relying on `packageVersion()` alone. No GitHub push, default-branch merge, site deployment, license decision or academic-file upload is authorized.

**Executed software checks before final Git freeze:**

- Original failure reproduced in an isolated install of `4c94ae5`. Source version could not be inferred from the failed Windows reinstallation.
- Proposed `rulearn` version `0.3.1` installed locally; original RLY-QA-001 through RLY-QA-010 and independent paraphrase/no-match questions passed. All 46 canonical walkthroughs rendered into parseable temporary Rd and ordinary text with no raw Quarto fences, execution metadata or printer-backspace controls. Legacy `correlation_test` is explicitly marked as wrapper-based.
- The existing 22-query search benchmark still returned `22/22` correct top results; the historical task benchmark returned `18/19` appropriate top outcomes (last item intentionally outside this statistics reference). These are adapted scripted checks, not speed or retention evidence.
- `R CMD build` created `rulearn_0.3.1.tar.gz` from the working tree. After addressing two ordinary namespace-check NOTEs, `R CMD check --no-manual` reported **Status: OK** (0 errors, 0 warnings, 0 notes) across **seven** test scripts: consistency, data adaptation, reference, review regressions, smoke, transfer, and windows variables QA.
- Quarto 1.10.19 rendered 51 pages; static audit found 0 broken links/assets, 0 missing image descriptions, and all 51 pages had document language and primary heading. The source archive contained 165 files, including 46 runnable example scripts, with no original academic documents or named student identifiers.
- Code behavior in an actual Windows RStudio graphical Help or Source pane is **NOT VERIFIED** by m710's headless tests; the next supervised manual session must verify Help-pane opening, back navigation, Source editor opening, and correct package replacement after restarting R.

**Final checks and Windows QA kit:** Verify again after committing the source and stamping a private installer with its full Git SHA. The earlier `4c94ae5` package remains preserved. No GitHub publication or license change has been authorized.

## Assignment-first Viewer and source coverage audit — 2026-10-20

### Source audit and coverage boundaries

- The private source inventory located **303 potentially relevant files**: 255 in the introductory statistics source tree and 48 in the geography source tree. These counts include repeated instructor materials, drafts, duplicate representations, private student work, worksheets, notes, and outlines. They are not 303 distinct verified assignments or completed tasks.
- Read both priority sources directly: a displaying-and-summarizing-data lecture (student-authored exercises, provided answers/scripts and slides) and a descriptive-statistics laboratory (the original R and Quarto documents). Direct tasks include sorting, extrema and range, stem-and-leaf plots, histograms, shape/skew/modality, density displays, category bar charts, boxplots, CSV import, R objects and columns, quartiles, mean, variance, standard deviation, and Pearson/Spearman correlation. The associated student interpretations were **not** treated as correct merely because they are written in a completed-looking document.
- Source inventory and source-to-entry identifiers are recorded **only** under the owner's private shared drive for the QA work. They are deliberately **not** in the public Git tree. No original datasets, original exercises, student answers, identities, instructor slides, or marked assessments were copied into package fixtures.
- The sanitized package ledger `inst/extdata/coverage.csv` contains **120 distinct topic records** in eight learning domains: R fundamentals (20), data/measurement (10), descriptive statistics (25), data visualization (16), association (10), probability (15), sampling/inference (13), and spatial/time/modeling (11). The statuses explicitly distinguish **31 VERIFIED** compact reference entries (software tests and editorial review, Windows learner test pending), **23 NEEDS_REVIEW**, and **66 DISCOVERED**. Source matches are directly documented for 18 priority statistics tasks and 11 priority geography tasks; the remaining topics are organized scope candidates, **not** individually verified against every source or implemented in full. This ledger does not itself establish complete course coverage.
- The existing 46 long-form guides, 21 Rd concept references and 11 Rd function articles remain available. A legacy entry without a reviewed compact lesson is identified as not yet compact and is not falsely presented as native-R teaching.

### Adopt/extend/build decision

**Extend** the installed R package and native RStudio Viewer. Do not add a new application, Shiny, a calculation system, a database, an LLM, a model dependency, a backend service, or an online requirement. Keep official R Help for detailed function arguments and RStudio's existing Source editor for editable code.

Compact entries use **one canonical Markdown source each** under `inst/lessons/` and are rendered as local temporary HTML; no independent text copies of those entries are generated in Git. Each has the task/question, direct answer, native R code, editable-element table, checks, interpretation, optional collapsed `Learn more`, official source and related topics. The Viewer uses only packaged CSS, minimal JavaScript and five reproducible SVG teaching figures (skew direction, peaks/modality, histogram bins using recorded iris data, schematic boxplot features, and recorded mtcars correlation). Constructed model diagrams are explicitly illustrative and never presented as student observations.

The source lives in `R/viewer.R` and `R/viewer-navigation.R`; this builds on, rather than replaces, the existing statistics and search methods. The public `ru_find()`, `ru_open()`, `ru_guide()` and `ru_topics()` return results invisibly and open the RStudio Viewer when present. `ru_edit()` opens an ordinary editable source file without overwriting older work. For command-line use without the Viewer, `ru_text()` explicitly prints a short local explanation. Results and no-match pages escape search queries and provide local navigation. No automatic code execution is triggered from the Copy control; clipboard failure falls back to selection plus a Ctrl+C instruction without claiming success.

### Executed tests and remaining barriers

- R examples from **31/31 compact lessons executed** against included R datasets or explicitly theoretical models; ordinary statistical values and assumptions were reviewed against the named official functions. User-specific answers, timing, and assessments were not published.
- **20/20** exact acceptance questions return an appropriate first compact reference. **11/11** additional test paraphrases likewise retrieve the expected appropriate topic. The prior general benchmark remains **22/22** correct first results. An earlier private 19-question historical mapping has **17/19 literal exact IDs**: a new directly relevant sample-space lesson intentionally supersedes a broader probability article, and the outside-scope Quarto-to-PDF request correctly gets no statistical match. Those two items are not statistical retrieval errors; they are changes from the old exact-ID benchmark.
- Static mock clipboard tests passed for secure Clipboard API success, legacy copy-command success, and clipboard denial with select-and-copy fallback. These **do not** prove clipboard operation on Windows RStudio.
- Static offline Viewer audit found **98 local HTML pages, five valid local SVG files, ten image references with descriptions, and zero broken internal links, missing H1/page language, missing CSP metadata, or missing image alternative text**. Responsive CSS explicitly supports a single-column layout with breakpoints for narrow panes and horizontal overflow restricted to the code block. Rendering inside Windows RStudio at 350/450/600 CSS pixels, Help/Viewer history, keyboard behaviour and Windows clipboard **remain UNVERIFIED**.
- Local m710 source package `rulearn` version `0.4.0`: pre-freeze `R CMD build` passed and `R CMD check --no-manual` completed with **Status: OK**, zero errors/warnings/notes, eight test scripts including viewer code, native help, data adaptation and transfer. A previous check warning for non-ASCII characters in R code was corrected and the check rerun. The existing Quarto source site rendered 51 HTML pages. These checks must also pass after freezing the exact source SHA and stamping the private installer.
- The repository's explicit unselected redistribution licence is unchanged. No GitHub push, default-branch merge, site deployment or release is authorized.

**Release gates remain open:** human Windows RStudio Viewer/clipboard and student application/interpretation, later retention, exhaustive topic-by-topic source assessment for 89 incomplete catalogue entries, rights determination for broader redistribution, and explicit authorization for remote publication. A useful local QA candidate is not a verified learning-outcome improvement.
