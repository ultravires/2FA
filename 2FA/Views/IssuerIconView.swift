import SwiftUI

/// 根据 issuer 名称显示近似图标（无品牌资源时使用 SF Symbol + 圆形底）。
struct IssuerIconView: View {
    let issuer: String

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.opacity(0.22))
            Image(systemName: symbolName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(foregroundColor)
        }
        .frame(width: 44, height: 44)
    }

    private var key: String {
        issuer.lowercased()
    }

    private var symbolName: String {
        if key.contains("github") { return "chevron.left.forwardslash.chevron.right" }
        if key.contains("google") { return "globe" }
        if key.contains("nvidia") || key.contains("geforce") { return "cpu" }
        if key.contains("figma") { return "paintpalette.fill" }
        if key.contains("apple") || key.contains("icloud") { return "apple.logo" }
        if key.contains("microsoft") { return "square.grid.3x3.fill" }
        if key.contains("slack") { return "number" }
        return "key.fill"
    }

    private var foregroundColor: Color {
        if key.contains("github") { return Color.primary }
        if key.contains("google") { return Color.blue }
        if key.contains("figma") { return Color.purple }
        return Color.primary
    }

    private var backgroundColor: Color {
        if key.contains("github") { return Color.gray }
        if key.contains("google") { return Color.blue }
        if key.contains("nvidia") { return Color.green }
        if key.contains("figma") { return Color.purple }
        return Color.gray
    }
}
