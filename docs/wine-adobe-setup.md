# Wine and Adobe DNG Converter Setup

Adobe does not provide a native Linux DNG Converter. The practical Linux route is to run the free Windows Adobe DNG Converter under Wine.

## Ubuntu Packages

```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y wine64 wine wine32:i386 xvfb curl exiftool python3 python3-venv
```

`wine32:i386` matters even on a 64-bit machine because many Wine setups still need 32-bit support libraries. `xvfb` lets the converter run headlessly from a terminal.

## Install Adobe DNG Converter

```bash
bin/setup-adobe-dng-wine
```

The script downloads Adobe's Windows installer and runs it in this Wine prefix by default:

```text
$HOME/.local/share/z9-nef-wine-fits/wineprefix
```

The Adobe installer may show a GUI once. Finish that installer. Normal conversions after that are command-line driven.

## Non-Default Prefix

```bash
ADOBE_DNG_WINEPREFIX=/some/prefix bin/setup-adobe-dng-wine
```

Use the same prefix when converting if it is not the default:

```bash
ADOBE_DNG_WINEPREFIX=/some/prefix bin/z9-nef-to-fits '/data/orig/*.NEF'
```
