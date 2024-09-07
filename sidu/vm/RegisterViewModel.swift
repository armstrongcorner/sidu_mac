//
//  RegisterViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import Foundation

@Observable
class RegisterViewModel {
    var resendCountDown: Int = 0    // in seconds
    private var countDownTimer: Timer?
    
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
    
    deinit {
        countDownTimer?.invalidate()
    }
}
