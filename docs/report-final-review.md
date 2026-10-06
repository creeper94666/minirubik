# Final report review and replacement sections

AI-generated editorial/support material, 2026-10-07. This is a local review of the live [HackMD note](https://hackmd.io/qtmRCStHRkOGkX3KbAyLMA), not a claim that the online note has been edited or formally submitted. The [captured page](../measurements/gui_followup_20261007/report/hackmd-before-ax.txt) identifies the reviewed content. The student must review the technical interpretation and accurately disclose authorship.

## Version labels to use consistently

“Current verified implementation” means `solver7_search.c` and the matching current `solver7_optimization.s`, with `solver7_optimization_led.s` as the shared renderer-switch source. It does not mean that student-authorship, GUI observation or submission requirements are complete. “Historical” applies to solver3–solver7, direct-move assembly and Horner assembly before canonical pruning/inverse orientation. Do not call the 34,934,509-instruction Horner snapshot the final solver.

| Location in the live note | Required correction |
| --- | --- |
| Final Solver Profile | Rename to **Historical Horner Assembly Profile**. Keep 34,934,509 instructions, 3,788 text bytes and 118,708 static bytes only under that label |
| solver7 heuristic described as final `max(hp,ho)` | Label it historical. Current heuristic also includes inverse-orientation distance, as the existing Additional Search Pruning section already states |
| GCC reference comparison TODO | Replace the factual rows with the current comparison below; keep student interpretation separate |
| Worst-case distance-11 TODO | Replace with the complete 2,644-case result below |
| Host correctness `test_all.c`, 1111.137 s, called final | `test_all.c` is an earlier solver test. Use the pinned `solver7_search.c` H3 summary and 415.305790 s; do not assign the unverified 1111.137 s to the current build |
| Target test matrix TODO | Insert all three ISS/RV32_5S CLI cases below; label the pipeline column as CLI execution, not GUI signals |
| Renderer switch TODO | Replace with the existing build and allocated-byte equality evidence below |
| Finite replay 35,251,419 instructions | Label historical Horner/RAM-renderer result. Current finite RAM-renderer check is 15,464,846, not a GUI observation |
| Optimization summary ends at Assembly v2 | Keep v1/v2 as history and append current C/current assembly rows |
| “12.45 times” called final | Applies to 435,132,487 / 34,934,509 only. Keep as a historical ratio or remove; do not attach it to the current solver |
| Stage 1 command rendered with an en dash | Put `--repetitions 3` inside a code block so the two ASCII hyphens remain intact |
| Student reasoning, reflection and AI disclosure TODOs | These remain genuine author tasks; do not delete them as if evidence tables satisfy them |
| GUI/pipeline blocker says the user program is still running | Superseded by this follow-up: it was stopped with authorization, but subsequent load/control errors prevent verified GUI observations |

The local historical draft has been edited to make these version boundaries explicit. The live note has **not** been changed in this task as of the review capture. Subsequent publication was explicitly authorized on 2026-10-07; see [publication status](publication-status-20261007.md).

## Replacement: current C and assembly comparison

All results in this table are existing **AI-executed** measurements for RV32_ISS, RV32I without extensions, renderer disabled. Counts include startup, search, replay validation, output and exit. The comparison uses the same current search algorithm; old `solver7.c` is a historical reference, not the final C comparison target.

| Current implementation | `21345671111111` instructions | `54721631111111` instructions | Linked `.text` bytes | Static data bytes |
| --- | ---: | ---: | ---: | ---: |
| `solver7_search.c`, GCC -O2 | 31,343,837 | 79,635,246 | 2,752 | 126,088 |
| `solver7_optimization.s` | 15,147,934 | 38,543,830 | 4,296 | 126,079 |

Assembly reduces executed instructions at the cost of 1,544 additional text bytes. The two comparisons do not by themselves establish a worst-case bound; that comes from the separate complete sweep. [Pinned current evidence index](https://github.com/creeper94666/minirubik/blob/d565c5b9636610f5c88f363f16a543b26599b8e1/docs/submission-status.md).

The complete renderer-disabled assembly sweep measured all **2,644** exact distance-11 states. Maximum: **38,543,830** instructions at `54721631111111`; cases above 50,000,000: **0**. The specified input took **15,147,934** instructions. All returned paths had length 11 and passed independent replay. [Sweep summary](https://github.com/creeper94666/minirubik/blob/d565c5b9636610f5c88f363f16a543b26599b8e1/measurements/solver7_submission_validation/ripes/summary.json).

The current full-domain C validation covers every one of the **3,674,160** ranks exactly once, checks optimal solution lengths and independently replays solutions. Its four-worker H3 wall time is **415.305790 seconds**, under the recorded concurrent-load conditions. This is C validation, not an all-state execution proof for assembly. The C source SHA-256 is `23df991e6ac85882a45aa27588f504dd49b573658a35b84d264b43d130725998`. [H3 summary](https://github.com/creeper94666/minirubik/blob/d565c5b9636610f5c88f363f16a543b26599b8e1/measurements/solver7_search/full/host/summary.json).

## Replacement: target model checks

These are existing AI-executed CLI results for the shared renderer-off source. Both models return the expected optimal length and pass independent replay. The one-instruction difference between models is retained as actually reported; the terminating ecall can be counted differently.

| Input | Optimal length | RV32_ISS instructions | RV32_5S CLI instructions |
| --- | ---: | ---: | ---: |
| `12345671111111` | 0 | 424 | 423 |
| `25314672313211` | 1 | 1,236 | 1,235 |
| `21345671111111` | 11 | 15,147,934 | 15,147,933 |

[Per-case model evidence](https://github.com/creeper94666/minirubik/tree/d565c5b9636610f5c88f363f16a543b26599b8e1/measurements/solver7_submission_validation/models). These results do not establish an IF/ID/EX/MEM/WB signal walkthrough.

## Replacement: renderer build scope

The same `solver7_optimization_led.s` builds with assembler symbol `RENDER=0` for CLI measurement and `RENDER=1` for GUI replay. The renderer-off build has byte-identical allocated contents to the benchmarked optimized solver. The GUI build passes the observed `LED_MATRIX_0_BASE`, `LED_MATRIX_0_WIDTH` and `LED_MATRIX_0_HEIGHT` symbols, with compile-time 35×25 checks. The measured renderer-off static data is 126,079 bytes and text is 4,296 bytes. The current infinite GUI replay build has 127,099 static bytes and 5,416 text bytes.

The current finite two-round RAM-renderer check took 15,464,846 ISS instructions. Its RAM destination and finite-loop build differ from the GUI build; this supports replay integration, not visible peripheral behavior. [Build guide](https://github.com/creeper94666/minirubik/blob/d565c5b9636610f5c88f363f16a543b26599b8e1/solver7_optimization_led_README.md). Live initial/intermediate/solved screenshots and observed per-move redraw remain unverified.

## Prepared addition: critique of upstream report.md section 7

This is AI-generated analysis for student review. It is grounded in [section 7 at the checked upstream baseline](https://github.com/sysprog21/minirubik/blob/231796cc48868f4ea276f652139b6bebbad0cd02/report.md#7-implementation-notes-and-possible-improvements), also preserved in the [local section snapshot](../measurements/gui_followup_20261007/report/upstream-report-section7.md).

The upstream report's recommendations are reasonable for a hosted solver, but their value changes under this assignment's target constraints. Its first proposal removes the 14,696,640-byte BFS queue and encodes depth and move together in each table byte. That removes most of the dominant baseline allocation, but still retains 3,674,160 bytes for complete states and 34,614 bytes of transitions: **3,708,774 bytes**, before other storage. Even the state table alone is more than 28 times the 131,072-byte static-data limit. Moving it to the heap is not a workaround because heap allocation is forbidden. Scanning all states for 12 levels also entails 44,089,920 table-entry inspections, before expansions; that is an operation count, not an RV32I retired-instruction measurement. Queue removal alone therefore does not meet the target memory or execution requirements.

The final paragraph argues for retaining the complete table because it is a verification artifact. Exhaustive BFS is valuable as a **host-side oracle**: it supplies exact distances, a coverage count and the depth histogram used to establish diameter 11 for the encoded move graph. Those artifacts can be retained with fingerprints and used to test the target algorithm without rebuilding or storing the full-state table in every target execution. The target can instead carry admissible abstract tables and perform actual bounded search. This separation preserves exhaustive host evidence while respecting the target data limit and the prohibition on a precomputed complete answer table. Exhaustive graph traversal alone also does not prove that an erroneous move model matches a physical cube; independent move/representation checks remain necessary.

Other recommendations transfer more directly. Checking a move before indexing and bounding replay prevent malformed-table errors from becoming out-of-bounds accesses or an unbounded replay; the target should likewise validate its returned sequence. Distinguishing allocation failures from completeness failures is useful for the host oracle, although the no-heap target has a different failure model. Moving the 34,614-byte transition arrays off the stack helps some embedded configurations, but making them static counts against the target budget, and relocating them does not remove their storage cost. Incremental proofs of unranking validity help justify the host model and index bounds; they complement, rather than replace, end-to-end comparison and independent replay.

Finally, upstream host runtimes and measured MiB values are specific to its platform and executable. They must not be presented as Ripes measurements. The newly recorded control/large-region experiment measures a process peak-RSS slope, with explicit variability and background-load limitations, rather than assuming that each guest byte costs one host byte.

## Publication and formal-submission status

The note was readable in a browser state showing a Login button. This is evidence that the note was readable without an authenticated editing session at observation time; it does not by itself verify its exact Publish state, Signed-in users permission, or revision history. A later revision dialog displayed five saved timestamps (2026-10-05 21:59, 22:10, 22:25; 2026-10-06 23:50; 2026-10-07 01:45). The count alone does not establish substantive differences; at least three substantive saved revisions remain unverified. No history was fabricated.

The original fork-at-creation SHA remains unproven. Keep the existing limitation rather than relabeling the earliest pre-push baseline as a proven fork SHA.

No GitHub upload, HackMD edit, commit, push, tag or form submission occurred in this follow-up. New evidence paths are still local. The older pinned links above refer to already published evidence; new local files must receive verified remote links only after authorized publication. The factual disclosure must describe AI-generated implementation/assembly, tests, execution and writing where applicable; do not replace it with a no-AI declaration or imply that disclosure establishes independent student authorship.

The final submission still requires an explicitly selected main commit/tag, a saved HackMD revision URL, verified permissions/history, accurate disclosure, and the actual automated accepted response. No accepted email or submission is claimed.
