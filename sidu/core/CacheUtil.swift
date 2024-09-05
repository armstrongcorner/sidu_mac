//
//  CacheUtil.swift
//  sidu
//
//  Created by Armstrong Liu on 05/09/2024.
//

import Foundation

enum CacheKey: String {
    case authInfo = "authInfo"
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

}
