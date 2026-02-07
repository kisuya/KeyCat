import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let appState = AppState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState.setup()

        let popover = NSPopover()
        popover.contentSize = NSSize(
            width: AppConstants.popoverWidth,
            height: AppConstants.popoverHeight
        )
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView(store: appState.store)
        )
        self.popover = popover

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
    }

    func applicationWillTerminate(_ notification: Notification) {
        appState.teardown()
    }

    @objc private func togglePopover() {
        guard let popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
