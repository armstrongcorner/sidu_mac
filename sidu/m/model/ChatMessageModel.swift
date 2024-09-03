//
//  ChatContextModel.swift
//  sidu
//
//  Created by Armstrong Liu on 03/09/2024.
//

import Foundation

enum ChatStatus: Codable {
    case sending // Sending the chat context, binary files already uploaded and returned access url
    case waiting // Waiting for GPT response, normally used to display the waiting UI widget
    case uploading // Uploading the binary file e.g: image, audio
    case done // Finish send and already get the response, mark the context as done
    case failure // Something wrong with send or get response, mark the context as failure and show
}

struct ChatMessageModel: Codable, Hashable, Identifiable {
    var id: String?
    var role: String?
    var content: String?
    var type: String?
    var fileAccessUrl: String?
    var sentSize: Int?
    var receivedSize: Int?
    var totalSize: Int?
    var createAt: Int?
    var status: ChatStatus?
    var isCompleteChatFlag: Bool?
}
