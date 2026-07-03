<div align="center">
  <img src="web/assets/logo.png" alt="Owl Sidecar" width="120" height="120"/>

  # Owl Sidecar

  **Turn a device you own into a private residential exit for Owl Browser.**

  Install it on a home or office machine, pair it to your Owl account with a code, and your browser can route traffic out through that device. Your traffic goes straight from the browser to the sidecar. It never passes through Olib servers.

  [![Latest release](https://img.shields.io/github/v/release/Olib-AI/owl-sidecar?label=download&style=flat-square&color=4e9179)](https://github.com/Olib-AI/owl-sidecar/releases/latest)
  [![Platform](https://img.shields.io/badge/platform-macOS%20%C2%B7%20Windows%20%C2%B7%20Linux-4e9179?style=flat-square)](https://github.com/Olib-AI/owl-sidecar/releases)
  [![Notarized](https://img.shields.io/badge/Apple-notarized-4e9179?style=flat-square)](docs/installation.md)
  [![License](https://img.shields.io/badge/license-proprietary-6B7785?style=flat-square)](LICENSE)

  [Download](https://github.com/Olib-AI/owl-sidecar/releases/latest) · [Install](#install) · [Pairing](docs/pairing.md) · [Docs](docs/) · [olib.ai](https://www.olib.ai)
</div>

---

## What is Owl Sidecar?

Owl Sidecar is the exit side of the Owl proxy tunnel. You run it on a device with the connection you want to use, and Owl Browser sends traffic through it.

A residential connection looks like an ordinary home user, so sites treat it as one. The sidecar opens a normal outbound connection to each target and forwards raw bytes, so the browser keeps its own TLS handshake end to end. There is no extra header, no rewrite, and nothing on the wire that marks the traffic as proxied.

Once paired, the app runs quietly in the menu bar or system tray. It shows whether it is online, how many connections are active, and how much has been transferred. You can pause it at any time without unpairing.

## How the connection works

- **Peer to peer.** The browser and the sidecar connect directly and carry your traffic between them. Olib runs a small coordination service that helps the two sides find each other, and then it steps out of the path. It never carries your data.
- **No open ports.** The sidecar makes an outbound connection only, so it works from a home network behind NAT with nothing forwarded.
- **Paired to your account.** A device is usable only by browsers signed in to the same account. Pairing uses a short code from the portal and a key that is generated on the device and never leaves it.
- **You stay in control.** Enable, disable, and configure a device from the portal. Pause or unpair from the app.

## Install

Owl Sidecar ships for macOS (Apple Silicon), Windows (x64), and Linux (x64 and arm64). Pick your platform below, then follow the [pairing guide](docs/pairing.md) to connect it to your account.

### macOS

1. Download `owl-sidecar-macos-arm64.tar.gz` from the [latest release](https://github.com/Olib-AI/owl-sidecar/releases/latest).
2. Extract it and move `OwlSidecar.app` to your Applications folder.
3. Open it. The app is signed with the Olib AI Apple Developer ID and notarized by Apple, so it opens without a Gatekeeper override.

### Windows

1. Download `owl-sidecar-0.1.0-x64.zip` from the [latest release](https://github.com/Olib-AI/owl-sidecar/releases/latest).
2. Extract it and run `owl-sidecar.exe`.

### Linux

The Linux build is a command-line binary for servers, with no desktop GUI and
`libc6` as its only dependency. Pair it once and run it headless.

Debian and Ubuntu based systems can install the package:

```sh
sudo dpkg -i owl-sidecar_0.1.0_amd64.deb   # or _arm64.deb on ARM
```

For other distributions, use the tarball or the install script:

```sh
curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-sidecar/main/scripts/install.sh | sh
```

The script detects your platform, downloads the matching release, and installs the binary to `~/.owl-sidecar/bin` with a shim on your `PATH`. It also works on macOS if you prefer the command line to the app.

## Pairing

You need an Owl account with the proxy feature enabled. From the portal, open **Proxy Devices**, add a device, and copy the code it shows. Enter that code in the app and it registers itself and comes online. Full steps are in the [pairing guide](docs/pairing.md).

## Documentation

- [Installation](docs/installation.md)
- [Pairing and daily use](docs/pairing.md)
- [FAQ](docs/faq.md)

## Support

- Questions and issues: [GitHub issues](https://github.com/Olib-AI/owl-sidecar/issues)
- Security reports: see [SECURITY.md](SECURITY.md)
- Contact: support@olib.ai

Owl Sidecar is part of Owl Browser by [Olib AI](https://www.olib.ai).
