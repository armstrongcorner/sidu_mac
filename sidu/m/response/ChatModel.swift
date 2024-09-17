//
//  ChatModel.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation

struct ChatModel: Codable {
    let id: String?
    let object: String?
    let created: String?
    let model: String?
    let usage: ChatResultUsage?
    let choices: [ChatResultChoice]?
    
    struct ChatResultUsage: Codable {
        let prompt_tokens: String?
        let completion_tokens: String?
        let totaltokens: String?
    }
    
    struct ChatResultChoice: Codable {
        let message: ChatResultMessage?
        let finish_reason: String?
        let index: Int?
        
        struct ChatResultMessage: Codable {
            let role: String?
            let content: String?
        }
    }
}

typealias ChatResponse = BaseResponse<ChatModel>
