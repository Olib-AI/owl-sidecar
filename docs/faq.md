# FAQ

## Does my traffic go through Olib servers?

No. Traffic runs directly between the browser and the paired device. Olib runs a
small coordination service that helps the two sides find each other at the start
of a session, and then it is out of the path. It does not carry or see your
traffic.

## Can a site tell the browser is using a proxy?

The sidecar opens an ordinary outbound connection to each target and forwards
raw bytes. The browser keeps its own TLS handshake all the way to the site, so
the connection carries the browser's fingerprint and the device's residential
address. Nothing on the wire marks it as proxied. There is no added header and
no rewrite.

## Do I need to open a port or set up port forwarding?

No. The sidecar connects outbound only, so it works from a home network behind
NAT with nothing forwarded.

## Which platforms are supported?

macOS on Apple Silicon, Windows on x64, and Linux on x64 and arm64. The macOS
build is signed and notarized. The others are provided as a signed installer or
archive per platform.

## Can other people use my device as an exit?

No. A device is usable only by browsers signed in to the same account that
paired it. A session for one account cannot reach a device owned by another.

## Is the connection encrypted?

Yes. The tunnel between the browser and the device is mutually authenticated and
encrypted. The browser also keeps its own end to end TLS with each site.

## What happens if the network drops?

The app reconnects on its own and shows a reconnecting state while it does. Your
enrollment and key are kept, so you do not need to pair again.

## How do I stop it temporarily?

Pause it from the app or run `owl-sidecar pause`. The device stays paired and you
can resume at any time.

## Where is my device data stored?

The device key and enrollment live in a local config directory
(`~/.owl-sidecar` on macOS and Linux). The private key never leaves the device.

## How do I remove it?

Unpair from the app or run `owl-sidecar unpair`, then delete the app or the
package. On Debian and Ubuntu: `sudo dpkg -r owl-sidecar`.

## I have another question

Open a [GitHub issue](https://github.com/Olib-AI/owl-sidecar/issues) or email
support@olib.ai.
