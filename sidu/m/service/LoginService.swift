//
//  LoginService.swift
//  sidu
//
//  Created by Armstrong Liu on 30/08/2024.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

protocol LoginServiceProtocol: Sendable {
    func login(username: String, password: String) async throws -> AuthResponse
}

actor LoginService: LoginServiceProtocol, BaseServiceProtocol {
    func login(username: String, password: String) async throws -> AuthResponse {
        let loginRequest = LoginRequest(username: username, password: password)
        
        let authResponse = try await ApiClient().post(
            urlString: Endpoint.login.urlString,
            body: loginRequest,
            responseType: AuthResponse.self
        )
        
        guard let authResponse = authResponse else {
            throw ApiError.invalidResponse
        }
        
        guard let isSuccess = authResponse.isSuccess, isSuccess == true else {
            throw CommError.serverReturnedError(authResponse.failureReason ?? "")
        }
        
        return authResponse
    }
}
