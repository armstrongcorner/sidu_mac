//
//  AuthModel.swift
//  sidu
//
//  Created by Armstrong Liu on 30/08/2024.
//

import Foundation

struct AuthModel: Codable {
    let token: String?
    let validInMins: Int?
    let validUntilUTC: String?
}

typealias AuthResponse = BaseResponse<AuthModel>
