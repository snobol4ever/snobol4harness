#!/usr/bin/env bash
# snobol4harness/adapters/dotnet/run.sh
# Run a .sno file through DOTNET and emit stdout.
# Usage: run.sh <file.sno> [< input]
# Follows the harness calling convention: stdin→program stdin, stdout→program output.
set -e
SNO_FILE="$1"
DOTNET_REPO="${DOTNET_REPO:-$HOME/snobol4dotnet}"
export PATH="$PATH:$HOME/.dotnet"
exec dotnet run --project "$DOTNET_REPO/Snobol4/Snobol4.csproj" -c Release -- "$SNO_FILE"
