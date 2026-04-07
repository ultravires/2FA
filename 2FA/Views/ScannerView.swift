import AppKit
import SwiftUI

struct ScannerView: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var toastManager: ToastManager
    @StateObject private var screenScanner = ScreenQRScanner()
    @AppStorage("app_language") private var appLanguage = "en"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(L10n.Scanner.title)
                    .font(.headline)
                Spacer()
                Button(L10n.Common.close) { closeScannerWindow() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            ZStack {
                Color.clear

                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.green.opacity(0.9), lineWidth: 2)
                    .frame(width: 240, height: 240)
                    .shadow(color: .green.opacity(0.35), radius: 6)

                VStack(spacing: 16) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 56))
                        .foregroundColor(.primary.opacity(0.85))

                    Text(L10n.Scanner.hint)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button(action: { screenScanner.scanOnce() }) {
                        Label(L10n.Scanner.scanButton, systemImage: "viewfinder")
                            .frame(maxWidth: 240)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(screenScanner.isScanning)
                    .keyboardShortcut(.return, modifiers: .command)

                    if let err = screenScanner.lastError {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Text(screenScanner.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 380, minHeight: 480)
        .background(FloatingScannerWindowConfigurator())
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            screenScanner.statusText = L10n.Scanner.hintShortcut
            screenScanner.onOtpAuthPayload = { payload in
                guard let token = OtpAuthParser.token(from: payload) else {
                    screenScanner.lastError = L10n.Scanner.parseError
                    return
                }
                tokenStore.addToken(token)
                let name = token.issuer.isEmpty ? token.account : token.issuer
                toastManager.show(L10n.Scanner.added(name))
                closeScannerWindow()
                NSApp.activate(ignoringOtherApps: true)
                DispatchQueue.main.async {
                    NSApp.windows.first { $0.title == "2FA" && $0.isVisible }?.makeKeyAndOrderFront(nil)
                }
            }
        }
    }

    private func closeScannerWindow() {
        let scannerTitle = L10n.Scanner.windowTitle
        if let w = NSApp.windows.first(where: { $0.title == scannerTitle }) {
            w.close()
        } else {
            NSApp.keyWindow?.close()
        }
    }
}
