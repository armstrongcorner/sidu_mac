//
//  UserViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 07/09/2024.
//

import Foundation

@Observable
class UserViewModel {
    var isLoggedIn: Bool {
        return CacheUtil.shared.getAuthInfo() != nil
    }
    
}
