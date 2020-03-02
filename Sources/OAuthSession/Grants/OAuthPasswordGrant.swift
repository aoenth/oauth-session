/// <#Description#>
public struct OAuthPasswordGrant: OAuthGrant {
    /// <#Description#>
    public let username: String
    
    /// <#Description#>
    public let password: String
    
    /// <#Description#>
    public let scope: Set<OAuthScope>

    public var parameters: [String : String] {
        let scope = self.scope.reduce(into: self.scope.first?.rawValue) {
            $0?.append(", \($1.rawValue)")
        }

        return [
            "username" : username,
            "password" : password,
            "grant_type" : "password",
            "scope" : scope ?? ""
        ]
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - password: <#password description#>
    ///   - scope: <#scope description#>
    public init(username: String, password: String, scope: Set<OAuthScope>) {
        self.username = username
        self.password = password
        self.scope = scope
    }
}

