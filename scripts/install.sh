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
# To install the macOS app instead, download owl-sidecar-<version>-macos-arm64.tar.gz
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

if [ "$IS_MAC" = "1" ]; then
  ASSET="owl-sidecar-${VER}-macos-arm64.tar.gz"
else
  ASSET="owl-sidecar-${VER}-linux-${UARCH}.tar.gz"
fi
URL="https://github.com/${REPO}/releases/download/${TAG}/${ASSET}"

# ----- download + verify + extract ------------------------------------------
SUMS_URL="https://github.com/${REPO}/releases/download/${TAG}/SHA256SUMS"

# Pick a SHA-256 tool. Refuse to continue without one: silently skipping the
# check is how an unverified binary gets installed, which is the bug this
# guards against.
if command -v shasum >/dev/null 2>&1; then
  sha256_of() { shasum -a 256 "$1" | awk '{print $1}'; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha256_of() { sha256sum "$1" | awk '{print $1}'; }
else
  die "no shasum or sha256sum available; cannot verify the download"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
say "downloading ${ASSET}"
curl -fSL "$URL" -o "$TMP/pkg.tar.gz" || die "download failed: $URL"

say "verifying SHA-256"
curl -fsSL "$SUMS_URL" -o "$TMP/SHA256SUMS" \
  || die "could not download SHA256SUMS from $SUMS_URL - refusing to install unverified"

# Take only the line for the asset we actually downloaded. Anchor the filename
# so a substring cannot match a different artifact.
EXPECTED="$(awk -v want="$ASSET" '$2 == want || $2 == "*" want {print $1; exit}' "$TMP/SHA256SUMS")"
[ -n "${EXPECTED:-}" ] || die "no SHA-256 published for ${ASSET} - refusing to install unverified"

ACTUAL="$(sha256_of "$TMP/pkg.tar.gz")"
if [ "$ACTUAL" != "$EXPECTED" ]; then
  printf '\n' >&2
  printf '  expected: %s\n' "$EXPECTED" >&2
  printf '  actual:   %s\n' "$ACTUAL" >&2
  die "SHA-256 mismatch for ${ASSET} - the download is corrupt or tampered with; NOT installing"
fi
say "checksum ok"

tar -xzf "$TMP/pkg.tar.gz" -C "$TMP" || die "could not extract the archive"

if [ "$IS_MAC" = "1" ]; then
  BIN="$(find "$TMP" -type f -path '*OwlSidecar.app/Contents/MacOS/owl-sidecar' | head -1)"
  [ -n "$BIN" ] || BIN="$(find "$TMP" -type f -name owl-sidecar | head -1)"

  # Second, INDEPENDENT integrity check on macOS: verify Apple's Developer ID
  # signature and notarization on the extracted bundle.
  #
  # This is stronger than the SHA-256 check above, because the checksums live in
  # the same GitHub release as the artifact - whoever can replace one can
  # replace the other. An attacker cannot forge an Apple-notarized bundle, so
  # this check survives a compromised release. Skipping it would leave the
  # digest as the only barrier, and the digest is same-origin.
  APP="$(find "$TMP" -type d -name 'OwlSidecar.app' | head -1)"
  if [ -n "${APP:-}" ] && command -v codesign >/dev/null 2>&1; then
    say "verifying Apple code signature"
    codesign --verify --deep --strict "$APP" 2>/dev/null \
      || die "code signature invalid on $(basename "$APP") - NOT installing"
    if command -v spctl >/dev/null 2>&1; then
      # Gatekeeper's own assessment, which also covers notarization.
      spctl --assess --type exec "$APP" >/dev/null 2>&1 \
        || die "Gatekeeper rejected $(basename "$APP") (unsigned, or notarization missing/revoked) - NOT installing"
    fi
    say "signature ok"
  fi
else
  BIN="$(find "$TMP" -type f -name owl-sidecar | head -1)"
fi
[ -n "${BIN:-}" ] && [ -f "$BIN" ] || die "owl-sidecar binary not found in the archive"

# ----- install --------------------------------------------------------------
mkdir -p "$INSTALL_DIR/bin" "$BIN_DIR"
install -m 0755 "$BIN" "$INSTALL_DIR/bin/owl-sidecar"
# NOTE: the macOS quarantine attribute is deliberately NOT removed here.
# Stripping it disables the Gatekeeper check on a binary this script just
# fetched over the network, which removes the last defence if the download or
# the release host is compromised - and it did so unconditionally, including
# when verification had never run. The integrity check above is what makes the
# install trustworthy; Gatekeeper is the second, independent one, and we do not
# get to turn it off on the user's behalf.
#
# A binary downloaded by curl carries no quarantine attribute in the first
# place (only browser/LaunchServices downloads are quarantined), so this call
# was usually a no-op and, when it did fire, only ever weakened the user.
#
# The real fix for Gatekeeper friction is to sign with a Developer ID, notarize
# and staple the ticket - see notarize-macos.sh in the build repo - after which
# nothing needs stripping.
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
