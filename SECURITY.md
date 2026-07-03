# Security policy

## Reporting a vulnerability

Email **security@olib.ai** with:

- A short description of the issue
- Steps to reproduce
- Your platform and the Owl Sidecar version
- Whether the issue affects the app, the command-line tool, or the pairing and connection flow

We acknowledge reports within 2 business days and aim to ship a fix within 14
days for confirmed high-severity issues.

Please do not file a public GitHub issue for security reports.

## Scope

In scope:

- Any path that lets a device or session reach a proxy it is not authorized to use
- Weaknesses in pairing, session tokens, or the mutual authentication of the tunnel
- Privilege or sandbox issues in the signed binaries
- Tampering with the update or download path

Out of scope:

- Behavior of the sites and services you route traffic to
- Rate limits or account policy enforced by the Owl portal

## Design notes

Traffic runs directly between the browser and the paired device over a mutually
authenticated tunnel. The coordination service helps the two sides find each
other and does not carry or see your traffic. Pairing binds a device to a single
account, and a session cannot reach a device owned by another account.

## Credit

We do not run a paid bounty program, but we will credit researchers (with
permission) in the release notes for the version that contains the fix.
