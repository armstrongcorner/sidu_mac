//
//  LoginViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation
import SwiftUI
import SwiftData
import OSLog

let logger = Logger(subsystem: "au.com.matrixthoughts.desktop.sidu", category: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")

@MainActor
@Observable
final class LoginViewModel: BaseViewModel {
//    var username: String = "armstrong.liu@matrixthoughts.com.au"
//    var password: String = "1"
    var username: String = ""
    var password: String = ""
    var isLoggedIn: CommonResult = .none
    var isShowingConfirmLogout: Bool = false
    var isShowingConfirmDeleteAccount: Bool = false
    var errMsg: String?
    
    @ObservationIgnored
    var createUserHandler: @Sendable () async -> UserHandler?
    
    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let userService: UserServiceProtocol
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        userService: UserServiceProtocol = UserService(),
        createUserHandler: @Sendable @escaping () async -> UserHandler? = { UserHandler(container: DatabaseProvider.shared.sharedModelContainer) }
    ) {
        self.loginService = loginService
        self.userService = userService
        self.createUserHandler = createUserHandler
    }
    
    func login() async {
        do {
            // Login
            let authResponse = try await loginService.login(username: username, password: password)
            // Cache the auth info for future use
            try CacheUtil.shared.cacheAuthInfo(authInfo: authResponse.value)
            // Cache the username for future use
            CacheUtil.shared.cacheUsername(username: username)
            
            // Get user info
            let userInfoResponse = try await userService.getUserInfo(username: username)
            // Cache the user info for future use
            Task.detached {
                if let userHandler = await self.createUserHandler(), let userInfoModel = userInfoResponse.value {
                    try await userHandler.addUser(data: userInfoModel)
                }
            }
            
            self.isLoggedIn = .success
        } catch {
            self.isLoggedIn = .failed
            self.errMsg = handelError(error, #function)
        }
    }
    
    func deleteAccount() {
        // Delete the user
        Task.detached {
            do {
                if let userHandler = await self.createUserHandler(), let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue) {
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
