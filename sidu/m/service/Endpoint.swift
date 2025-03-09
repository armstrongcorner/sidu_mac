//
//  Endpoint.swift
//  sidu
//
//  Created by Armstrong Liu on 30/08/2024.
//

import Foundation

enum Endpoint {
//    static let userURL = "https://intensivecredentialdev.azurewebsites.net/api"
//    static let chatURL = "https://intensiveconversedev.azurewebsites.net/api"
    static let userURL = "https://intensivecredentialprod.azurewebsites.net/api"
    static let chatURL = "https://intensiveconverseprod.azurewebsites.net/api"
    
    case login
    case checkUserExist
    case sendVerificationEmail
    case verifyRegistration
    case completeRegistration
    case userInfo
    case chat
    
    var urlString: String {
        switch self {
        case .login:
            return "\(Endpoint.userURL)/identity/token"
        case .checkUserExist:
            return "\(Endpoint.userURL)/identity/user/exist"
        case .sendVerificationEmail:
            return "\(Endpoint.userURL)/identity/user/create"
        case .verifyRegistration:
            return "\(Endpoint.userURL)/identity/user/authenticate"
        case .completeRegistration:
            return "\(Endpoint.userURL)/identity/user/password"
        case .userInfo:
            return "\(Endpoint.userURL)/identity/user?username="
        case .chat:
            return "\(Endpoint.chatURL)/chat/balance/complete"
        }
    }
}
