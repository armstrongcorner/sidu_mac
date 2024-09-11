//
//  ChatViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation
import SwiftData

@Observable
class ChatViewModel {
    var chatContexts: [ChatMessageModel]
    var userMessage: String = ""
    var errMsg: String?
    var topicList: [Topic] = []
    var currentTopic: Topic?
    
    var modelContext: ModelContext?
    
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol = ChatService(), chatContexts: [ChatMessageModel] = []) {
        self.chatService = chatService
        self.chatContexts = chatContexts
    }
    
    func getCurrentUser() throws -> User? {
        let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
        return try User.fetchUser(byUsername: username, context: modelContext!)
    }
    
    func getTopicList() async {
        do {
            // Get current user's topics
            let currentUser = try getCurrentUser()
            self.topicList = currentUser?.topics ?? []
        } catch {
            self.errMsg = error.localizedDescription
        }
    }

    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        let isFirstChat = chatContexts.isEmpty
        
        if !userMessage.isEmpty && !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            var userChatContext = ChatMessageModel(
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
            self.chatContexts.append(contentsOf: [userChatContext, waitForResponseContext])
            
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
                guard let assistantChatResponse = try await chatService.sendChat(newChatContexts.reversed()) else {
                    DispatchQueue.main.async {
                        self.errMsg = "Sending chat message failed with unknown reason"
                        self.userMessage = tmpCacheUserMessage
                    }
                    return
                }
                
                if assistantChatResponse.isSuccess ?? false {
                    // Chat response is successful
                    userChatContext.status = .done
                    // 1) Build chat message model from response
                    let assistantChatModel = assistantChatResponse.value
                    let assistantChatMessage = ChatMessageModel(
                        id: assistantChatModel?.id,
                        role: .assistant,
                        content: assistantChatModel?.choices?.first?.message?.content,
                        type: .text,
                        createAt: Int(assistantChatModel?.created ?? ""),
                        status: .done,
                        isCompleteChatFlag: false
                    )
                    // 2) Save chat message to database
                    // 2-1) If first chat in the topic, we need to add an initial topic in database. The topic subject is the first user message
                    if isFirstChat {
                        let currentUser = try getCurrentUser()
                        let topic = Topic(title: tmpCacheUserMessage, createTime: Int(Date().timeIntervalSince1970), isComplete: false, user: currentUser)
                        self.currentTopic = topic
                        try? Topic.addTopic(topic: topic, context: modelContext)
                    }
                    // 2-2) Save chat message to database
                    // Save user sent message first
                    let userChat = Chat(fromContextModel: userChatContext)
                    userChat.topic = currentTopic
                    try? Chat.addChat(chat: userChat, context: modelContext)
                    // Save assistant response message
                    let assistantChat = Chat(fromContextModel: assistantChatMessage)
                    assistantChat.topic = currentTopic
                    try? Chat.addChat(chat: assistantChat, context: modelContext)
                    // 3) Replace 'waiting' message with chatMessage
                    DispatchQueue.main.async {
                        self.chatContexts.replace([waitForResponseContext], with: [assistantChatMessage])
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errMsg = assistantChatResponse.failureReason
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
