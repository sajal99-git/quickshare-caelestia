# Quick Share for Caelestia (Quickshell)

Quick Share (Google Nearby Share protocol) for the Caelestia Quickshell shell, tested on **stable v2.5.0**.

Tested on CachyOS (Arch), Hyprland, Qt 6.12. Sending and receiving both work.

## What's in here

- `plugin/`: C++ QML plugin (`QSExt.QuickShare`): discovery, crypto, connection, protobuf, OpenSSL
- `shell/new/`: new QML files copied into the shell (service, device selector, delete modal, list card)
- `patches/quickshare.patch`: edits to existing Caelestia files (toggle, notification handling, utilities wrapper)
- `install.sh`: builds and installs the plugin, copies the files, applies the patch

## Requirements

`cmake`, `ninja`, `patch`, `patchelf`, Qt 6 (base + declarative), OpenSSL, protobuf, and a working Caelestia v2.5.0 shell.

## What the patch changes in your shell

- `modules/utilities/Content.qml`: the recorder card becomes page 1 of a swipeable carousel (with indicator dots) and Quick Share is page 2; adds the delete modal and device selector
- `modules/utilities/cards/Toggles.qml`: adds the near_me Quick Share toggle
- `modules/notifications/Notification.qml`, `services/Notifs.qml`, `services/NotifData.qml`: support for Quick Share accept/decline popups (`forceExpand`, kept out of `notifs.json`)
- `modules/utilities/Wrapper.qml`: persistent properties, and keeps the panel open while the file dialog is open

## Install

    git clone <this repo>
    cd <this repo>
    ./install.sh                      # default: ~/.config/quickshell/caelestia
    ./install.sh /path/to/shell/dir   # custom shell dir

The script backs up your shell dir first and aborts without changes if the patch doesn't apply cleanly.

Restart the shell afterwards: `qs kill -c caelestia; qs -c caelestia -d`, then enable the near_me toggle in the utilities panel.

## Firewall

The plugin listens on **TCP 47802** (pinned, falls back to a random port only if 47802 is busy). Discovery uses mDNS on UDP 5353. With ufw:

    sudo ufw allow from <your-lan-subnet> to any proto tcp port 47802
    sudo ufw allow 5353/udp

On the phone, set Quick Share visibility to Everyone while testing.

## After a Qt upgrade

Rebuild and reinstall the plugin: run `./install.sh` again (it backs up first).

## Rollback

Restore the `*.pre-quickshare.*` backup the installer created, and remove `/usr/lib/qt6/qml/QSExt/QuickShare`.

## Credits and license

The Quick Share QML files and shell integration come from MiDnight Shell (https://github.com/dim-ghub/midnight-shell), a fork of Caelestia (https://github.com/caelestia-dots/shell), both under GPL-3.0. This repository is also released under GPL-3.0.
