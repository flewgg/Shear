import ApplicationServices
import Carbon
import Cocoa

final class EventTapManager {
    private struct ModifierRule {
        let required: CGEventFlags
        let disallowed: CGEventFlags
    }

    private enum ShortcutKey {
        case copy
        case cut
        case paste

        init?(keyCode: Int) {
            switch keyCode {
            case kVK_ANSI_C: self = .copy
            case kVK_ANSI_X: self = .cut
            case kVK_ANSI_V: self = .paste
            default: return nil
            }
        }

        var keyCode: Int {
            switch self {
            case .copy: return kVK_ANSI_C
            case .cut: return kVK_ANSI_X
            case .paste: return kVK_ANSI_V
            }
        }
    }

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isCutMode = false
    private let injectedEventTag: Int64 = 0x434D4458
    private var retryWorkItem: DispatchWorkItem?
    private let retryDelay: TimeInterval = 2
    private var hasLoggedMissingPermissions = false
    private static let finderBundleIdentifier = "com.apple.finder"

    deinit {
        stop()
    }

    func start() {
        guard eventTap == nil else { return }
        guard hasRequiredPermissions() else {
            scheduleRetry()
            return
        }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return EventTapManager.passThrough(event)
            }

            let manager = Unmanaged<EventTapManager>.fromOpaque(userInfo).takeUnretainedValue()
            switch type {
            case .tapDisabledByTimeout, .tapDisabledByUserInput:
                manager.reenableEventTap()
                return EventTapManager.passThrough(event)
            case .keyDown:
                return manager.handle(event: event) ? nil : EventTapManager.passThrough(event)
            default:
                return EventTapManager.passThrough(event)
            }
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
            NSLog("Shear: failed to create event tap (will retry)")
            scheduleRetry()
            return
        }

        retryWorkItem?.cancel()
        retryWorkItem = nil
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        retryWorkItem?.cancel()
        retryWorkItem = nil

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            runLoopSource = nil
        }

        if let tap = eventTap {
            CFMachPortInvalidate(tap)
            eventTap = nil
        }

        isCutMode = false
    }

    private func hasRequiredPermissions() -> Bool {
        let inputMonitoringGranted = CGPreflightListenEventAccess()
        let eventSynthesisGranted = CGPreflightPostEventAccess()
        if !inputMonitoringGranted || !eventSynthesisGranted {
            if !hasLoggedMissingPermissions {
                NSLog(
                    "Shear: waiting for permissions (Input Monitoring: %@, Accessibility/Post Events: %@)",
                    inputMonitoringGranted ? "granted" : "missing",
                    eventSynthesisGranted ? "granted" : "missing"
                )
                hasLoggedMissingPermissions = true
            }
            return false
        }
        hasLoggedMissingPermissions = false
        return true
    }

    private func scheduleRetry() {
        guard eventTap == nil else { return }
        guard retryWorkItem == nil else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.retryWorkItem = nil
            self.start()
        }
        retryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay, execute: workItem)
    }

    private func reenableEventTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
            NSLog("Shear: event tap was disabled and has been re-enabled")
        } else {
            scheduleRetry()
        }
    }

    private func handle(event: CGEvent) -> Bool {
        guard event.getIntegerValueField(.eventSourceUserData) != injectedEventTag else { return false }
        guard isFinderFrontmost() else { return false }

        let flags = event.flags
        guard shouldHandleModifier(flags: flags) else { return false }
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        guard let key = ShortcutKey(keyCode: keyCode) else { return false }

        let isAutoRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
        switch key {
        case .copy:
            setCutMode(false)
            return false
        case .cut:
            guard !isAutoRepeat else { return true }
            setCutMode(true)
            postKeyCombo(ShortcutKey.copy.keyCode, flags: [.maskCommand])
            return true
        case .paste:
            guard !isAutoRepeat else { return isCutMode }
            guard isCutMode else { return false }
            setCutMode(false)
            postKeyCombo(ShortcutKey.paste.keyCode, flags: [.maskCommand, .maskAlternate])
            return true
        }
    }

    private func shouldHandleModifier(flags: CGEventFlags) -> Bool {
        let rule = modifierRule(for: currentModifier)
        guard flags.contains(rule.required) else { return false }
        return flags.intersection(rule.disallowed).isEmpty
    }

    private func modifierRule(for modifier: ShortcutModifier) -> ModifierRule {
        switch modifier {
        case .control:
            return ModifierRule(
                required: .maskControl,
                disallowed: [.maskCommand, .maskAlternate, .maskShift, .maskSecondaryFn]
            )
        case .command:
            return ModifierRule(
                required: .maskCommand,
                disallowed: [.maskControl, .maskAlternate, .maskShift, .maskSecondaryFn]
            )
        case .function:
            return ModifierRule(
                required: .maskSecondaryFn,
                disallowed: [.maskControl, .maskCommand, .maskAlternate, .maskShift]
            )
        }
    }

    private var currentModifier: ShortcutModifier {
        let rawValue = UserDefaults.standard.string(forKey: ShortcutModifier.storageKey)
        return ShortcutModifier(storedValue: rawValue)
    }

    private func isFinderFrontmost() -> Bool {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier == EventTapManager.finderBundleIdentifier
    }

    private func postKeyCombo(_ keyCode: Int, flags: CGEventFlags) {
        guard let source = CGEventSource(stateID: .combinedSessionState),
              let keyDown = CGEvent(
                  keyboardEventSource: source,
                  virtualKey: CGKeyCode(keyCode),
                  keyDown: true
              ),
              let keyUp = CGEvent(
                  keyboardEventSource: source,
                  virtualKey: CGKeyCode(keyCode),
                  keyDown: false
              ) else {
            return
        }

        keyDown.flags = flags
        keyUp.flags = flags
        keyDown.setIntegerValueField(.eventSourceUserData, value: injectedEventTag)
        keyUp.setIntegerValueField(.eventSourceUserData, value: injectedEventTag)
        keyDown.post(tap: .cgSessionEventTap)
        keyUp.post(tap: .cgSessionEventTap)
    }

    private func setCutMode(_ active: Bool) {
        guard isCutMode != active else { return }
        isCutMode = active
    }

    private static func passThrough(_ event: CGEvent) -> Unmanaged<CGEvent> {
        Unmanaged.passUnretained(event)
    }
}
