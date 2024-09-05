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
    var errMsg: String?
    
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol = ChatService()) {
        self.chatService = chatService
    }

    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        
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
            do {
                userMessage = ""
                guard let chatResponse = try await chatService.sendChat(tmpCacheUserMessage) else {
                    self.errMsg = "Sending chat message failed with unknown reason"
                    userMessage = tmpCacheUserMessage
                    return
                }
                
                if chatResponse.isSuccess ?? false {
                    // Get resposne from chat service
                    // 1) Build chat message model from response
                    let chatModel = chatResponse.value
                    let chatMessage = ChatMessageModel(
                        id: chatModel?.id,
                        role: .assistant,
                        content: chatModel?.choices?.first?.message?.content,
                        type: .text,
                        createAt: Int(chatModel?.created ?? ""),
                        status: .done,
                        isCompleteChatFlag: false
                    )
                    // 2) Replace 'waiting' message with chatMessage
                    chatContexts.replace([waitForResponseContext], with: [chatMessage])
                } else {
                    self.errMsg = chatResponse.failureReason
                    userMessage = tmpCacheUserMessage
                }
            } catch {
                self.errMsg = error.localizedDescription
                userMessage = tmpCacheUserMessage
            }
            
        }
    }
}
