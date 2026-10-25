# RU three-mode interaction, reference and visual design

RU is one R package with three distinct but connected experiences: Learning teaches and checks knowledge through learnr; Analyzing turns an explicit research question and inspected data into a reviewable statistical plan through Shiny/bslib; Referencing gives local answers, reproducible examples and installed R Help. The three experiences share verified semantic identifiers and source provenance. They do not share an invented exercise engine, execute code by navigation, or duplicate all educational prose into a new registry.

This document specifies intended screens, actions, states, responsive behavior and content contracts. It is an implementation target, not a substitute for executable UI, numerical, keyboard, platform or rights verification.

## 1. Entry points, capabilities and cross-mode returns

The home screen offers **Learn** (“follow a guided course and practise”), **Analyze** (“work from a question to a checked R analysis”) and **Reference** (“look up a concept, function, task or error”). A recoverable **Resume [specific lesson]** action is conditional on a valid stored record; a fresh installation never invents progress. Secondary links expose settings, Help, build identity, accessibility information and rights.

The intended new API entry behavior is explicit:

| Call | Intended visible behavior and outcome |
| --- | --- |
| `ru_workspace()` | Show the three-mode selector. Do not launch a lesson, execute data or reject an omitted argument because a formal default lists choices. |
| `ru_workspace(mode = "learn")` | Enter Learning path/lesson/resume selection; no arbitrary lesson selected. |
| `ru_workspace(mode = "analyze")` | Enter question-first Analyzing; no computation from navigation or supplied data alone. |
| `ru_workspace(mode = "reference")` | Call `ru_reference(query = NULL, view = "summary", open = TRUE)` to display the local catalogue/search entry. |
| `ru_workspace(mode = NULL)` | Reject the explicit invalid mode; do not interpret it as omitted. |
| `ru_workspace(mode = c("learn", "analyze"))`, `NA`, `""`, unknown value | Reject with a named invalid-argument result explaining exactly which values are accepted; do not guess or take only the first. |
| `ru_reference()` and `ru_reference(query = NULL)` | Display or return the local search/catalogue entry; no arbitrary reference is opened. |
| `ru_reference("histogram")` | Resolve the exact query using the preserved search contract, with summary as the default view. |
| `ru_reference("histogram", view = "detail", open = FALSE)` | Return the validated structured local match/path without showing an interface or executing a calculation. |
| `ru_reference(query = "", view = "summary")`, `NA` or invalid `view` | Return a typed input error; blank non-NULL is not silently treated as catalogue selection. |

`view` omitted selects `summary` even if the formal declaration uses `c("summary", "detail")`; an explicitly supplied vector is invalid. Boolean `open` must be a single nonmissing logical. Existing `ru_home`, `ru_open`, `ru_find`, `ru_plan` and R Help behavior stay compatible until an approved, independently tested change.

The shared content resolver, owned by the platform layer, joins locally installed source descriptors instead of copying Markdown text. Proposed exact surface codes are `learn`, `analyze`, `reference`, `example`, `asset` and `native_help`; the platform contract must freeze and test those names. The candidate descriptor includes stable ID, title, content version, local learning/reference/example/help/asset locators, supported method IDs, prerequisite and outcome IDs, rights provenance and separate review dimensions. Only the platform contract may freeze the exact surface-code vocabulary and record structure. A path is usable only after validating its installed root, existence and safe resolution; traversal, symlink escape, bad locale and unknown IDs return typed unavailable reasons. A syntactically valid ID cannot be treated as installed content.

**Distinct failure semantics.** Reference `NOT_FOUND` means a valid query has no indexed match; `UNAVAILABLE` means an identified requested representation, installed locator or capability cannot be used. Analysis `UNSUPPORTED` is a separate scientific-method result, never a search failure. Direct R API invalid input raises `ru_invalid_argument`; its bound UI displays `INVALID_ARGUMENT`. These are proposed new APIs, not existing legacy behavior.

A cross-mode control preserves the originating mode, source question, selected ID, version and a Back/Return destination. It does not pass private data to Learn or Reference merely to demonstrate a link. Content links may offer a non-executing explanation even when a method cannot execute.

### 1.1 Reference entry states, representations and return focus

Proposed `ru_reference(query=NULL, view=c("summary","detail"), open=TRUE, representation=NULL)` opens the catalogue for omitted/NULL query. `open=FALSE` returns a descriptor without Viewer, Help or code execution. Omitted `view` means `summary`; explicitly multivalued `view`, blank/NA query, invalid `open`, or a representation specified with NULL query raise `ru_invalid_argument`. A bound UI renders the invalid condition as `INVALID_ARGUMENT` and focuses the relevant control. `opened=TRUE` requires observing a real Viewer/Help launch. Keep existing `ru_find` and `ru_open` behavior.

