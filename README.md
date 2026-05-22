# z9-nef-wine-fits

Convert Nikon Z9 `.NEF` files, including HE/HE* compressed files that `rawpy`/`dcraw` cannot read directly, into linear FITS files on Linux.

The command first tries direct raw reading. If that fails, it silently uses Adobe DNG Converter through Wine to make a temporary DNG, reads that DNG, writes FITS, and removes the intermediate DNG by default. The normal user-facing output is intentionally quiet. Full details go to a log file in the output directory.

## What It Produces

Default output is a 3-plane linear FITS cube written to `FITS_LINEAR/` next to the input files. The default mode extracts per-channel Bayer planes and averages the two green planes into a single G plane for a cube ordered as R, G, B.

FITS headers include exposure metadata when `exiftool` is installed: `DATE-OBS`, `ORIGFILE`, `EXPTIME`, `ISO`, `FNUMBER`, `FOCALLEN`, and `INSTRUME`.

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

Or use your own Python environment and install the packages from `pyproject.toml`.

Set up Adobe DNG Converter under Wine:

```bash
./z9-nef-wine-fits/bin/setup-adobe-dng-wine
```

The Adobe installer opens a normal Windows installer window under Wine the first time. Accept the license agreement, continue the installation, then on the final screen remove the check mark from "Launch Adobe DNG Converter" and click Finish. Normal conversions after this are command-line only.

Convert files from one directory above the checkout:

```bash
./z9-nef-wine-fits/bin/z9-nef-to-fits '/path/with spaces/orig/iss*.NEF'
```

From inside a directory containing an `orig/` folder, use the full path to the checked-out command:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits orig/iss*.NEF
```

If your shell is currently inside the repository root, the shorter `bin/...` form also works:

```bash
bin/z9-nef-to-fits examples/sample-data/iss074e0407380.NEF
```

The output will be:

```text
orig/FITS_LINEAR/*.fits
orig/FITS_LINEAR/z9-nef-to-fits.log
```

## Commands

Main command:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits PATH_OR_WILDCARD [FILE ...]
```

Examples:

```bash
./z9-nef-wine-fits/bin/z9-nef-to-fits './z9-nef-wine-fits/examples/sample-data/iss074e0407380.NEF'
./z9-nef-wine-fits/bin/z9-nef-to-fits '/data/session with spaces/orig/iss074e0407*.NEF'
./z9-nef-wine-fits/bin/z9-nef-to-fits /data/session/orig
```

Advanced one-file/batch command with options:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits-one INPUT [OUTPUT_DIR] [INPUT ...] [--outdir DIR] [--mode cfa|planes|rgb] [--greens mean|both] [--keep-dng]
```

Modes:

- `planes`: default, linear R/G/B cube derived from CFA planes.
- `cfa`: raw CFA counts as a single plane.
- `rgb`: simple linear demosaic through `rawpy`.

By default, temporary DNG files are deleted after each FITS file is successfully written. Use `--keep-dng` only when debugging.

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

Older variable names are also accepted for compatibility: `ADC_WINEPREFIX`, `ADC_WIN_EXE`, and `ADC_WINE_BIN`.

## Sample Data

A single trial NEF is included under `examples/sample-data/` for local smoke testing. Before publishing a public repository, verify that the sample image's license permits redistribution, or replace it with a clearly redistributable test file.

## Smoke Test

After setup:

```bash
./z9-nef-wine-fits/tests/smoke-test.sh
```

The test converts `examples/sample-data/iss074e0407380.NEF` and checks that the FITS file exists and can be opened with Astropy.

## Notes

This tool is designed for photometric processing. It does not do black subtraction, gamma correction, auto-brightening, or arbitrary scaling before writing FITS.
