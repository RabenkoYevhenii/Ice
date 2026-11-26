# macOS 27 FDA onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Native hiding on macOS 27 asks for the permission it really needs (Full Disk Access), tells the user when it is not in force, and switches to native without a restart once granted.

**Architecture:** A pure rule in `Ice/MenuBar/MacOS27/Core` decides the backend and whether to warn; `Concealer27` uses it, publishes the warning state, and re-checks availability on a 2 s timer only while degraded. A new `Permission` subclass surfaces FDA in the existing onboarding/settings lists.

**Tech Stack:** Swift 5 mode, SwiftUI, Combine, Swift Testing (`swift test` on the `IceMacOS27Core` package), xcodebuild.

**Spec:** `docs/superpowers/specs/2026-11-26-macos27-fda-onboarding-design.md`

## Global Constraints

- Every new path is gated on `#available(macOS 27.0, *)`; nothing changes on macOS 26 and earlier.
- FDA settings URL, verbatim: `x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles`
- The FDA permission is `isRequired: false`.
- Re-check interval: 2 seconds, running only while native is selected and not in force.
- No new third-party dependencies; build with the PR's existing ad-hoc command (Task 4).

## Review Focus

- FDA granted while Ice runs → backend switches to native within ~2 s, no relaunch (Task 4 live check).
- FDA revoked while Ice runs → the native apply fails (`nativeFailed`) → assessment, and the warning shows (Task 1 test `failedNativeWarns`).
- User explicitly picks assessment mode → no warning and no re-check timer (Task 1 test `assessmentSelectedNoWarning`; Task 2 timer guard).
- macOS 26 or earlier → no FDA row in onboarding (Task 3 `#available` gate, reviewed by reading).
- Timer must stop once native is in force, so a healthy setup pays nothing (Task 2 step).

---

### Task 1: Backend choice rule

**Files:**
- Create: `Ice/MenuBar/MacOS27/Core/HidingBackendChoice27.swift`
- Test: `Tests/IceMacOS27CoreTests/HidingBackendChoice27Tests.swift`

**Interfaces:**
- Produces: `enum HidingBackendChoice27 { enum Backend: Equatable { case native, assessment }; struct Decision: Equatable { let backend: Backend; let warnNativeUnavailable: Bool }; static func decide(nativeSelected: Bool, nativeAvailable: Bool, nativeFailed: Bool) -> Decision }`

- [ ] **Step 1: Write the failing tests** (Swift Testing, `@Suite("HidingBackendChoice27")`):
  - `nativeWorks`: `decide(true, true, false)` == `Decision(backend: .native, warnNativeUnavailable: false)`
  - `nativeUnavailableWarns`: `decide(true, false, false)` == `(.assessment, true)`
  - `failedNativeWarns`: `decide(true, true, true)` == `(.assessment, true)`
  - `assessmentSelectedNoWarning`: `decide(false, false, false)` and `decide(false, true, false)` both == `(.assessment, false)`
- [ ] **Step 2: Run** `swift test --filter HidingBackendChoice27` — expected: FAIL, `HidingBackendChoice27` not found.
- [ ] **Step 3: Implement** `HidingBackendChoice27.decide` in the new file.
- [ ] **Step 4: Run** `swift test` — expected: all suites pass (new + the existing 92+).
- [ ] **Step 5: Commit** the two files: `fix(macos27): pure rule for hiding backend and FDA warning`.

### Task 2: Concealer27 uses the rule, publishes the warning, re-checks live

**Files:**
- Modify: `Ice/MenuBar/MacOS27/Concealer27.swift` (`resolvedBackend` ~L153, `performSetup` ~L164, properties ~L39)

**Interfaces:**
- Consumes: `HidingBackendChoice27.decide(...)` (Task 1).
- Produces: `@Published private(set) var nativeUnavailable: Bool` on `Concealer27` (true when the decision warns); `func recheckNativeAvailability()`.

