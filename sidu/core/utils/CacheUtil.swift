//
//  CacheUtil.swift
//  sidu
//
//  Created by Armstrong Liu on 05/09/2024.
//

import Foundation

enum CacheKey: String {
    case authInfo = "authInfo"
    case registerAuthInfo = "registerAuthInfo"
    case username = "username"
    case currentLanguage = "currentLanguage"
}

@MainActor
final class CacheUtil {
    static let shared = CacheUtil()
    
    private init() {}
    
    func cacheAuthInfo(authInfo: AuthModel?) throws {
        // cache authInfo
        if let authInfo = authInfo {
            let encodedAuthInfo = try JSONEncoder().encode(authInfo)
            UserDefaults.standard.set(encodedAuthInfo, forKey: CacheKey.authInfo.rawValue)
        }
    }
    
    func getAuthInfo() -> AuthModel? {
        if let encodedAuthInfo = UserDefaults.standard.data(forKey: CacheKey.authInfo.rawValue) {
            return try? JSONDecoder().decode(AuthModel.self, from: encodedAuthInfo)
        }
        
        return nil
    }
    
    func cacheUsername(username: String) {
        UserDefaults.standard.set(username, forKey: CacheKey.username.rawValue)
    }
    
    func getUsername() -> String? {
        return UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
    }
    
    func cacheRegisterAuthInfo(registerAuthInfo: AuthModel?) {
        // cache registerAuthInfo
        if registerAuthInfo != nil, let encodedRegisterAuthInfo = try? JSONEncoder().encode(registerAuthInfo) {
            UserDefaults.standard.set(encodedRegisterAuthInfo, forKey: CacheKey.registerAuthInfo.rawValue)
        }
    }
    
    func getRegisterAuthInfo() -> AuthModel? {
        if let encodedRegisterAuthInfo = UserDefaults.standard.data(forKey: CacheKey.registerAuthInfo.rawValue) {
            return try? JSONDecoder().decode(AuthModel.self, from: encodedRegisterAuthInfo)
        }
        
        return nil
    }
}
