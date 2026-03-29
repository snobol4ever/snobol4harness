#!/usr/bin/env bash
# harness/adapters/dotnet/bench.sh
# Run BenchmarkSuite2 and emit the results table to stdout.
# Usage: bench.sh
set -e
DOTNET_REPO="${DOTNET_REPO:-$HOME/snobol4dotnet}"
export PATH="$PATH:$HOME/.dotnet"
exec dotnet run --project "$DOTNET_REPO/BenchmarkSuite2/BenchmarkSuite2.csproj" -c Release
