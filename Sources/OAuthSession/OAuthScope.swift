/// <#Description#>
public struct OAuthScope: RawRepresentable, Equatable, Hashable {
    /// <#Description#>
    public let rawValue: String

    /// <#Description#>
    public static var openID: OAuthScope { Self(rawValue: "openid") }

    /// <#Description#>
    public static var offlineAccess: OAuthScope {
        OAuthScope(rawValue: "offline_access")
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
