//
//  Chat.swift
//  sidu
//
//  Created by Armstrong Liu on 08/09/2024.
//

import SwiftData

@Model
class Chat {
    @Attribute(.unique) var id: String?
    var role: ChatRole?
    var content: String?
    var type: ChatContentType?
    var fileAccessUrl: String?
    var createAt: Int?
    var status: ChatStatus?
    
    var topic: Topic?
    
    init(id: String?, role: ChatRole?, content: String?, type: ChatContentType?, fileAccessUrl: String?, createAt: Int?, status: ChatStatus?, topic: Topic?) {
        self.id = id
        self.role = role
        self.content = content
        self.type = type
        self.fileAccessUrl = fileAccessUrl
        self.createAt = createAt
        self.status = status
        self.topic = topic
    }
}
