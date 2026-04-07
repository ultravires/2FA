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
    @AppStorage("app_language") private var appLanguage = "en"

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

            ScrollView {
                VStack(spacing: 30) {
                    Text(L10n.Transfer.hint)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()

                    ForEach(tokens) { token in
                        VStack(spacing: 10) {
                            Text(token.issuer)
                                .font(.headline)
                            Text(token.account)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            QRCodeView(string: generateOtpAuthUrl(for: token), size: 200)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding()
                        .background(Color(nsColor: .windowBackgroundColor))
                        .cornerRadius(15)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 700)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
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
