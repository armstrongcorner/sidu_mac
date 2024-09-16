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
    
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol = ChatService(), selectedTopicIndex: Int? = nil, topicList: [TopicMessage] = []) {
        self.chatService = chatService
        self.topicList = topicList
        self.selectedTopicIndex = selectedTopicIndex
    }
    
    func getCurrentUser() throws -> User? {
        let username = UserDefaults.standard.string(forKey: CacheKey.username.rawValue)
        return try User.fetchUser(byUsername: username, context: modelContext)
    }
    
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
                let topicMessage = topicList[i]
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
    
    func sendChat() async {
        let tmpCacheUserMessage: String = userMessage
        // No chat history, or the topic is completed, then it's the first chat in the topic
        let isFirstChat = chatList.isEmpty || selectedTopicIndex == nil || topicList[selectedTopicIndex ?? 0].isComplete ?? false
        
        if !userMessage.isEmpty && !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let userChatMessage = ChatMessage(
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
                let firstTopicMessage = TopicMessage(
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
                DispatchQueue.main.async {
                    self.userMessage = ""
                }
                // Reverse back the newChatContexts to positive order, then send chat message
                guard let assistantChatResponse = try await chatService.sendChat(newChatList.reversed()) else {
                    DispatchQueue.main.async {
                        self.errMsg = "Sending chat message failed with unknown reason"
                        self.userMessage = tmpCacheUserMessage
                    }
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
                    DispatchQueue.main.async {
                        self.chatList.replaceSubrange(self.chatList.count - 1..<self.chatList.count, with: [assistantChatMessage])
                        self.topicList[self.selectedTopicIndex ?? 0].chatMessages = self.chatList
                    }
                    // 3) Save chat message to database
                    if isFirstChat {
                        // 3-1) If first chat, we need to add an initial topic in database. The topic subject is the first user message. And add the related chat messages.
                        guard let currentUser = try getCurrentUser() else {
                            DispatchQueue.main.async {
                                self.errMsg = "Current user not found"
                                self.userMessage = tmpCacheUserMessage
                            }
                            return
                        }
                        guard let firstTopicMessage = topicList.first else {
                            DispatchQueue.main.async {
                                self.errMsg = "Error in getting first topic"
                                self.userMessage = tmpCacheUserMessage
                            }
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
                            DispatchQueue.main.async {
                                self.errMsg = "Current topic not found"
                                self.userMessage = tmpCacheUserMessage
                            }
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
    
    func markTopicAsCompleted(topicId: String) {
        do {
            // Mark the topic as complete
            let topic = try Topic.fetchTopicById(topicId: topicId, context: modelContext)
            topic?.isComplete = true
            let topicMessageIndex = topicList.firstIndex(where: { $0.id == topicId }) ?? 0
            let topicMessage = topicList[topicMessageIndex]
            topicMessage.isComplete = true
            topicList.replaceSubrange(topicMessageIndex..<topicMessageIndex + 1, with: [topicMessage])
        } catch {
            self.errMsg = error.localizedDescription
        }
    }
    
    func deleteTopic(topic: Topic) async {
//        do {
//            let indexToDelete = topicList.firstIndex(where: { $0.id == topic.id }) ?? 0
//            
////            print("\n\n\nselected topic title: \(topicList[indexToDelete].title ?? "")\n")
////            for i in 0..<chatContexts.count {
////                print("topic \(i) title: \(topicList[i].title ?? "")")
////            }
//            
//            guard let currentUser = try getCurrentUser() else {
//                DispatchQueue.main.async {
//                    self.errMsg = "Current user not found"
//                }
//                return
//            }
//            
//            // Decide which topic should be selected after delete
//            if topicList.count > 1 {
//                // More than one topic before delete
//                if indexToDelete <= selectedTopicIndex ?? 0 {
//                    // When to-be-deleted topic is before selected topic
////                    currentUser.topics.remove(at: indexToDelete)
//                    let newIndex = (selectedTopicIndex ?? 0) - 1
//                    selectedTopicIndex = newIndex >= 0 ? newIndex : 0
//                }
//            } else {
//                // Only one topic, then no one should be selected after delete
//                selectedTopicIndex = nil
//                currentTopic = nil
//                chatContexts = []
//            }
//            
//            // Delete the topic
//            currentUser.topics.remove(at: indexToDelete)
////            topicList.remove(at: indexToDelete)
//            DispatchQueue.main.async {
//                Task {
//                    await self.getTopicList()
//                }
//            }
//            if selectedTopicIndex != nil {
//                currentTopic = topicList[selectedTopicIndex ?? 0]
//            }
//            print("aaa: \(currentUser.topics.count)")
//            print("bbb: \(topicList.count)")
//            
////            currentUser.topics.remove(at: indexToDelete)
//////            try Topic.deleteTopic(topic: topic, context: modelContext)
////            await getTopicList()
////            if selectedTopicIndex ?? 0 >= indexToDelete {
////                let newIndex = (selectedTopicIndex ?? 0) - 1
////                selectedTopicIndex = newIndex >= 0 ? newIndex : 0
////            }
////            if topicList.count > 0 {
////                currentTopic = topicList[selectedTopicIndex ?? 0]
////            } else {
////                currentTopic = nil
////            }
//            
//        } catch {
//            self.errMsg = error.localizedDescription
//        }
    }
}
