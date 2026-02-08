import AppKit
import SwiftUI

private final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class WindowManager {
    private var panel: NSPanel?
    private let appState: AppState

    var isVisible: Bool {
        panel?.isVisible ?? false
    }

    init(appState: AppState) {
        self.appState = appState
    }

    func open() {
        if let panel, panel.isVisible {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = KeyablePanel(
            contentRect: .zero,
            styleMask: [.borderless, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .windowBackgroundColor
        panel.minSize = NSSize(width: 600, height: 400)

        let contentView = WideContentView(appState: appState) { [weak self] in
            self?.close()
        }
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.sizingOptions = []  // SwiftUI가 창 크기를 덮어쓰지 않도록
        panel.contentViewController = hostingController

        // contentViewController 설정 후 프레임 지정 (순서 중요)
        let screen = currentScreen()
        let screenFrame = screen.visibleFrame
        let width = screenFrame.width * AppConstants.wideViewScreenRatio
        let height = screenFrame.height * AppConstants.wideViewScreenRatio
        let x = screenFrame.origin.x + (screenFrame.width - width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - height) / 2
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)

        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.panel = panel

        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.saveFrame()
        }
    }

    func close() {
        saveFrame()
        panel?.close()
        panel = nil
    }

    func toggle() {
        if isVisible {
            close()
        } else {
            open()
        }
    }

    private func currentScreen() -> NSScreen {
        // Use the screen that contains the mouse cursor
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { screen in
            screen.frame.contains(mouseLocation)
        }
        return screen ?? NSScreen.main ?? NSScreen.screens[0]
    }

    private func isFrameOnScreen(_ frame: NSRect) -> Bool {
        // Check if at least a portion of the frame is visible on any screen
        let minVisible: CGFloat = 100
        return NSScreen.screens.contains { screen in
            let intersection = screen.visibleFrame.intersection(frame)
            return intersection.width >= minVisible && intersection.height >= minVisible
        }
    }

    private func saveFrame() {
        guard let frame = panel?.frame else { return }
        UserDefaults.standard.set(NSStringFromRect(frame), forKey: "wideViewFrame")
    }

    private func loadSavedFrame() -> NSRect? {
        guard let frameString = UserDefaults.standard.string(forKey: "wideViewFrame") else {
            return nil
        }
        let frame = NSRectFromString(frameString)
        guard frame.width > 0, frame.height > 0 else { return nil }
        return frame
    }
}
