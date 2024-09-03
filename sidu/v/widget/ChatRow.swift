//
//  ChatRow.swift
//  sidu
//
//  Created by Armstrong Liu on 03/09/2024.
//

import SwiftUI

struct ChatRow: View {
    @Environment(AppSize.self) var appSize
    
    var chatContext: ChatMessageModel
    
    init(_ chatContext: ChatMessageModel) {
        self.chatContext = chatContext
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer(minLength: appSize.getScreenWidth() * 0.1)
            Text("\(chatContext.content ?? "")")
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .shadowAndRoundedCorner(color: .userMsgBg, radius: 5, shadowRadius: 1)
                .padding(.top, 6)
            Image(systemName: "person")
                .resizable()
                .frame(width: 15, height: 15)
                .aspectRatio(contentMode: .fit)
                .padding(.top, 10)
                .padding(.trailing, 5)
        }
        .id(chatContext.id)
    }
}

#Preview {
    let chatContext = ChatMessageModel(
        id: UUID().uuidString,
        role: "user",
        content: "Test preview message",
        type: "text",
        createAt: Int(Date().timeIntervalSince1970),
        status: .sending,
        isCompleteChatFlag: false
    )
    
    return Group {
        ChatRow(chatContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
        ChatRow(chatContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
        ChatRow(chatContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
    }
}
