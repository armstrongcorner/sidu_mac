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
    
    init(chatService: ChatServiceProtocol = ChatService(), chatContexts: [ChatMessageModel] = []) {
        self.chatService = chatService
        self.chatContexts = chatContexts
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
            self.chatContexts.append(contentsOf: [chatContext, waitForResponseContext])
            
            // Reverse loop the chatContexts with max chat depth, until the complete chat flag is true
            var count = 0
            var newChatContexts: [ChatMessageModel] = []
            for item in chatContexts.filter({ $0.status != .waiting }).reversed() {
                if item.isCompleteChatFlag ?? false || count >= MAX_CHAT_DEPTH {
                    break
                }
                
                newChatContexts.append(item)
                count += 1
            }
            
            do {
                DispatchQueue.main.async {
                    self.userMessage = ""
                }
                // Reverse back the newChatContexts to positive order, then send chat message
                guard let chatResponse = try await chatService.sendChat(newChatContexts.reversed()) else {
                    DispatchQueue.main.async {
                        self.errMsg = "Sending chat message failed with unknown reason"
                        self.userMessage = tmpCacheUserMessage
                    }
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
                    DispatchQueue.main.async {
                        self.chatContexts.replace([waitForResponseContext], with: [chatMessage])
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errMsg = chatResponse.failureReason
                        self.userMessage = tmpCacheUserMessage
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errMsg = error.localizedDescription
                    self.userMessage = tmpCacheUserMessage
                }
            }
            
        }
    }
}