- [ ] **Step 1:** `resolvedBackend` returns `.native` / `.assessment` from `HidingBackendChoice27.decide(nativeSelected: method == .nativeAllowList, nativeAvailable: nativeIsAvailable, nativeFailed: nativeFailed)` and sets `nativeUnavailable` to `warnNativeUnavailable` (assign only on change).
- [ ] **Step 2:** `recheckNativeAvailability()`: re-reads `NativeAllowListConcealer27.isAvailable`; if it changed, assigns `nativeIsAvailable`, logs `notice("Native switch is now readable" / "…no longer readable")`, clears `suspendedUntil`, calls `update()` — the same sequence as the existing method-change sink.
- [ ] **Step 3:** A 2 s `Timer.publish` cancellable that is started when `nativeUnavailable` becomes true and cancelled when it becomes false (drive it from a `$nativeUnavailable.removeDuplicates()` sink set up in `performSetup`). It calls `recheckNativeAvailability()`.
- [ ] **Step 4: Build** with the Task 4 build command — expected `** BUILD SUCCEEDED **`; then `swift test` still green.
- [ ] **Step 5: Commit** `Concealer27.swift`: `fix(macos27): no silent assessment fallback; re-check native access live`.

### Task 3: FDA permission in onboarding + settings warning

**Files:**
- Modify: `Ice/Permissions/Permission.swift` (add `FullDiskAccessPermission` after `ScreenRecordingPermission`)
- Modify: `Ice/Permissions/AppPermissions.swift` (`PermissionKey`, property, `allPermissions`)
- Modify: `Ice/Settings/SettingsPanes/AdvancedSettingsPane.swift` (`macOS27HidingMethod` annotation, ~L64)

**Interfaces:**
- Consumes: `Concealer27.nativeUnavailable` (Task 2) via `appState.concealer27`.
- Produces: `final class FullDiskAccessPermission: Permission`; `AppPermissions.fullDiskAccess`.

- [ ] **Step 1:** `FullDiskAccessPermission`: title `"Full Disk Access"`, details `["Hide apps with macOS's own Allow in the Menu Bar switch.", "Without it, Ice uses assessment mode, which briefly shows hidden items when you click the clock, Wi-Fi or battery."]`, `isRequired: false`, settings URL from Global Constraints, `check`: `#available(macOS 27.0, *) ? NativeAllowListConcealer27.isAvailable : true`, `request`: no-op.
- [ ] **Step 2:** `AppPermissions`: add `case fullDiskAccess`, `let fullDiskAccess = FullDiskAccessPermission()`, and `allPermissions` = `[accessibility, screenRecording]` plus `fullDiskAccess` only `if #available(macOS 27.0, *)`.
- [ ] **Step 3:** In the `.nativeAllowList` annotation, when `appState.concealer27.nativeUnavailable`: append a warning `Text("Not in use: native hiding needs Full Disk Access, so assessment mode is used — clicks on system items briefly show hidden items.")` (orange/secondary style matching the pane) and a `Button("Open Full Disk Access Settings")` opening the FDA URL.
- [ ] **Step 4: Build** (Task 4 command) — expected `** BUILD SUCCEEDED **`.
- [ ] **Step 5: Commit** the three files: `fix(macos27): ask for Full Disk Access and show when native hiding is not in force`.

### Task 4: Install and verify live

Build command (from repo root):
`xcodebuild -project Ice.xcodeproj -scheme Ice -configuration Release -destination 'platform=macOS' -derivedDataPath /tmp/ice-build-fda build ENABLE_HARDENED_RUNTIME=NO CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual CODE_SIGNING_REQUIRED=YES CODE_SIGNING_ALLOWED=YES DEVELOPMENT_TEAM= PROVISIONING_PROFILE_SPECIFIER=`

- [ ] **Step 1:** Quit Ice; replace `/Applications/Ice.app` with the build via `ditto`; `codesign --verify --deep --strict` passes. (New ad-hoc signature ⇒ `tccutil reset Accessibility|ScreenCapture com.jordanbaird.Ice` and the user re-grants; FDA entry must be re-added too.)
- [ ] **Step 2 (degraded):** with FDA off, launch: log shows `cannot be read, so assessment mode is used`; Advanced shows the warning + button; onboarding lists Full Disk Access as not granted.
- [ ] **Step 3 (live switch):** user turns FDA on without relaunching: within ~5 s the log shows `Native switch is now readable` and no further `Click bridge: held back press` on clock/Wi-Fi/battery clicks; warning disappears.
- [ ] **Step 4:** `swift test` full run green; commit any fix-ups; leave the branch ready for a PR against `RabenkoYevhenii/Ice:macos-27-support` (PR opened only on the user's go).
