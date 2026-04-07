import Foundation

struct Token: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var issuer: String
    var account: String
    var secret: String // Base32 encoded secret
    var type: String = "totp"
    var algorithm: String = "SHA1"
    var digits: Int = 6
    var period: Int = 30
    var counter: UInt64 = 0
    
    init(id: UUID = UUID(), issuer: String, account: String, secret: String, type: String = "totp", algorithm: String = "SHA1", digits: Int = 6, period: Int = 30, counter: UInt64 = 0) {
        self.id = id
        self.issuer = issuer
        self.account = account
        self.secret = secret
        self.type = type
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
        self.counter = counter
    }
    
    var serviceName: String {
        return "2FA_Service"
    }
}
