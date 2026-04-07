import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var tokenStore: TokenStore
    @AppStorage("app_theme") private var appTheme: String = "System"
    @AppStorage("app_language") private var appLanguage: String = "en"
    @AppStorage("show_next_token") private var showNextToken: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var showingFileImporter = false
    @State private var showingTransferView = false

    var body: some View {
        VStack(spacing: 0) {
            Text(L10n.Settings.title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

            Divider()

            Form {
                Section(L10n.Settings.display) {
                    Toggle(L10n.Settings.showNext, isOn: $showNextToken)

                    Picker(L10n.Settings.theme, selection: $appTheme) {
                        Text(L10n.Settings.themeSystem).tag("System")
                        Text(L10n.Settings.themeLight).tag("Light")
                        Text(L10n.Settings.themeDark).tag("Dark")
                    }
                }

                Section(L10n.Settings.language) {
                    Picker(L10n.Settings.appLanguage, selection: $appLanguage) {
                        Text("English").tag("en")
                        Text("简体中文").tag("zh-Hans")
                        Text("繁體中文").tag("zh-Hant")
                    }
                }

                Section(L10n.Settings.about) {
                    HStack {
                        Text(L10n.Settings.version)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            VStack(spacing: 10) {
                Button(action: exportData) {
                    Label(L10n.Settings.backup, systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Button(action: { showingFileImporter = true }) {
                    Label(L10n.Settings.restore, systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Button(action: { showingTransferView = true }) {
                    Label(L10n.Settings.transfer, systemImage: "qrcode")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)

                Button(L10n.Common.done) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 500, height: 650)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    if url.startAccessingSecurityScopedResource() {
                        if let data = try? Data(contentsOf: url) {
                            let _ = tokenStore.importTokens(from: data)
                        }
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showingTransferView) {
            TransferView(tokens: tokenStore.tokens)
        }
    }

    private func exportData() {
        if let data = tokenStore.exportTokens() {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("2FA_Backup.json")
            try? data.write(to: tempURL)

            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.json]
            savePanel.nameFieldStringValue = "2FA_Backup.json"
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    try? data.write(to: url)
                }
            }
        }
    }
}
