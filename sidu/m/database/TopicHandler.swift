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
    
    @discardableResult
    func addTopic(data: TopicMessage, username: String) throws -> PersistentIdentifier {
        let topic = Topic(fromContextModel: data)
        let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userName == username })
        let users = try context.fetch(fetchDescriptor)
    
        topic.user = users.first
        
        context.insert(topic)
        if context.hasChanges {
            try context.save()
        }
        
        return topic.persistentModelID
    }

    func fetchTopics(byUsername username: String) throws -> [TopicMessage] {
        let fetchDescriptor = FetchDescriptor<Topic>(
            predicate: #Predicate { $0.user?.userName == username }
        )
        let topics = try context.fetch(fetchDescriptor)
        
        return topics.map { topic in
            TopicMessage(
                id: topic.id,
                title: topic.title,
                createTime: topic.createTime,
                isComplete: topic.isComplete
            )
        }
    }

    func updateTopic(id: PersistentIdentifier, data: TopicMessage) throws {
        guard let topic = self[id, as: Topic.self] else { return }
        
        topic.id = data.id
        topic.title = data.title
        topic.createTime = data.createTime
        topic.isComplete = data.isComplete
        
        try context.save()
    }
 
    func updateTopic(topicId: String, data: TopicMessage) throws {
        let fetchDescriptor = FetchDescriptor<Topic>(predicate: #Predicate { $0.id == topicId })
        let topics = try context.fetch(fetchDescriptor)
        if let topicToUpdate = topics.first {
            topicToUpdate.id = data.id
            topicToUpdate.title = data.title
            topicToUpdate.createTime = data.createTime
            topicToUpdate.isComplete = data.isComplete
            
            try context.save()
        }
    }

    func deleteTopic(id: PersistentIdentifier) throws {
        guard let topic = self[id, as: Topic.self] else { return }
        context.delete(topic)
        if context.hasChanges {
            try context.save()
        }
    }

    func deleteTopic(topicId: String) throws {
        let fetchDescriptor = FetchDescriptor<Topic>(predicate: #Predicate { $0.id == topicId })
        let topics = try context.fetch(fetchDescriptor)
        if let topicToDelete = topics.first {
            context.delete(topicToDelete)
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    func deleteTopic(byUsername username: String) throws {
        let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.userName == username })
        let users = try context.fetch(fetchDescriptor)
        if let user = users.first {
            for topic in user.topics {
                context.delete(topic)
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
