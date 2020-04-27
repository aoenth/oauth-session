//
//  File.swift
//  
//
//  Created by Jacob Christie on 2020-02-20.
//

import Foundation

public struct OAuthError: Error {
    public let code: Code

    public let userInfo: [UserInfoKey : Any]
    public var localizedDescription: String {
        errorDescription!
    }

    init(code: Code, userInfo: [UserInfoKey : Any] = [:]) {
        self.code = code
        self.userInfo = userInfo
    }
}

extension OAuthError {
    public enum Code {
        case invalidCredential
        case credentialDecodeFailure
        case unknown
        case urlError
    }
}

extension OAuthError {
    public static func validUserInfoKeys(for code: Code) -> [UserInfoKey] {
        switch code {
        case .invalidCredential: return []
        case .unknown: return [.httpResonse]
        case .urlError: return [.urlError]
        case .credentialDecodeFailure:
            return [
                .rawCredential,
                .credentialDecodingError
            ]
        }
    }

    public enum UserInfoKey {
        case httpResonse
        case urlError
        case rawCredential
        case credentialDecodingError
    }
}

extension OAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self.code {
        case .invalidCredential:
            return "Invalid credentials"

        case .unknown:
            return "An unknown error occured"

        case .urlError:
            return "Unable to connect to authorization server"

        case .credentialDecodeFailure:
            return "Unable to decode returned credentials"
        }
    }
}

// Convenience API
extension OAuthError {
    static func urlError(_ error: URLError) -> Self {
        Self(code: .urlError, userInfo: [.urlError : error])
    }

    static var invalidCredential: Self {
        Self(code: .invalidCredential)
    }

    static func unknown(_ response: HTTPURLResponse) -> Self {
        Self(code: .unknown, userInfo: [.httpResonse : response])
    }

    static func credentialDecodeFailure(
        _ data: Data,
        error: DecodingError
    ) -> Self {
        Self(
            code: .credentialDecodeFailure,
            userInfo: [
                .rawCredential : data,
                .credentialDecodingError : error
            ]
        )
    }
}
