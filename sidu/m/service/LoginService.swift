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
    func login(username: String, password: String) async throws -> AuthResponse?
}

actor LoginService: LoginServiceProtocol {
    func login(username: String, password: String) async throws -> AuthResponse? {
        let httpBody = try JSONEncoder().encode(LoginRequest(username: username, password: password))
        let authResponse = try await ApiClient.shared.post(url: Endpoint.login.url, body: httpBody, responseType: AuthResponse.self)
        
        return authResponse
    }
}
