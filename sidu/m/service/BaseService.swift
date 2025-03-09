//
//  BaseService.swift
//  sidu
//
//  Created by Armstrong Liu on 06/03/2025.
//

import Foundation

protocol BaseServiceProtocol: Sendable {
    func getDefaultHeaders() async -> [String: String]
}

extension BaseServiceProtocol {
    func getDefaultHeaders() async -> [String: String] {
        var headers: [String: String] = [:]
        
        // Put cached token to header
        if let token = await CacheUtil.shared.getAuthInfo()?.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
