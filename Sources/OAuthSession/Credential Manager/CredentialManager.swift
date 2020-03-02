import Foundation

struct CredentialManager {

    let items: [String : KeychainPasswordItem]

    init(provider: OAuthProvider) {
        items = [
            "access" : KeychainPasswordItem(
                service: provider.accessTokenURL.absoluteString,
                account: "access"
            ),
            "accessExpiry" : KeychainPasswordItem(
                service: provider.accessTokenURL.absoluteString,
                account: "accessExpiry"
            ),
            "refresh" : KeychainPasswordItem(
                service: provider.accessTokenURL.absoluteString,
                account: "refresh"
            ),
            "refreshExpiry" : KeychainPasswordItem(
                service: provider.accessTokenURL.absoluteString,
                account: "refreshExpiry"
            )
        ]
    }

    func currentCredential() -> OAuthCredential? {
        do {
            let dict = try items.mapValues { try $0.readPassword() }
            return OAuthCredential(keychainDictionary: dict)
        } catch {
            return nil
        }
    }
    
    func persist<Credential: OAuthCredentialProtocol>(credential: Credential) {
        credential.toKeychainDictionary().forEach {
            try! items[$0]?.savePassword($1)
        }
    }

    func deleteAllItems() {
        items.forEach { try! $1.deleteItem() }
    }
}
