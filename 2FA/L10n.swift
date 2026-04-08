import Foundation

/// 与 `UserDefaults` 键 `app_language`（`en` / `zh-Hans` / `zh-Hant`）保持一致。
enum L10n {
    private static let storageKey = "app_language"

    private static var lang: String {
        UserDefaults.standard.string(forKey: storageKey) ?? "en"
    }

    private static let table: [String: [String: String]] = [
        "en": en,
        "zh-Hans": zhHans,
        "zh-Hant": zhHant,
    ]

    private static func template(_ key: String) -> String {
        table[lang]?[key] ?? table["en"]?[key] ?? key
    }

    /// 无格式占位符的文案。
    static func text(_ key: String) -> String {
        template(key)
    }

    /// 带 `String(format:)` 的文案（`%@` / `%d` 等）。
    static func formatted(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: template(key), arguments: Array(arguments))
    }

    // MARK: - Namespaces（便于调用处阅读）

    enum Main {
        static var searchPlaceholder: String { text("main.search_placeholder") }
        static var noMatch: String { text("main.no_match") }
        static var emptyTitle: String { text("main.empty_title") }
        static var emptySubtitle: String { text("main.empty_subtitle") }
        static var menuScan: String { text("main.menu_scan") }
        static var menuManual: String { text("main.menu_manual") }
        static var helpTapCopy: String { text("main.help_tap_copy") }
    }

    enum Common {
        static var cancel: String { text("common.cancel") }
        static var save: String { text("common.save") }
        static var done: String { text("common.done") }
        static var close: String { text("common.close") }
        static var delete: String { text("common.delete") }
        static var unknown: String { text("common.unknown") }
        static var copy: String { text("common.copy") }
    }

    enum Toast {
        static var copied: String { text("toast.copied") }
    }

    enum Settings {
        static var title: String { text("settings.title") }
        static var display: String { text("settings.display") }
        static var showNext: String { text("settings.show_next") }
        static var theme: String { text("settings.theme") }
        static var themeSystem: String { text("settings.theme_system") }
        static var themeLight: String { text("settings.theme_light") }
        static var themeDark: String { text("settings.theme_dark") }
        static var language: String { text("settings.language") }
        static var appLanguage: String { text("settings.app_language") }
        static var about: String { text("settings.about") }
        static var version: String { text("settings.version") }
        static var backup: String { text("settings.backup") }
        static var restore: String { text("settings.restore") }
        static var transfer: String { text("settings.transfer") }
    }

    enum Add {
        static var title: String { text("add.title") }
        static var sectionToken: String { text("add.section_token") }
        static var sectionAdvanced: String { text("add.section_advanced") }
        static var service: String { text("add.service") }
        static var account: String { text("add.account") }
        static var secret: String { text("add.secret") }
        static var promptService: String { text("add.prompt_service") }
        static var promptAccount: String { text("add.prompt_account") }
        static var promptSecret: String { text("add.prompt_secret") }
        static var type: String { text("add.type") }
        static var algorithm: String { text("add.algorithm") }
        static var digits: String { text("add.digits") }
        static func period(_ seconds: Int) -> String {
            formatted("add.period", seconds)
        }
    }

    enum Scanner {
        static var windowTitle: String { text("scanner.window_title") }
        static var title: String { text("scanner.title") }
        static var hint: String { text("scanner.hint") }
        static var scanButton: String { text("scanner.scan_button") }
        static var hintShortcut: String { text("scanner.hint_shortcut") }
        static var parseError: String { text("scanner.parse_error") }
        static func added(_ name: String) -> String {
            formatted("scanner.added_format", name)
        }
    }

    enum ScannerStatus {
        static var scanning: String { text("scanner_status.scanning") }
        static var screenDenied: String { text("scanner_status.screen_denied") }
        static var needPermission: String { text("scanner_status.need_permission") }
        static var failed: String { text("scanner_status.failed") }
        static var noQr: String { text("scanner_status.no_qr") }
        static var recognized: String { text("scanner_status.recognized") }
    }

    enum Transfer {
        static var title: String { text("transfer.title") }
        static var hint: String { text("transfer.hint") }
        static var previous: String { text("transfer.previous") }
        static var next: String { text("transfer.next") }
        static func pageIndex(_ current: Int, _ total: Int) -> String {
            formatted("transfer.page_index", current, total)
        }
    }

    // MARK: - en

    private static let en: [String: String] = [
        "main.search_placeholder": "Search tokens",
        "main.no_match": "No matching tokens",
        "main.empty_title": "No Tokens",
        "main.empty_subtitle": "Use the + menu to scan or add manually.",
        "main.menu_scan": "Scan QR Code",
        "main.menu_manual": "Enter Manually",
        "main.help_tap_copy": "Click to copy verification code",
        "common.cancel": "Cancel",
        "common.save": "Save",
        "common.done": "Done",
        "common.close": "Close",
        "common.delete": "Delete",
        "common.unknown": "Unknown",
        "common.copy": "Copy",
        "toast.copied": "Copied",
        "settings.title": "Settings",
        "settings.display": "Display",
        "settings.show_next": "Show Next Token",
        "settings.theme": "Theme",
        "settings.theme_system": "System",
        "settings.theme_light": "Light",
        "settings.theme_dark": "Dark",
        "settings.language": "Language",
        "settings.app_language": "App Language",
        "settings.about": "About",
        "settings.version": "Version",
        "settings.backup": "Backup Tokens",
        "settings.restore": "Restore Tokens",
        "settings.transfer": "Transfer Tokens (via QR)",
        "add.title": "Add Token Manually",
        "add.section_token": "Token",
        "add.section_advanced": "Advanced",
        "add.service": "Service",
        "add.account": "Account",
        "add.secret": "Secret",
        "add.prompt_service": "e.g. GitHub",
        "add.prompt_account": "Email or username",
        "add.prompt_secret": "Base32 secret key",
        "add.type": "Type",
        "add.algorithm": "Algorithm",
        "add.digits": "Digits",
        "add.period": "Period: %d s",
        "scanner.window_title": "Scan QR Code",
        "scanner.title": "Scan QR Code",
        "scanner.hint": "Keep the QR code fully visible on screen (not covered by this window), then tap the button or use the shortcut to scan.",
        "scanner.scan_button": "Scan Screen",
        "scanner.hint_shortcut": "Use “Scan Screen” or ⌘↩",
        "scanner.parse_error": "Could not parse otpauth link",
        "scanner.added_format": "Added: %@",
        "scanner_status.scanning": "Scanning…",
        "scanner_status.screen_denied": "Cannot capture screen. Allow this app in System Settings › Privacy & Security › Screen Recording.",
        "scanner_status.need_permission": "Screen Recording permission required",
        "scanner_status.failed": "Scan failed",
        "scanner_status.no_qr": "No otpauth QR found on screen. Adjust and try again.",
        "scanner_status.recognized": "Recognized otpauth, adding…",
        "transfer.title": "Transfer Tokens",
        "transfer.hint": "Swipe or use the buttons to show one QR code at a time. Scan on another device to transfer.",
        "transfer.previous": "Previous",
        "transfer.next": "Next",
        "transfer.page_index": "%d of %d",
    ]

    private static let zhHans: [String: String] = [
        "main.search_placeholder": "搜索令牌",
        "main.no_match": "无匹配令牌",
        "main.empty_title": "暂无令牌",
        "main.empty_subtitle": "点击右上角 + 扫码或手动添加",
        "main.menu_scan": "扫描二维码",
        "main.menu_manual": "手动输入",
        "main.help_tap_copy": "点击复制验证码",
        "common.cancel": "取消",
        "common.save": "保存",
        "common.done": "完成",
        "common.close": "关闭",
        "common.delete": "删除",
        "common.unknown": "未知",
        "common.copy": "复制",
        "toast.copied": "已复制",
        "settings.title": "设置",
        "settings.display": "显示",
        "settings.show_next": "显示下一个令牌",
        "settings.theme": "主题",
        "settings.theme_system": "跟随系统",
        "settings.theme_light": "浅色",
        "settings.theme_dark": "深色",
        "settings.language": "语言",
        "settings.app_language": "应用语言",
        "settings.about": "关于",
        "settings.version": "版本",
        "settings.backup": "备份令牌",
        "settings.restore": "恢复令牌",
        "settings.transfer": "通过二维码转移令牌",
        "add.title": "手动添加令牌",
        "add.section_token": "令牌信息",
        "add.section_advanced": "高级",
        "add.service": "服务",
        "add.account": "账号",
        "add.secret": "密钥",
        "add.prompt_service": "例如 GitHub",
        "add.prompt_account": "邮箱或用户名",
        "add.prompt_secret": "Base32 密钥",
        "add.type": "类型",
        "add.algorithm": "算法",
        "add.digits": "位数",
        "add.period": "周期：%d 秒",
        "scanner.window_title": "扫描二维码",
        "scanner.title": "扫描二维码",
        "scanner.hint": "将二维码完整显示在屏幕上（勿被本窗口遮挡），然后点击下方按钮或使用快捷键扫描。",
        "scanner.scan_button": "扫描当前屏幕",
        "scanner.hint_shortcut": "点击「扫描当前屏幕」或按 ⌘↩",
        "scanner.parse_error": "无法解析 otpauth 链接",
        "scanner.added_format": "已添加：%@",
        "scanner_status.scanning": "正在扫描…",
        "scanner_status.screen_denied": "无法截取屏幕。请在「系统设置 › 隐私与安全性 › 屏幕录制」中允许本应用。",
        "scanner_status.need_permission": "需要屏幕录制权限",
        "scanner_status.failed": "扫描失败",
        "scanner_status.no_qr": "未在屏幕中找到 otpauth 二维码，请调整后再次扫描",
        "scanner_status.recognized": "已识别 otpauth，正在添加…",
        "transfer.title": "转移令牌",
        "transfer.hint": "可滑动或使用按钮逐页查看二维码，在另一台设备上扫描以转移账户。",
        "transfer.previous": "上一页",
        "transfer.next": "下一页",
        "transfer.page_index": "第 %d / %d 个",
    ]

    private static let zhHant: [String: String] = [
        "main.search_placeholder": "搜尋令牌",
        "main.no_match": "沒有符合的令牌",
        "main.empty_title": "尚無令牌",
        "main.empty_subtitle": "點右上角 + 掃碼或手動新增",
        "main.menu_scan": "掃描 QR 碼",
        "main.menu_manual": "手動輸入",
        "main.help_tap_copy": "點擊複製驗證碼",
        "common.cancel": "取消",
        "common.save": "儲存",
        "common.done": "完成",
        "common.close": "關閉",
        "common.delete": "刪除",
        "common.unknown": "未知",
        "common.copy": "複製",
        "toast.copied": "已複製",
        "settings.title": "設定",
        "settings.display": "顯示",
        "settings.show_next": "顯示下一個令牌",
        "settings.theme": "主題",
        "settings.theme_system": "跟隨系統",
        "settings.theme_light": "淺色",
        "settings.theme_dark": "深色",
        "settings.language": "語言",
        "settings.app_language": "應用程式語言",
        "settings.about": "關於",
        "settings.version": "版本",
        "settings.backup": "備份令牌",
        "settings.restore": "還原令牌",
        "settings.transfer": "透過 QR 碼轉移令牌",
        "add.title": "手動新增令牌",
        "add.section_token": "令牌資訊",
        "add.section_advanced": "進階",
        "add.service": "服務",
        "add.account": "帳號",
        "add.secret": "密鑰",
        "add.prompt_service": "例如 GitHub",
        "add.prompt_account": "電子郵件或使用者名稱",
        "add.prompt_secret": "Base32 密鑰",
        "add.type": "類型",
        "add.algorithm": "演算法",
        "add.digits": "位數",
        "add.period": "週期：%d 秒",
        "scanner.window_title": "掃描 QR 碼",
        "scanner.title": "掃描 QR 碼",
        "scanner.hint": "請將 QR 碼完整顯示在螢幕上（勿被本視窗遮擋），然後點下方按鈕或使用快捷鍵掃描。",
        "scanner.scan_button": "掃描目前螢幕",
        "scanner.hint_shortcut": "點「掃描目前螢幕」或按 ⌘↩",
        "scanner.parse_error": "無法解析 otpauth 連結",
        "scanner.added_format": "已新增：%@",
        "scanner_status.scanning": "正在掃描…",
        "scanner_status.screen_denied": "無法截取螢幕。請在「系統設定 › 隱私權與安全性 › 螢幕錄製」中允許本 App。",
        "scanner_status.need_permission": "需要螢幕錄製權限",
        "scanner_status.failed": "掃描失敗",
        "scanner_status.no_qr": "螢幕上找不到 otpauth QR 碼，請調整後再試",
        "scanner_status.recognized": "已辨識 otpauth，正在加入…",
        "transfer.title": "轉移令牌",
        "transfer.hint": "可滑動或使用按鈕逐頁檢視 QR 碼，在另一台裝置上掃描以轉移帳戶。",
        "transfer.previous": "上一頁",
        "transfer.next": "下一頁",
        "transfer.page_index": "第 %d / %d 個",
    ]
}
