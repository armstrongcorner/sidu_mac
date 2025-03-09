//
//  BaseViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 09/03/2025.
//

import Foundation
import OSLog

enum CommError: Error {
    case serverReturnedError(String)
    
    var errorDescription: String {
        switch self {
        case .serverReturnedError(let msg):
            return msg
        }
    }
}

@MainActor
class BaseViewModel {
    let logger = Logger()
    
    func handelError(_ error: Error, _ module: String) -> String {
        switch error {
        case let error as CommError:
            logger.error("[\(module)]: \(error.errorDescription)")
            return error.errorDescription
        default:
            logger.error("[\(module)]: Unknown Error")
            return "Unknown Error"
        }
    }
}
