//
//  Chat.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftData
import SwiftUI

@Model
final class Chat {
    @Attribute(.unique) var id: String?
    var role: ChatRole?
    var content: String?
    var type: ChatContentType?
    var fileAccessUrl: String?
    var createAt: Int?
    var status: ChatStatus?
    var isCompleteChatFlag: Bool?
    
    var topic: Topic?
    
    init(id: String?, role: ChatRole?, content: String?, type: ChatContentType?, fileAccessUrl: String?, createAt: Int?, status: ChatStatus?, isCompleteChatFlag: Bool?, topic: Topic?) {
        self.id = id
        self.role = role
        self.content = content
        self.type = type
        self.fileAccessUrl = fileAccessUrl
        self.createAt = createAt
        self.status = status
        self.isCompleteChatFlag = isCompleteChatFlag
        self.topic = topic
    }
    
    init(fromContextModel chatMessageModel: ChatMessageModel) {
        self.id = chatMessageModel.id
        self.role = chatMessageModel.role
        self.content = chatMessageModel.content
        self.type = chatMessageModel.type
        self.fileAccessUrl = chatMessageModel.fileAccessUrl
        self.createAt = chatMessageModel.createAt
        self.status = chatMessageModel.status
        self.isCompleteChatFlag = chatMessageModel.isCompleteChatFlag
    }
    
    static func addChat(chat: Chat, context: ModelContext?) throws {
        context?.insert(chat)
        if context?.hasChanges ?? false {
            try context?.save()
        }
    }
    
    static func fetchChat(for topic: Topic, context: ModelContext) throws -> [Chat]? {
        // Using topic id to fetch the chat
        let topicId = topic.id
        let predicate = #Predicate<Chat> { $0.topic?.id == topicId }
        // Forward order
        let sortDescriptor = SortDescriptor(\Chat.createAt, order: .forward)
        
        let fetchDescriptor = FetchDescriptor<Chat>(predicate: predicate, sortBy: [sortDescriptor])
        
        return try? context.fetch(fetchDescriptor)
    }
    
    static func updateChat(chat: Chat, context: ModelContext?) throws {
        // Fetch the chat by id
        let chatId = chat.id
        let fetchDescriptor = FetchDescriptor<Chat>(predicate: #Predicate<Chat> { $0.id == chatId })
        // Update the chat
        if let chatToUpdate = try context?.fetch(fetchDescriptor) {
            chatToUpdate.first?.role = chat.role
            chatToUpdate.first?.content = chat.content
            chatToUpdate.first?.type = chat.type
            chatToUpdate.first?.fileAccessUrl = chat.fileAccessUrl
            chatToUpdate.first?.createAt = chat.createAt
            chatToUpdate.first?.status = chat.status
            chatToUpdate.first?.isCompleteChatFlag = chat.isCompleteChatFlag
            if context?.hasChanges ?? false {
                try context?.save()
            }
        }
    }
    
    static func deleteChat(chat: Chat, context: ModelContext?) throws {
        let chatId = chat.id
        // Delete the chat
        try context?.delete(model: Chat.self, where: #Predicate<Chat> { $0.id == chatId })
        if context?.hasChanges ?? false {
            try context?.save()
        }
    }
}