| Reference result | Trigger and required behavior |
| --- | --- |
| `CATALOGUE` | NULL query: local search and categories; no arbitrarily selected page |
| `SINGLE_MATCH` | Exactly one registered ID; exact lookup before fuzzy search; resolve requested representation |
| `MULTIPLE_MATCHES` | Two or more distinct legitimate IDs: stable labelled candidate list and explicit user choice; never auto-open first |
| `NOT_FOUND` | Valid query without indexed hits: retain query and working Search/catalogue links |
| `UNAVAILABLE` | Identified ID but missing representation/installed locator/capability: name reason and verified alternatives |
| `INVALID_ARGUMENT` | UI rendering of the direct API `ru_invalid_argument` condition; no side effects |

On multiple matches, focus the results heading, then distinct candidate links. Selection focuses the article heading; Back restores query, result order, scroll and selected link focus if still compatible, or a safe heading with an announcement. One ID with compact and guide representations remains `SINGLE_MATCH`, not search ambiguity. Keep existing 960/400/320 CSS-pixel layouts and logical DOM order; this is a design contract, not a tested keyboard or screen-reader result.

Preserve **six** resolver surfaces: `learn`, `analyze`, `reference`, `example`, `asset`, `native_help`. Typed representations distinguish `reference/compact_md` (default), explicit `reference/legacy_guide_qmd`, `example/r_script`, `asset/svg`, proposed registered `asset/csv`, and `native_help/rd_alias`. No seventh guide surface. Record source presence, actual installed locator (`AVAILABLE`/`UNAVAILABLE` plus reason), consumer capability, version, independent reviews and rights separately. A known `missing_values` ID without compact Markdown reports `UNAVAILABLE/MISSING_ASSET`; its existing guide and example may be offered as separately labelled alternatives, never silently substituted.

Validate IDs by surface and exact registry membership. Keep legacy Viewer IDs matching `^[a-z][a-z0-9_]*$` in their original route, while new Learning/Analyzing descriptors may accept registered dotted IDs such as `ru.learning.foundation.03.bridge` and `describe.numeric`; registered assets may include `histogram-bins.svg`. Reject traversal, empty segments, unknown extensions/names, percent-encoded separators, slashes, backslashes, absolute/drive/UNC paths, controls, unsupported locale and symlink escape. Resolve only trusted registry locators under the installed root, checking canonical containment and regular file type. Never turn unchecked query text into a path or code.

## 2. Learning: entry to independent transfer

### 2.1 960 CSS px — guided lesson

~~~text
┌──────────────────────────────────────────────────────────────────────────────┐
│ Skip to lesson  RU  Learn | Analyze | Reference                  Help / Exit │
├──────────────────────────────────────────────────────────────────────────────┤
│ Learning › Lesson 3: Inspect before summaries           Step 2 of 5        │
│ Objective: check variable type, missingness, and observational units        │
├───────────────────┬──────────────────────────────────────┬───────────────────┤
│ YOUR PATH         │ CURRENT TASK                         │ WHY / FEEDBACK    │
│ ✓ Entry/refresh   │ Explain: NA is unknown, not zero     │ Prerequisites     │
│ ✓ Worked example  │                                      │ ORI-03, R-01...   │
│ ● Try with hints  │ R exercise editor (ordinary R)       │                   │
│ ○ Independent     │ [ code ...                    ]      │ Hint 1 (closed)   │
│ ○ Source transfer │ [Run code] [Check answer] [Hint]      │ Show why an       │
│                   │ [Reset this attempt]                │ error occurred    │
│                   │ OUTPUT or parser feedback below      │ [Related reference]│
├───────────────────┴──────────────────────────────────────┴───────────────────┤
│ Previous | Continue when ready | Save & exit | Discard current entry         │
└──────────────────────────────────────────────────────────────────────────────┘
~~~

At first entry, show three nonbinding placement routes: “new to R and statistics,” “know statistics, new to R” and “know R, revisiting statistics.” Each route shows what it skips and offers a prerequisite refresh. Skipping a lesson is not evidence of mastery, and no prerequisite is silently considered passed.

A lesson starts with one named outcome, an explanation and a worked example using bundled/local or base-R data. “Try” is a learnr exercise with an explicitly stated sandbox; it is not the student's ordinary Source pane. **Run** executes the exercise's actual R code if the runtime supports it; **Check** evaluates declared answer criteria, not time spent; **Hint** discloses progressively more help; **Reset** warns that current unsubmitted text will be replaced.

**Wrong answer path.** A parser error (“unexpected end of input”) keeps submitted code visible and locates the likely unmatched quote/bracket, offering a first hint rather than reporting statistical incompetence. A valid execution with the wrong answer shows expected properties (“three observed numeric values after excluding one NA”) instead of silently supplying a solution. Example conceptual misconception: `x == NA` does not identify missing data; feedback introduces `is.na(x)`. Wrong-case feedback should identify the misconception, retain the attempt for the active session and permit another try.

