//
//  RegisterViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation

@Observable
class RegisterViewModel {
    var email: String = ""
    var vericode: String = ""
    var errMsg: String?
    
    var resendCountDown: Int = 0    // in seconds
    private var countDownTimer: Timer?
    
    private let loginService: LoginServiceProtocol
    private let registerServic: RegisterServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService(), registerServic: RegisterServiceProtocol = RegisterService()) {
        self.loginService = loginService
        self.registerServic = registerServic
    }
    
    deinit {
        countDownTimer?.invalidate()
    }
    
    func startCountDown() {
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
    
    func requestVerificationEmail() async {
        do {
            // Request temp token (by super admin) for request verification email
            guard let tempAuthResponse = try await loginService.login(username: "matrixthoughtsadmin", password: "Nbq4dcz123") else {
                DispatchQueue.main.async {
                    self.errMsg = "Request temp token failed with unknown reason"
                }
                return
            }
            if tempAuthResponse.isSuccess ?? false {
                // Cache the temp token for sending verification email
                CacheUtil.shared.cacheAuthInfo(authInfo: tempAuthResponse.value)
                
                // Use the temp token to request verification email
                guard let requestVerificationResponse = try await registerServic.requestVerificationEmail(email: email) else {
                    DispatchQueue.main.async {
                        self.errMsg = "Request verification email failed with unknown reason"
                    }
                    return
                }
                if requestVerificationResponse.isSuccess ?? false {
                    // Request verification email success, cache the auth token for verification
                    CacheUtil.shared.cacheAuthInfo(authInfo: requestVerificationResponse.value)
                } else {
                    DispatchQueue.main.async {
                        self.errMsg = "Request verification email failed with error: \(requestVerificationResponse.failureReason ?? "unknown reason")"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errMsg = "Request temp token failed with error: \(tempAuthResponse.failureReason ?? "unknown reason")"
                }
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.errMsg = "Request verification email failed with error: \(error.localizedDescription)"
            }
        }
    }
    
    func goVerifyRegistration() async -> Bool {
        do {
            // Verify the registration
            guard let verifyRegistrationResponse = try await registerServic.goVerifyRegistration(vericode: vericode) else {
                DispatchQueue.main.async {
                    self.errMsg = "Verify registration failed with unknown reason"
                }
                return false
            }
            if verifyRegistrationResponse.isSuccess ?? false {
                // Verify registration success, cache the username for complete registration
                UserDefaults.standard.setValue(verifyRegistrationResponse.value?.userName, forKey: CacheKey.username.rawValue)
                return true
            } else {
                DispatchQueue.main.async {
                    self.errMsg = "Verify registration failed with error: \(verifyRegistrationResponse.failureReason ?? "unknown reason")"
                }
                return false
            }
        } catch {
            DispatchQueue.main.async {
                self.errMsg = "Verify registration failed with error: \(error.localizedDescription)"
            }
            return false
        }
    }
}
