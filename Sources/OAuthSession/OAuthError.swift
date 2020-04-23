//
//  File.swift
//  
//
//  Created by Jacob Christie on 2020-02-20.
//

import Foundation

public enum OAuthError: Error {
    case invalidCredential
    case unknown
    case urlError(URLError)

    public var localizedDescription: String {
        errorDescription!
    }
}

extension OAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credentials"

        case .unknown:
            return "An unknown error occured"

        case .urlError:
            return "Unable to connect to authorization server"
        }
    }
}
