# Ice for macOS 27 — preview build

A build of [PR #995](https://github.com/jordanbaird/Ice/pull/995), which restores hiding, the Ice
Bar and the Menu Bar Layout editor on macOS 27. Built from
[`macos-27-support`](https://github.com/RabenkoYevhenii/Ice/tree/macos-27-support) at `e26e895`,
version `0.11.13-dev.2a (1121)`.

This is not an official Ice release and does not come from Ice's maintainer. It is a preview for
people who want to try the branch without building it themselves.

**Download:** https://github.com/RabenkoYevhenii/Ice/releases/latest

## Installing

The order matters: **move the app before you open it.**

1. Download `Ice-macOS27-preview-1.zip` and unzip it.
2. **Move `Ice.app` into your Applications folder first.** Opened straight from Downloads, macOS
   runs it from a random temporary copy, permissions never stick to it, and it looks broken.
   If you already run Ice, quit it and replace it with this one — your settings stay where they
   are, so your layout carries over, and putting your old copy back later restores everything.
3. Open it. macOS will refuse: *"Apple could not verify Ice is free of malware."* The app is not
   notarized — that costs a paid Apple developer membership, which this build does not have.
   Click **Done**. Do not click *Move to Trash*.
4. Open **System Settings → Privacy & Security**, scroll to the **Security** section, and use
   **Open Anyway** on the entry for Ice that appeared there. Confirm, then **Open**.
   Control-clicking the app and choosing *Open* no longer works for unnotarized apps on macOS 27.
5. Ice asks for two permissions:
   - **Accessibility** — required. Hiding items and reading the menu bar both depend on it.
   - **Screen Recording** — the icons shown in the Ice Bar are cut from a capture of the menu bar.
     Without it Ice runs, but the Ice Bar has no icons.

   If you already had Ice installed, macOS may show the permissions as granted while this build
   still asks: the two builds are signed differently, so a grant made to one does not carry to the
   other. Grant them again for this one. When you go back to your own build, expect to grant them
   there again too.

Verifying the download, if you like:

```
shasum -a 256 Ice-macOS27-preview-1.zip
# d96b3a26724eebee023215d42c9a8e24f9a99115257a1ee8ca081aa764b6372b
```

## What works on macOS 27

- Hiding and revealing items, including the always-hidden section.
- Reveal on hover, and the Ice Bar, on either display.
- Real menu bar glyphs in the Ice Bar, cut from the bar itself rather than app icons.
- Clicking an item in the Ice Bar opens that item's own menu or window.
- Moving applications between sections in the Menu Bar Layout editor.

## What to expect, honestly

- **Ice's own icon disappears while anything is hidden.** While the hiding is in force macOS keeps
  only items of applications signed with a Developer ID on the bar, and this build is signed ad
  hoc. Reveal with hover instead, or bind a hotkey. Hiding itself is unaffected.
- **Opening the clock, battery or Wi-Fi panel takes roughly 150 ms longer** than with Ice not
  running. macOS ignores clicks on those while items are hidden, so Ice lifts the hiding for a
  moment and replays the click. Dismissing a panel costs nothing.
- **Items cannot be dragged around the bar.** macOS 27 arranges them itself; which section an
  application belongs to comes from a saved layout instead of its position.
- **On a MacBook's built-in display**, items that macOS folded away before Ice started can stay
  folded after Ice frees the space, with no "«" left to reach them. Relaunching the application
  whose item is missing brings it back.
- Search, item spacing and hiding the application menus are off on macOS 27.
- Tested on macOS 27.0 with a built-in and an external display. On macOS 26 it should behave like
  Ice's own `macos-26` branch, but that is not tested here.

## Going back

Quit this build and put your own copy of `Ice.app` back where it was. Nothing outside the app
bundle is changed, and settings are shared, so your sections and layout stay as they were. You may
have to grant Accessibility and Screen Recording to your own build again, for the reason above.

## Reporting problems

Please report on [PR #995](https://github.com/jordanbaird/Ice/pull/995) rather than on Ice's issue
tracker — this build is not the maintainer's work, and issues about it would land on him.
Ice is GPLv3; the source of this build is the branch linked at the top.
