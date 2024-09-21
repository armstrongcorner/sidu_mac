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

class CacheUtil {
    static let shared = CacheUtil()
    
    private init() {}
    
    func cacheAuthInfo(authInfo: AuthModel?) {
        // cache authInfo
        if authInfo != nil, let encodedAuthInfo = try? JSONEncoder().encode(authInfo) {
            UserDefaults.standard.setValue(encodedAuthInfo, forKey: CacheKey.authInfo.rawValue)
        }
    }
    
    func getAuthInfo() -> AuthModel? {
        if let encodedAuthInfo = UserDefaults.standard.data(forKey: CacheKey.authInfo.rawValue) {
            return try? JSONDecoder().decode(AuthModel.self, from: encodedAuthInfo)
        }
        
        return nil
    }
    
    func cacheRegisterAuthInfo(registerAuthInfo: AuthModel?) {
        // cache registerAuthInfo
        if registerAuthInfo != nil, let encodedRegisterAuthInfo = try? JSONEncoder().encode(registerAuthInfo) {
            UserDefaults.standard.setValue(encodedRegisterAuthInfo, forKey: CacheKey.registerAuthInfo.rawValue)
        }
    }
    
    func getRegisterAuthInfo() -> AuthModel? {
        if let encodedRegisterAuthInfo = UserDefaults.standard.data(forKey: CacheKey.registerAuthInfo.rawValue) {
            return try? JSONDecoder().decode(AuthModel.self, from: encodedRegisterAuthInfo)
        }
        
        return nil
    }
}
