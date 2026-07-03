# Pairing and daily use

Pairing links a device to your Owl account so your browser can route traffic
through it. You do it once per device.

## Before you start

You need an Owl account with the proxy feature enabled. If you are not sure
whether it is on, contact support@olib.ai.

## Get a pairing code

1. Sign in to the Owl portal.
2. Open **Proxy Devices**.
3. Choose **Add device**. The portal shows a short code that is valid for a few
   minutes and can be used once.

## Pair the device

### With the app

1. Open Owl Sidecar on the device.
2. Enter the pairing code and choose **Connect**.

The app generates a key on the device, registers with your account, and comes
online. The key never leaves the device. Once paired, the app shows the proxy
id, the online state, active connections, and transferred bytes.

### From the command line

```sh
owl-sidecar pair YOURCODE
```

Run `owl-sidecar status` afterward to confirm it is online.

## Use it from Owl Browser

Each paired device has a proxy id, shown in the app and in the portal. Point a
browser context at that id and it routes traffic through the device. See the Owl
Browser proxy documentation for the exact call for your setup.

The device shows the connection as active while traffic flows, along with a
running total of bytes.

## Pause, resume, and unpair

- **Pause** stops serving traffic but keeps the device paired. Resume when you
  want it back. From the command line: `owl-sidecar pause` and `owl-sidecar resume`.
- **Unpair** removes the enrollment and wipes the device key. Do this if you are
  moving the device off your account. From the command line: `owl-sidecar unpair`.
- You can also disable a device from the portal, which stops new sessions from
  reaching it.

## Start at login

Turn on **Start at login** in the app to keep the exit running across reboots.
On Linux you can instead enable the systemd user service:

```sh
systemctl --user enable --now owl-sidecar
```

Run only one instance per device. If the app and a background service both run
with the same identity, they compete for the same connection.

## Close to the tray

Closing the window keeps the node running in the menu bar or system tray. Use
**Quit** from the tray menu to stop it.
