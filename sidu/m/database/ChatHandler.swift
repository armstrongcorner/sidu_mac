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
    func addChat(data: ChatMessage, topicId: PersistentIdentifier? = nil) throws -> PersistentIdentifier {
        let chat = Chat(fromContextModel: data)
        if let topicId = topicId, let topic = self[topicId, as: Topic.self] {
            chat.topic = topic
        }
        
        context.insert(chat)
        if context.hasChanges {
            try context.save()
        }
        
        return chat.persistentModelID
    }

    public func updateChat(id: PersistentIdentifier, data: ChatMessage) throws {
        guard let chat = self[id, as: Chat.self] else { return }
        
        chat.role = data.role
        chat.content = data.content
        chat.type = data.type
        chat.fileAccessUrl = data.fileAccessUrl
        chat.createAt = data.createAt
        chat.status = data.status

        try context.save()
    }
    
    public func deleteChat(id: PersistentIdentifier) throws {
        guard let chat = self[id, as: Chat.self] else { return }
        context.delete(chat)
        if context.hasChanges {
            try context.save()
        }
    }
}
