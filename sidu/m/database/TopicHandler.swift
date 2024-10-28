//
//  TopicHandler.swift
//  sidu
//
//  Created by Armstrong Liu on 28/10/2024.
//

import Foundation
import SwiftData

@ModelActor
actor TopicHandler {
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    @discardableResult
    func addTopic(data: TopicMessage, userId: PersistentIdentifier? = nil) throws -> PersistentIdentifier {
        let topic = Topic(fromContextModel: data)
        if let userId = userId, let user = self[userId, as: User.self] {
            topic.user = user
        }
        
        context.insert(topic)
        if context.hasChanges {
            try context.save()
        }
        
        return topic.persistentModelID
    }

    public func updateTopic(id: PersistentIdentifier, data: TopicMessage) throws {
        guard let topic = self[id, as: Topic.self] else { return }
        
        topic.title = data.title
        topic.createTime = data.createTime
        topic.isComplete = data.isComplete
        
        try context.save()
    }
    
    public func deleteTopic(id: PersistentIdentifier) throws {
        guard let topic = self[id, as: Topic.self] else { return }
        context.delete(topic)
        if context.hasChanges {
            try context.save()
        }
    }
}
