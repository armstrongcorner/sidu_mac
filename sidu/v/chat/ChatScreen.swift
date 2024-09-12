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
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(chatVM.topicList) { topic in
                    Button {
                        Task {
                            chatVM.currentTopic = topic
                        }
                    } label: {
                        Text(topic.title ?? "")
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
