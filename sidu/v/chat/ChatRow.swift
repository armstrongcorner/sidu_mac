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
    var lastChatContext: ChatMessageModel?
    
    init(_ chatContext: ChatMessageModel, lastChatContext: ChatMessageModel? = nil) {
        self.chatContext = chatContext
        self.lastChatContext = lastChatContext
    }
    
    var body: some View {
        VStack {
            // Chat time label (only shown when the time difference between two chat messages is more than 5 minutes)
            if DateUtil.shared.compareTimeDifference(startTimeStamp: lastChatContext?.createAt ?? 0, endTimeStamp: chatContext.createAt ?? 0, inUnit: .minute) > 5 {
                Text(DateUtil.shared.decideToShowDateTime(chatContext.createAt ?? 0))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            // Chat content
            if chatContext.role == .user {
                HStack(alignment: .top) {
                    Spacer(minLength: appSize.getScreenWidth() * 0.1)
                    Text("\(chatContext.content ?? "")")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .shadowAndRoundedCorner(color: .userMsgBg, radius: 5, shadowRadius: 1)
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 4)
                        .padding(.trailing, 5)
                }
                .id(chatContext.id)
            } else if chatContext.role == .assistant {
                HStack(alignment: .top) {
                    Image("gpt_icon")
                        .resizable()
                        .frame(width: 17, height: 17)
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 4)
                        .padding(.leading, 5)
                    Text("\(chatContext.content ?? "")")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .shadowAndRoundedCorner(color: .white, radius: 5, shadowRadius: 1)
                    Spacer(minLength: appSize.getScreenWidth() * 0.1)
                }
                .id(chatContext.id)
            }
        }
    }
}

#Preview {
    let chatContext = ChatMessageModel(
        id: UUID().uuidString,
        role: .user,
        content: "Test preview message",
        type: .text,
        createAt: Int(Date().timeIntervalSince1970),
        status: .sending,
        isCompleteChatFlag: false
    )
    let waitForResponseContext = ChatMessageModel(
        id: UUID().uuidString,
        role: .assistant,
        content: "...",
        type: .text,
        createAt: Int(Date().timeIntervalSince1970),
        status: .waiting,
        isCompleteChatFlag: false
    )
    let gptResponseContext = ChatMessageModel(
        id: UUID().uuidString,
        role: .assistant,
        content: "你说的对，使用 .padding(.top, -40) 这样的负值时，会改变视图的布局方式，从而可能导致点击事件不起作用。具体来说，负的 padding 会将视图向相反的方向移动，但它并不会扩展视图的点击区域，反而可能会导致视图的点击区域缩小甚至消失。",
        type: .text,
        createAt: Int(Date().timeIntervalSince1970),
        status: .done,
        isCompleteChatFlag: false
    )
    
    return Group {
        ChatRow(chatContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
        ChatRow(chatContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
        ChatRow(waitForResponseContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
        ChatRow(chatContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
        ChatRow(gptResponseContext)
            .environment(AppSize(CGSize(width: 1024, height: 768)))
    }
}
