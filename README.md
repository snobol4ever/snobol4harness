# harness

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Shared test infrastructure for the snobol4ever compiler/runtime family.

Serves three compiler/runtime repos:

| Repo | What |
|------|------|
| [snobol4dotnet](https://github.com/snobol4ever/snobol4dotnet) | Full SNOBOL4/SPITBOL → .NET/MSIL |
| [snobol4jvm](https://github.com/snobol4ever/snobol4jvm) | Full SNOBOL4/SPITBOL → JVM bytecode |
| [one4all](https://github.com/snobol4ever/one4all) | Native compiler → x86-64 ASM |

## What Goes Here

| Component | Status |
|-----------|--------|
| Oracle build scripts (CSNOBOL4 + SPITBOL from source) | Planned |
| Cross-engine runner — same program on all three engines, diff outputs | Planned |
| Worm generator bridge — feed generated programs to all three engines | Planned |
| Three-oracle triangulation (SPITBOL + CSNOBOL4 → ground truth) | Planned |
| `diff_monitor.py` — Sprint 20 double-trace diff tool | Planned |
| Corpus test runner — all corpus programs × all engines | Planned |
| Coverage grid — feature × engine pass/fail matrix | Planned |

## Design Principles

- **Language-agnostic interface.** Each engine exposes `run(program, input) → output`.
  The harness does not care whether the engine is C#, Clojure, or C.
- **Corpus-driven.** Test programs live in
  [corpus](https://github.com/snobol4ever/corpus).
  No test programs live here.
- **Oracle-first.** CSNOBOL4 and SPITBOL are always ground truth.
  The harness builds them, runs them, and compares our engines against them.
- **Incremental.** Start with the cross-engine runner. Add components one at a time.

## Status

**Active — `net-benchmark-scaffold` sprint.**

| Component | Status |
|-----------|--------|
| `crosscheck/crosscheck.sh` — engine-agnostic corpus runner | ✅ session155 |
| `adapters/dotnet/run.sh` — DOTNET calling convention | ✅ session155 |
| `adapters/dotnet/run_crosscheck_dotnet.sh` — DOTNET-specific runner | ✅ session155 |
| `adapters/tiny/run.sh` — TINY (one4all) calling convention | ✅ session156 |
| `adapters/jvm/run.sh` — JVM (snobol4jvm) calling convention | ✅ session156 |
| Oracle build scripts | Planned |
| Benchmark grid (`bench.sh`) | Planned |
| Three-oracle triangulation | Planned |

### Quick start

```bash
# Run DOTNET against full corpus crosscheck
CORPUS=$HOME/corpus/crosscheck \
  bash crosscheck/crosscheck.sh --engine dotnet

# Run DOTNET only (direct, faster)
CORPUS=$HOME/corpus/crosscheck \
  bash adapters/dotnet/run_crosscheck_dotnet.sh

# Run all available engines
bash crosscheck/crosscheck.sh
```

Full design: see `PLAN.md §7` in
[snobol4ever/.github](https://github.com/snobol4ever/.github).

## CSNOBOL4 adapter (added session this session)

The Budne CSNOBOL4 2.3.3 test suite (118 programs) is now wired into the harness.

| Component | Status |
|-----------|--------|
| `adapters/csnobol4/run.sh` — CSNOBOL4 calling convention | ✅ |
| `adapters/spitbol/run.sh` — SPITBOL calling convention | ✅ |
| `adapters/csnobol4/run_crosscheck_csnobol4.sh` — Budne suite runner | ✅ |

### Baselines (recorded against corpus/programs/csnobol4-suite, 116 runnable of 124)

| Engine | Pass | Notes |
|--------|------|-------|
| SPITBOL oracle | 45/116 | Many deltas due to dialect differences (8-bit ids, OPSYN, etc.) |
| CSNOBOL4 | 47/116 | 2 more passes than SPITBOL; engine-specific quirks differ |
| SPITBOL — FENCE tests (058–067) | 7/10 | 3 SPITBOL bugs: 061 seal, 064 capture, 065 decimal |
| CSNOBOL4 — FENCE tests (058–067) | 1/10 | 058 keyword passes; 059–067 need GOAL-CSNOBOL4-FENCE |

### Quick start

```bash
# Run csnobol4-suite against CSNOBOL4
bash adapters/csnobol4/run_crosscheck_csnobol4.sh --engine csnobol4

# Run csnobol4-suite against SPITBOL oracle
bash adapters/csnobol4/run_crosscheck_csnobol4.sh --engine spitbol

# Run FENCE tests via crosscheck
CORPUS=$HOME/corpus/crosscheck \
  bash crosscheck/crosscheck.sh --engine csnobol4 --filter pat_fence
```

### Excluded from suite (8 total)

`bench.sno` (no .ref), `breakline.sno` (large-record I/O hangs SPITBOL),
`genc.sno` (file output), `k.sno` (large-record I/O hangs SPITBOL),
`line2.sno` (no .ref), `ndbm.sno` (DBM library), `sleep.sno` / `time.sno` (time-dependent).
