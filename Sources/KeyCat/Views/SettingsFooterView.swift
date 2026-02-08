import SwiftUI
import UniformTypeIdentifiers

struct SettingsFooterView: View {
    @Bindable var appState: AppState
    @State private var showCopiedFeedback = false
    @State private var showFileList = false
    @State private var launchAtLogin = LaunchAtLoginManager.isEnabled

    var body: some View {
        VStack(spacing: 6) {
            // Row 1: File management
            HStack(spacing: 10) {
                Button {
                    openConfigFolder()
                } label: {
                    Label("폴더 열기", systemImage: "folder")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("~/.config/keycat/ 폴더를 Finder에서 엽니다")

                Button {
                    copyPath()
                } label: {
                    Label(
                        showCopiedFeedback ? "복사됨!" : "경로 복사",
                        systemImage: showCopiedFeedback ? "checkmark" : "doc.on.clipboard"
                    )
                    .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(showCopiedFeedback ? .green : .secondary)
                .help("설정 폴더 경로를 클립보드에 복사합니다")

                Button {
                    openConfigFile()
                } label: {
                    Label("설정 편집", systemImage: "gearshape")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("config.yaml을 기본 에디터에서 엽니다")

                Button {
                    promptTemplateName()
                } label: {
                    Label("새 템플릿", systemImage: "doc.badge.plus")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button {
                    exportMarkdown()
                } label: {
                    Label("내보내기", systemImage: "square.and.arrow.up")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("단축키를 Markdown 파일로 내보냅니다")

                Spacer()

                // File list popover
                Button {
                    showFileList.toggle()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "doc.text.magnifyingglass")
                        Text("\(appState.store.files.count)")
                    }
                    .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .popover(isPresented: $showFileList) {
                    fileListView
                }
                .help("로드된 YAML 파일 목록")

                // Error badge
                if appState.hasErrors {
                    Button {
                        appState.showingErrors.toggle()
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("\(appState.loadErrors.count)")
                        }
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $appState.showingErrors) {
                        errorDetailView
                    }
                }
            }

            // Row 2: View toggle + Launch at Login + Quit
            HStack {
                Toggle(isOn: Binding(
                    get: { appState.viewMode == .wide },
                    set: { appState.viewMode = $0 ? .wide : .compact }
                )) {
                    Label("넓은 보기", systemImage: "rectangle.expand.vertical")
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                .tint(.accentColor)
                .id(appState.viewMode)
                .help("넓은 보기 모드로 전환합니다 (⌘E)")

                Spacer()

                Toggle(isOn: $launchAtLogin) {
                    Label("자동 시작", systemImage: "play.circle")
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                .tint(.accentColor)
                .help("로그인 시 자동으로 실행합니다")
                .onChange(of: launchAtLogin) {
                    LaunchAtLoginManager.toggle()
                }

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("종료", systemImage: "power")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - File List Popover

    private var fileListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("단축키 파일 관리")
                    .font(.headline)
                Spacer()
                Text("\(appState.store.files.count)개")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            if appState.store.files.isEmpty {
                Text("로드된 YAML 파일이 없습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(appState.store.orderedFiles) { file in
                            fileRow(file: file)
                        }
                    }
                }
                .frame(maxHeight: 260)
            }

            Divider()

            // Action buttons
            HStack(spacing: 8) {
                Button {
                    importYAMLFile()
                } label: {
                    Label("가져오기", systemImage: "square.and.arrow.down")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("외부 YAML 파일을 가져옵니다")

                Spacer()

                Text(AppConstants.userConfigDirectory.path)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding()
        .frame(width: 320)
    }

    private func fileRow(file: ShortcutFile) -> some View {
        let source = appState.store.sourceFor(file.app)
        let count = file.categories.reduce(0) { $0 + $1.shortcuts.count }

        return HStack(spacing: 6) {
            Image(systemName: file.icon ?? AppConstants.defaultIcon)
                .font(.caption)
                .frame(width: 16)
                .foregroundStyle(.secondary)

            Text(file.app)
                .font(.caption)

            Text(source == .user ? "custom" : "built-in")
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(source == .user ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15))
                .foregroundStyle(source == .user ? .blue : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 3))

            Spacer()

            Text("\(count)개")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            // Edit button
            Button {
                openShortcutFile(file.app)
            } label: {
                Image(systemName: "pencil")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("\(file.app).yaml 편집")

            // Reset button (only for user files that have a bundled version)
            if source == .user && appState.store.hasBundledVersion(for: file.app) {
                Button {
                    resetToBundled(file.app)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.orange)
                .help("기본값으로 리셋")
            }

            // Delete button (only for user-created files without bundled version)
            if source == .user && !appState.store.hasBundledVersion(for: file.app) {
                Button {
                    deleteUserFile(file.app)
                } label: {
                    Image(systemName: "trash")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red.opacity(0.7))
                .help("파일 삭제")
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Error Detail Popover

    private var errorDetailView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YAML 로드 오류")
                .font(.headline)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(appState.loadErrors) { error in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(.orange)
                                Text(error.fileName)
                                    .font(.caption.bold())
                            }
                            Text(error.message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .frame(width: 300)
    }

    // MARK: - Actions

    private func openConfigFolder() {
        let url = AppConstants.userConfigDirectory
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }
        NSWorkspace.shared.open(url)
    }

    private func openConfigFile() {
        let configURL = AppConstants.configFilePath
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: configURL.path) {
            InitialSetup.copyDefaultConfigIfNeeded()
        }

        openInVSCode(configURL)
    }

    private func copyPath() {
        let path = AppConstants.userConfigDirectory.path
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        showCopiedFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedFeedback = false
        }
    }

    private func exportMarkdown() {
        let files = appState.store.orderedFiles
        guard !files.isEmpty else { return }
        let markdown = MarkdownExporter.export(files: files)
        MarkdownExporter.saveWithPanel(content: markdown)
    }

    private func openInVSCode(_ url: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/code")
        process.arguments = [url.path]
        // Fallback paths for Apple Silicon / Homebrew
        if !FileManager.default.fileExists(atPath: "/usr/local/bin/code") {
            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/code")
        }
        do {
            try process.run()
        } catch {
            // VSCode not found, fall back to system default
            NSWorkspace.shared.open(url)
        }
    }

    private func openShortcutFile(_ appName: String) {
        let fileName = "\(appName.lowercased()).yaml"
        let fileURL = AppConstants.userConfigDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            openInVSCode(fileURL)
        } else {
            // Copy bundled file to user directory first, then open
            InitialSetup.ensureConfigDirectoryExists()
            if let bundleURL = Bundle.module.url(
                forResource: appName.lowercased(),
                withExtension: "yaml",
                subdirectory: "Shortcuts"
            ) ?? Bundle.module.url(
                forResource: appName.lowercased(),
                withExtension: "yaml",
                subdirectory: "Defaults"
            ) {
                try? FileManager.default.copyItem(at: bundleURL, to: fileURL)
            }
            openInVSCode(fileURL)
        }
    }

    private func resetToBundled(_ appName: String) {
        let alert = NSAlert()
        alert.messageText = "\(appName) 기본값 복원"
        alert.informativeText = "커스터마이징한 내용이 사라집니다. 기존 파일은 .bak으로 백업됩니다."
        alert.addButton(withTitle: "복원")
        alert.addButton(withTitle: "취소")
        alert.alertStyle = .warning

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let fileName = "\(appName.lowercased()).yaml"
        let userFileURL = AppConstants.userConfigDirectory.appendingPathComponent(fileName)
        let backupURL = AppConstants.userConfigDirectory.appendingPathComponent("\(fileName).bak")
        let fileManager = FileManager.default

        // Backup existing file
        if fileManager.fileExists(atPath: userFileURL.path) {
            try? fileManager.removeItem(at: backupURL)
            try? fileManager.moveItem(at: userFileURL, to: backupURL)
        }

        // Copy bundled file
        if let bundleURL = Bundle.module.url(
            forResource: appName.lowercased(),
            withExtension: "yaml",
            subdirectory: "Shortcuts"
        ) ?? Bundle.module.url(
            forResource: appName.lowercased(),
            withExtension: "yaml",
            subdirectory: "Defaults"
        ) {
            try? fileManager.copyItem(at: bundleURL, to: userFileURL)
        } else {
            // No bundled version, just remove user file to use bundled
            try? fileManager.removeItem(at: userFileURL)
        }

        appState.showToast(.init(text: "\(appName) 기본값 복원됨", icon: "arrow.counterclockwise"))
    }

    private func deleteUserFile(_ appName: String) {
        let alert = NSAlert()
        alert.messageText = "\(appName) 파일 삭제"
        alert.informativeText = "\(appName).yaml 파일을 삭제합니다."
        alert.addButton(withTitle: "삭제")
        alert.addButton(withTitle: "취소")
        alert.alertStyle = .warning

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let fileName = "\(appName.lowercased()).yaml"
        let userFileURL = AppConstants.userConfigDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: userFileURL)

        appState.showToast(.init(text: "\(appName) 삭제됨", icon: "trash"))
    }

    private func importYAMLFile() {
        let panel = NSOpenPanel()
        panel.title = "YAML 파일 가져오기"
        panel.allowedContentTypes = [.yaml]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK else { return }

        InitialSetup.ensureConfigDirectoryExists()
        let fileManager = FileManager.default
        var importedCount = 0

        for url in panel.urls {
            let destURL = AppConstants.userConfigDirectory.appendingPathComponent(url.lastPathComponent)
            do {
                // Validate before importing
                let data = try Data(contentsOf: url)
                let validation = YAMLValidator.validate(data: data, fileName: url.lastPathComponent)
                guard validation.isValid else { continue }

                if fileManager.fileExists(atPath: destURL.path) {
                    try fileManager.removeItem(at: destURL)
                }
                try fileManager.copyItem(at: url, to: destURL)
                importedCount += 1
            } catch {
                continue
            }
        }

        if importedCount > 0 {
            appState.showToast(.init(text: "\(importedCount)개 파일 가져옴", icon: "square.and.arrow.down"))
        }
    }

    private func promptTemplateName() {
        let alert = NSAlert()
        alert.messageText = "새 템플릿 생성"
        alert.informativeText = "앱 이름을 입력하세요:"
        alert.addButton(withTitle: "생성")
        alert.addButton(withTitle: "취소")

        let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        inputField.placeholderString = "예: docker"
        alert.accessoryView = inputField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let name = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return }
            do {
                let url = try TemplateGenerator.writeTemplate(appName: name)
                openInVSCode(url)
            } catch {
                let errorAlert = NSAlert()
                errorAlert.messageText = "템플릿 생성 실패"
                errorAlert.informativeText = error.localizedDescription
                errorAlert.runModal()
            }
        }
    }
}
