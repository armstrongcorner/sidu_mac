//
//  ChatView.swift
//  sidu
//
//  Created by Armstrong Liu on 02/09/2024.
//

import SwiftUI
import Combine

struct ChatView: View {
    @Binding var chatContexts: [ChatMessageModel]
    
    var body: some View {
        // Using ScrollViewReader to keep the chat view at the bottom when new message comes
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(chatContexts) { chatContext in
                        ChatRow(chatContext)
                    }
                }
            }
            .onReceive(Just(chatContexts)) { _ in
                withAnimation {
                    proxy.scrollTo(chatContexts.last?.id, anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    let chatContext1 = ChatMessageModel(
        id: UUID().uuidString,
        role: "user",
        content: "Test preview message",
        type: "text",
        createAt: Int(Date().timeIntervalSince1970),
        status: .sending,
        isCompleteChatFlag: false
    )
    let chatContext2 = ChatMessageModel(
        id: UUID().uuidString,
        role: "user",
        content: "Another test preview message",
        type: "text",
        createAt: Int(Date().timeIntervalSince1970),
        status: .sending,
        isCompleteChatFlag: false
    )
    let chatContext3 = ChatMessageModel(
        id: UUID().uuidString,
        role: "user",
        content: "111",
        type: "text",
        createAt: Int(Date().timeIntervalSince1970),
        status: .sending,
        isCompleteChatFlag: false
    )
    let chatContext4 = ChatMessageModel(
        id: UUID().uuidString,
        role: "user",
        content: "在 Swift 中，你可以定义一个通用的数据类型来表示可能具有不同类型值的字段。在你的例子中，我们希望定义一个名为 ChatMessageModel 的结构体，其中 content 字段的类型不确定，可能是 String，Image，或 Data。",
        type: "text",
        createAt: Int(Date().timeIntervalSince1970),
        status: .sending,
        isCompleteChatFlag: false
    )
    
    return ChatView(chatContexts: .constant([chatContext1, chatContext2, chatContext3, chatContext4]))
        .environment(AppSize(CGSize(width: 1024, height: 768)))
}
