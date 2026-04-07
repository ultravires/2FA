import AppKit
import SwiftUI

struct AddTokenView: View {
    @ObservedObject var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_language") private var appLanguage = "en"

    @State private var issuer: String = ""
    @State private var account: String = ""
    @State private var secret: String = ""
    @State private var type: String = "totp"
    @State private var algorithm: String = "SHA1"
    @State private var digits: Int = 6
    @State private var period: Int = 30

    var body: some View {
        VStack(spacing: 0) {
            titleHeader

            Divider()

            ScrollView {
                Form {
                    Section(L10n.Add.sectionToken) {
                        LabeledContent(L10n.Add.service) {
                            TextField("", text: $issuer, prompt: Text(L10n.Add.promptService))
                                .textFieldStyle(.roundedBorder)
                        }
                        LabeledContent(L10n.Add.account) {
                            TextField("", text: $account, prompt: Text(L10n.Add.promptAccount))
                                .textFieldStyle(.roundedBorder)
                        }
                        LabeledContent(L10n.Add.secret) {
                            TextField("", text: $secret, prompt: Text(L10n.Add.promptSecret))
                                .textFieldStyle(.roundedBorder)
                        }
                        Picker(L10n.Add.type, selection: $type) {
                            Text("TOTP").tag("totp")
                            Text("HOTP").tag("hotp")
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(L10n.Add.sectionAdvanced) {
                        Picker(L10n.Add.algorithm, selection: $algorithm) {
                            Text("SHA1").tag("SHA1")
                            Text("SHA256").tag("SHA256")
                            Text("SHA512").tag("SHA512")
                        }

                        if type == "totp" {
                            Picker(L10n.Add.digits, selection: $digits) {
                                Text("6").tag(6)
                                Text("8").tag(8)
                            }
                            Stepper(value: $period, in: 30...300, step: 30) {
                                Text(L10n.Add.period(period))
                            }
                        }
                    }
                }
                .formStyle(.grouped)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            footerActions
        }
        .frame(width: 460, height: 560)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private var titleHeader: some View {
        Text(L10n.Add.title)
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(nsColor: .windowBackgroundColor))
    }

    private var footerActions: some View {
        HStack(spacing: 12) {
            Button(L10n.Common.cancel) {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)

            Spacer()

            Button(L10n.Common.save) {
                saveToken()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
            .disabled(secret.isEmpty || account.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func saveToken() {
        let token = Token(
            issuer: issuer,
            account: account,
            secret: secret,
            type: type,
            algorithm: algorithm,
            digits: digits,
            period: period
        )
        tokenStore.addToken(token)
        dismiss()
    }
}
