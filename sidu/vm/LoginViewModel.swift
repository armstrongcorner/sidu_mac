//
//  LoginViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class LoginViewModel {
    var username: String = "armstrong.liu@matrixthoughts.com.au"
    var password: String = "1"
    var isLoggedIn: CommonResult = .none
    var isShowingConfirmLogout: Bool = false
    var isShowingConfirmDeleteAccount: Bool = false
    var errMsg: String?
    
    var modelContext: ModelContext?
    
    private let loginService: LoginServiceProtocol
    private let userServic: UserServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService(), userService: UserServiceProtocol = UserService()) {
        self.loginService = loginService
        self.userServic = userService
    }
    
    func login() async {
        do {
            // Login
            guard let authResponse = try await loginService.login(username: username, password: password) else {
                DispatchQueue.main.async {
                    self.isLoggedIn = .failed
                    self.errMsg = "Login failed with unknown reason"
                }
                return
            }
            
            // Cache the auth info for future use
            CacheUtil.shared.cacheAuthInfo(authInfo: authResponse.value)
            // Cache the username for future use
            UserDefaults.standard.setValue(username, forKey: CacheKey.username.rawValue)

            // Get user info
            guard let userInfoResponse = try await userServic.getUserInfo(username: username) else {
                DispatchQueue.main.async {
                    self.isLoggedIn = .failed
                    self.errMsg = "Get user info failed with unknown reason"
                }
                return
            }
            
            // Cache the user info for future use
            let user = User(row: userInfoResponse.value?.toDictionary() ?? [:])
            try User.addUser(user: user, context: modelContext)

            DispatchQueue.main.async {
                if authResponse.isSuccess ?? false {
                    self.isLoggedIn = .success
                } else {
                    self.isLoggedIn = .failed
                    self.errMsg = authResponse.failureReason
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoggedIn = .failed
                self.errMsg = error.localizedDescription
            }
        }
    }
    
    func deleteAccount() {
        do {
            // Get current user from database
            let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
            let user = try User.fetchUser(byUsername: username, context: modelContext)
            if user != nil {
                // Delete the user
                try User.deleteUser(user: user!, context: modelContext)
                // Logout
                logout()
            } else {
                DispatchQueue.main.async {
                    self.errMsg = "User not found"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errMsg = error.localizedDescription
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: CacheKey.username.rawValue)
        UserDefaults.standard.removeObject(forKey: CacheKey.authInfo.rawValue)
        UserDefaults.standard.removeObject(forKey: CacheKey.registerAuthInfo.rawValue)
        
        DispatchQueue.main.async {
            self.isLoggedIn = .none
        }
    }

    func clearCredentials() {
        DispatchQueue.main.async {
            self.username = ""
            self.password = ""
            self.isLoggedIn = .none
            self.errMsg = nil
        }
    }
}
