//
//  Chat.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftData
import SwiftUI

typealias Chat = SchemaV1.Chat

extension SchemaV1 {
    @Model
    final class Chat {
        @Attribute(.unique) var id: String?
        var role: ChatRole?
        var content: String?
        var type: ChatContentType?
        var fileAccessUrl: String?
        var createAt: TimeInterval?
        var status: ChatStatus?
        
        var topic: Topic?
        
        init(id: String?, role: ChatRole?, content: String?, type: ChatContentType?, fileAccessUrl: String?, createAt: TimeInterval?, status: ChatStatus?, topic: Topic? = nil) {
            self.id = id
            self.role = role
            self.content = content
            self.type = type
            self.fileAccessUrl = fileAccessUrl
            self.createAt = createAt
            self.status = status
            
            self.topic = topic
        }
        
        init(fromContextModel chatMessageModel: ChatMessage, topic: Topic? = nil) {
            self.id = chatMessageModel.id
            self.role = chatMessageModel.role
            self.content = chatMessageModel.content
            self.type = chatMessageModel.type
            self.fileAccessUrl = chatMessageModel.fileAccessUrl
            self.createAt = chatMessageModel.createAt
            self.status = chatMessageModel.status
            
            self.topic = topic
        }
    }
}
