#!/usr/bin/env sh
# =============================================================================
# Owl Sidecar installer
#   curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-sidecar/main/scripts/install.sh | sh
# =============================================================================
# Downloads the latest Owl Sidecar release for your platform from GitHub
# Releases, installs the binary to ~/.owl-sidecar/bin, and adds a shim to
# ~/.local/bin/owl-sidecar. Works on macOS (Apple Silicon) and Linux (x64,
# arm64). On macOS it also clears the quarantine flag.
#
# To install the macOS app instead, download owl-sidecar-macos-arm64.tar.gz
# from the releases page and move OwlSidecar.app to /Applications. The app is
# notarized and needs no extra steps. On Windows, download the zip and run
# owl-sidecar.exe.
# =============================================================================
set -eu

REPO="${OWL_SIDECAR_REPO:-Olib-AI/owl-sidecar}"
INSTALL_DIR="${OWL_SIDECAR_HOME:-$HOME/.owl-sidecar}"
BIN_DIR="${OWL_SIDECAR_BIN_DIR:-$HOME/.local/bin}"
VERSION="${OWL_SIDECAR_VERSION:-latest}"

if [ -t 1 ]; then
  G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; N='\033[0m'
else
  G=''; R=''; Y=''; N=''
fi
say()  { printf "${G}==>${N} %s\n" "$1"; }
warn() { printf "${Y}!! ${N} %s\n" "$1"; }
die()  { printf "${R}xx ${N} %s\n" "$1" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }
need curl; need tar; need uname

# ----- platform -------------------------------------------------------------
os="$(uname -s)"
cpu="$(uname -m)"
case "$os" in
  Darwin)
    [ "$cpu" = "arm64" ] || [ "$cpu" = "aarch64" ] || die "macOS build is Apple Silicon only (your CPU is $cpu)"
    ASSET="owl-sidecar-macos-arm64.tar.gz"
    IS_MAC=1
    ;;
  Linux)
    case "$cpu" in
      x86_64|amd64) UARCH="x86_64" ;;
      aarch64|arm64) UARCH="aarch64" ;;
      *) die "unsupported Linux CPU: $cpu" ;;
    esac
    IS_MAC=0
    ;;
  *)
    die "unsupported OS: $os. On Windows, download the zip from the releases page."
    ;;
esac

# ----- resolve version ------------------------------------------------------
if [ "$VERSION" = "latest" ]; then
  say "resolving latest release"
  TAG="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
          | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -1)"
  [ -n "${TAG:-}" ] || die "could not resolve the latest tag from the GitHub API"
else
  TAG="$VERSION"
fi
VER="${TAG#v}"
say "installing ${TAG}"

if [ "$IS_MAC" = "0" ]; then
  ASSET="owl-sidecar-${VER}-${UARCH}.tar.gz"
fi
URL="https://github.com/${REPO}/releases/download/${TAG}/${ASSET}"

# ----- download + extract ---------------------------------------------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
say "downloading ${ASSET}"
curl -fSL "$URL" -o "$TMP/pkg.tar.gz" || die "download failed: $URL"
tar -xzf "$TMP/pkg.tar.gz" -C "$TMP" || die "could not extract the archive"

if [ "$IS_MAC" = "1" ]; then
  BIN="$(find "$TMP" -type f -path '*OwlSidecar.app/Contents/MacOS/owl-sidecar' | head -1)"
  [ -n "$BIN" ] || BIN="$(find "$TMP" -type f -name owl-sidecar | head -1)"
else
  BIN="$(find "$TMP" -type f -name owl-sidecar | head -1)"
fi
[ -n "${BIN:-}" ] && [ -f "$BIN" ] || die "owl-sidecar binary not found in the archive"

# ----- install --------------------------------------------------------------
mkdir -p "$INSTALL_DIR/bin" "$BIN_DIR"
install -m 0755 "$BIN" "$INSTALL_DIR/bin/owl-sidecar"
if [ "$IS_MAC" = "1" ]; then
  xattr -d com.apple.quarantine "$INSTALL_DIR/bin/owl-sidecar" 2>/dev/null || true
fi
ln -sf "$INSTALL_DIR/bin/owl-sidecar" "$BIN_DIR/owl-sidecar"

say "installed to $INSTALL_DIR/bin/owl-sidecar"
say "shim at $BIN_DIR/owl-sidecar"

case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *)
    warn "$BIN_DIR is not on your PATH. Add this to your shell profile:"
    printf '\n    export PATH="%s:$PATH"\n\n' "$BIN_DIR"
    ;;
esac

echo ""
say "done. next steps:"
echo "    owl-sidecar --version"
echo "    owl-sidecar pair YOURCODE      # code from the Owl portal, Proxy Devices"
echo "    owl-sidecar status"
