# Troubleshooting

## `wine: could not load kernel32.dll`

Install 32-bit Wine support and rerun setup:

```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y wine64 wine wine32:i386
```

## No FITS Files Are Produced

Check the log in the output directory:

```bash
cat /path/to/orig/FITS_LINEAR/z9-nef-to-fits.log
```

Then verify that Adobe DNG Converter exists inside the Wine prefix:

```bash
find "$HOME/.local/share/z9-nef-wine-fits/wineprefix" -iname 'Adobe DNG Converter.exe'
```

## Paths With Spaces

Quote wildcard patterns when passing one pattern:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits '/data/session with spaces/orig/iss*.NEF'
```

Unquoted shell-expanded wildcards also work when the shell expands them to files:

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits orig/iss*.NEF
```

## Keeping DNGs Temporarily

```bash
/path/to/z9-nef-wine-fits/bin/z9-nef-to-fits-one '/data/orig/*.NEF' --keep-dng
```

DNGs are otherwise deleted after successful FITS creation.