**Hint ladder.** First hint recalls the underlying concept; second identifies the relevant command or test; third can reveal an annotated worked step only after the learner chooses. Hint level is recorded as assessment context. Completing a guided step after a revealed solution is “practised,” not “performed independently.” Alternative correct R syntax must be accepted by a specified rubric, not rejected merely for differing from a model string.

**Independent transfer** uses a different input or context and no revealed solution. Check both result and explanation, distinguish factual correctness from luck or copied output, and allow another attempt. A learner may continue despite an incorrect response, with a visible “review recommended” consequence. The assessment must not claim a secure grade, timed examination or proctored identity.

**Source/Console transfer** is a separate learning step: open or create an ordinary R script in RStudio; explain that the learnr exercise environment and the real project differ; save, run, restart and rerun when supported. The UI does not claim the background tutorial can edit the parent IDE without verified `rstudioapi` capabilities. If unavailable, display explicit manual instructions and require real user observation before marking transfer achieved.

**Exit/resume.** “Save & exit” writes only versioned minimal progress (lesson ID, outcome/assessment ID, attempt result, hint level and review recommendation) through the platform revision-safe state adapter; typed code is retained only if an explicitly disclosed, supported storage choice exists. “Discard current entry” asks confirmation. On restart, Resume names the actual lesson/outcome and restored step; it does not invent the last draft text. A changed content version shows “prior attempt exists; review before continuing,” not automatic regrading. On crash or unsupported process cancellation, preserve the last validated state and mark the interrupted step unconfirmed.

### 2.2 400 CSS px — lesson in the RStudio pane

~~~text
┌─────────────────────────────────────┐
│ Skip to lesson  RU > Learn          │
│ Lesson 3: Inspect before summaries  │
│ Step 2 / 5   [Show prerequisites]   │
│ Objective and short explanation     │
│ ┌─────────────────────────────────┐ │
│ │ R code editor                  │ │
│ │ input remains after error      │ │
│ └─────────────────────────────────┘ │
│ [Run code           ]               │
│ [Check answer       ]               │
│ [Show hint          ]               │
│ Feedback: error, remedy, retry      │
│ ▸ Why / related Reference           │
│ [Independent transfer]              │
│ [Previous] [Save & exit]            │
└─────────────────────────────────────┘
~~~

At 400 CSS px the three columns become one reading sequence: objective and prerequisite summary; instruction; code; Run/Check/Hint; feedback; reference; navigation. Place the Run and Check buttons after the editor in DOM order, never visually reorder them away from keyboard order. Feedback appears next to the exercise with an accessible status region and focus target after an explicit Check.

### 2.3 320 CSS px — lesson reflow

~~~text
┌──────────────────────────────┐
│ RU > Learn                   │
│ Lesson / outcome             │
│ Prerequisites ▸              │
│ Explanation wraps            │
│ Code editor: scroll within   │
│ [Run code                  ] │
│ [Check answer              ] │
│ [Hint                      ] │
│ Feedback and retry           │
│ [Independent task          ] │
│ [Save & exit               ] │
└──────────────────────────────┘
~~~

Use 12 CSS px page gutters, single-column cards, visible labels, no horizontal page panning. Code can have an individually labelled scroll region and Copy. Screen zoom and actual RStudio tutorial process behavior require measured tests, not wireframe approval.

**Learning focus route:** skip → brand/nav → lesson goal → prerequisite link → step text → editor → Run → Check → Hint → feedback → independent task → Previous/Continue → Save/Exit. On error, announce a bounded explanation and place focus at the affected editor/feedback heading without losing code. Resume announces restored lesson, outcome and version.

## 3. Analyzing: question to checked and exportable computation

The analysis workflow is a staged decision with inspectable, deterministic planning. Opening the mode and inspecting data never automatically evaluates a method. The domain engine defines eligibility; the interface cannot change a returned status to make the page appear successful.

### 3.1 960 CSS px — scientific workbench

~~~text
┌──────────────────────────────────────────────────────────────────────────────┐
│ Skip  RU  Learn | Analyze | Reference                 Build/Help/Rights     │
├──────────────────┬──────────────────────────────────────┬────────────────────┤
│ STEPS            │ QUESTION-FIRST WORKSPACE             │ EVIDENCE & LIMITS  │
│ 1. Question   ✓  │ What should be described/estimated?   │ Checked in data:   │
│ 2. Data       ✓  │ [question and target units]          │ column, type, n    │
│ 3. Design     ●  │ [Select file/bundled data/object]     │ User attests: unit │
│ 4. Plan       ○  │ [numeric outcome] [missingness rule]  │ and exclusions     │
│ 5. Review     ○  │ [specific method/operation]          │ Unknown: sampling  │
│ 6. Run        ○  │ [Inspect checks and errors]           │ and representativity│
│ 7. Interpret  ○  │ [Back] [Review plan]                 │ No population leap │
│ 8. Export     ○  │                                      │ [Reference topic]  │
├──────────────────┴──────────────────────────────────────┴────────────────────┤
│ No execution until explicit plan review and affirmative Run confirmation.    │
└──────────────────────────────────────────────────────────────────────────────┘
~~~

