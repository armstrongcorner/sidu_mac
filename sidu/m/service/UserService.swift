//
//  UserService.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import Foundation

protocol UserServiceProtocol: Sendable {
    func getUserInfo(username: String) async throws -> UserInfoResponse?
}

actor UserService: UserServiceProtocol {
    func getUserInfo(username: String) async throws -> UserInfoResponse? {
        let userInfoResponse = try await ApiClient.shared.get(url: URL(string: "\(Endpoint.userInfo.url.absoluteString)\(username)")!, responseType: UserInfoResponse.self)
        
        return userInfoResponse
    }
}
