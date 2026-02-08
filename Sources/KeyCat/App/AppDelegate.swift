import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    let appState = AppState()
    private var windowManager: WindowManager?
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState.setup()

        let popover = NSPopover()
        popover.contentSize = NSSize(
            width: AppConstants.popoverWidth,
            height: AppConstants.popoverHeight
        )
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView(appState: appState)
        )
        self.popover = popover

        windowManager = WindowManager(appState: appState)

        appState.onViewModeChanged = { [weak self] mode in
            DispatchQueue.main.async {
                switch mode {
                case .wide:
                    self?.popover?.performClose(nil)
                    self?.windowManager?.open()
                case .compact:
                    self?.windowManager?.close()
                    // Re-open popover when switching back to compact
                    if let button = self?.statusItem?.button, let popover = self?.popover {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                        popover.contentViewController?.view.window?.makeKey()
                    }
                }
            }
        }

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: AppConstants.menuBarIcon,
                accessibilityDescription: AppConstants.appName
            )
            button.action = #selector(togglePopover)
            button.target = self
        }

        requestAccessibilityIfNeeded()

        hotkeyManager = HotkeyManager(config: appState.config.hotkey) { [weak self] in
            self?.toggleFromHotkey()
        }
        hotkeyManager?.start()
    }

    private func requestAccessibilityIfNeeded() {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)

            // 권한 부여 후 핫키 재시작을 위해 폴링
            DispatchQueue.global().async { [weak self] in
                for _ in 0..<30 {
                    sleep(2)
                    if AXIsProcessTrusted() {
                        DispatchQueue.main.async {
                            self?.hotkeyManager?.stop()
                            self?.hotkeyManager?.start()
                        }
                        return
                    }
                }
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.stop()
        appState.teardown()
    }

    @objc private func togglePopover() {
        if appState.viewMode == .wide {
            switchToWideView()
        } else {
            toggleCompactPopover()
        }
    }

    private func toggleFromHotkey() {
        if appState.viewMode == .wide {
            windowManager?.toggle()
        } else {
            toggleCompactPopover()
        }
    }

    private func toggleCompactPopover() {
        guard let popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func switchToWideView() {
        popover?.performClose(nil)
        windowManager?.open()
    }

    func switchToCompactView() {
        windowManager?.close()
    }
}
