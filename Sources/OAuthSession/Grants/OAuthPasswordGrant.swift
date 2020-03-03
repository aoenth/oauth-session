/// <#Description#>
public struct OAuthPasswordGrant: OAuthGrant {
    /// <#Description#>
    public let username: String
    
    /// <#Description#>
    public let password: String
    
    /// <#Description#>
    public let scope: Set<OAuthScope>

    public let audience: String?

    public var parameters: [String : String] {
        let scope = self.scope.reduce(into: self.scope.first?.rawValue) {
            $0?.append(", \($1.rawValue)")
        }

        return {
            var dict = [
                "username" : username,
                "password" : password,
                "grant_type" : "password",
            ]
            
            if let scope = scope {
                dict["scope"] = scope
            }

            if let audience = audience {
                dict["audience"] = audience
            }

            return dict
        }()
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - username: <#username description#>
    ///   - password: <#password description#>
    ///   - scope: <#scope description#>
    ///   - audience: <#audience description#>
    public init(
        username: String,
        password: String,
        scope: Set<OAuthScope>,
        audience: String? = nil
    ) {
        self.username = username
        self.password = password
        self.scope = scope
        self.audience = audience
    }
}

