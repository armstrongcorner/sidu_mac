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
    var userMessage: String = ""
    var errMsg: String?
    
    var selectedTopicIndex: Int?
    var topicList: [TopicMessage] = []
    var chatContexts: [ChatMessage]
    var currentTopic: Topic? {
        didSet {
            self.chatContexts = currentTopic?.chats.sorted(by: { chat1, chat2 in
                chat1.createAt ?? 0 < chat2.createAt ?? 0
            }).map({ chat in
                print("content: \(chat.content)")
                return ChatMessage(
                    id: chat.id,
                    role: chat.role,
                    content: chat.content,
                    type: .text,
                    createAt: chat.createAt,
                    status: chat.status
                )
            }) ?? []
        }
    }
    
    var modelContext: ModelContext?
    
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol = ChatService(), chatContexts: [ChatMessage] = []) {
        self.chatService = chatService
        self.chatContexts = chatContexts
    }
    
    func getCurrentUser() throws -> User? {
        let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
        return try User.fetchUser(byUsername: username, context: modelContext)
    }
    
    func getTopicList() async {
        do {
            // Get current user's topics
            let currentUser = try getCurrentUser()
            DispatchQueue.main.async {
                self.topicList = (currentUser?.topics ?? []).sorted(by: { topic1, topic2 in
                    topic1.createTime ?? 0 > topic2.createTime ?? 0
                })
                print("topicList count: \(self.topicList.count)");
                for i in 0..<self.topicList.count {
                    print("topic \(i) chats count: \(self.topicList[i].chats.count)");
                }
            }
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        // No chat history, or the topic is completed, then it's the first chat in the topic
        let isFirstChat = chatContexts.isEmpty || self.currentTopic?.isComplete ?? false
        
        if !userMessage.isEmpty && !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            var userChatContext = ChatMessage(
                id: UUID().uuidString,
                role: .user,
                content: userMessage,
                type: .text,
                createAt: Int(Date().timeIntervalSince1970),
                status: .sending
            )
            let waitForResponseContext = ChatMessage(
                id: UUID().uuidString,
                role: .assistant,
                content: "...",
                type: .text,
                createAt: Int(Date().timeIntervalSince1970),
                status: .waiting
            )
            
            if isFirstChat {
                self.chatContexts = [userChatContext, waitForResponseContext]
            } else {
                self.chatContexts.append(contentsOf: [userChatContext, waitForResponseContext])
            }
            
            // Reverse loop the chatContexts with max chat depth, until the complete chat flag is true
            var count = 0
            var newChatContexts: [ChatMessage] = []
            for item in chatContexts.filter({ $0.status != .waiting }).reversed() {
                if count >= MAX_CHAT_DEPTH {
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
                    let assistantChatMessage = ChatMessage(
                        id: assistantChatModel?.id,
                        role: .assistant,
                        content: assistantChatModel?.choices?.first?.message?.content,
                        type: .text,
                        createAt: Int(assistantChatModel?.created ?? ""),
                        status: .done
                    )
                    // 2) Save chat message to database
                    // 2-1) If first chat in the topic, we need to add an initial topic in database. The topic subject is the first user message
                    if isFirstChat {
                        guard let currentUser = try getCurrentUser() else {
                            DispatchQueue.main.async {
                                self.errMsg = "Current user not found"
                                self.userMessage = tmpCacheUserMessage
                            }
                            return
                        }
                        let topic = Topic(title: tmpCacheUserMessage, createTime: Int(Date().timeIntervalSince1970), isComplete: false, user: currentUser)
                        try Topic.addTopic(topic: topic, context: modelContext)
                        // Update topic list
                        await getTopicList()
                        self.currentTopic = topic
                        selectedTopicIndex = 0
                    }
                    // 2-2) Save chat message to database
                    // Save user sent message first
                    let userChat = Chat(fromContextModel: userChatContext, topic: currentTopic)
                    try Chat.addChat(chat: userChat, context: modelContext)
                    // Save assistant response message
                    let assistantChat = Chat(fromContextModel: assistantChatMessage, topic: currentTopic)
                    try Chat.addChat(chat: assistantChat, context: modelContext)
                    // 3) Replace 'waiting' message with chatMessage
                    DispatchQueue.main.async {
                        self.chatContexts.replace([waitForResponseContext], with: [assistantChatMessage])
                    }
                    // 4) Update current topic for refresh the chat list
                    self.currentTopic = try Topic.fetchTopicById(topicId: currentTopic?.id ?? "", context: modelContext)
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
    
    func markTopicAsCompleted(topic: Topic) async {
        do {
            // Mark the topic as complete
            topic.isComplete = true
            try Topic.updateTopic(topic: topic, context: modelContext)
            
            await getTopicList()
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    func deleteTopic(topic: Topic) async {
        do {
            let indexToDelete = topicList.firstIndex(where: { $0.id == topic.id }) ?? 0
            
//            print("\n\n\nselected topic title: \(topicList[indexToDelete].title ?? "")\n")
//            for i in 0..<chatContexts.count {
//                print("topic \(i) title: \(topicList[i].title ?? "")")
//            }
            
            guard let currentUser = try getCurrentUser() else {
                DispatchQueue.main.async {
                    self.errMsg = "Current user not found"
                }
                return
            }
            
            // Decide which topic should be selected after delete
            if topicList.count > 1 {
                // More than one topic before delete
                if indexToDelete <= selectedTopicIndex ?? 0 {
                    // When to-be-deleted topic is before selected topic
//                    currentUser.topics.remove(at: indexToDelete)
                    let newIndex = (selectedTopicIndex ?? 0) - 1
                    selectedTopicIndex = newIndex >= 0 ? newIndex : 0
                }
            } else {
                // Only one topic, then no one should be selected after delete
                selectedTopicIndex = nil
                currentTopic = nil
                chatContexts = []
            }
            
            // Delete the topic
            currentUser.topics.remove(at: indexToDelete)
//            topicList.remove(at: indexToDelete)
            DispatchQueue.main.async {
                Task {
                    await self.getTopicList()
                }
            }
            if selectedTopicIndex != nil {
                currentTopic = topicList[selectedTopicIndex ?? 0]
            }
            print("aaa: \(currentUser.topics.count)")
            print("bbb: \(topicList.count)")
            
//            currentUser.topics.remove(at: indexToDelete)
////            try Topic.deleteTopic(topic: topic, context: modelContext)
//            await getTopicList()
//            if selectedTopicIndex ?? 0 >= indexToDelete {
//                let newIndex = (selectedTopicIndex ?? 0) - 1
//                selectedTopicIndex = newIndex >= 0 ? newIndex : 0
//            }
//            if topicList.count > 0 {
//                currentTopic = topicList[selectedTopicIndex ?? 0]
//            } else {
//                currentTopic = nil
//            }
            
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
}
