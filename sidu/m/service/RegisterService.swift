//
//  RegisterService.swift
//  sidu
//
//  Created by Armstrong Liu on 17/09/2024.
//

import Foundation

struct VerificationEmailRequest: Codable {
    let username: String
    let role: String
    let mobile: String
    let email: String
    let language: String
    let tokenDurationInMin: Int
    let isActive: Bool
}

struct CompleteRegistrationRequest: Codable {
    let username: String
    let password: String
    let activateUser: Bool
}

protocol RegisterServiceProtocol {
    func requestVerificationEmail(email: String) async throws -> AuthResponse?
    func goVerifyRegistration(vericode: String) async throws -> UserInfoResponse?
    func completeRegistration(username: String, password: String) async throws -> AuthResponse?
}

class RegisterService: RegisterServiceProtocol {
    func requestVerificationEmail(email: String) async throws -> AuthResponse? {
        let httpBody = try JSONEncoder().encode(VerificationEmailRequest(
            username: email,
            role: "User",
            mobile: "",
            email: email,
            language: "Chinese",
            tokenDurationInMin: USER_DEFAULT_TOKEN_DURATION_IN_MIN,
            isActive: false
        ))
        // Use the temp token to send verification email
        var newHeaders = [:] as [String: String]
        if let tmpToken = await CacheUtil.shared.getRegisterAuthInfo()?.token {
            newHeaders["Authorization"] = "Bearer \(tmpToken)"
        }
        
        let requestVerificationResponse = try await ApiClient.shared.post(
            url: Endpoint.sendVerificationEmail.url,
            headers: newHeaders,
            body: httpBody,
            responseType: AuthResponse.self
        )
        
        return requestVerificationResponse
    }
    
    func goVerifyRegistration(vericode: String) async throws -> UserInfoResponse? {
        let httpBody = try JSONEncoder().encode(["authenticationCode": vericode])
        // Use the temp token to send verification email
        var newHeaders = [:] as [String: String]
        if let tmpToken = await CacheUtil.shared.getRegisterAuthInfo()?.token {
            newHeaders["Authorization"] = "Bearer \(tmpToken)"
        }
        
        let verifyRegistrationResponse = try await ApiClient.shared.post(
            url: Endpoint.verifyRegistration.url,
            headers: newHeaders,
            body: httpBody,
            responseType: UserInfoResponse.self
        )
        
        return verifyRegistrationResponse
    }
    
    func completeRegistration(username: String, password: String) async throws -> AuthResponse? {
        let httpBody = try JSONEncoder().encode(CompleteRegistrationRequest(
            username: username,
            password: password,
            activateUser: true
        ))
        // Use the temp token to send verification email
        var newHeaders = [:] as [String: String]
        if let tmpToken = await CacheUtil.shared.getRegisterAuthInfo()?.token {
            newHeaders["Authorization"] = "Bearer \(tmpToken)"
        }
        
        let completeRegistrationResponse = try await ApiClient.shared.post(
            url: Endpoint.completeRegistration.url,
            headers: newHeaders,
            body: httpBody,
            responseType: AuthResponse.self
        )
        
        return completeRegistrationResponse
    }
}
