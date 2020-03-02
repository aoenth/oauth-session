import Foundation

/// <#Description#>
public struct OAuthProvider {
    /// <#Description#>
    public let clientID: String

    /// <#Description#>
    public let clientSecret: String?

    /// <#Description#>
    public let authorizeURL: URL?

    /// <#Description#>
    public let accessTokenURL: URL

    /// <#Description#>
    public let responseType: String?

    /// <#Description#>
    public let contentType: String

    /// <#Description#>
    /// - Parameters:
    ///   - clientID: <#clientID description#>
    ///   - clientSecret: <#clientSecret description#>
    ///   - authorizeURL: <#authorizeURL description#>
    ///   - accessTokenURL: <#accessTokenURL description#>
    ///   - responseType: <#responseType description#>
    ///   - contentType: <#contentType description#>
    public init(
        clientID: String,
        clientSecret: String?,
        authorizeURL: URL?,
        accessTokenURL: URL,
        responseType: String?,
        contentType: String
    ) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = authorizeURL
        self.accessTokenURL = accessTokenURL
        self.responseType = responseType
        self.contentType = contentType
    }
}
