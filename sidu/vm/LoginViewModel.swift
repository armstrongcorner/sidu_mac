//
//  LoginViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation

enum LoginResult: Equatable {
    case none
    case success
    case failed
}

@Observable
class LoginViewModel {
    var username: String = "armstrong.liu@matrixthoughts.com.au"
    var password: String = "1"
    var isLoggedIn: LoginResult = .none
    var errMsg: String?
    var isLoading: Bool = false
    
    private let loginService: LoginServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService()) {
        self.loginService = loginService
    }
    
    func login() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            guard let authResponse = try await loginService.login(username: username, password: password) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errMsg = "Login failed with unknown reason"
                }
                return
            }
            
            // Cache the auth info for future use
            CacheUtil.shared.cacheAuthInfo(authInfo: authResponse.value)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if authResponse.isSuccess ?? false {
                    self.isLoggedIn = .success
                } else {
                    self.isLoggedIn = .failed
                    self.errMsg = authResponse.failureReason
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isLoggedIn = .failed
                self.errMsg = error.localizedDescription
            }
        }
    }
    
    func clearCredentials() {
        DispatchQueue.main.async {
            self.username = ""
            self.password = ""
            self.isLoggedIn = .none
            self.errMsg = nil
            self.isLoading = false
        }
    }
}
