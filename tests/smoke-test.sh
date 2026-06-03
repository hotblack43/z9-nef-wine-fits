#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_SAMPLE="$REPO_ROOT/examples/sample-data/iss074e0407380.NEF"
SAMPLE="${SAMPLE_NEF:-$DEFAULT_SAMPLE}"

if [ ! -s "$SAMPLE" ]; then
  cat >&2 <<EOF
No sample NEF found; skipping smoke test.

Place a test file at:
  $DEFAULT_SAMPLE

or run with:
  SAMPLE_NEF=/path/to/your/test.NEF $0
EOF
  exit 0
fi

OUT="$(dirname "$SAMPLE")/FITS_LINEAR/$(basename "${SAMPLE%.*}").fits"

"$REPO_ROOT/bin/z9-nef-to-fits" "$SAMPLE"

if [ ! -s "$OUT" ]; then
  echo "Missing FITS output: $OUT" >&2
  exit 1
fi

if command -v uv >/dev/null 2>&1; then
  uv run --project "$REPO_ROOT" python - "$OUT" <<'PY'
import sys
from astropy.io import fits
path = sys.argv[1]
with fits.open(path) as hdul:
    print(path)
    print(hdul[0].data.shape, hdul[0].data.dtype)
PY
else
  python3 - "$OUT" <<'PY'
import sys
from astropy.io import fits
path = sys.argv[1]
with fits.open(path) as hdul:
    print(path)
    print(hdul[0].data.shape, hdul[0].data.dtype)
PY
fi
