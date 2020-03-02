import Foundation
import URLEncodedForm

public enum OAuthError: Error {
    case invalidCredential
    case unknown
    case networkError(Error)
//    case urlError(URLError)
}

/// <#Description#>
public final class OAuthSession {
//    public typealias OAuthCompletion = (Result<Void, URLEr)

    /// The OAuth provider this session is managing credentials for
    public let provider: OAuthProvider

    /// The decoder used to decode tokens
    public var decoder = JSONDecoder()

    /// A boolean indicating the status of the session. If `false` the user will need to reauthenticate.
    public var isAuthenticated: Bool {
        credentialManager.currentCredential()?.isExpired == false
    }

    private let urlSession: URLSession

    /// <#Description#>
    public var additionalRequestHeaders: [String : String]?

    private lazy var credentialManager = CredentialManager(provider: provider)

    private var refreshListeners: [LoginCompletion] = []

    public init(provider: OAuthProvider, session: URLSession = .shared) {
        self.provider = provider
        self.urlSession = session
    }

    public convenience init(
        provider: OAuthProvider,
        configuration: URLSessionConfiguration
    ) {
        let session = URLSession(configuration: configuration)
        self.init(provider: provider, session: session)
    }
}

extension OAuthSession {
    public typealias LoginCompletion = (Result<OAuthCredential, OAuthError>) -> Void

    /// <#Description#>
    /// - Parameters:
    ///   - grant: <#grant description#>
    ///   - completion: <#completion description#>
    public func login(grant: OAuthGrant, completion: @escaping LoginCompletion) {
        var parameters = grant.parameters
        parameters["client_id"] = provider.clientID

        let request = makeTokenRequest(parameters: parameters)
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse else {
                return completion(.failure(.networkError(error!)))
            }

            guard response.statusCode == 200 else {
                if response.statusCode == 401 {
                    completion(.failure(.invalidCredential))
                } else {
                    completion(.failure(.unknown))
                }
                return
            }

            do {
                let credential = try self.decoder.decode(
                    OAuthCredential.self,
                    from: data
                )
                self.credentialManager.persist(credential: credential)
                completion(.success(credential))
            } catch {
                completion(.failure(.unknown))
            }
        }

        task.resume()
    }

    public func authenticateRequest(
        _ request: URLRequest,
        completion: @escaping (Result<URLRequest, OAuthError>) -> Void
    ) {
        guard let credential = credentialManager.currentCredential(),
            !credential.isExpired
            else {
                completion(.failure(.invalidCredential))
                return
        }

        // Refresh if access token is expired
        if credential.access.isExpired {
            return refreshCredential(credential) { (result) in
                switch result {
                case .success:
                    let authenticatedRequest = self.injectToken(
                        credential.access,
                        into: request
                    )
                    completion(.success(authenticatedRequest))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        let authenticatedRequest = injectToken(
            credential.access,
            into: request
        )
        completion(.success(authenticatedRequest))
    }

    public func refreshCredentials(completion: @escaping LoginCompletion) {
        guard let credential = credentialManager.currentCredential(),
            !credential.isExpired
            else {
                completion(.failure(.invalidCredential))
                return
        }

        refreshCredential(credential, completion: completion)
    }

    private func refreshCredential(
        _ credential: OAuthCredential,
        completion: @escaping LoginCompletion
    ) {
        guard !credential.isExpired else {
            completion(.failure(.invalidCredential))
            return
        }

        // Escape early. Completion will be called when refresh is complete
        guard refreshListeners.isEmpty else {
            refreshListeners.append(completion)
            return
        }
        refreshListeners.append(completion)

        let refresh = OAuthRefreshGrant(token: credential.refresh)
        login(grant: refresh) { (result) in
            self.refreshListeners.forEach { $0(result) }
            self.refreshListeners.removeAll(keepingCapacity: true)

            if case .failure = result {
                self.logout()
            }
        }
    }

    public func logout() {
        credentialManager.deleteAllItems()
        NotificationCenter.default.post(
            name: OAuthSession.sessionDidExpire,
            object: self
        )
    }
}

// MARK: Utility

extension OAuthSession {
    private func makeTokenRequest(parameters: [String : String]) -> URLRequest {
        let accessTokenURL = provider.accessTokenURL
        var request = URLRequest(url: accessTokenURL)
        request.httpMethod = "POST"

        let coder = URLEncodedFormEncoder()
        let data = try! coder.encode(parameters)
        request.httpBody = data
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        if let headers = additionalRequestHeaders {
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }

        return request
    }

    private func injectToken(
        _ token: OAuthToken,
        into request: URLRequest
    ) -> URLRequest {
        var request = request
        request.setValue(
            "Bearer \(token.value)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
}
