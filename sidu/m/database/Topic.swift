//
//  Topic.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftUI
import SwiftData

@Model
class Topic {
    @Attribute(.unique) var id: String = UUID().uuidString
    var title: String?
    var createTime: Int?
    var isComplete: Bool?
    
    var user: User?
    var chats: [Chat] = []
    
    init(title: String?, createTime: Int?, isComplete: Bool?, user: User?) {
        self.title = title
        self.createTime = createTime
        self.isComplete = isComplete
        self.user = user
    }
    
    static func fetchTopic(for user: User, context: ModelContext) throws -> [Topic]? {
        // Using user id to fetch the topic
        let predicate = #Predicate<Topic> { $0.user?.id == user.id }
        // Lastest topic first
        let sortDescriptor = SortDescriptor(\Topic.createTime, order: .reverse)
        
        let fetchDescriptor = FetchDescriptor<Topic>(predicate: predicate, sortBy: [sortDescriptor])
        
        return try? context.fetch(fetchDescriptor)
    }
}
