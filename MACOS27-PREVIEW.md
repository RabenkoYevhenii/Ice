# Ice for macOS 27 — preview build

A build of [PR #995](https://github.com/jordanbaird/Ice/pull/995), which restores hiding, the Ice
Bar and the Menu Bar Layout editor on macOS 27. Built from
[`macos-27-support`](https://github.com/RabenkoYevhenii/Ice/tree/macos-27-support) at `889f1ea`,
version `0.11.13-dev.2a (1121)`.

This is not an official Ice release and does not come from Ice's maintainer. It is a preview for
people who want to try the branch without building it themselves.

**Download:** https://github.com/RabenkoYevhenii/Ice/releases/latest

## Installing

The order matters: **move the app before you open it.**

1. Download `Ice-macOS27-preview-19.zip` and unzip it.
2. **Move `Ice.app` into your Applications folder first.** Opened straight from Downloads, macOS
   runs it from a random temporary copy, permissions never stick to it, and it looks broken.
   If you already run Ice, quit it and replace it with this one. Your settings stay where they
   are, so your layout carries over, and putting your old copy back later restores everything.
3. Open it. macOS will refuse: *"Apple could not verify Ice is free of malware."* The app is not
   notarized, which needs a paid Apple developer membership this build does not have.
   Click **Done**. Do not click *Move to Trash*.
4. Open **System Settings → Privacy & Security**, scroll to the **Security** section, and use
   **Open Anyway** on the entry for Ice that appeared there. Confirm, then **Open**.
   Control-clicking the app and choosing *Open* no longer works for unnotarized apps on macOS 27.
5. Ice asks for two permissions:
   - **Accessibility** — required. Hiding items and reading the menu bar both depend on it.
   - **Screen Recording** — the icons shown in the Ice Bar are cut from a capture of the menu bar.
     Without it Ice runs, but the Ice Bar has no icons.

   If you already had Ice installed, macOS may show the permissions as granted while this build
   still asks for them. The two builds are signed differently, so a grant made to one does not
   carry to the other. Grant them again for this one, and expect to do the same when you go back
   to your own build.

6. **Turn off automatic updates**, or Ice will replace this build with the newest official
   release, which does not work on macOS 27:

   ```
   defaults write com.jordanbaird.Ice SUAutomaticallyUpdate -bool false
   ```

Verifying the download:

```
shasum -a 256 Ice-macOS27-preview-19.zip
# ed81d2b3b6fc3a52e369881a3e4d536a731add4536667b32a5206cc3daa018e9
```

## What works on macOS 27

- Hiding and revealing items, including the always-hidden section.
- Reveal on hover, and the Ice Bar, on either display.
- Real menu bar glyphs in the Ice Bar, cut from the bar itself rather than app icons.
- Clicking an item in the Ice Bar opens that item's own menu or window, including an item that
  does not fit beside the notch and has been folded into the system overflow.
- Moving applications between sections in the Menu Bar Layout editor.
- Search.

## Known limitations

- **Ice's own icon disappears while anything is hidden.** While hiding is in force, macOS keeps
  only items of applications it trusts, which as far as anyone has measured means notarized ones,
  and this build is signed ad hoc. @carlossantos74 measured on
  [#1001](https://github.com/jordanbaird/Ice/pull/1001) that an unnotarized Developer ID signature
  does not bring the item back either. Reveal with hover instead, or bind a hotkey. Hiding itself
  still works.
- **Opening the clock, battery or Wi-Fi panel takes about 150 ms longer** than with Ice not
  running. macOS ignores clicks on those while items are hidden, so Ice lifts the hiding for a
  moment and replays the click. Closing a panel costs nothing.
- **Which section an application belongs to comes from a saved layout**, not from where its item
  sits on the bar. The order inside a section is still yours: a ⌘ drag in the menu bar works on
  macOS 27 and the new order sticks, measured by hand and with a synthetic drag. You cannot drag
  an item that is currently hidden, because macOS takes it off the bar. Ice does not rearrange
  the bar by itself. The earlier version of this document said dragging was impossible; that came
  from watching an ad-hoc signed test item refuse to move, which only happens to such processes.
- **On a MacBook, plugging in a display can empty the built-in display's menu bar.** macOS lays
  the bar out again, drops the items that do not fit beside the notch, and leaves no "«" to reach
  them. This is not Ice's doing: with Ice quit, unplugging a second display and plugging it back
  leaves that bar with the system items and nothing else.

  Two things bring the items back, both buttons in **Menu Bar Layout**. Restarting the menu bar is
  the one to try first: it restarts the process that draws the bar, which comes back on its own in
  about a second, and clears the state where macOS refuses to draw an item at all. Measured on a
  bar missing ten items: all ten returned, and relaunching the applications themselves had not
  helped. Relaunching the application that owns the missing item sometimes works too.
- **Control Centre's camera button is not drawn while items are hidden**, and no allowlist brings
  it back. Ice draws one of its own, and clicking it opens the real controls. That costs about a
  quarter of a second with hiding lifted, because the module it presses does not exist while
  anything is hidden. The small green dot beside the clock is not an item and shows either way.
- **Item spacing is not offered on macOS 27**, for the reason given above. On macOS 26 it works
  as it always did.
- **Hiding the application menus is off on macOS 27, on purpose.** macOS folds away the items that
  do not fit, so shown items never cover the menus, and switching it on only took keyboard focus
  from whatever you were using.
- Tested on macOS 27.0 with a built-in and an external display. On macOS 26 it should behave like
  Ice's own `macos-26` branch, but that is not tested here.

## Going back

Quit this build and put your own copy of `Ice.app` back where it was. Nothing outside the app
bundle is changed, and settings are shared, so your sections and layout stay as they were. You may
have to grant Accessibility and Screen Recording to your own build again, for the reason above.

## Reporting problems

Please report on [PR #995](https://github.com/jordanbaird/Ice/pull/995) rather than on Ice's issue
tracker. This build is not the maintainer's work, and issues about it would land on him.
Ice is GPLv3; the source of this build is the branch linked at the top.


