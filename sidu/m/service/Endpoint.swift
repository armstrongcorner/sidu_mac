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
    case useInfo
    case chat
    
    var url: URL {
        switch self {
        case .login:
            return URL(string: "\(Endpoint.userURL)/identity/token")!
        case .checkUserExist:
            return URL(string: "\(Endpoint.userURL)/identity/user/exist")!
        case .sendVerificationEmail:
            return URL(string: "\(Endpoint.userURL)/identity/user/create")!
        case .verifyRegistration:
            return URL(string: "\(Endpoint.userURL)/identity/user/authenticate")!
        case .completeRegistration:
            return URL(string: "\(Endpoint.userURL)/identity/user/password")!
        case .useInfo:
            return URL(string: "\(Endpoint.userURL)/identity/user")!
        case .chat:
            return URL(string: "\(Endpoint.chatURL)/chat/balance/complete")!
        }
    }
}
