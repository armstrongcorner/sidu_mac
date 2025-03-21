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
    let messages: [ChatRequestMessage]
}

struct ChatRequestMessage: Codable {
    let role: String
    let content: String
}

protocol ChatServiceProtocol: Sendable {
    func sendChat(_ messageList: [ChatMessage]) async throws -> ChatResponse?
}

actor ChatService: ChatServiceProtocol, BaseServiceProtocol {
    func sendChat(_ messageList: [ChatMessage]) async throws -> ChatResponse? {
        let chatRequest = ChatRequest(
            model: DEFAULT_AI_MODEL,
            max_tokens:DEFAULT_MAX_TOKENS,
            messages: buildUplinkMessage(messageList)
        )
        let defaultHeaders = await getDefaultHeaders()
        
        let chatResponse = try await ApiClient().post(
            urlString: Endpoint.chat.urlString,
            headers: defaultHeaders,
            body: chatRequest,
            responseType: ChatResponse.self
        )
        
        return chatResponse
    }
    
    func buildUplinkMessage(_ messageList: [ChatMessage]) -> [ChatRequestMessage] {
        return messageList.map {
            ChatRequestMessage(role: $0.role?.rawValue ?? ChatRole.user.rawValue, content: $0.content ?? "")
        }
    }
}
