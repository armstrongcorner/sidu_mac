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
    }
}
