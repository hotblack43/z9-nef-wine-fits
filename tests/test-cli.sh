#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

assert_success() {
  local name="$1"; shift
  if "$@" >"$TMP_DIR/${name}.out" 2>"$TMP_DIR/${name}.err"; then
    return 0
  fi
  cat "$TMP_DIR/${name}.out" >&2 || true
  cat "$TMP_DIR/${name}.err" >&2 || true
  fail "$name should have succeeded"
}

assert_failure() {
  local name="$1"; shift
  if "$@" >"$TMP_DIR/${name}.out" 2>"$TMP_DIR/${name}.err"; then
    cat "$TMP_DIR/${name}.out" >&2 || true
    cat "$TMP_DIR/${name}.err" >&2 || true
    fail "$name should have failed"
  fi
}

assert_success help "$REPO_ROOT/bin/z9-nef-to-fits" --help
grep -q 'Usage:' "$TMP_DIR/help.err" || fail "help output should include Usage"
grep -q -- '--outdir DIR' "$TMP_DIR/help.err" || fail "help output should mention --outdir"

assert_failure invalid_mode "$REPO_ROOT/bin/z9-nef-to-fits" --mode bogus "$TMP_DIR/missing.NEF"
grep -q -- '--mode must be cfa|planes|rgb' "$TMP_DIR/invalid_mode.err" || fail "invalid mode error was not reported"

assert_failure nonexistent_input "$REPO_ROOT/bin/z9-nef-to-fits" "$TMP_DIR/does not exist.NEF"
grep -q 'No NEF/DNG files matched' "$TMP_DIR/nonexistent_input.err" || fail "nonexistent input error was not reported"

if ! SAMPLE_NEF="$TMP_DIR/no sample here.NEF" "$REPO_ROOT/tests/smoke-test.sh" >"$TMP_DIR/smoke_skip.out" 2>"$TMP_DIR/smoke_skip.err"; then
  cat "$TMP_DIR/smoke_skip.out" >&2 || true
  cat "$TMP_DIR/smoke_skip.err" >&2 || true
  fail "smoke_skip should have succeeded"
fi
grep -q 'No sample NEF found; skipping smoke test.' "$TMP_DIR/smoke_skip.err" || fail "smoke test did not report a clean skip"

echo "CLI tests passed"
