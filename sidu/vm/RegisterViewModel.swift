//
//  RegisterViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation
import SwiftData

@Observable
final class RegisterViewModel: Sendable {
    var email: String = ""
    var vericode: String = ""
    var password: String = ""
    var confirm: String = ""
    var isVerified: CommonResult = .none
    var errMsg: String?
    
    var modelContext: ModelContext?
    
    var resendCountDown: Int = 0    // in seconds
    private var countDownTimer: Timer?
    
    private let loginService: LoginServiceProtocol
    private let registerServic: RegisterServiceProtocol
    private let userServic: UserServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService(), registerServic: RegisterServiceProtocol = RegisterService(), userServic: UserServiceProtocol = UserService()) {
        self.loginService = loginService
        self.registerServic = registerServic
        self.userServic = userServic
    }
    
    deinit {
        countDownTimer?.invalidate()
    }
    
    func startCountDown() {
        if !isEmailValid() {
            return
        }
        
        resendCountDown = RESEND_VERI_CODE_COUNTDOWN_IN_SEC
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.resendCountDown -= 1
            if self.resendCountDown == 0 {
                timer.invalidate()
            }
        }
    }
    
    func stopCountDown() {
        countDownTimer?.invalidate()
        countDownTimer = nil
        resendCountDown = 0
    }
    
    func isEmailValid() -> Bool {
        if email.isEmpty {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Email is required"
            }
            return false
        }
        
        return true
    }
    
    func isVericodeValid() -> Bool {
        if vericode.isEmpty {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Verification code is required"
            }
            return false
        }
        
        return true
    }
    
    func isPasswordMatched() -> Bool {
        if password.isEmpty || confirm.isEmpty {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Password and confirm password are required"
            }
            return false
        }
        
        if password != confirm {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Password and confirm password are not matched"
            }
            return false
        }
        
        return true
    }
    
    func requestVerificationEmail() async {
        do {
            // Validate the email
            if !isEmailValid() {
                return
            }
            
            // Request temp token (by super admin) for request verification email
            guard let tempAuthResponse = try await loginService.login(username: "matrixthoughtsadmin", password: "Nbq4dcz123") else {
                DispatchQueue.main.async {
                    self.isVerified = .failed
                    self.errMsg = "Request temp token failed with unknown reason"
                }
                return
            }
            if tempAuthResponse.isSuccess ?? false {
                // Cache the temp token for sending verification email
                await CacheUtil.shared.cacheRegisterAuthInfo(registerAuthInfo: tempAuthResponse.value)
                
                // Use the temp token to request verification email
                guard let requestVerificationResponse = try await registerServic.requestVerificationEmail(email: email) else {
                    DispatchQueue.main.async {
                        self.isVerified = .failed
                        self.errMsg = "Request verification email failed with unknown reason"
                    }
                    return
                }
                if requestVerificationResponse.isSuccess ?? false {
                    // Request verification email success, cache the auth token for verification
                    await CacheUtil.shared.cacheRegisterAuthInfo(registerAuthInfo: requestVerificationResponse.value)
                } else {
                    DispatchQueue.main.async {
                        self.isVerified = .failed
                        self.errMsg = "Request verification email failed with error: \(requestVerificationResponse.failureReason ?? "unknown reason")"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isVerified = .failed
                    self.errMsg = "Request temp token failed with error: \(tempAuthResponse.failureReason ?? "unknown reason")"
                }
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Request verification email failed with error: \(error.localizedDescription)"
            }
        }
    }
    
    func goVerifyRegistration() async {
        do {
            // Validate the email and verification code
            if !isEmailValid() || !isVericodeValid() {
                return
            }
            
            // Verify the registration
            guard let verifyRegistrationResponse = try await registerServic.goVerifyRegistration(vericode: vericode) else {
                DispatchQueue.main.async {
                    self.isVerified = .failed
                    self.errMsg = "Verify registration failed with unknown reason"
                }
                return
            }
            if verifyRegistrationResponse.isSuccess ?? false {
                // Verify registration success
                DispatchQueue.main.async {
                    self.isVerified = .success
                }
            } else {
                DispatchQueue.main.async {
                    self.isVerified = .failed
                    self.errMsg = "Verify registration failed with error: \(verifyRegistrationResponse.failureReason ?? "unknown reason")"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Verify registration failed with error: \(error.localizedDescription)"
            }
        }
    }
    
    func completeRegistration() async {
        do {
            // Validate password matched
            if !isPasswordMatched() {
                return
            }
            
            // Complete the registration
            guard let completeRegistrationResponse = try await registerServic.completeRegistration(username: email, password: password) else {
                DispatchQueue.main.async {
                    self.isVerified = .failed
                    self.errMsg = "Complete registration failed with unknown reason"
                }
                return
            }
            if completeRegistrationResponse.isSuccess ?? false {
                // Complete registration success, cache the auth info for future use
                await CacheUtil.shared.cacheAuthInfo(authInfo: completeRegistrationResponse.value)
                // Cache the email as username for future use
                UserDefaults.standard.setValue(email, forKey: CacheKey.username.rawValue)

                // Get user info
                guard let userInfoResponse = try await userServic.getUserInfo(username: email) else {
                    DispatchQueue.main.async {
                        self.isVerified = .failed
                        self.errMsg = "Get user info failed with unknown reason"
                    }
                    return
                }
                if userInfoResponse.isSuccess ?? false {
                    // Cache the user info for future use
                    let user = User(row: userInfoResponse.value?.toDictionary() ?? [:])
                    try User.addUser(user: user, context: modelContext)
                    DispatchQueue.main.async {
                        self.isVerified = .success
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isVerified = .failed
                        self.errMsg = "Get user info failed with error: \(userInfoResponse.failureReason ?? "unknown reason")"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isVerified = .failed
                    self.errMsg = "Complete registration failed with error: \(completeRegistrationResponse.failureReason ?? "unknown reason")"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isVerified = .failed
                self.errMsg = "Complete registration failed with error: \(error.localizedDescription)"
            }
        }
    }
}
