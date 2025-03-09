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

protocol RegisterServiceProtocol: Sendable {
    func requestVerificationEmail(email: String) async throws -> AuthResponse
    func goVerifyRegistration(vericode: String) async throws -> UserInfoResponse
    func completeRegistration(username: String, password: String) async throws -> AuthResponse
}

actor RegisterService: RegisterServiceProtocol, BaseServiceProtocol {
    let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func requestVerificationEmail(email: String) async throws -> AuthResponse {
        let verificationEmailRequest = VerificationEmailRequest(
            username: email,
            role: "User",
            mobile: "",
            email: email,
            language: "Chinese",
            tokenDurationInMin: USER_DEFAULT_TOKEN_DURATION_IN_MIN,
            isActive: false
        )
        // Use the temp token to send verification email
        let defaultHeaders = await getDefaultHeaders()
        
        let requestVerificationResponse = try await apiClient.post(
            urlString: Endpoint.sendVerificationEmail.urlString,
            headers: defaultHeaders,
            body: verificationEmailRequest,
            responseType: AuthResponse.self
        )
        
        guard let requestVerificationResponse = requestVerificationResponse else {
            throw ApiError.invalidResponse
        }
        guard let isSuccess = requestVerificationResponse.isSuccess, isSuccess == true else {
            throw CommError.serverReturnedError(requestVerificationResponse.failureReason ?? "")
        }

        return requestVerificationResponse
    }
    
    func goVerifyRegistration(vericode: String) async throws -> UserInfoResponse {
        let body = ["authenticationCode": vericode]
        // Use the temp token to send verification email
        let defaultHeaders = await getDefaultHeaders()
        
        let verifyRegistrationResponse = try await apiClient.post(
            urlString: Endpoint.verifyRegistration.urlString,
            headers: defaultHeaders,
            body: body,
            responseType: UserInfoResponse.self
        )
        
        guard let verifyRegistrationResponse = verifyRegistrationResponse else {
            throw ApiError.invalidResponse
        }
        guard let isSuccess = verifyRegistrationResponse.isSuccess, isSuccess == true else {
            throw CommError.serverReturnedError(verifyRegistrationResponse.failureReason ?? "")
        }
        
        return verifyRegistrationResponse
    }
    
    func completeRegistration(username: String, password: String) async throws -> AuthResponse {
        let completeRegistrationRequest = CompleteRegistrationRequest(
            username: username,
            password: password,
            activateUser: true
        )
        // Use the temp token to send verification email
        let defaultHeaders = await getDefaultHeaders()
        
        let completeRegistrationResponse = try await apiClient.post(
            urlString: Endpoint.completeRegistration.urlString,
            headers: defaultHeaders,
            body: completeRegistrationRequest,
            responseType: AuthResponse.self
        )
        
        guard let completeRegistrationResponse = completeRegistrationResponse else {
            throw ApiError.invalidResponse
        }
        guard let isSuccess = completeRegistrationResponse.isSuccess, isSuccess == true else {
            throw CommError.serverReturnedError(completeRegistrationResponse.failureReason ?? "")
        }
        
        return completeRegistrationResponse
    }
}
