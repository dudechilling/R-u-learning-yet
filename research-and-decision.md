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

- Native `.Rd` concept and function help, indexed for local search, with direct `help()` and ``?` / ``??` access.
- Local query search `ru_find()` returning concept, function and walkthrough types, `ru_open()` for a direct result, and `ru_guide()`/`ru_edit()` for portable content.
- 46 question-led walkthroughs preserved in `inst/guides/` and runnable example scripts in `inst/examples/`.
- Flagship examples for histogram, grouped boxplot and Welch independent-groups t-test using authentic datasets and ordinary R.
- Existing weighted-probability, alternatives, nonplot, irregular-time and route-reachability safeguards retained and tested.
- R help for common errors, deterministic typo correction, explicit suggestions rather than silently inventing a command or datum.
- Quarto renderable local reference navigation plus a light GitHub Actions check pipeline.
- No new statistical calculation functions, external runtime server, learner tracking, proprietary search service or license changes.

**Further accessibility improvement:** Flagship guides use explicit quick answers, question/data/method, one canonical commented R script (loaded with `knitr::read_chunk()`), interpretation, mistakes, alternative decision, related R Help, descriptive plot alt text, and optional independent transfer prompts.

**Phase 5 unknown:** The other 43 guides remain primarily convenience-wrapper demonstrations until they are carefully converted in place; this limitation is deliberate rather than disguised by a larger article count.



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