**Step 1 — Question.** Require an objective and desired quantity/operation. The user may select a documented method ID or a uniquely explained deterministic mapping; ambiguous language returns NEEDS_INPUT and a choice, not AI-selected inference. A purely descriptive question does not require the user to certify independent population sampling; an inferential question requests its method-specific design information.

**Step 2 — Data selection.** No raw data is loaded simply by entering Analyzing. The user chooses an existing R object, a local file with visible path/import preview, or an installed example. Show selected source, observational unit, column names and apparent types, row count, missing/nonfinite values and a read-only preview. Data column names are quoted safely; they are never pasted as executable R expressions. Selection does not overwrite R objects or quietly normalize types. On invalid file, parsing uncertainty, duplicated identifiers or missing column, preserve the question, show a typed error, and offer Change file / Fix role / Back.

**Step 3 — Design and policy.** Ask what one row represents and, only when method-relevant, dependence, grouping, sampling/design, estimand, effect orientation and attestations. Keep distinct panels:
- **Checked data facts:** values and types actually computed from this selected snapshot, with check names and selection revision.
- **Attested study-design claims:** answers supplied by the user, including which records count as units and which exclusions are permitted.
- **Unknown/unresolved:** absent, contradictory or scientifically uncheckable assumptions. Unknown is not false and not independent.

A numeric outcome and NA values with no handling policy produce NEEDS_INPUT; text passed as numeric with no consent to transform is INVALID; a recognized clustered/repeated design for an unsupported inferential operation is UNSUPPORTED. A user can open an appropriate reference from any state, but cannot silently substitute a different method.

**Step 4 — Plan.** Call the pure planner with a validated schema that includes common fields, explicit `method_id`, `operation` and a typed method-specific `parameters` list. Show one of READY, NEEDS_INPUT, UNSUPPORTED or INVALID, the interpreted question, accepted/rejected methods, checked facts, attestations, missing decisions, warnings and limitations. Clicking a missing item returns the user to its controlling step. READY states only eligibility for this computation under recorded inputs; it does not prove design validity.

**Step 5 — Review and consent.** Render ordinary R source from `ru_analyze_code(plan)`, planned transformations/exclusions, outcome orientation, denominator, software version and any expected diagnostics. Include a checkbox acknowledging the current data snapshot and an explicit “Run this plan” control. Disclosure of data inclusion or removal must be a separate affirmative choice. A changed dataset, method, bound config or policy invalidates the old confirmation; execution must revalidate the binding. No data rows are silently logged or exported.

**Step 6 — Execute / cancel / fail.** Show an actual running state with the named method and progress only when knowable. Cancel must signal the real executing process when supported; on confirmation, display CANCELLED without fabricated partial success. A failed fit, parser error, dependency loss, rank deficiency, separation or nonconvergence yields FAILED with original diagnostics and a remedy link; no “success” card from partial estimates. Re-run requires a new review if assumptions or data changed. Unsupported cancellation must be explained, not simulated.

**Step 7 — Interpret and diagnose.** For SUCCESS, render estimates and uncertainty only where defined, sample/exclusion counts, warnings, method assumptions, limitations and exact code. Keep data checks, user attestations and unknowns visible beside output. State which population/causal claims are unsupported. A descriptive plot with a tiny sample is not proof of a particular distribution. For FAILED/CANCELLED, permit diagnostics and Back, not an output falsely labelled complete.

**Step 8 — Export and recovery.** Preview destination and proposed filenames, content kind, reproducible R script, summary, package/version provenance and `include_data = FALSE` by default. Never create files without explicit approval. An existing filename produces collision with Rename / Choose path / Cancel choices; an unwritable directory or serialization failure preserves plan/results and gives retry instructions. Including a dataset requires a distinct opt-in and a complete preview. A success notice names actual paths and persisted artifact hashes/identity; cancelling export does not alter results. Generated scripts must run without a proprietary RU GUI if their documented dependencies are installed.

### 3.2 400 CSS px — analysis in a narrow pane

~~~text
┌─────────────────────────────────────┐
│ RU > Analyze      Step 3: Design    │
│ [Steps 1–8 ▸]                     │
│ Question: describe temperature      │
│ Data: local selected table [Change] │
│ Outcome [temp_c             ▾]      │
│ Unit [one measured record     ]     │
│ Missingness [Choose policy   ▾]     │
│ [Checked facts ▸]                  │
│ [Your attestations ▸]              │
│ [Unknowns / limits ▸]              │
│ [Back] [Review plan]                │
│ Status: NEEDS_INPUT — choose policy │
└─────────────────────────────────────┘
~~~

