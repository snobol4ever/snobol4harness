#!/usr/bin/env bash
# harness/adapters/spitbol/run.sh
# Run a .sno file through SPITBOL x64 and emit program stdout only.
# Usage: run.sh <file.sno> [< input]
# Calling convention: stdin → program stdin, stdout → program output (no banner).
#
# -b suppresses sign-on banner. Program output goes to stdout.
set -euo pipefail
SNO_FILE="$1"
SPITBOL="${SPITBOL:-/home/claude/x64/bin/sbl}"
"$SPITBOL" -b "$SNO_FILE"
