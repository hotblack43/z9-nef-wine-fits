# z9-nef-wine-fits

Convert Nikon Z9 `.NEF` files, including HE/HE* compressed files that
`rawpy`/`dcraw` cannot read directly, into linear FITS files on Linux.

Keywords: Nikon Z9, Nikon Z8, HE, HE*, High Efficiency RAW, NEF, DNG,
Wine, Linux, FITS, astronomy, photometry.

The command first tries direct raw reading. If that fails, it uses Adobe
DNG Converter through Wine to make a temporary DNG, reads that DNG, writes
FITS, and removes the intermediate DNG by default.

The normal user-facing output is intentionally quiet. Full details go to a
log file in the output directory.

## TL;DR

```bash
./bin/setup-adobe-dng-wine
./bin/z9-nef-to-fits --mode planes --greens mean '/path/with spaces/orig/*.NEF'
```

By default this writes linear FITS files to `FITS_LINEAR/` next to the input
files and removes intermediate DNG files. Use `--outdir DIR` to choose another
output directory, and `--keep-dng` only when debugging.

## What This Is / Is Not

This is not an open-source decoder for Nikon HE/HE* compression.

It is a Linux workflow bridge that uses Adobe DNG Converter under Wine when
direct `rawpy`/LibRaw decoding fails. The purpose is to recover a practical,
scriptable, photometry-oriented path from Nikon Z9/Z8 HE/HE* NEF files to
linear FITS.

## What It Produces

Default output is a 3-plane linear FITS cube written to `FITS_LINEAR/` next
to the input files.

The default mode is:

```text
--mode planes --greens mean
```

This extracts per-channel Bayer CFA planes and writes:

```text
Plane 1 = R CFA pixels
Plane 2 = mean(G1, G2) CFA pixels
Plane 3 = B CFA pixels
```

If you explicitly request:

```text
--mode planes --greens both
```

the output is a 4-plane cube:

```text
Plane 1 = R CFA pixels
Plane 2 = G1 CFA pixels
Plane 3 = G2 CFA pixels
Plane 4 = B CFA pixels
```

Other modes are:

- `--mode cfa`: one-plane raw CFA counts.
- `--mode rgb`: 3-plane linear demosaiced RGB cube from `rawpy`.

FITS headers include exposure metadata when `exiftool` is installed:
`DATE-OBS`, `ORIGFILE`, `EXPTIME`, `ISO`, `FNUMBER`, `FOCALLEN`, and
`INSTRUME`.

## Scientific Caveats

- Adobe DNG conversion is an intermediate proprietary decoding step.
- FITS output is intended to preserve linear image data as read from
  `rawpy`/DNG.
- No dark subtraction, flat-fielding, photometric calibration, gamma
  correction, auto-brightening, or cosmetic stretching is applied.
- Users doing precision photometry should validate linearity and metadata
  for their own camera body, firmware, compression mode, and exposure
  settings.

## Quick Start

Install Linux packages first. On Ubuntu:

```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y wine64 wine wine32:i386 xvfb curl exiftool python3 python3-venv
```

Clone the repository and work from one directory above the checkout:

```bash
git clone https://github.com/hotblack43/z9-nef-wine-fits.git
uv sync --project z9-nef-wine-fits
```

Or use your own Python environment and install the packages from
`pyproject.toml`.

Set up Adobe DNG Converter under Wine:

```bash
./z9-nef-wine-fits/bin/setup-adobe-dng-wine
```

The Adobe installer opens a normal Windows installer window under Wine the
first time. Accept the license agreement, continue the installation, then on
the final screen remove the check mark from "Launch Adobe DNG Converter" and
click Finish.

Normal conversions after this are command-line only.

Convert files from one directory above the checkout:

```bash
./z9-nef-wine-fits/bin/z9-nef-to-fits '/path/with spaces/orig/iss*.NEF'
```

From inside a directory containing an `orig/` folder, use the full path to
the checked-out command:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits orig/iss*.NEF
```

If your shell is currently inside the repository root, the shorter `bin/...`
form also works:

```bash
bin/z9-nef-to-fits /data/session/orig/iss0000000000.NEF
```

## Where The Output Goes

For input files like:

```text
/data/session/orig/*.NEF
```

the output will be:

```text
/data/session/orig/FITS_LINEAR/*.fits
/data/session/orig/FITS_LINEAR/z9-nef-to-fits.log
```

## Commands

Main command:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits [OPTIONS] PATH_OR_WILDCARD [FILE ...]
```

Examples:

```bash
./z9-nef-wine-fits/bin/z9-nef-to-fits '/data/session with spaces/orig/iss074e0407*.NEF'
./z9-nef-wine-fits/bin/z9-nef-to-fits /data/session/orig
```

Advanced one-file/batch command with options:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits-one INPUT [OUTPUT_DIR] [INPUT ...] \
  [--outdir DIR] [--mode cfa|planes|rgb] [--greens mean|both] [--keep-dng]
```

Modes:

- `planes`: default, linear CFA-derived cube. With the default
  `--greens mean`, this is `R, mean(G1,G2), B`.
- `cfa`: raw CFA counts as a single plane.
- `rgb`: simple linear demosaic through `rawpy`, written as `R, G, B`.

By default, temporary DNG files are deleted after each FITS file is
successfully written. Use `--keep-dng` only when debugging.

## Adobe/Wine Configuration

The setup script installs Adobe DNG Converter into this default Wine prefix:

```text
$HOME/.local/share/z9-nef-wine-fits/wineprefix
```

Runtime environment overrides:

```bash
ADOBE_DNG_WINEPREFIX=/path/to/wineprefix \
ADOBE_DNG_EXE='/path/to/Adobe DNG Converter.exe' \
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits '/data/orig/*.NEF'
```

Older variable names are also accepted for compatibility: `ADC_WINEPREFIX`,
`ADC_WIN_EXE`, and `ADC_WINE_BIN`.

## Sample Data

No Nikon HE/HE* sample NEF is included in the public repository.

To run the smoke test, place a test NEF at:

```text
examples/sample-data/iss074e0407380.NEF
```

or run the smoke test with `SAMPLE_NEF=/path/to/your/test.NEF`.

## Smoke Test

After setup, if sample data are available:

```bash
./z9-nef-wine-fits/tests/smoke-test.sh
```

The test converts `examples/sample-data/iss074e0407380.NEF` and checks that
the FITS file exists and can be opened with Astropy.

## Tested / Not Yet Tested

Tested in CI without sample data:

- `bin/z9-nef-to-fits --help` exits successfully.
- Invalid `--mode` values fail before conversion.
- Nonexistent input paths fail without requiring Wine or Adobe DNG Converter.
- `tests/smoke-test.sh` skips cleanly when no sample NEF is present.

Not yet tested in public CI:

- Real Nikon Z9/Z8 HE or HE* NEF conversion.
- Adobe DNG Converter under Wine on GitHub-hosted runners.
- Photometric linearity for a specific camera body, firmware, and exposure set.

## Notes

This tool is designed for photometric processing. It does not do black
subtraction, gamma correction, auto-brightening, or arbitrary scaling before
writing FITS.
