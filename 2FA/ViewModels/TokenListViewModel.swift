import Foundation
import Combine
import SwiftUI
import SwiftOTP

class TokenListViewModel: ObservableObject {
    @Published var tokens: [Token] = []
    @Published var currentSeconds: Int = 0

    private var timer: AnyCancellable?
    public let tokenStore: TokenStore

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore

        tokenStore.$tokens
            .assign(to: &$tokens)

        startTimer()
    }

    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                let now = Date()
                let seconds = Int(now.timeIntervalSince1970)
                self?.currentSeconds = seconds
            }
    }

    func timeRemaining(for token: Token) -> Int {
        let now = Date()
        let seconds = Int(now.timeIntervalSince1970)
        return token.period - (seconds % token.period)
    }

    func progress(for token: Token) -> Double {
        return Double(timeRemaining(for: token)) / Double(token.period)
    }

    func getOTP(for token: Token, at date: Date = Date()) -> String {
        guard let secretData = token.secret.base32DecodedData else {
            return "ERR"
        }

        let algorithm: OTPAlgorithm
        switch token.algorithm {
        case "SHA256": algorithm = .sha256
        case "SHA512": algorithm = .sha512
        default: algorithm = .sha1
        }

        if token.type == "totp" {
            if let totp = TOTP(secret: secretData, digits: token.digits, timeInterval: token.period, algorithm: algorithm) {
                return totp.generate(time: date) ?? "------"
            }
        } else {
            // HOTP
            if let hotp = HOTP(secret: secretData, digits: token.digits, algorithm: algorithm) {
                return hotp.generate(counter: token.counter) ?? "------"
            }
        }

        return "------"
    }

    func getNextOTP(for token: Token) -> String {
        let nextDate = Date().addingTimeInterval(Double(token.period))
        return getOTP(for: token, at: nextDate)
    }
}
