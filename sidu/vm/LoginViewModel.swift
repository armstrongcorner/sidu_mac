//
//  LoginViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation
import SwiftUI
import SwiftData

@Observable @MainActor
final class LoginViewModel {
    var username: String = "armstrong.liu@matrixthoughts.com.au"
    var password: String = "1"
    var isLoggedIn: CommonResult = .none
    var isShowingConfirmLogout: Bool = false
    var isShowingConfirmDeleteAccount: Bool = false
    var errMsg: String?
    
//    var modelContext: ModelContext?
    @ObservationIgnored
    var createUserHandler: @Sendable () async -> UserHandler?
    var userId: PersistentIdentifier?
    
    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let userServic: UserServiceProtocol
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        userService: UserServiceProtocol = UserService(),
        createUserHandler: @Sendable @escaping () async -> UserHandler? = { UserHandler(container: DatabaseProvider.shared.sharedModelContainer) }
    ) {
        self.loginService = loginService
        self.userServic = userService
        self.createUserHandler = createUserHandler
    }
    
    func login() async {
        do {
            // Login
            guard let authResponse = try await loginService.login(username: username, password: password) else {
                self.isLoggedIn = .failed
                self.errMsg = "Login failed with unknown reason"
                return
            }
            
            // Cache the auth info for future use
            await CacheUtil.shared.cacheAuthInfo(authInfo: authResponse.value)
            // Cache the username for future use
            await CacheUtil.shared.cacheUsername(username: username)
            
            // Get user info
            guard let userInfoResponse = try await userServic.getUserInfo(username: username) else {
                self.isLoggedIn = .failed
                self.errMsg = "Get user info failed with unknown reason"
                return
            }
            
            // Cache the user info for future use
//            let user = User(row: userInfoResponse.value?.toDictionary() ?? [:])
//            try User.addUser(user: user, context: modelContext)
            Task.detached {
                if let userHandler = await self.createUserHandler(), let userInfoModel = userInfoResponse.value {
//                    try await dbManager.insert(data: user)
                    let newUserId = try await userHandler.addUser(data: userInfoModel)
                    await MainActor.run {
                        self.userId = newUserId
                    }
                }
            }
            
            if authResponse.isSuccess ?? false {
                self.isLoggedIn = .success
            } else {
                self.isLoggedIn = .failed
                self.errMsg = authResponse.failureReason
            }
        } catch {
            self.isLoggedIn = .failed
            self.errMsg = error.localizedDescription
        }
    }
    
    func deleteAccount() {
        // Get current user from database
        let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
//        let user = try User.fetchUser(byUsername: username, context: modelContext)
        // Delete the user
//        try User.deleteUser(user: user!, context: modelContext)
        Task.detached {
            do {
                if let userHandler = await self.createUserHandler(), let username = username {
                    try await userHandler.deleteUser(byUsername: username)
                }
                await MainActor.run {
                    // Logout
                    self.logout()
                }
            } catch {
                await MainActor.run {
                    self.errMsg = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: CacheKey.username.rawValue)
        UserDefaults.standard.removeObject(forKey: CacheKey.authInfo.rawValue)
        UserDefaults.standard.removeObject(forKey: CacheKey.registerAuthInfo.rawValue)
        
        self.isLoggedIn = .none
    }
    
    func clearCredentials() {
        self.username = ""
        self.password = ""
        self.isLoggedIn = .none
        self.errMsg = nil
    }
}
