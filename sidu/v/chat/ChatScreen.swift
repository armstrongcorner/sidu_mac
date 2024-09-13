//
//  ChatScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 01/09/2024.
//

import SwiftUI
import SwiftData

struct ChatScreen: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.myRoute) var path
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State var chatVM: ChatViewModel = ChatViewModel()
//    @State var selectedTopicIndex: Int?
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(0..<chatVM.topicList.count, id: \.self) { i in
                    let topic = chatVM.topicList[i]
                    Button {
                        chatVM.selectedTopicIndex = i
                        chatVM.currentTopic = topic
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(topic.isComplete ?? false ? .gpt : .gray)
                            Text(topic.title ?? "")
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(chatVM.selectedTopicIndex == i ? .gray.opacity(0.5) : .clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        } detail: {
            VStack {
                // Chat area
                ChatView(chatVM: $chatVM)
                // User input area
                UserInputView(chatVM: $chatVM)
            }
        }
        .onAppear() {
            Task {
                self.chatVM.modelContext = modelContext
                await self.chatVM.getTopicList()
                // Select the first topic by default if topic list is not empty
                if let firstTopic = chatVM.topicList.first {
                    chatVM.currentTopic = firstTopic
                    chatVM.selectedTopicIndex = 0
                }
            }
        }
        .navigationTitle("Chat")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            Button {
                path.wrappedValue.append(.liveChatScreen)
            } label: {
                HStack {
                    Image(systemName: "headphones.circle.fill")
                    Text("Live Chat")
                }
                .padding(.horizontal, 6)
            }
        }
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview {
    ChatScreen()
        .environment(AppSize(CGSize(width: 1024, height: 768)))
        .environment(ToastViewObserver())
        .modelContainer(for: [User.self, Topic.self, Chat.self])
}