The left stepper becomes a labelled disclosure ahead of the current step. The right evidence panel becomes three ordered sections directly below controls. Step status is textual, not icon/color-only. Returning to an earlier step preserves non-sensitive choices but invalidates READY/confirmation where the underlying data or method changed.

### 3.3 320 CSS px — analysis reflow and failure path

~~~text
┌──────────────────────────────┐
│ RU > Analyze                 │
│ Step 6 / 8: Run             │
│ Ready under stated facts     │
│ [Review R code            ] │
│ [Run this plan            ] │
│ [Cancel if available      ] │
│ FAILED: fit did not converge │
│ ▸ Original diagnostics       │
│ [Edit model / data         ] │
│ [Back to plan             ] │
└──────────────────────────────┘
~~~

At this width, the step list, evidence blocks, code preview, diagnostics and export options appear in one DOM sequence. No chart, table or ordinary paragraph requires two-axis panning; responsive numerical tables can stack field/value pairs. Any code block has a labelled internal scroll region. Execution failure remains visible without requiring the user to discover a hidden sidebar.

**Analysis focus route:** skip → mode nav → numbered step heading → current fields in scientific decision order → checked/attested/unknown disclosures → Back/Review → inspect script → explicit confirmation → Run/Cancel → result heading → diagnostic details → export preview → confirm/save. On invalid plan, move focus to first unresolved field with an error summary; on failure, announce status and retain the inspected plan; on export collision, focus Rename/Choose path. Progress indicators have textual labels and cannot claim elapsed-time accuracy without a real signal.

## 4. Referencing: direct answer and source-aware depth

### 4.1 960 CSS px — summary before depth

~~~text
┌─────────────────────────────────────────────────────────────────────────────┐
│ Skip to content  RU           Learn | Analyze | Reference          Help      │
│ Reference > Histograms                                 Local build identity│
│ [Search a concept, task, function or error                 ] [Search]       │
├─────────────────────────────────────────┬───────────────────────────────────┤
│ Direct answer: what the graph shows     │ Source status and version         │
│ Native R example and Copy button        │ ▸ Match and limitations           │
│ Expected output; figure/caption/alt     │ [Learn this] [Analyze with this]  │
│ ▸ Arguments, assumptions, uncertainty   │ [Open native R Help]              │
│ ▸ Citations and asset provenance        │ [Back to search results]          │
└─────────────────────────────────────────┴───────────────────────────────────┘
~~~

Search remains visible. The indexed answer and example arrive before deep arguments. Function signatures point to the currently installed R Help; legacy wrapper code is labelled as such. Copy never executes JavaScript-evaluated R code. No match, unavailable installed target and incompatible analysis selection receive different explanations.

### 4.2 400 CSS px — reference pane

~~~text
┌─────────────────────────────────────┐
│ RU > Reference                     │
│ [Search topic or R error          ]│
│ [Search                          ]│
│ Histogram: direct answer           │
│ [Native help] [Copy R example]     │
│ Code inside labelled scroll region │
│ Expected output / explanation      │
│ Figure scaled to content width     │
│ Caption plus descriptive text      │
│ ▸ Assumptions / sources            │
│ [Learn this] [Analyze with this]   │
│ [Back to results]                  │
└─────────────────────────────────────┘
~~~

### 4.3 320 CSS px — reference reflow

~~~text
┌──────────────────────────────┐
│ RU > Reference               │
│ [Search                     ]│
│ [Search                     ]│
│ Immediate answer wraps       │
│ [Copy R example             ]│
│ [Open native help           ]│
│ Figure and text description  │
│ ▸ Limits / attribution       │
│ [Learn this                ] │
│ [Analyze with this         ] │
│ [Return to results         ] │
└──────────────────────────────┘
~~~

At 400 CSS px permit 16 CSS px side gutters; at 320 use 12 CSS px. Search and action controls stack before ordinary content overflows. Tables render as labelled stacked cells. The full-size figure link must open a local asset; links to external sources clearly identify that leaving offline RU may require network access. The Copy failure path selects text, describes the OS shortcut and leaves focus/keyboard context intact.

**Reference focus route:** skip → brand/nav → search field → Search → result heading → one or multiple selectable IDs → chosen article heading → direct answer → Copy → native Help → expandable limits/sources → Learn/Analyze → Back. For `MULTIPLE_MATCHES`, require exact-ID selection and restore the prior list/query/focused link on Back. Unavailable content focuses a status heading with a genuine alternative. A catalogue visit selects no arbitrary page. Keyboard and rendered focus remain NOT_TESTED.

## 5. Common state table and design guarantees

