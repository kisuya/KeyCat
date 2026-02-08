import SwiftUI

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
                .help("넓은 보기 모드로 전환합니다 (⌘E)")

                Spacer()

                Toggle(isOn: $launchAtLogin) {
                    Label("자동 시작", systemImage: "play.circle")
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
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
                Text("로드된 파일")
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
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(appState.store.orderedFiles) { file in
                            HStack(spacing: 6) {
                                Image(systemName: file.icon ?? AppConstants.defaultIcon)
                                    .font(.caption)
                                    .frame(width: 16)
                                    .foregroundStyle(.secondary)

                                Text(file.app)
                                    .font(.caption)

                                Spacer()

                                let count = file.categories.reduce(0) { $0 + $1.shortcuts.count }
                                Text("\(count)개")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }

            Divider()

            Text(AppConstants.userConfigDirectory.path)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .textSelection(.enabled)
        }
        .padding()
        .frame(width: 250)
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

        // Ensure the file exists
        if !fileManager.fileExists(atPath: configURL.path) {
            InitialSetup.copyDefaultConfigIfNeeded()
        }

        NSWorkspace.shared.open(configURL)
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
                NSWorkspace.shared.open(url)
            } catch {
                let errorAlert = NSAlert()
                errorAlert.messageText = "템플릿 생성 실패"
                errorAlert.informativeText = error.localizedDescription
                errorAlert.runModal()
            }
        }
    }
}
