# Four completed analysis sections

These passages are evidence-based AI-assisted drafts, not invented personal claims.

## Optimization selection

The retained profiling record identifies repeated copying of the 14-byte state as the dominant cost in solver3. This made the move interface a useful first target: passing source and destination pointers removes parameter and return-value copies from a routine called throughout the search. Direct mappings for all nine HTM moves also avoid repeating quarter-turn work for half and inverse turns. These changes preserve the search space and heuristic, so they address per-node execution cost without changing which solutions are admissible.

For the same recorded distance-11 input, the combined change reduced retired instructions from 435,132,487 to 184,068,852, a 57.7% reduction, and the resulting ELF contained no memcpy calls. This comparison measures the pointer interface and direct mappings together; it does not isolate their individual contributions. Afterward, permutation indexing accounted for 45.51% of the recorded solver4 profile, motivating the next lookup/indexing changes rather than further work on copying.

---

## Assembly reasoning

Each of the nine moves has a fixed cubie permutation and fixed orientation adjustments. Explicit assembly paths make those choices constants, avoiding the generic loop's repeated index calculation, move-table selection and loop-control instructions. This matters on RV32I, where general multiplication and division are unavailable and address-generation work must be expressed using simpler instructions.

The retained specified-input comparison falls from 53,779,947 instructions for solver7 to 40,549,573 for the direct-move assembly, approximately 24.6% fewer instructions. That supports the change for this measured input; it is not an exhaustive worst-case result for the historical version. The final assembly separately passed all 2,644 distance-11 inputs, with maximum 38,543,830 instructions.

Specialization trades code bytes for less runtime work. The final assembly has 4,296 bytes of text versus 2,752 bytes for the final GCC -O2 C build, an increase of 1,544 bytes (56.1%). This is a final-version comparison containing several optimizations, not an isolated measurement of move expansion. Its renderer-off static data is 126,079 bytes, within 128 KiB, so the larger code remains compatible with the stated static-data budget.

---

## Results synthesis

The measurements show that optimizing one dominant operation exposes another. Removing state copies shifted attention to ranking and move generation; host-generated tables and direct sparse lookup then reduced target-side indexing work. Removing a heuristic component and specializing assembly further reduced work per visited node, while the final search pruning reduced how often move generation and heuristic evaluation were needed. A lower cost per node and fewer explored nodes are distinct mechanisms and should not be conflated.

The selected design spends static space on precomputed distance tables and code space on fixed move paths. In exchange, it avoids building the full-state BFS table on the target and avoids expensive dense ranking in the hot heuristic path. The final renderer-off assembly uses 126,079 static bytes, leaving 4,993 bytes below the 131,072-byte limit, plus a separately reported 4,096-byte reserved stack. On the specified input it executes 15,147,934 instructions versus 31,343,837 for the final C build, approximately 51.7% fewer. The all-distance-11 maximum of 38,543,830 leaves 11,456,170 instructions below the 50-million limit. These claims follow the recorded build and measurement conventions; they do not establish simulator wall-time speedups on every host.

---

## Development reflection

The retained artifacts show three recurring difficulties: reducing target instruction cost without exceeding static memory, preserving optimal solutions while changing the search, and separating simulated execution checks from actual GUI observations. The progression from by-value states to pointer moves, then to precomputed lookup structures and specialized assembly, follows the measured cost shifts described above. The final C and assembly also have different performance results, so the report identifies the exact implementation for each number instead of treating all solver7 files as interchangeable.

Correctness evidence was kept separate from performance evidence. Host checks cover heuristic admissibility and optimal C solutions, while the assembly distance-11 sweep replays each returned path independently. CLI model passes and RAM renderer checks were useful but did not establish visible LED or pipeline behavior. That gap was closed by actual five-stage observations and twelve consecutive LED breakpoint captures, with every captured frame checked against the expected facelets.

The GUI work also exposed a practical verification problem: an attempted click or stale screenshot does not prove that a program loaded or a frame advanced. Recording the breakpoint, checking stopped execution and comparing complete frames made the final observation auditable. This reflection is a retrospective interpretation of retained AI-assisted records, not a claim that the student independently performed the experiments or a reconstruction of undocumented personal decisions.