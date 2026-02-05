# Command X

Command X is a tiny menubar app for macOS that enables **Cut (Cmd+X)** and **Paste (Cmd+V)** in Finder, similar to Windows/Linux.

This was inspired by [Command X](https://sindresorhus.com/command-x). I built this because I didnt want to pay $4 for a stupid simple shortcut remap.

## How It Works
- When Finder is frontmost:
  - `Cmd+X` triggers a copy
  - The next `Cmd+V` becomes **Move** (Finder	s `Cmd+Option+V`)
- Normal `Cmd+C` and `Cmd+V` still behave as expected.

## Permissions
- **Input Monitoring** may be required depending on your macOS version and security settings.

## Install (Manual Build)
There is no prebuilt binary yet. Please build manually:
1. Open `Command X.xcodeproj` in Xcode.
2. Build and run the `Command X` target.

## Security
- App Sandbox enabled
- No network access
- No file access outside its sandbox
