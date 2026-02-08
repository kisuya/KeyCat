import Foundation

final class FileWatcher {
    private var fileDescriptor: Int32 = -1
    private var dispatchSource: DispatchSourceFileSystemObject?
    private let directoryURL: URL
    private let onChange: () -> Void
    private let debounceInterval: TimeInterval
    private var debounceWorkItem: DispatchWorkItem?

    init(
        directory: URL,
        debounceInterval: TimeInterval = 0.5,
        onChange: @escaping () -> Void
    ) {
        self.directoryURL = directory
        self.debounceInterval = debounceInterval
        self.onChange = onChange
    }

    func start() {
        ensureDirectoryExists()

        fileDescriptor = open(directoryURL.path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename, .extend],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.scheduleChange()
        }

        source.setCancelHandler { [weak self] in
            guard let self else { return }
            if self.fileDescriptor >= 0 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }

        source.resume()
        dispatchSource = source
    }

    func stop() {
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
        dispatchSource?.cancel()
        dispatchSource = nil
    }

    private func scheduleChange() {
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.onChange()
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
    }

    private func ensureDirectoryExists() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try? fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }
    }

    deinit {
        stop()
    }
}
