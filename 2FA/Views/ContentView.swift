import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: TokenListViewModel
    @State private var showingAddToken = false
    @State private var showingSettings = false
    @State private var searchText = ""
    @Environment(\.openWindow) private var openWindow
    @AppStorage("show_next_token") private var showNextToken = false
    /// 随语言变化刷新界面；勿在根视图用 `.id(appLanguage)`，否则会关掉已打开的 Sheet。
    @AppStorage("app_language") private var appLanguage = "en"

    private var filteredTokens: [Token] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return viewModel.tokens }
        return viewModel.tokens.filter { t in
            t.issuer.lowercased().contains(q) || t.account.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                ScrollView {
                    LazyVStack(spacing: 0) {
                        if viewModel.tokens.isEmpty {
                            emptyState
                                .padding(.top, 24)
                        } else if filteredTokens.isEmpty {
                            Text(L10n.Main.noMatch)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else {
                            ForEach(Array(filteredTokens.enumerated()), id: \.element.id) { index, token in
                                TokenRow(
                                    token: token,
                                    remainingTime: viewModel.timeRemaining(for: token),
                                    progress: viewModel.progress(for: token),
                                    showNext: showNextToken,
                                    otp: viewModel.getOTP(for: token),
                                    nextOtp: showNextToken ? viewModel.getNextOTP(for: token) : nil,
                                    onDelete: {
                                        viewModel.tokenStore.deleteToken(id: token.id)
                                    }
                                )
                                if index < filteredTokens.count - 1 {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("2FA")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { openWindow(id: "scanner") }) {
                            Label(L10n.Main.menuScan, systemImage: "qrcode.viewfinder")
                        }
                        Button(action: { showingAddToken = true }) {
                            Label(L10n.Main.menuManual, systemImage: "keyboard")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddToken) {
                AddTokenView(tokenStore: viewModel.tokenStore)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(tokenStore: viewModel.tokenStore)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(L10n.Main.searchPlaceholder, text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text(L10n.Main.emptyTitle)
                .font(.title2.weight(.semibold))
            Text(L10n.Main.emptySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}
