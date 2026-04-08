import AppKit
import CoreImage
import SwiftUI

struct QRCodeView: View {
    let string: String
    let size: CGFloat

    var body: some View {
        if let image = generateQRCode(from: string) {
            Image(nsImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: size, height: size)
        }
    }

    func generateQRCode(from string: String) -> NSImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return NSImage(cgImage: cgImage, size: CGSize(width: size, height: size))
                }
            }
        }
        return nil
    }
}

struct TransferView: View {
    let tokens: [Token]
    @Environment(\.dismiss) private var dismiss
    @State private var pageIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(L10n.Transfer.title)
                    .font(.headline)
                Spacer()
                Button(L10n.Common.done) { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            if tokens.isEmpty {
                Spacer()
                Text(L10n.Main.emptyTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                VStack(spacing: 0) {
                    Text(L10n.Transfer.hint)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    ZStack {
                        tokenPage(for: tokens[pageIndex])
                            .id(pageIndex)
                            .transition(.opacity)
                    }
                    .animation(.easeInOut(duration: 0.2), value: pageIndex)
                    .frame(height: 360)

                    if tokens.count > 1 {
                        HStack(spacing: 7) {
                            ForEach(0..<tokens.count, id: \.self) { i in
                                Button {
                                    pageIndex = i
                                } label: {
                                    Circle()
                                        .fill(i == pageIndex ? Color.accentColor : Color.secondary.opacity(0.35))
                                        .frame(width: 7, height: 7)
                                }
                                .buttonStyle(.plain)
                                .help(L10n.Transfer.pageIndex(i + 1, tokens.count))
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    HStack(spacing: 20) {
                        Button {
                            pageIndex = max(0, pageIndex - 1)
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.borderless)
                        .disabled(pageIndex == 0)
                        .help(L10n.Transfer.previous)
                        .keyboardShortcut(.leftArrow, modifiers: [])

                        Text(L10n.Transfer.pageIndex(pageIndex + 1, tokens.count))
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(minWidth: 120)

                        Button {
                            pageIndex = min(tokens.count - 1, pageIndex + 1)
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.borderless)
                        .disabled(pageIndex >= tokens.count - 1)
                        .help(L10n.Transfer.next)
                        .keyboardShortcut(.rightArrow, modifiers: [])
                    }
                    .padding(.vertical, 14)
                }
            }
        }
        .frame(width: 400, height: 540)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            if pageIndex >= tokens.count {
                pageIndex = max(0, tokens.count - 1)
            }
        }
    }

    @ViewBuilder
    private func tokenPage(for token: Token) -> some View {
        VStack(spacing: 12) {
            Text(token.issuer)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(token.account)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            QRCodeView(string: generateOtpAuthUrl(for: token), size: 220)
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func generateOtpAuthUrl(for token: Token) -> String {
        let type = token.type.lowercased()
        let label = "\(token.issuer):\(token.account)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        var url = "otpauth://\(type)/\(label)?secret=\(token.secret)&issuer=\(token.issuer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if token.algorithm != "SHA1" {
            url += "&algorithm=\(token.algorithm)"
        }
        if token.digits != 6 {
            url += "&digits=\(token.digits)"
        }
        if type == "totp" && token.period != 30 {
            url += "&period=\(token.period)"
        } else if type == "hotp" {
            url += "&counter=\(token.counter)"
        }

        return url
    }
}
