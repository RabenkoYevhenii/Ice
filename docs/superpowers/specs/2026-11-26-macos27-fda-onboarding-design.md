# macOS 27: Full Disk Access for native hiding — design (short)

Date: 2026-11-26 · Branch: `fix/macos27-fda-onboarding` (off PR #995 head `889f1ea`)

## Why

The native backend (`nativeAllowList`, the default) reads and writes MenuBarAgent's
`trackedApplications` in the `group.com.apple.controlcenter` group container. macOS only allows that
with **Full Disk Access** (measured 2026-11-26: tccd checks `kTCCServiceSystemPolicyAllFiles`, then
`kTCCServiceSystemPolicyAppDataDetailed` with "user interaction not allowed"; cfprefsd rejects the
read). Without FDA, `Concealer27.performSetup` logs one line and silently runs **assessment mode**
for the rest of the process: Settings still says "native", the onboarding never mentions FDA, and
every click on the clock, Wi-Fi or battery flashes the hidden items (assessment mode's click lift).
A user who granted every permission Ice asked for ends up here.

A narrower permission was tested and does not work: a foreground, user-initiated read of the
container (spike 3) was denied with no consent dialog. FDA is what PR #995's author relies on too.

## What changes

1. **`FullDiskAccessPermission`** (macOS 27 only, optional like Screen Recording): its check is the
   real read the native backend needs (`NativeAllowListConcealer27.isAvailable`), so "granted" means
   "native hiding works". Its button opens Privacy & Security › Full Disk Access
   (`x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles`). It appears in the
   onboarding window and in Settings › Advanced › Permissions through `allPermissions`.
2. **No silent fallback:** when native is selected but not in force, the Hiding method annotation
   says so, explains the cost, and offers a button to the FDA pane.
3. **Live re-check:** while native is selected but unavailable, Ice re-checks every 2 s and switches
   to native through the existing `update()` path as soon as the read succeeds. No restart.

## Non-goals

- Any change to hiding, the click bridge, or assessment mode itself.
- The pointer freezes (`mouseMovedTap` disabled by timeout) — separate issue.
- The reveal-modes work (separate branch/PR).

## Approaches

One sensible way: reuse the existing `Permission` model and the existing method-change path in
`Concealer27`. A dedicated FDA prompt flow or an entitlement-based route was ruled out (FDA cannot be
requested programmatically; the narrow App Data consent is not offered for this Apple container).
