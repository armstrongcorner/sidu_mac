//
//  TopicMessage.swift
//  sidu
//
//  Created by Armstrong Liu on 15/09/2024.
//

import Foundation

class TopicMessage {
    var id: String?
    var title: String?
    var createTime: Int?
    var isComplete: Bool?
    
    var chatMessages: [ChatMessage] = []
    
    init(id: String? = nil, title: String? = nil, createTime: Int? = nil, isComplete: Bool? = nil) {
        self.id = id
        self.title = title
        self.createTime = createTime
        self.isComplete = isComplete
    }
}
