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
    var selectedTopicIndex: Int?
    var topicList: [Topic] = []
    var currentTopic: Topic? {
        didSet {
            self.chatContexts = currentTopic?.chats.sorted(by: { chat1, chat2 in
                chat1.createAt ?? 0 < chat2.createAt ?? 0
            }).map({ chat in
                print("content: \(chat.content)")
                return ChatMessageModel(
                    id: chat.id,
                    role: chat.role,
                    content: chat.content,
                    type: .text,
                    createAt: chat.createAt,
                    status: chat.status,
                    isCompleteChatFlag: chat.isCompleteChatFlag
                )
            }) ?? []
        }
    }
    
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
            self.topicList = (currentUser?.topics ?? []).sorted(by: { topic1, topic2 in
                topic1.createTime ?? 0 > topic2.createTime ?? 0
            })
            print("topicList count: \(topicList.count)");
            print("chat count: \(currentUser?.topics.first?.chats.count ?? 0)")
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        // No chat history, or the topic is completed, then it's the first chat in the topic
        let isFirstChat = chatContexts.isEmpty || self.currentTopic?.isComplete ?? false
        
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
                        try Topic.addTopic(topic: topic, context: modelContext)
                        // Update topic list
                        await getTopicList()
                        self.currentTopic = topic
                        selectedTopicIndex = 0
                    }
                    // 2-2) Save chat message to database
                    // Save user sent message first
                    let userChat = Chat(fromContextModel: userChatContext)
                    userChat.topic = currentTopic
                    try Chat.addChat(chat: userChat, context: modelContext)
                    // Save assistant response message
                    let assistantChat = Chat(fromContextModel: assistantChatMessage)
                    assistantChat.topic = currentTopic
                    try Chat.addChat(chat: assistantChat, context: modelContext)
                    // 3) Replace 'waiting' message with chatMessage
                    DispatchQueue.main.async {
                        self.chatContexts.replace([waitForResponseContext], with: [assistantChatMessage])
                    }
                    // 4) Update current topic for refresh the chat list
                    self.currentTopic = userChat.topic
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
    
    func endChat() {
        do {
            // 1) Update the last chat context UI
            var lastChatContext = chatContexts.last!
            lastChatContext.isCompleteChatFlag = true
            chatContexts[chatContexts.count - 1] = lastChatContext
            // 2) Update database (topic and chat)
            // Update the current topic to complete
            currentTopic?.isComplete = true
            try Topic.updateTopic(topic: currentTopic!, context: modelContext)
            // Update the last chat to complete
            let lastChat = Chat(fromContextModel: lastChatContext)
            try Chat.updateChat(chat: lastChat, context: modelContext)
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
}
