# Installation

Owl Sidecar runs on macOS (Apple Silicon), Windows (x64), and Linux (x64 and
arm64). Install it on the device whose connection you want Owl Browser to use.

After installing, follow the [pairing guide](pairing.md) to connect the device
to your account.

## macOS

1. Download `owl-sidecar-0.1.0-macos-arm64.tar.gz` from the [latest release](https://github.com/Olib-AI/owl-sidecar/releases/latest).
2. Double-click the tarball to extract `OwlSidecar.app`.
3. Move `OwlSidecar.app` to your Applications folder.
4. Open it.

The app is signed with the Olib AI Apple Developer ID and notarized by Apple. It
opens without a right-click override and without a quarantine warning.

## Windows

### Installer (recommended)

1. Download `owl-sidecar-0.1.0-windows-x64-setup.exe` from the [latest release](https://github.com/Olib-AI/owl-sidecar/releases/latest).
2. Run it. The installer places Owl Sidecar under your user profile, adds a
   Start-menu shortcut (and an optional desktop shortcut), and can enable
   "Start at login" so the exit node comes back after a reboot.
3. Launch it from the Start menu. It runs in the system tray with no console window.

The installer is not yet code-signed, so SmartScreen may warn on first run —
choose "More info" then "Run anyway". Uninstall any time from Settings > Apps.

### Portable zip

1. Download `owl-sidecar-0.1.0-windows-x64.zip`.
2. Extract the zip.
3. Run `owl-sidecar.exe`.

You can keep it running in the background from the system tray, and you can turn
on "Start at login" from the app so it comes back after a reboot.

## Linux

### Debian and Ubuntu

Download the package for your architecture and install it:

```sh
sudo dpkg -i owl-sidecar-0.1.0-linux-amd64.deb    # Intel and AMD
sudo dpkg -i owl-sidecar-0.1.0-linux-arm64.deb    # ARM
```

If dpkg reports missing dependencies, pull them in with:

```sh
sudo apt-get install -f
```

The package installs the `owl-sidecar` binary, a desktop entry, and a systemd
user service you can enable for a headless exit node:

```sh
systemctl --user enable --now owl-sidecar
```

### Install script

For other distributions, or if you prefer the command line, use the script. It
detects your platform, downloads the matching release, and installs the binary
to `~/.owl-sidecar/bin` with a `owl-sidecar` shim in `~/.local/bin`.

```sh
curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-sidecar/main/scripts/install.sh | sh
```

If `~/.local/bin` is not on your `PATH`, the script prints the line to add to
your shell profile. The same script works on macOS if you want the CLI rather
than the app.

### Tarball

1. Download `owl-sidecar-0.1.0-linux-x86_64.tar.gz` (or `-linux-aarch64` on ARM).
2. Extract it: `tar -xzf owl-sidecar-0.1.0-linux-x86_64.tar.gz`
3. Move the binary somewhere on your `PATH`, for example `~/.local/bin/`.

The Linux build is a command-line binary with no desktop GUI, built for
servers. It depends only on `libc6` and runs on a bare machine with no display.
Pair it once and run it with `owl-sidecar run --headless`, or enable the systemd
user service above. The desktop app with the tray and window ships on macOS and
Windows.

## Verify it runs

```sh
owl-sidecar --version
owl-sidecar status
```

`status` shows whether the device is paired and online. If it is not paired yet,
head to the [pairing guide](pairing.md).
