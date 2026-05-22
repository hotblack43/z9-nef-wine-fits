#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$REPO_ROOT/bin/z9-nef-to-fits" "$REPO_ROOT/examples/sample-data/iss074e0407380.NEF"
