//
//  RegisterViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class RegisterViewModel: BaseViewModel {
    var email: String = ""
    var vericode: String = ""
    var password: String = ""
    var confirm: String = ""
    var isVerified: CommonResult = .none
    var errMsg: String?

    var resendCountDown: Int = 0    // in seconds
    private var countDownTimer: Timer?
    
    @ObservationIgnored
    var createUserHandler: @Sendable () async -> UserHandler?

    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let registerServic: RegisterServiceProtocol
    @ObservationIgnored
    private let userServic: UserServiceProtocol
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        registerServic: RegisterServiceProtocol = RegisterService(),
        userServic: UserServiceProtocol = UserService(),
        createUserHandler: @Sendable @escaping () async -> UserHandler? = { UserHandler(container: DatabaseProvider.shared.sharedModelContainer) }
    ) {
        self.loginService = loginService
        self.registerServic = registerServic
        self.userServic = userServic
        self.createUserHandler = createUserHandler
    }
    
    func startCountDown() {
        if !isEmailValid() {
            return
        }
        
        resendCountDown = RESEND_VERI_CODE_COUNTDOWN_IN_SEC
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.resendCountDown -= 1
                if self.resendCountDown == 0 {
                    self.countDownTimer?.invalidate()
                }
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
            self.isVerified = .failed
            self.errMsg = "Email is required"
            return false
        }
        
        return true
    }
    
    func isVericodeValid() -> Bool {
        if vericode.isEmpty {
            self.isVerified = .failed
            self.errMsg = "Verification code is required"
            return false
        }
        
        return true
    }
    
    func isPasswordMatched() -> Bool {
        if password.isEmpty || confirm.isEmpty {
            self.isVerified = .failed
            self.errMsg = "Password and confirm password are required"
            return false
        }
        
        if password != confirm {
            self.isVerified = .failed
            self.errMsg = "Password and confirm password are not matched"
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
            let tempAuthResponse = try await loginService.login(username: "matrixthoughtsadmin", password: "Nbq4dcz123")
            // Cache the temp token for sending verification email
            CacheUtil.shared.cacheRegisterAuthInfo(registerAuthInfo: tempAuthResponse.value)
            
            // Use the temp token to request verification email
            let requestVerificationResponse = try await registerServic.requestVerificationEmail(email: email)
            // Request verification email success, cache the auth token for verification
            CacheUtil.shared.cacheRegisterAuthInfo(registerAuthInfo: requestVerificationResponse.value)
        } catch {
            self.isVerified = .failed
            self.errMsg = "Request verification email failed with error: \(handelError(error, #function))"
        }
    }
    
    func goVerifyRegistration() async {
        do {
            // Validate the email and verification code
            if !isEmailValid() || !isVericodeValid() {
                return
            }
            
            // Verify the registration
            let _ = try await registerServic.goVerifyRegistration(vericode: vericode)
            self.isVerified = .success
        } catch {
            self.isVerified = .failed
            self.errMsg = "Verify registration failed with error: \(handelError(error, #function))"
        }
    }
    
    func completeRegistration() async {
        do {
            // Validate password matched
            if !isPasswordMatched() {
                return
            }
            
            // Complete the registration
            let completeRegistrationResponse = try await registerServic.completeRegistration(username: email, password: password)
            // Complete registration success, cache the auth info for future use
            try CacheUtil.shared.cacheAuthInfo(authInfo: completeRegistrationResponse.value)
            // Cache the email as username for future use
            UserDefaults.standard.set(email, forKey: CacheKey.username.rawValue)
            
            // Get user info
            let userInfoResponse = try await userServic.getUserInfo(username: email)
            // Cache the user info for future use
            Task.detached {
                if let userHandler = await self.createUserHandler(), let userInfoModel = userInfoResponse.value {
                    try await userHandler.addUser(data: userInfoModel)
                    
                    await MainActor.run {
                        self.isVerified = .success
                    }
                }
            }
        } catch {
            self.isVerified = .failed
            self.errMsg = "Complete registration failed with error: \(handelError(error, #function))"
        }
    }
}
