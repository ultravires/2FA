import AppKit
import SwiftUI

struct TokenRow: View {
    let token: Token
    let remainingTime: Int
    let progress: Double
    let showNext: Bool

    let otp: String
    let nextOtp: String?

    var onDelete: () -> Void

    @State private var showCopiedToast = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            IssuerIconView(issuer: token.issuer.isEmpty ? token.account : token.issuer)

            // 中栏：上为「服务名 (账号)」一行，下为令牌
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(token.issuer.isEmpty ? L10n.Common.unknown : token.issuer)
                        .font(.body.weight(.semibold))
                    Text("(\(token.account))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.75)

                HStack(spacing: 6) {
                    Text(formatOTP(otp))
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)

                    if showNext, let next = nextOtp {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.blue)
                        Text(formatOTP(next))
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .opacity(0.12)
                    .foregroundStyle(.blue)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .foregroundStyle(remainingTime < 5 ? Color.red : Color.blue)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: progress)
                Text("\(remainingTime)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 38, height: 38)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .help(L10n.Main.helpTapCopy)
        .onTapGesture {
            copyOTPToPasteboard()
        }
        .overlay {
            if showCopiedToast {
                Text(L10n.Toast.copied)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: showCopiedToast)
        .contextMenu {
            Button(L10n.Common.copy, systemImage: "doc.on.doc") {
                copyOTPToPasteboard()
            }
            Button(L10n.Common.delete, systemImage: "trash", role: .destructive) {
                onDelete()
            }
        }
    }

    private func copyOTPToPasteboard() {
        let digits = String(otp.filter(\.isNumber))
        guard !digits.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(digits, forType: .string)
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showCopiedToast = false
        }
    }

    private func formatOTP(_ otp: String) -> String {
        var formatted = otp
        if formatted.count == 6 {
            formatted.insert(" ", at: formatted.index(formatted.startIndex, offsetBy: 3))
        } else if formatted.count == 8 {
            formatted.insert(" ", at: formatted.index(formatted.startIndex, offsetBy: 4))
        }
        return formatted
    }
}
