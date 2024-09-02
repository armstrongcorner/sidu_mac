//
//  LoginService.swift
//  sidu
//
//  Created by Armstrong Liu on 30/08/2024.
//

import Foundation

protocol LoginServiceProtocol {
    func login(username: String, password: String) async throws -> AuthResponse?
}

class LoginService: LoginServiceProtocol {
    func login(username: String, password: String) async throws -> AuthResponse? {
        var request = URLRequest(url: Endpoint.login.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["username": username, "password": password])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data)
        return authResponse
    }
}
