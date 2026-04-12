#!/usr/bin/env bash
# crosscheck.sh — run corpus crosscheck against one or more engines
#
# Usage: crosscheck.sh [--engine ENGINE[,ENGINE...]] [--filter PATTERN] [--corpus DIR]
#
# Engines: csnobol4, dotnet, spitbol  (default: all available)
# Each engine adapter lives in adapters/<engine>/run.sh
# Calling convention: run.sh <file.sno> [< input]  →  stdout = program output
#
# Exit: 0 if all pass for all engines, 1 if any fail.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CORPUS="${CORPUS:-$HOME/corpus}"
FILTER=""
ENGINES=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --engine)   ENGINES="$2"; shift 2 ;;
        --filter)   FILTER="$2";  shift 2 ;;
        --corpus)   CORPUS="$2";  shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Default: all adapters that have a run.sh
if [[ -z "$ENGINES" ]]; then
    ENGINES=$(ls "$HARNESS_ROOT/adapters/" 2>/dev/null | tr '\n' ',')
    ENGINES="${ENGINES%,}"
fi

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; RESET='\033[0m'

TOTAL_PASS=0; TOTAL_FAIL=0

DIRS=(crosscheck/hello crosscheck/output crosscheck/assign crosscheck/concat crosscheck/arith_new crosscheck/control_new crosscheck/patterns crosscheck/capture crosscheck/strings crosscheck/functions crosscheck/data crosscheck/keywords
      crosscheck/rung2 crosscheck/rung3 crosscheck/rung4 crosscheck/rung8 crosscheck/rung9 crosscheck/rung10 crosscheck/rung11
      programs/csnobol4-suite)

run_engine() {
    local engine="$1"
    local adapter="$HARNESS_ROOT/adapters/$engine/run.sh"

    if [[ ! -x "$adapter" ]]; then
        echo -e "${YELLOW}SKIP engine $engine${RESET} — $adapter not executable"
        return
    fi

    echo -e "${CYAN}=== Engine: $engine ===${RESET}"
    local pass=0 fail=0 skip=0

    for dir in "${DIRS[@]}"; do
        local full="$CORPUS/$dir"
        [[ -d "$full" ]] || continue
        echo "── $dir ──"
        for sno in "$full"/*.sno; do
            [[ -f "$sno" ]] || continue
            local ref="${sno%.sno}.ref"
            local input="${sno%.sno}.input"
            local name
            name=$(basename "$sno" .sno)

            [[ -n "$FILTER" && "$name" != *"$FILTER"* ]] && { skip=$((skip+1)); continue; }
            [[ ! -f "$ref" ]] && { echo -e "${YELLOW}SKIP${RESET} $name (no .ref)"; skip=$((skip+1)); continue; }

            local got
            if [[ -f "$input" ]]; then
                got=$(timeout 10 "$adapter" "$sno" < "$input" 2>/dev/null || true)
            else
                got=$(timeout 10 "$adapter" "$sno" 2>/dev/null || true)
            fi

            local exp
            exp=$(cat "$ref")

            if [[ "$got" == "$exp" ]]; then
                echo -e "${GREEN}PASS${RESET} $name"
                pass=$((pass+1))
            else
                echo -e "${RED}FAIL${RESET} $name"
                diff <(echo "$exp") <(echo "$got") | head -6 | sed 's/^/      /' || true
                fail=$((fail+1))
            fi
        done
        echo ""
    done

    echo -e "${CYAN}$engine: ${GREEN}$pass passed${RESET}, ${RED}$fail failed${RESET}, ${YELLOW}$skip skipped${RESET}"
    echo ""
    TOTAL_PASS=$((TOTAL_PASS+pass))
    TOTAL_FAIL=$((TOTAL_FAIL+fail))
}

IFS=',' read -ra ENGINE_LIST <<< "$ENGINES"
for engine in "${ENGINE_LIST[@]}"; do
    [[ -n "$engine" ]] && run_engine "$engine"
done

echo "============================================"
echo -e "TOTAL: ${GREEN}$TOTAL_PASS passed${RESET}, ${RED}$TOTAL_FAIL failed${RESET}"
[[ $TOTAL_FAIL -eq 0 ]] && exit 0
exit 1
