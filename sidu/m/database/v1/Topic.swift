//
//  Topic.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftUI
import SwiftData

typealias Topic = SchemaV1.Topic

extension SchemaV1 {
    @Model
    final class Topic {
        @Attribute(.unique) var id: String?
        var title: String?
        var createTime: TimeInterval?
        var isComplete: Bool?
        
        var user: User?
        @Relationship(deleteRule: .cascade) var chats: [Chat]
        
        init(id: String?, title: String?, createTime: TimeInterval?, isComplete: Bool?, user: User? = nil, chats: [Chat] = []) {
            self.id = id
            self.title = title
            self.createTime = createTime
            self.isComplete = isComplete
            
            self.user = user
            self.chats = chats
        }
        
        init(fromContextModel topicMessageModel: TopicMessage, user: User? = nil, chats: [Chat] = []) {
            self.id = topicMessageModel.id
            self.title = topicMessageModel.title
            self.createTime = topicMessageModel.createTime
            self.isComplete = topicMessageModel.isComplete
            
            self.user = user
            self.chats = chats
        }
        
        static func addTopic(topic: Topic, context: ModelContext?) throws {
            context?.insert(topic)
            if context?.hasChanges ?? false {
                try context?.save()
            }
        }
        
        static func fetchTopic(for user: User, context: ModelContext?) throws -> [Topic]? {
            // Using user id to fetch the topic
            /**
             We have to make this constant or variable to use for the predicate, otherwise it will crash
             See this thread: https://stackoverflow.com/questions/77039981/swiftdata-query-with-predicate-on-relationship-model
             it seems that the predicate is not able to capture the user.id directly or #Predicate will not let you use another @Model in the code block.
             */
            let userId = user.id
            let predicate = #Predicate<Topic> { $0.user?.id == userId }
            // Lastest topic first
            let sortDescriptor = SortDescriptor(\Topic.createTime, order: .reverse)
            
            let fetchDescriptor = FetchDescriptor<Topic>(predicate: predicate, sortBy: [sortDescriptor])
            
            return try? context?.fetch(fetchDescriptor)
        }
        
        static func fetchTopicById(topicId: String, context: ModelContext?) throws -> Topic? {
            let fetchDescriptor = FetchDescriptor<Topic>(predicate: #Predicate<Topic> { $0.id == topicId })
            return try? context?.fetch(fetchDescriptor).first
        }
        
        static func updateTopic(topic: Topic, context: ModelContext?) throws {
            // Fetch the topic by id
            let topicId = topic.id
            let fetchDescriptor = FetchDescriptor<Topic>(predicate: #Predicate<Topic> { $0.id == topicId })
            // Update the topic
            if let topicToUpdate = try context?.fetch(fetchDescriptor) {
                topicToUpdate.first?.title = topic.title
                topicToUpdate.first?.createTime = topic.createTime
                topicToUpdate.first?.isComplete = topic.isComplete
                if context?.hasChanges ?? false {
                    try context?.save()
                }
            }
        }
        
        static func deleteTopic(topic: Topic, context: ModelContext?) throws {
            //        let topicId = topic.id
            //        // Delete the topic
            //        try context?.delete(model: Topic.self, where: #Predicate<Topic> { $0.id == topicId })
            //        if context?.hasChanges ?? false {
            //            try context?.save()
            //        }
            context?.delete(topic)
            if context?.hasChanges ?? false {
                try context?.save()
            }
        }
    }
}
