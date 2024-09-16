//
//  ChatRow.swift
//  sidu
//
//  Created by Armstrong Liu on 03/09/2024.
//

import SwiftUI

struct ChatRow: View {
    @Environment(AppSize.self) var appSize
    
    @Binding var chatVM: ChatViewModel
    
    var chatMessage: ChatMessage
    var beforeChatMessage: ChatMessage?
    
    init(_ chatMessage: ChatMessage, beforeChatMessage: ChatMessage? = nil, chatVM: Binding<ChatViewModel>) {
        self.chatMessage = chatMessage
        self.beforeChatMessage = beforeChatMessage
        self._chatVM = chatVM
    }
    
    var body: some View {
        VStack {
            // Chat time label (only shown when the time difference between two chat messages is more than 5 minutes)
            if DateUtil.shared.compareTimeDifference(startTimeStamp: beforeChatMessage?.createAt ?? 0, endTimeStamp: chatMessage.createAt ?? 0, inUnit: .minute) > 5 {
                Text(DateUtil.shared.decideToShowDateTime(chatMessage.createAt ?? 0))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            // Chat content
            if chatMessage.role == .user {
                HStack(alignment: .top) {
                    Spacer(minLength: appSize.getScreenWidth() * 0.1)
                    Text("\(chatMessage.content ?? "")")
                        .textSelection(.enabled)
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
                .id(chatMessage.id)
            } else if chatMessage.role == .assistant {
                HStack(alignment: .top) {
                    Image("gpt_icon")
                        .resizable()
                        .frame(width: 17, height: 17)
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 4)
                        .padding(.leading, 5)
                    Text("\(chatMessage.content ?? "")")
                        .textSelection(.enabled)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .shadowAndRoundedCorner(color: .white, radius: 5, shadowRadius: 1)
                    Spacer(minLength: appSize.getScreenWidth() * 0.1)
                }
                .id(chatMessage.id)
                
                if chatMessage.status != .waiting && chatVM.chatList.last?.id == chatMessage.id {
                    if chatVM.topicList[chatVM.selectedTopicIndex ?? 0].isComplete ?? false {
                        // Show chat end message, if chat is complete
                        Text("Chat is completed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    } else {
                        // Show manually end chat button, if chat is not complete
                        HStack {
                            Button {
                                print("End chat button clicked")
                                chatVM.markTopicAsCompleted(topicId: chatVM.topicList[chatVM.selectedTopicIndex ?? 0].id ?? "")
                            } label: {
                                Text("Click to end chat")
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .shadowAndRoundedCorner(color: .userMsgBg, radius: 5, shadowRadius: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.leading, 30)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    let chatContext = ChatMessageModel(
//        id: UUID().uuidString,
//        role: .user,
//        content: "Test preview message",
//        type: .text,
//        createAt: Int(Date().timeIntervalSince1970),
//        status: .sending,
//        isCompleteChatFlag: false
//    )
//    let waitForResponseContext = ChatMessageModel(
//        id: UUID().uuidString,
//        role: .assistant,
//        content: "...",
//        type: .text,
//        createAt: Int(Date().timeIntervalSince1970),
//        status: .waiting,
//        isCompleteChatFlag: false
//    )
//    let gptResponseContext = ChatMessageModel(
//        id: UUID().uuidString,
//        role: .assistant,
//        content: "你说的对，使用 .padding(.top, -40) 这样的负值时，会改变视图的布局方式，从而可能导致点击事件不起作用。具体来说，负的 padding 会将视图向相反的方向移动，但它并不会扩展视图的点击区域，反而可能会导致视图的点击区域缩小甚至消失。",
//        type: .text,
//        createAt: Int(Date().timeIntervalSince1970),
//        status: .done,
//        isCompleteChatFlag: false
//    )
//    
//    let mockChatVM = ChatViewModel()
//    
//    return Group {
//        ChatRow(chatContext, chatVM: Binding.constant(mockChatVM))
//            .environment(AppSize(CGSize(width: 1024, height: 768)))
//        ChatRow(chatContext)
//            .environment(AppSize(CGSize(width: 1024, height: 768)))
//        ChatRow(waitForResponseContext)
//            .environment(AppSize(CGSize(width: 1024, height: 768)))
//        ChatRow(chatContext)
//            .environment(AppSize(CGSize(width: 1024, height: 768)))
//        ChatRow(gptResponseContext)
//            .environment(AppSize(CGSize(width: 1024, height: 768)))
//    }
//}
