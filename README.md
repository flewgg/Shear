# Shear

Shear is a tiny menubar app for macOS that enables **Cut (⌘X)** and **Paste (⌘V)** in Finder, similar to Windows/Linux.

## Install

Homebrew:
```bash
brew install --cask flewgg/tap/shear
```

Or download [directly from GitHub](https://github.com/flewgg/Shear/releases/latest).

Automatic update checks are powered by [Sparkle](https://github.com/sparkle-project/Sparkle), and preference storage uses [Defaults](https://github.com/sindresorhus/Defaults).


## How It Works
- When Finder is frontmost:
  - Any enabled modifier shortcut + `X` triggers a copy
  - The next `⌘V` becomes **Move** (`⌘⌥V`)
- Shortcut options in Settings: `⌃` (Control), `⌘` (Command), `Fn/Globe`, or `Multiple`.
- `⌘` mode may interfere with Finder text cut in editing fields.
- Normal `⌘C` and `⌘V` still behave as expected.

## Permissions
- **Input Monitoring** is required so the app can detect your shortcut while Finder is active.
- **Accessibility** is required so the app can send Finder's move-paste shortcut.

## Security

The app is sandboxed and does not request file access entitlements.

## Acknowledgements

Shear uses [Sparkle](https://github.com/sparkle-project/Sparkle) for app updates and [Defaults](https://github.com/sindresorhus/Defaults) for preference storage. The About tab includes an acknowledgements window with both licenses.
