//
//  UserViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 07/09/2024.
//

import SwiftData

@Observable
class UserViewModel {
    var modelContext: ModelContext?
    
    var isLoggedIn: Bool {
        return CacheUtil.shared.getAuthInfo() != nil
    }
    
}