| Surface | Empty / first visit | Working | Invalid, unsupported or unavailable | Success | Exit / return |
| --- | --- | --- | --- | --- | --- |
| Workspace | Exactly three choices, no fabricated resume | Probe routes with explained progress | Unavailable dependency named, no fake callback | Intent opens validated surface | No background data execution |
| Learning | Named outcome and optional prerequisite refresh | Run/Check/hints and actual status | Parser/misconception feedback preserves attempt | Rubric-based evidence; guided ≠ independent | Save bounded progress or explicitly discard |
| Analyzing | Question-first; data not automatically read | Inspected data → plan → reviewed execution | NEEDS_INPUT/INVALID/UNSUPPORTED and FAILED/CANCELLED distinct | Checked result with uncertainty/limits as applicable | Back preserves safe inputs; data never silently overwritten |
| Reference | Catalogue/search entry | Local search state | NOT_FOUND/UNAVAILABLE different from plan UNSUPPORTED | Direct answer, tested example when available and real links | Return to prior query/mode without executing |
| Export | Destination and data-inclusion preview | Named artifact creation and real cancellation | Collision/unwritable/failed serialization explained | Existing artifact path and identity confirmed | Never overwrite implicitly |

For all three modes: stable headings and landmarks; skip link; logical DOM order; visible focus; keyboard-only operation; status messages with proper name/role and readable announcements. At 400 CSS px and 200% zoom and at 320 CSS px ordinary text must reflow without page-level horizontal scrolling. Long code may scroll within a named container. All essential information is available without relying on hue, hover or animation. These are testable requirements, not claims of tested accessibility. Applicable web baseline: WCAG 2.2 AA (https://www.w3.org/TR/WCAG22/). Real RStudio and assistive-technology tests are necessary to qualify a released build.

## 6. Field Atlas typography, color and statistical figures

The canonical installed token source is `inst/www/field-atlas.css`; `R/field-atlas.R` parses its nine named roles for R users and `scripts/generate-figures.R` uses it for source-generated SVG. Other runtimes consume the same decisions rather than creating a second theme.

| Token | Value | Purpose and restrictions |
| --- | --- | --- |
| ocean | #28627A | Readable primary links, selected control and action background |
| clay | #C66A49 | Warning edge or chart annotation with explicit text; not small regular text on paper |
| jade | #3F806E | Status and chart accent with a label; not normal body text on paper until contrast is verified |
| ochre | #B18A3B | Distinct chart stroke/pattern; not sole meaning |
| iris | #7B668C | Alternate chart annotation with noncolor distinction |
| slate | #73818B | Nonessential stroke or subdued illustration, not small muted body text |
| warm-paper | #FAF8F4 | Page background |
| deep-ink | #273640 | Main body/heading/status text |
| grid | #E1E4E0 | Dividers; not the only focus cue |

Design targets: 16 CSS px system body at about 1.55 line height; 14 CSS px secondary explanatory text; scalable 13–14 CSS px monospace; spacing scale 4/8/12/16/24/32 CSS px; 3 CSS px visible focus stroke with offset; aim for 44 by 44 CSS px pointer targets without hiding keyboard controls; 4–6 CSS px corner radius; motion never required. Use white/paper surfaces with deep-ink text and ocean action backgrounds with white text. The source sRGB ratios calculate to approximately 11.73:1 ink/paper, 6.35:1 ocean/paper and 6.73:1 white/ocean. Clay/paper, jade/paper and slate/paper are below 4.5:1 for regular text (approximately 3.56:1, 4.38:1, 3.78:1). Measured rendering and interactive states still need browser/platform verification.

Statistical plots state whether they use measured observations, simulated values or a schematic. Every axis names variable/unit and whether its vertical scale is count, density, proportion, probability or another quantity. Density bars are interpreted by **area** when widths differ. Multiple series use direct labels, line patterns and independent text—not color alone. Plot calculations and labels come from a checked reproducible R generator; the script and committed SVG are distinct distribution artifacts. Avoid a network-hosted image, external font or nonessential renderer.

## 7. Semantic source roles, licensing and reproducibility

Maintain separate authorities for distinct use cases:

| Canonical source | Distinct purpose |
| --- | --- |
| `inst/extdata/coverage.csv` | Legacy local-topic index, content-review labels and lookup identifiers; not a curriculum mastery table |
| `inst/lessons/{id}.md` | Compact native Viewer reference answer and metadata |
| `inst/guides/{id}.qmd` | Long-form explanation and worked guide source, optionally rendered through installed R Help/Console without Quarto CLI dependency for learners |
| `inst/examples/{id}.R` | Ordinary R example for inspection, editing and legacy `ru_code`/`ru_edit`/`ru_run` consumers |
| `inst/extdata/reference.csv` and `man/*.Rd` | Installed help/topic index; base/stats/graphics signatures remain authoritative in corresponding installed R Help |
| `inst/www/figures/*.svg` | Local generated vector illustrations with source, caption and text alternative |
| Learning outcome/assessment registry | Versioned instructional achievements and transfer criteria; does not inherit legacy VERIFIED labels |
| Analysis method registry | Supported typed computations, data checks and limits; independent from legacy keyword matching |

A source ledger entry records original creator or upstream, source version/reopenable locator, license evidence, actual permitted use, derivative status, attribution, data context and independent review outcome. Declared MIT and CC-BY-4.0 scope labels do **not** independently establish rights or originality. A bibliography URL is attribution, not permission. Keep unresolved material distinct, exclude affected distribution when rights are unknown, and do not rewrite licenses by assumption. In the baseline `missing_values` has no compact `inst/lessons/missing_values.md`, but does have distinct `inst/guides/missing_values.qmd` and `inst/examples/missing_values.R`, with pending review. The `import_csv` compact, guide and R example exist and are separate from future L2 teaching CSV assets. Native Help alias `r_mean` is in `man/function-mean.Rd`; `r_hist` is in `man/function-hist.Rd`.

The histogram topic legitimately links compact `histogram`, adjacent `histogram_breaks`, long guide `inst/guides/histogram.qmd`, ordinary example `inst/examples/histogram.R`, native Help alias `r_hist`, and source-generated `inst/www/figures/histogram-bins.svg` from `scripts/generate-figures.R`. The figure's observations are **150 iris sepal lengths**, not a learner's private file. The preserved candidate illustrates **four 1-cm bins and sixteen 0.25-cm bins** with equal count-axis scale under the default **right-closed** convention: (5, 6] cm has 57 flowers and (5, 5.25] cm has 13. A separately labelled **left-closed** illustration with identical observations and breakpoints instead has [5, 6) = 61 and [5, 5.25) = 23; it must recompute text/captions and must not reuse the right-closed counts. The earlier baseline broad panel uses `breaks=8` (eight bins under the inspected R version), not the preserved candidate's four. The separate existing `faithful` tutorial concerns **272 eruptions**, and the G2 teaching example uses **four constructed temperatures**: neither is depicted in the iris SVG. Keep existing figure/alt/captions intact unless a documented defect warrants targeted review. L3 reviews statistics and the rights reviewer examines original sources. Installed `graphics::hist` Help governs the running R version.

## 8. One end-to-end foundation journey, without premature histogram mastery

This example is the required **design contract** linking a foundation lesson, a descriptive analysis and a reference. It is not a claim that the new lesson/runtime/API is installed.

**Learning identifiers.** The outcome IDs `ORI-03` (Source/restart), `R-01` (vectors/assignment), `R-02` (functions/help), `R-03` (indexing and missingness), `R-04` (data frames and types), and `DAT-01` (import/type/unit provenance) are the curriculum's specified IDs. The Learning-owner R1 contract proposes stable tutorial IDs `ru.learning.foundation.01`, `ru.learning.foundation.02` and `ru.learning.foundation.03`, all under content version `ru-learning-foundation-v1`. The third is the linked journey ID; these IDs are **proposed by the Learning owner, pending platform resolver registration**, not existing installed tutorials. Exercise identifiers use its documented suffixes `.index`, `.frame`, `.summary`, `.csv`, `.transfer` and `.bridge`. The lesson's taught prerequisites and transfer rubric must be frozen before deployment. `DAT-01` remains incomplete until the learner imports the proposed `sites-intro-v1.csv`, inspects actual source/types/unit declarations and independently transfers work to Source/Console. L2 has authored exact synthetic guided and held-out CSV **bytes in external specifications**, but neither is installed as a package asset or proven usable in RStudio. The held-out `sites-transfer-v1.csv` remains distinct; a constructed in-memory example cannot satisfy independent CSV transfer.

**Entry and learning.** The learner opens `ru_workspace()`, chooses Learn and resumes or selects `ru.learning.foundation.03` only after viewing its ORI/R prerequisites. Within learnr, explain NA versus zero using this **constructed in-memory example**, not the future guided L2 CSV:

~~~r
x <- c(13, NA_real_, 18, 20)
d <- data.frame(site = c("N", "N", "S", "S"), temp_c = x)
str(d)
sum(is.na(d$temp_c))
mean(d$temp_c, na.rm = TRUE)
~~~

The recorded data table has four rows, one NA and three observed values (13, 18, 20 degrees C). The repeated N/S site labels are categories, not unique observational-unit IDs and not evidence of independent sampled units. Excluding the missing value explicitly gives mean 17 degrees C. The learner checks types, explains the exclusion denominator, repairs an `== NA` misconception, then independently handles a differently ordered variable with a new missing entry. Mark a hint-assisted result “practised” only; independent performance requires the distinct transfer assessment. A separate Source/Console step checks whether the student can save and rerun a script; it is not passed by completing the learnr sandbox.

**Transition to Analyze.** For the constructed example immediately above, “Analyze these observations” carries the objective `describe the observed temperatures`, selected numeric role `temp_c` and its constructed-source identifier, **not** the guided CSV asset ID. It requires visible consent before opening or selecting the data. The analysis target is **AN-01 / `describe.numeric`**. Show four selected rows, one missing, three included after user selection of “omit NA for this summary,” output n = 3, mean = 17 degrees C, and the no-inference warning. If no exclusion policy is chosen, the plan is NEEDS_INPUT; a text-type substitution without consent is INVALID. Do not require an independence attestation for this purely descriptive summary. Plan review lists `method_id = "describe.numeric"`, the bound dataset version, chosen missingness, previewable R and intended plot options. Execution requires explicit Run; an altered data snapshot invalidates old confirmation. A small-sample histogram may be offered as an exploratory output with a caution about unstable bins, not as evidence of mastering later `EXP-02`.

**Different authored CSV bridge, not the same research frame.** L2's proposed guided asset `ru.learning.foundation.03.sites-intro-v1` has columns `row_key` (character log-record key), `site_group` (repeated category) and `reading` (numeric outcome), with four fictional records and one missing value. Only the explicit L2 **source card** declares the measurement unit `degree_Celsius`; the column name itself supplies no unit. Its uninstalled held-out transfer asset `ru.learning.foundation.03.sites-transfer-v1` has different rows/fields, leading-zero character codes and readings declared `degree_Fahrenheit`, not a continuation of the guided Celsius data. Neither repeating groups nor log-record keys prove independent sampled participants.

If a user chooses to analyze the guided asset instead of the constructed frame, use the actual `reading` column, source asset ID/version, authored unit provenance and a fresh snapshot of the imported values/types/order/NA pattern. Do not silently rename it to constructed `temp_c`, reuse that demonstration's consent or plan identity, or transmit raw learner rows to Reference. L1's proposed `source_context` keeps **raw parsed frame**, **declared source-card metadata**, and **derived contextual unit-enriched snapshot** distinct without mutating the user's data. The proposed `ru-units-v1` string `degree_Celsius` is an authored declaration; `degC` occurs only as a version-pinned legacy alias for the distinct constructed L3 fixture. Unit absence or conflict must produce a typed question/refusal, never inference from `reading`, `temp_c` or a filename. Both example datasets can yield observed-case mean 17 degrees C under explicit exclusion consent, but remain different records, source identity, snapshots and plan IDs.

**Transition to Reference.** “Why did missingness change my denominator?” opens the available compact `mean` reference, which explains the explicit `na.rm=TRUE` decision and denominator; “How do I inspect stored types and count NAs?” opens the existing compact `inspect_columns` reference. Installed function-help topic `r_mean` provides the documented function usage. The coverage registry also names `missing_values` as an AUTHORED topic, but the corresponding compact `inst/lessons/missing_values.md` does not exist in the inspected baseline: the resolver must report typed UNAVAILABLE rather than claiming a reviewed direct answer. “What is a histogram?” may expose `histogram` and adjacent `histogram_breaks` with the **separately sourced** figure `inst/www/figures/histogram-bins.svg`, whose data are iris flowers, not the four temperatures. This optional link is orientation only; do not mark `EXP-01` or `EXP-02` achieved or substitute the iris figure for the learner's calculated output. Returning to Analyze preserves the question, plan status and no private-data transfer into Reference.

**Export and return.** After explicit confirmation and a successful numeric summary, preview `analysis.R` and `summary.txt` (proposed names) without raw data by default. A destination collision yields Rename/Choose path, not overwrite. The saved script records how the originally selected example data are obtained and how NA handling was chosen. Back to Learn preserves the relevant outcome and attempt version; transfer evidence is unchanged by browsing references or executing a descriptive analysis.

**Cross-mode route IDs:** `ru.learning.foundation.03` (exercise `.bridge`) → `R-03`/`R-04` (with `DAT-01` independently assessed) → `AN-01`/`describe.numeric` with exact bound `temp_c` for the constructed dataset **or** `reading` for the future guided CSV → compact `mean`, `inspect_columns`, `import_csv`, native Help `r_mean`; compact `missing_values` reports `UNAVAILABLE` with separately labelled guide/example alternatives. Optional `histogram`/`histogram_breaks` and `inst/www/figures/histogram-bins.svg` concern a different iris dataset. No status is promoted merely because a route was visited.

## 9. Design review obligations

The platform owner must prove valid no-argument launches, typed resolver outcomes, content provenance, safe return routes and compatibility of learnr, bslib, static Viewer and R Help. The Learning owner must supply actual lesson IDs, accepted equivalent solutions, diagnostic wrong cases, hints and a separately observable Source/Console transfer. The Analysis owner must confirm typed plan/method statuses, dataset binding, method-specific attestation rules and numeric oracles. Independent QA must test exact committed source, installed and offline routes, 400/320 CSS-px reflow, real keyboard/focus behavior, Windows process lifecycle, rights evidence and representative users. Review of drawings or terminology alone cannot satisfy those tests.

The implementation must preserve original distinct sources, working legacy APIs, validated mathematical meaning and unmodified user data. Missing or unverified dependencies appear as honest unavailable routes. No new editor, custom statistics engine, hosted account requirement, or unapproved redistribution is implied by these screens.
