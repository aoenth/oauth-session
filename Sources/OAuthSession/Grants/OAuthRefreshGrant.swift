/// <#Description#>
public struct OAuthRefreshGrant: OAuthGrant {
    /// <#Description#>
    public let token: OAuthToken

    public var parameters: [String : String] {
        [
            "grant_type" : "refresh_token",
            "refresh_token" : token.value
        ]
    }

    /// <#Description#>
    /// - Parameter token: <#token description#>
    public init(token: OAuthToken) {
        self.token = token
    }
}
