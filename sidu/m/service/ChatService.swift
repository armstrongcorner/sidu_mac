//
//  ChatService.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation

struct ChatRequest: Codable {
    let model: String
    let max_tokens: Int
    let messages: [ChatMessage]
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

protocol ChatServiceProtocol {
    func sendChat(_ message: String) async throws -> ChatResponse?
}

class ChatService: ChatServiceProtocol {
    func sendChat(_ message: String) async throws -> ChatResponse? {
        let httpBody = try JSONEncoder().encode(ChatRequest(model: "gpt-4o", max_tokens:4096, messages: [ChatMessage(role: ChatRole.user.rawValue, content: message)]))
        let chatResponse = try await ApiClient.shared.post(url: Endpoint.chat.url, body: httpBody, responseType: ChatResponse.self)
        
        return chatResponse
    }
}
