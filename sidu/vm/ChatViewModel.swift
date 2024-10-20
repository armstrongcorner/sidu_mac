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
    
    var modelContext: ModelContext?
    
    @ObservationIgnored
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol = ChatService(), selectedTopicIndex: Int? = nil, topicList: [TopicMessage] = []) {
        self.chatService = chatService
        self.topicList = topicList
        self.selectedTopicIndex = selectedTopicIndex
    }
    
    // Get current user from database
    func getCurrentUser() throws -> User? {
        let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
        return try User.fetchUser(byUsername: username, context: modelContext)
    }
    
    // Get all topic and related chats for current user
    func getTopicAndChat() {
        do {
            // Get current user's topics
            let currentUser = try getCurrentUser()
            
            // Load topic list
            topicList = (currentUser?.topics ?? []).map({ topic in
                TopicMessage(
                    id: topic.id,
                    title: topic.title,
                    createTime: topic.createTime,
                    isComplete: topic.isComplete
                )
            }).sorted(by: { topicMessage1, topicMessage2 in
                topicMessage1.createTime ?? 0 > topicMessage2.createTime ?? 0
            })
            
            // Load chat list for all topics
            for i in 0..<topicList.count {
                var topicMessage = topicList[i]
                let topic = try Topic.fetchTopicById(topicId: topicMessage.id ?? "", context: modelContext)
                let chatList = (topic?.chats ?? []).map({ chat in
                    ChatMessage(
                        id: chat.id,
                        role: chat.role == .user ? .user : .assistant,
                        content: chat.content,
                        type: chat.type == .text ? .text : .image,
                        createAt: chat.createAt,
                        status: chat.status
                    )
                }).sorted(by: { chatMessage1, chatMessage2 in
                    chatMessage1.createAt ?? 0 < chatMessage2.createAt ?? 0
                })
                topicMessage.chatMessages = chatList
            }
            
            print("topicList count: \(self.topicList.count)");
            for i in 0..<self.topicList.count {
                print("topic \(i) chats count: \(self.topicList[i].chatMessages.count)");
            }
            
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    // Main chat logic
    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        // No chat history, or the topic is completed, then it's the first chat in the topic
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
                    // 2) Replace 'waiting' message with the reponse Message
                    self.chatList.replaceSubrange(self.chatList.count - 1..<self.chatList.count, with: [assistantChatMessage])
                    self.topicList[self.selectedTopicIndex ?? 0].chatMessages = self.chatList
                    // 3) Save chat message to database
                    if isFirstChat {
                        // 3-1) If first chat, we need to add an initial topic in database. The topic subject is the first user message. And add the related chat messages.
                        guard let currentUser = try getCurrentUser() else {
                            self.errMsg = "Current user not found"
                            self.userMessage = tmpCacheUserMessage
                            return
                        }
                        guard let firstTopicMessage = topicList.first else {
                            self.errMsg = "Error in getting first topic"
                            self.userMessage = tmpCacheUserMessage
                            return
                        }
                        let firstTopic = Topic(fromContextModel: firstTopicMessage, user: currentUser)
                        try Topic.addTopic(topic: firstTopic, context: modelContext)
                        for i in 0..<firstTopicMessage.chatMessages.count {
                            let chatMessage = firstTopicMessage.chatMessages[i]
                            let chat = Chat(fromContextModel: chatMessage, topic: firstTopic)
                            firstTopic.chats.append(chat)
                        }
                    } else {
                        // 3-2) If chat in existing topic, retrieve the topic from database and add the chat messages
                        guard let currentTopic = try Topic.fetchTopicById(topicId: topicList[selectedTopicIndex ?? 0].id ?? "", context: modelContext) else {
                            self.errMsg = "Current topic not found"
                            self.userMessage = tmpCacheUserMessage
                            return
                        }
                        print("BEFORE currentTopic chats count: \(currentTopic.chats.count)")
                        print("\n")
                        
                        let chatMessagesToSave = chatList.filter { chatMessage in
                            !currentTopic.chats.contains(where: { chat in
                                chat.id == chatMessage.id && chat.content == chatMessage.content
                            })
                        }
                        for chatMessage in chatMessagesToSave {
                            let chat = Chat(fromContextModel: chatMessage)
                            currentTopic.chats.append(chat)
                        }
                        print("AFTER currentTopic chats count: \(currentTopic.chats.count)")
                        print("\n")
                        
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
        do {
            // Mark the topic as complete
            let topic = try Topic.fetchTopicById(topicId: topicId, context: modelContext)
            topic?.isComplete = true
            let topicMessageIndex = topicList.firstIndex(where: { $0.id == topicId }) ?? 0
            var topicMessage = topicList[topicMessageIndex]
            topicMessage.isComplete = true
            topicList.replaceSubrange(topicMessageIndex..<topicMessageIndex + 1, with: [topicMessage])
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    // Delete specific topic from database and UI
    func deleteTopic(topicId: String) {
        do {
            // Delete the topic from database
            guard let currentUser = try getCurrentUser() else {
                self.errMsg = "Current user not found"
                return
            }
            currentUser.topics.removeAll(where: { $0.id == topicId })
            
            // Delete the topic in UI
            // Decide which topic to select after deletion
            let toDeleteIndex = topicList.firstIndex(where: { $0.id == topicId }) ?? 0
            self.topicList.removeAll(where: { $0.id == topicId })
            if toDeleteIndex <= selectedTopicIndex ?? 0 {
                if topicList.count > 0 {
                    let newIndex = (selectedTopicIndex ?? 0) - 1
                    selectedTopicIndex = newIndex >= 0 ? newIndex : 0
                } else {
                    selectedTopicIndex = nil
                }
            }
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    // Delete all topic for current user
    func deleteAllTopic() {
        do {
            // Delete all topics from database
            guard let currentUser = try getCurrentUser() else {
                self.errMsg = "Current user not found"
                return
            }
            currentUser.topics.removeAll()
            
            // Delete all topics in UI
            self.topicList.removeAll()
            selectedTopicIndex = nil
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
}
