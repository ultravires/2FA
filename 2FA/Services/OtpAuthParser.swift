import Foundation

enum OtpAuthParser {
    /// 解析 `otpauth://totp/...` / `otpauth://hotp/...` 字符串为 `Token`。
    static func token(from string: String) -> Token? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              url.scheme?.lowercased() == "otpauth",
              let host = url.host?.lowercased(),
              host == "totp" || host == "hotp" else {
            return nil
        }

        let path = url.path
        let pathWithoutSlash = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let labelPart = pathWithoutSlash.removingPercentEncoding ?? pathWithoutSlash

        var issuerFromLabel = ""
        var accountFromLabel = ""
        if let colon = labelPart.firstIndex(of: ":") {
            issuerFromLabel = String(labelPart[..<colon])
            accountFromLabel = String(labelPart[labelPart.index(after: colon)...])
        } else {
            accountFromLabel = labelPart
        }

        var secret = ""
        var issuer = issuerFromLabel
        var algorithm = "SHA1"
        var digits = 6
        var period = 30
        var counter: UInt64 = 0

        if let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in items {
                let name = item.name.lowercased()
                let value = item.value ?? ""
                switch name {
                case "secret":
                    secret = value
                case "issuer":
                    if !value.isEmpty { issuer = value }
                case "algorithm":
                    algorithm = value.uppercased()
                case "digits":
                    digits = Int(value) ?? 6
                case "period":
                    period = Int(value) ?? 30
                case "counter":
                    counter = UInt64(value) ?? 0
                default:
                    break
                }
            }
        }

        guard !secret.isEmpty else { return nil }

        return Token(
            issuer: issuer,
            account: accountFromLabel.isEmpty ? "Account" : accountFromLabel,
            secret: secret,
            type: host,
            algorithm: algorithm,
            digits: digits,
            period: period,
            counter: counter
        )
    }
}
