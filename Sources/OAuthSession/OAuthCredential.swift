import Foundation

/// <#Description#>
public protocol OAuthCredentialProtocol: Equatable, Decodable {
    /// <#Description#>
    var access: OAuthToken { get }

    /// <#Description#>
    var refresh: OAuthToken { get }

    /// <#Description#>
    func toKeychainDictionary() -> [String : String]

    /// <#Description#>
    /// - Parameter keychainDictionary: <#keychainDictionary description#>
    init(keychainDictionary: [String : String])
}

extension OAuthCredentialProtocol {
    public func toKeychainDictionary() -> [String : String] {
        let expiryFormatter = ISO8601DateFormatter()

        return [
            "access" : access.value,
            "accessExpiry" : expiryFormatter.string(from: access.expiry),
            "refresh" : refresh.value,
            "refreshExpiry" : expiryFormatter.string(from: refresh.expiry)
        ]
    }
}

extension OAuthCredentialProtocol {
    /// <#Description#>
    public var isExpired: Bool {
        refresh.isExpired
    }
}

public struct OAuthCredential: OAuthCredentialProtocol {
    /// <#Description#>
    public let access: OAuthToken
    
    /// <#Description#>
    public let refresh: OAuthToken

    private enum DecodingKeys: String, CodingKey {
        case access = "access_token"
        case accessExpiry = "expires_in"
        case refresh = "refresh_token"
        case refreshExpiry = "refresh_expires_in"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKeys.self)
        let b = try container.decode(String.self, forKey: .access)
        let bExpiresIn = try container.decode(Double.self, forKey: .accessExpiry)
        access = OAuthToken(value: b, expiresIn: bExpiresIn)

        let r = try container.decode(String.self, forKey: .refresh)

        do {
            let rExpiresIn = try container
                .decode(Double.self, forKey: .refreshExpiry)
            refresh = OAuthToken(value: r, expiresIn: rExpiresIn)
        } catch let rError {
            // TODO: Remove when consolidating authentication
            do {
                let rExpiresIn = try container
                    .decodeIfPresent(Double.self, forKey: .refreshExpiry)
                refresh = OAuthToken(value: r, expiresIn: rExpiresIn)
            } catch {
                throw rError
            }
        }
    }

    init(access: OAuthToken, refresh: OAuthToken) {
        self.access = access
        self.refresh = refresh
    }

    public init(keychainDictionary dict: [String : String]) {
        let expiryFormatter = ISO8601DateFormatter()

        self.access = OAuthToken(
            value: dict["access"]!,
            expiry: expiryFormatter.date(from: dict["accessExpiry"]!)!
        )

        self.refresh = OAuthToken(
            value: dict["refresh"]!,
            expiry: expiryFormatter.date(from: dict["refreshExpiry"]!)!
        )
    }
}
