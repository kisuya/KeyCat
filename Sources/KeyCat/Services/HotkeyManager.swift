import Carbon
import AppKit

final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let config: HotkeyConfig
    private let onTrigger: () -> Void

    private static weak var current: HotkeyManager?

    init(config: HotkeyConfig, onTrigger: @escaping () -> Void) {
        self.config = config
        self.onTrigger = onTrigger
    }

    func start() {
        guard let kc = keyCode(from: config.key) else { return }
        let mods = carbonModifiers(from: config.modifiers)

        HotkeyManager.current = self

        // Install event handler
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            HotkeyManager.current?.onTrigger()
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        // Register hotkey
        let hotkeyID = EventHotKeyID(
            signature: OSType(0x4B435454),  // "KCTT"
            id: 1
        )

        let status = RegisterEventHotKey(
            UInt32(kc),
            mods,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if status != noErr {
            NSLog("KeyCat: Failed to register hotkey (status: \(status))")
        }
    }

    func stop() {
        if let hotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
            self.hotkeyRef = nil
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private func carbonModifiers(from modifiers: [String]) -> UInt32 {
        var result: UInt32 = 0
        for modifier in modifiers {
            switch modifier.lowercased() {
            case "cmd", "command": result |= UInt32(cmdKey)
            case "shift": result |= UInt32(shiftKey)
            case "alt", "option", "opt": result |= UInt32(optionKey)
            case "ctrl", "control": result |= UInt32(controlKey)
            default: break
            }
        }
        return result
    }

    // ANSI keyCode mapping (입력기 무관)
    private func keyCode(from key: String) -> UInt16? {
        let map: [String: UInt16] = [
            "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
            "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
            "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
            "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
            "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35, "l": 37,
            "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44,
            "n": 45, "m": 46, ".": 47, "`": 50, " ": 49, "space": 49,
        ]
        return map[key.lowercased()]
    }

    deinit {
        stop()
    }
}
