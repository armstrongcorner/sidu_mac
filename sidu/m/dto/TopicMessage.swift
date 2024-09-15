//
//  TopicMessage.swift
//  sidu
//
//  Created by Armstrong Liu on 15/09/2024.
//

import Foundation

struct TopicMessage: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var title: String?
    var createTime: Int?
    var isComplete: Bool?
    
    var chatMessages: [ChatMessage] = []
}
