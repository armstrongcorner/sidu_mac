//
//  ChatViewModel.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation
import SwiftData

@Observable @MainActor
class ChatViewModel {
    var userMessage: String = ""
    var isShowingConfirmDeleteAllTopic: Bool = false
    var isShowingSetting: Bool = false
    var errMsg: String?
    
    var topicList: [TopicMessage] = []
    var chatList: [ChatMessage] = []
    var selectedTopicIndex: Int? {
        didSet {
            if selectedTopicIndex != nil {
                chatList = topicList[selectedTopicIndex ?? 0].chatMessages.sorted(by: { chat1, chat2 in
                    chat1.createAt ?? 0 < chat2.createAt ?? 0
                })
            } else {
                chatList = []
            }
        }
    }
    
//    var modelContext: ModelContext?
    @ObservationIgnored
    var createTopicHandler: @Sendable () async -> TopicHandler?
    @ObservationIgnored
    var createChatHandler: @Sendable () async -> ChatHandler?

    @ObservationIgnored
    private let chatService: ChatServiceProtocol
    
    init(
        chatService: ChatServiceProtocol = ChatService(),
        selectedTopicIndex: Int? = nil,
        topicList: [TopicMessage] = [],
        createUserHandler: @Sendable @escaping () async -> UserHandler? = { UserHandler(container: DatabaseProvider.shared.sharedModelContainer) },
        createTopicHandler: @Sendable @escaping () async -> TopicHandler? = { TopicHandler(container: DatabaseProvider.shared.sharedModelContainer) },
        createChatHandler: @Sendable @escaping () async -> ChatHandler? = { ChatHandler(container: DatabaseProvider.shared.sharedModelContainer) }
    ) {
        self.chatService = chatService
        self.topicList = topicList
        self.selectedTopicIndex = selectedTopicIndex
        self.createTopicHandler = createTopicHandler
        self.createChatHandler = createChatHandler
    }
    
