#!/bin/bash
#
# Builds Ice and installs it, signed.
#
# Replaces the project's "Copy to Applications" build phase, which cannot work:
# Xcode signs a target *after* its script phases run, so that phase always copies
# an unsigned bundle. macOS then refuses to launch it — "Launchd job spawn
# failed" — and the freshly built app appears simply broken.
#
# Installs to ~/Applications by default, which needs no administrator rights.
# Set DEST=/Applications to install system-wide; that path needs a password.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${DEST:-$HOME/Applications}"
DERIVED="${DERIVED:-/tmp/ice-build}"

echo "==> Building"
# The hardened runtime is turned off on purpose. Without an Apple developer team Xcode signs the
# app ad hoc, and the hardened runtime then refuses to load Sparkle, which carries a team of its
# own: "mapping process and mapped file (non-platform) have different Team IDs". `codesign
# --verify --deep --strict` passes all the same, so the script used to install a bundle that
# could not launch for anyone without a team (reported on jordanbaird/Ice#1006 by @Theralley).
# A copy installed from here is run by its builder, not distributed, so it loses nothing by it.
xcodebuild -project "$ROOT/Ice.xcodeproj" -scheme Ice -configuration Release \
    -destination 'platform=macOS' -derivedDataPath "$DERIVED" build \
    ENABLE_HARDENED_RUNTIME=NO \
    | tail -3

APP="$DERIVED/Build/Products/Release/Ice.app"
[ -d "$APP" ] || { echo "error: no product at $APP" >&2; exit 1; }

echo "==> Verifying the signature before installing"
# The whole point: never install something that will not launch.
codesign --verify --deep --strict "$APP"
codesign -dv "$APP" 2>&1 | grep -E 'Identifier=|TeamIdentifier=' | sed 's/^/    /'

echo "==> Installing to $DEST"
if pgrep -x Ice >/dev/null 2>&1; then
    osascript -e 'quit app "Ice"' >/dev/null 2>&1 || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -x Ice >/dev/null 2>&1 || break
        sleep 0.3
    done
    pgrep -x Ice >/dev/null 2>&1 && pkill -x Ice || true
fi

mkdir -p "$DEST"
rm -rf "${DEST:?}/Ice.app"
# ditto, not cp: it preserves the code signature.
ditto "$APP" "$DEST/Ice.app"

echo "==> Verifying the installed copy"
codesign --verify --deep --strict "$DEST/Ice.app"

open -a "$DEST/Ice.app"
echo "==> Running from $DEST/Ice.app"
