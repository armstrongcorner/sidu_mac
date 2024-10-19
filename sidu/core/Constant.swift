//
//  Constant.swift
//  sidu
//
//  Created by Armstrong Liu on 07/09/2024.
//

import Foundation

enum CommonResult: Equatable, Sendable {
    case none
    case success
    case failed
}

let supportedLanguageMap = [
    "en": "English",
    "zh": "中文",
]

let RESEND_VERI_CODE_COUNTDOWN_IN_SEC: Int = 60
let USER_DEFAULT_TOKEN_DURATION_IN_MIN: Int = 60 * 24 * 10

let DEFAULT_AI_MODEL: String = "gpt-4o"
let DEFAULT_MAX_TOKENS: Int = 4096
let CHAT_COMPLETE_GAP_IN_MINUTES: Int = 15
let MAX_CHAT_DEPTH: Int = 3
