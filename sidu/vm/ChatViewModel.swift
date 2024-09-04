//
//  ChatViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation

@Observable
class ChatViewModel {
    var chatContexts: [ChatMessageModel] = []
    var userMessage: String = ""
    
    func sendChat() {
        if !userMessage.isEmpty && !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let chatContext = ChatMessageModel(
                id: UUID().uuidString,
                role: .user,
                content: userMessage,
                type: .text,
                createAt: Int(Date().timeIntervalSince1970),
                status: .sending,
                isCompleteChatFlag: false
            )
            let waitForResponseContext = ChatMessageModel(
                id: UUID().uuidString,
                role: .assistant,
                content: "...",
                type: .text,
                createAt: Int(Date().timeIntervalSince1970),
                status: .waiting,
                isCompleteChatFlag: false
            )
            chatContexts.append(contentsOf: [chatContext, waitForResponseContext])
            userMessage = ""
        }
    }
}
