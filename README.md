# Command Cut

Command Cut is a tiny menubar app for macOS that enables **Cut (⌘X)** and **Paste (⌘V)** in Finder, similar to Windows/Linux.

## How It Works
- When Finder is frontmost:
  - Your selected modifier shortcut + `X` triggers a copy
  - The next `⌘V` becomes **Move** (`⌘⌥V`)
- Modifier options in Settings: `⌃` (Control), `⌘` (Command), and `Fn/Globe`.
- `⌘` mode may interfere with Finder text cut in editing fields.
- Normal `⌘C` and `⌘V` still behave as expected.

## Permissions
- **Input Monitoring** is required so the app can detect your shortcut while Finder is active.
- **Accessibility** is required so the app can send Finder's move-paste shortcut.

## Install (Manual Build)
There is no prebuilt binary yet. Please build manually:
1. Install Xcode from the App Store.
2. Clone this repo and open `Command Cut.xcodeproj` in Xcode.
3. Select the `Command Cut` target and click **Run**.
4. Grant **Input Monitoring** and **Accessibility** permissions if prompted.
5. The app runs as a menubar item.

## Build + Install Locally (No Gatekeeper Warnings)
If you build the app on your own machine, macOS won’t quarantine it:
1. In Xcode, use **Product > Archive** (Release build).
2. Export the `.app` and move it to `/Applications`.
3. Launch it once to set permissions.

## Security

The app is sandboxed and does not request file access entitlements.
