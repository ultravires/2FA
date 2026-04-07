import AppKit
import SwiftUI

@main
struct _FAApp: App {
    @StateObject private var tokenStore = TokenStore()
    @AppStorage("app_theme") private var appTheme: String = "System"
    @AppStorage("app_language") private var appLanguage: String = "en"

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: TokenListViewModel(tokenStore: tokenStore))
                .environmentObject(tokenStore)
                .preferredColorScheme(colorScheme)
                .environment(\.locale, .init(identifier: appLanguage))
                .frame(minWidth: 600, minHeight: 400)
                .onAppear {
                    // NSApp 在 App.init 时尚未就绪，此处再设置激活策略与前台
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
        }

        Window(L10n.Scanner.windowTitle, id: "scanner") {
            ScannerView()
                .environmentObject(tokenStore)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
}
