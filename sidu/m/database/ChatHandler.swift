//
//  ChatHandler.swift
//  sidu
//
//  Created by Armstrong Liu on 28/10/2024.
//

import Foundation
import SwiftData

@ModelActor
actor ChatHandler {
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    @discardableResult
    func addChat(data: ChatMessage, topicPersistentId: PersistentIdentifier? = nil) throws -> PersistentIdentifier {
        let chat = Chat(fromContextModel: data)
        if let topicId = topicPersistentId, let topic = self[topicId, as: Topic.self] {
            chat.topic = topic
        }
        
        context.insert(chat)
        if context.hasChanges {
            try context.save()
        }
        
        return chat.persistentModelID
    }
    
    @discardableResult
    func addChat(data: ChatMessage, topicId: String? = nil) throws -> PersistentIdentifier {
        let chat = Chat(fromContextModel: data)
        let fetchDescriptor = FetchDescriptor<Topic>(predicate: #Predicate { $0.id == topicId })
        let topics = try context.fetch(fetchDescriptor)
    
        chat.topic = topics.first
        
        context.insert(chat)
        if context.hasChanges {
            try context.save()
        }
        
        return chat.persistentModelID
    }

    func batchAddChat(data: [ChatMessage], topicId: String? = nil) throws {
        let fetchDescriptor = FetchDescriptor<Topic>(predicate: #Predicate { $0.id == topicId })
        let topics = try context.fetch(fetchDescriptor)
        
        for chatMessage in data {
            let chat = Chat(fromContextModel: chatMessage)
            chat.topic = topics.first
            
            context.insert(chat)
        }
        
        if context.hasChanges {
            try context.save()
        }
    }

    func fetchChats(byTopicId topicId: String) throws -> [ChatMessage] {
        let fetchDescriptor = FetchDescriptor<Chat>(
            predicate: #Predicate { $0.topic?.id == topicId }
        )
        let chats = try context.fetch(fetchDescriptor)
        
        return chats.map { chat in
            ChatMessage(
                id: chat.id,
                role: chat.role,
                content: chat.content,
                type: chat.type,
                fileAccessUrl: chat.fileAccessUrl,
                createAt: chat.createAt,
                status: chat.status
            )
        }
    }

    func updateChat(id: PersistentIdentifier, data: ChatMessage) throws {
        guard let chat = self[id, as: Chat.self] else { return }
        
        chat.role = data.role
        chat.content = data.content
        chat.type = data.type
        chat.fileAccessUrl = data.fileAccessUrl
        chat.createAt = data.createAt
        chat.status = data.status

        try context.save()
    }
    
    func deleteChat(id: PersistentIdentifier) throws {
        guard let chat = self[id, as: Chat.self] else { return }
        context.delete(chat)
        if context.hasChanges {
            try context.save()
        }
    }
}
