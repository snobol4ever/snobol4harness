#!/usr/bin/env bash
# harness/adapters/csnobol4/run.sh
# Run a .sno file through CSNOBOL4 and emit program stdout only.
# Usage: run.sh <file.sno> [< input]
# Calling convention: stdin → program stdin, stdout → program output (no banner).
#
# CSNOBOL4 flags: -f folds identifiers to uppercase (required); -P256k pattern stack.
# snobol4 emits program output to stdout; no banner suppression flag needed.
set -euo pipefail
SNO_FILE="$1"
snobol4 -f -P256k "$SNO_FILE"
