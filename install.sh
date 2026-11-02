#!/usr/bin/env bash
# Quick Share for Caelestia (stable v2.5.0): builds the QML plugin, installs it,
# copies the new QML files into the shell and applies the patch.
# Usage: ./install.sh [path-to-caelestia-shell-dir]
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SHELL_DIR="${1:-$HOME/.config/quickshell/caelestia}"
QML_DEST="/usr/lib/qt6/qml/QSExt/QuickShare"
BUILD_OUT="$REPO/plugin/build/qml/QSExt/QuickShare"
PORT=47802

die() { echo "error: $*" >&2; exit 1; }

[ -d "$SHELL_DIR" ] || die "shell dir not found: $SHELL_DIR"
[ -f "$SHELL_DIR/shell.qml" ] || die "$SHELL_DIR/shell.qml missing, is this a Caelestia shell dir?"
for c in cmake ninja patch patchelf sudo; do
  command -v "$c" >/dev/null || die "missing tool: $c (Arch: sudo pacman -S cmake ninja patch patchelf)"
done

echo "==> Building plugin"
cmake -S "$REPO/plugin" -B "$REPO/plugin/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$REPO/plugin/build"
[ -f "$BUILD_OUT/libqsquickshareplugin.so" ] || die "build output not found in $BUILD_OUT"

echo "==> Installing plugin to $QML_DEST (needs sudo)"
sudo install -d "$QML_DEST"
sudo cp -a "$BUILD_OUT/." "$QML_DEST/"
# The plugin links against libqsquickshare.so, which lives in the build root.
# Install it next to the plugin and make the plugin look there, so it keeps
# working even if the build dir is deleted.
[ -f "$REPO/plugin/build/libqsquickshare.so" ] || die "libqsquickshare.so not found in $REPO/plugin/build"
sudo cp -a "$REPO/plugin/build/libqsquickshare.so" "$QML_DEST/"
sudo patchelf --set-rpath '$ORIGIN' "$QML_DEST/libqsquickshareplugin.so"

echo "==> Backing up shell dir"
BACKUP="$SHELL_DIR.pre-quickshare.$(date +%Y%m%d-%H%M%S)"
cp -a "$SHELL_DIR" "$BACKUP"
echo "    backup: $BACKUP"

echo "==> Checking patch applies cleanly"
if ! (cd "$SHELL_DIR" && patch -p1 --dry-run < "$REPO/patches/quickshare.patch" >/dev/null); then
  die "patch does not apply. This repo targets Caelestia v2.5.0; your shell differs. Nothing was changed (backup kept)."
fi

echo "==> Copying new QML files and applying patch"
cp -a "$REPO/shell/new/." "$SHELL_DIR/"
(cd "$SHELL_DIR" && patch -p1 < "$REPO/patches/quickshare.patch")

echo
echo "Done. Restart your shell (qs kill -c caelestia; qs -c caelestia -d)."
echo "Then turn on the near_me toggle in the utilities panel."
echo
echo "Firewall: the plugin listens on TCP $PORT. If you use ufw, run (replace the subnet):"
echo "  sudo ufw allow from 192.168.1.0/24 to any proto tcp port $PORT"
echo "Rollback: restore $BACKUP"
