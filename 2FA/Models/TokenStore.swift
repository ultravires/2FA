import Foundation
import Combine

class TokenStore: ObservableObject {
    @Published var tokens: [Token] = []
    private let tokensKey = "saved_tokens"
    
    init() {
        loadTokens()
    }
    
    func addToken(_ token: Token) {
        tokens.append(token)
        saveTokens()
        // Save secret to Keychain
        if let data = token.secret.data(using: .utf8) {
            KeychainHelper.shared.save(data, service: token.serviceName, account: token.id.uuidString)
        }
    }
    
    func deleteToken(at offsets: IndexSet) {
        offsets.forEach { index in
            let token = tokens[index]
            KeychainHelper.shared.delete(service: token.serviceName, account: token.id.uuidString)
        }
        tokens.remove(atOffsets: offsets)
        saveTokens()
    }

    func deleteToken(id: UUID) {
        guard let index = tokens.firstIndex(where: { $0.id == id }) else { return }
        deleteToken(at: IndexSet(integer: index))
    }
    
    func loadTokens() {
        if let data = UserDefaults.standard.data(forKey: tokensKey),
           let decoded = try? JSONDecoder().decode([Token].self, from: data) {
            self.tokens = decoded
            // Secrets are in Keychain, but for this simplified version, let's assume we read from metadata for now
            // or we've stored secrets in the Token struct itself if we want them to be portable.
            // If we're strictly secure, we should read secrets from Keychain here if they aren't in the struct.
        }
    }
    
    func saveTokens() {
        if let encoded = try? JSONEncoder().encode(tokens) {
            UserDefaults.standard.set(encoded, forKey: tokensKey)
        }
    }
    
    // Backup and Restore
    func exportTokens() -> Data? {
        // In a real app, we should probably encrypt this.
        return try? JSONEncoder().encode(tokens)
    }
    
    func importTokens(from data: Data) -> Bool {
        if let decoded = try? JSONDecoder().decode([Token].self, from: data) {
            // Merge or replace
            for token in decoded {
                if !tokens.contains(where: { $0.id == token.id }) {
                    addToken(token)
                }
            }
            return true
        }
        return false
    }
}
