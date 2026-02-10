import Carbon
import Cocoa

final class EventTapManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isCutMode = false
    private let injectedEventTag: Int64 = 0x434D4458 

    private enum ShortcutMode: String {
        case command
        case control
    }

    func start() {
        guard eventTap == nil else { return }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard type == .keyDown else { return Unmanaged.passRetained(event) }
            
            let manager = Unmanaged<EventTapManager>.fromOpaque(userInfo!).takeUnretainedValue()
            return manager.handle(event: event) ? nil : Unmanaged.passRetained(event)
        }

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: refcon
        ) else {
            NSLog("Command Cut: failed to create event tap")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handle(event: CGEvent) -> Bool {
        let userTag = event.getIntegerValueField(.eventSourceUserData)
        if userTag == injectedEventTag {
            return false
        }

        guard isFinderFrontmost() else {
            return false
        }

        let flags = event.flags
        let modeRaw = UserDefaults.standard.string(forKey: "CutShortcutMode")
        let mode = ShortcutMode(rawValue: modeRaw ?? "") ?? .command

        let requiredFlag: CGEventFlags = (mode == .control) ? .maskControl : .maskCommand
        let otherModifier: CGEventFlags = (mode == .control) ? .maskCommand : .maskControl

        guard flags.contains(requiredFlag) else { return false }
        guard flags.intersection([otherModifier, .maskAlternate, .maskShift]).isEmpty else { return false }

        guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0 else {
            return true
        }

        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        switch keyCode {
        case kVK_ANSI_C:
            setCutMode(false)
            return false
        case kVK_ANSI_X:
            setCutMode(true)
            postKeyCombo(kVK_ANSI_C, flags: [.maskCommand])
            return true
        case kVK_ANSI_V:
            if isCutMode {
                setCutMode(false)
                postKeyCombo(kVK_ANSI_V, flags: [.maskCommand, .maskAlternate])
                return true
            }
            return false
        default:
            return false
        }
    }

    private func isFinderFrontmost() -> Bool {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.finder"
    }

    private func postKeyCombo(_ keyCode: Int, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: false)
        keyDown?.flags = flags
        keyUp?.flags = flags
        keyDown?.setIntegerValueField(.eventSourceUserData, value: injectedEventTag)
        keyUp?.setIntegerValueField(.eventSourceUserData, value: injectedEventTag)
        keyDown?.post(tap: .cgSessionEventTap)
        keyUp?.post(tap: .cgSessionEventTap)
    }

    private func setCutMode(_ active: Bool) {
        guard isCutMode != active else { return }
        isCutMode = active
        NotificationCenter.default.post(
            name: .commandCutModeChanged,
            object: nil,
            userInfo: ["active": active]
        )
    }
}

extension Notification.Name {
    static let commandCutModeChanged = Notification.Name("CommandCutModeChanged")
}
