# Required host verification and final C reference

AI-executed development evidence. This does not replace student-owned measurements.

- H1/H2: `full/host/oracle-summary.json`; admissibility over all 3,674,160 states,
  table occupancy, solved entries, maxima and 51,921 move comparisons.
- H3: `full/host/summary.json`; every state returns its BFS-optimal length and
  independently replays to solved. Four-worker wall time: 415.305790 seconds.
- H4: distance tables are byte entries, so no nibble accessor applies. Canonical
  masks are covered by `tests/solver7_search_assembly_test.py`.
- `host-checkpoints.tar.gz` contains per-shard logs and CSV hashes;
  `host-evidence-manifest.json` indexes exhaustive coverage. Large per-state CSV
  files remain local and can be reproduced with the commands below.
- `target/` retains raw final-C results for the two comparison inputs.
  `target-comparison.json` pins the final C binary and Ripes build.
- `distance11.csv` contains all 2,644 states from the independent BFS oracle.

## Reproduce from source

```sh
sh build_solver7_search.sh
cc -O2 -fno-builtin -fsanitize=undefined tests/solver7_search_test.c -o /tmp/search-test
/tmp/search-test
mkdir -p measurements/search_reproduction/host
cc -O3 -fno-builtin tests/solver7_search_exhaustive_test.c -o measurements/search_reproduction/host/verify
measurements/search_reproduction/host/verify oracle measurements/search_reproduction/host
python3 tools/run_final_validation.py host --out measurements/search_reproduction --workers 4 --source-label solver7_search.c
```

The H3 result is for C. Actual assembly performance and model execution are
separately documented in [target evidence](../solver7_submission_validation/README.md).
