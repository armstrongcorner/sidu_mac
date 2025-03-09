//
//  UserService.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import Foundation

protocol UserServiceProtocol: Sendable {
    func getUserInfo(username: String) async throws -> UserInfoResponse
}

actor UserService: UserServiceProtocol, BaseServiceProtocol {
    let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func getUserInfo(username: String) async throws -> UserInfoResponse {
        let defaultHeaders = await getDefaultHeaders()
        
        let userInfoResponse = try await apiClient.get(
            urlString: "\(Endpoint.userInfo.urlString)/\(username)",
            headers: defaultHeaders,
            responseType: UserInfoResponse.self
        )
        
        guard let userInfoResponse = userInfoResponse else {
            throw ApiError.invalidResponse
        }
        
        guard let isSuccess = userInfoResponse.isSuccess, isSuccess == true else {
            throw CommError.serverReturnedError(userInfoResponse.failureReason ?? "")
        }
        
        return userInfoResponse
    }
}
