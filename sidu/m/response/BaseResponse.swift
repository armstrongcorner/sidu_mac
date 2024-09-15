//
//  BaseResponse.swift
//  sidu
//
//  Created by Armstrong Liu on 30/08/2024.
//

import Foundation

struct BaseResponse<T: Codable>: Codable {
    let value: T?
    let failureReason: String?
    let isSuccess: Bool?
}