    // Get all topic and related chats for current user
    func getTopicAndChat() async {
        do {
            let task = Task.detached(priority: .high) {
                // Load topic list
                if let topicHandler = await self.createTopicHandler(), let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue) {
                    var topics = try await topicHandler.fetchTopics(byUsername: username)
                    // Load chat list for all topics
                    for i in 0..<topics.count {
                        var topicMessage = topics[i]
                        if let chatHandler = await self.createChatHandler(), let topicId = topicMessage.id {
                            var chats = try await chatHandler.fetchChats(byTopicId: topicId)
                            chats = chats.sorted(by: { chat1, chat2 in
                                chat1.createAt ?? 0 < chat2.createAt ?? 0
                            })
                            
                            topicMessage.chatMessages = chats
                            topics[i] = topicMessage
                        }
                        
                    }
                    return topics
                }
                return []
            }
            let unsortedTopicList = try await task.value
            topicList = unsortedTopicList.sorted(by: { topicMessage1, topicMessage2 in
                topicMessage1.createTime ?? 0 > topicMessage2.createTime ?? 0
            })
            
            print("topicList count: \(topicList.count)");
            for i in 0..<topicList.count {
                print("topic \(i) chats count: \(topicList[i].chatMessages.count)");
            }
            
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    // Main chat logic
    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        // No chat history, or the selected topic is completed, which means it's the first chat in the topic
        let isFirstChat = chatList.isEmpty || selectedTopicIndex == nil || topicList[selectedTopicIndex ?? 0].isComplete ?? false
        
        if !userMessage.isEmpty && !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            var userChatMessage = ChatMessage(
                id: UUID().uuidString,
                role: .user,
                content: userMessage,
                type: .text,
                createAt: Date().timeIntervalSince1970,
                status: .sending
            )
            let waitForResponseMessage = ChatMessage(
                id: UUID().uuidString,
                role: .assistant,
                content: "...",
                type: .text,
                createAt: Date().timeIntervalSince1970,
                status: .waiting
            )
            
            // Make UI update first
            if isFirstChat {
                var firstTopicMessage = TopicMessage(
                    id: UUID().uuidString,
                    title: userMessage,
                    createTime: Date().timeIntervalSince1970,
                    isComplete: false
                )
                firstTopicMessage.chatMessages = [userChatMessage, waitForResponseMessage]
                topicList.insert(firstTopicMessage, at: 0)
                chatList = firstTopicMessage.chatMessages
                selectedTopicIndex = 0
            } else {
                topicList[selectedTopicIndex ?? 0].chatMessages.append(contentsOf: [userChatMessage, waitForResponseMessage])
                chatList.append(contentsOf: [userChatMessage, waitForResponseMessage])
            }
            
            // Reverse loop the chatList with max chat depth
            var count = 0
            var newChatList: [ChatMessage] = []
            for item in chatList.filter({ $0.status != .waiting }).reversed() {
                if count >= MAX_CHAT_DEPTH {
                    break
                }
                
                newChatList.append(item)
                count += 1
            }
            
            do {
                self.userMessage = ""
                // Reverse back the newChatContexts to positive order, then send chat message
                guard let assistantChatResponse = try await chatService.sendChat(newChatList.reversed()) else {
                    self.errMsg = "Sending chat message failed with unknown reason"
                    self.userMessage = tmpCacheUserMessage
                    return
                }
                
                if assistantChatResponse.isSuccess ?? false {
                    // Chat response is successful
                    userChatMessage.status = .done
                    // 1) Build chat message model from response
                    let assistantChatModel = assistantChatResponse.value
                    let assistantChatMessage = ChatMessage(
                        id: assistantChatModel?.id,
                        role: .assistant,
                        content: assistantChatModel?.choices?.first?.message?.content,
                        type: .text,
                        createAt: Date().timeIntervalSince1970,
                        status: .done
                    )
                    // 2) Replace 'waiting'and user sending message with the reponse message and marked 'done' user message
                    self.chatList.replaceSubrange(self.chatList.count - 2..<self.chatList.count, with: [userChatMessage, assistantChatMessage])
                    self.topicList[self.selectedTopicIndex ?? 0].chatMessages = self.chatList
                    // 3) Save chat message to database
                    if isFirstChat {
                        // 3-1) If first chat, we need to add an initial topic in database. The topic subject is the first user message content. And add the related chat messages.
                        guard let firstTopicMessage = topicList.first else {
                            self.errMsg = "Error in getting first topic"
                            self.userMessage = tmpCacheUserMessage
                            return
                        }
                        Task.detached(priority: .high) {
                            do {
                                // Add topic
                                if let topicHandler = await self.createTopicHandler(), let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue) {
                                    try await topicHandler.addTopic(data: firstTopicMessage, username: username)
                                }
                                // Add chat
                                if let chatHandler = await self.createChatHandler() {
                                    try await chatHandler.batchAddChat(data: firstTopicMessage.chatMessages, topicId: firstTopicMessage.id)
                                }
                            } catch {
                                await MainActor.run {
                                    self.errMsg = error.localizedDescription
                                }
                            }
                        }
                    } else {
                        // 3-2) If chat in existing topic, append the new chat messages to the selected topic
                        Task.detached(priority: .high) {
                            do {
                                if let chatHandler = await self.createChatHandler(), let selectedTopicId = await self.topicList[self.selectedTopicIndex ?? 0].id {
                                    let chatsOfSelectedTopic = try await chatHandler.fetchChats(byTopicId: selectedTopicId)
                                    
                                    let chatMessagesToSave = await self.chatList.filter { chatMessage in
                                        !chatsOfSelectedTopic.contains(where: { chat in
                                            chat.id == chatMessage.id && chat.content == chatMessage.content
                                        })
                                    }
                                    try await chatHandler.batchAddChat(data: chatMessagesToSave, topicId: selectedTopicId)
                                }
                            } catch {
                                await MainActor.run {
                                    self.errMsg = error.localizedDescription
                                }
                            }
                        }
                    }
                } else {
                    self.errMsg = assistantChatResponse.failureReason
                    self.userMessage = tmpCacheUserMessage
                }
            } catch {
                self.errMsg = error.localizedDescription
                self.userMessage = tmpCacheUserMessage
            }
        }
    }
    
    // Mark the specific topic as completed
    func markTopicAsCompleted(topicId: String) {
        // Mark the topic as complete
        Task.detached(priority: .high) {
            do {
                if let topicHandler = await self.createTopicHandler() {
                    let topicMessageIndex = await self.topicList.firstIndex(where: { $0.id == topicId }) ?? 0
                    var topicMessage = await self.topicList[topicMessageIndex]
                    topicMessage.isComplete = true
                    let topicToComplete = topicMessage
                    
                    try await topicHandler.updateTopic(topicId: topicId, data: topicToComplete)
                    
                    await MainActor.run {
                        self.topicList.replaceSubrange(topicMessageIndex..<topicMessageIndex + 1, with: [topicToComplete])
                    }
                }
            } catch {
                await MainActor.run {
                    self.errMsg = error.localizedDescription
                }
            }
        }
    }
    
    // Delete specific topic from database and UI
    func deleteTopic(topicId: String) {
        Task.detached(priority: .high) {
            do {
                if let topicHandler = await self.createTopicHandler() {
                    // Delete the topic from database (cascade delete relative chats)
                    try await topicHandler.deleteTopic(topicId: topicId)
                    
                    // Delete the topic in UI
                    // Decide which topic to select after deletion
                    await MainActor.run {
                        let toDeleteIndex = self.topicList.firstIndex(where: { $0.id == topicId }) ?? 0
                        self.topicList.removeAll(where: { $0.id == topicId })
                        if toDeleteIndex <= self.selectedTopicIndex ?? 0 {
                            if self.topicList.count > 0 {
                                let newIndex = (self.selectedTopicIndex ?? 0) - 1
                                self.selectedTopicIndex = newIndex >= 0 ? newIndex : 0
                            } else {
                                self.selectedTopicIndex = nil
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errMsg = error.localizedDescription
                }
            }
        }
    }
    
    // Delete all topic for current user
    func deleteAllTopic() {
        Task.detached(priority: .high) {
            do {
                // Delete all topics from database
                if let topicHandler = await self.createTopicHandler(), let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue) {
                    try await topicHandler.deleteTopic(byUsername: username)
                }
                
                await MainActor.run {
                    // Delete all topics in UI
                    self.topicList.removeAll()
                    self.selectedTopicIndex = nil
                }
            } catch {
                await MainActor.run {
                    self.errMsg = error.localizedDescription
                }
            }
        }
    }
}
