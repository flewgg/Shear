# Command Cut

Command Cut is a tiny menubar app for macOS that enables **Cut (Cmd+X)** and **Paste (Cmd+V)** in Finder, similar to Windows/Linux.

## How It Works
- When Finder is frontmost:
  - `Cmd+X` triggers a copy
  - The next `Cmd+V` becomes **Move** (Finder\t `Cmd+Option+V`)
- Normal `Cmd+C` and `Cmd+V` still behave as expected.

## Permissions
- **Input Monitoring** may be required depending on your macOS version and security settings.

## Install (Manual Build)
There is no prebuilt binary yet. Please build manually:
1. Install Xcode from the App Store.
2. Clone this repo and open `Command X.xcodeproj` in Xcode.
3. Select the `Command X` target and click **Run**.
4. Grant **Input Monitoring** permission if prompted.
5. The app runs as a menubar item.

## Build + Install Locally (No Gatekeeper Warnings)
If you build the app on your own machine, macOS won’t quarantine it:
1. In Xcode, use **Product > Archive** (Release build).
2. Export the `.app` and move it to `/Applications`.
3. Launch it once to set permissions.

## Security

The app is sandboxed and will NOT connect to the internet. It also doesn't have any file access entitlements.

## TODO
- [ ] Fix file names and search queries in finder not being "cut"