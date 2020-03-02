import Foundation

/// <#Description#>
public struct OAuthToken: Equatable, Codable {
    /// <#Description#>
    public let value: String
    
    /// <#Description#>
    public let expiry: Date
    
    /// <#Description#>
    public var isExpired: Bool {
        return expiry < Date()
    }

    init(value: String, expiry: Date?) {
        self.value = value
        self.expiry = expiry ?? .distantFuture
    }

    init(value: String, expiresIn: TimeInterval?) {
        let expiresAt = expiresIn.map(Date.init(timeIntervalSinceNow:))
        self.init(value: value, expiry: expiresAt)
    }
}
