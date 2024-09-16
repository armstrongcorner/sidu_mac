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
                ForEach(0..<chatVM.topicList.count, id: \.self) { i in
                    let topicMessage = chatVM.topicList[i]
                    Button {
                        chatVM.selectedTopicIndex = i
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(topicMessage.isComplete ?? false ? .gpt : .gray)
                            Text(topicMessage.title ?? "")
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(chatVM.selectedTopicIndex == i ? .gray.opacity(0.5) : .clear)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu(ContextMenu(menuItems: {
                        // Mark the topic as completed
                        Button {
                            chatVM.markTopicAsCompleted(topicId: topicMessage.id ?? "")
                        } label: {
                            Text("Mark as Completed")
                        }
                        .disabled(topicMessage.isComplete ?? false)
                        
                        // Delete the topic
                        Button {
                            Task {
//                                await chatVM.deleteTopic(topic: topic)
//                                await chatVM.getTopicList()
                            }
                        } label: {
                            Text("Delete")
                        }
                    }))
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
                self.chatVM.getTopicAndChat()
                // Select the first topic by default if topic list is not empty
                if chatVM.topicList.count > 0 {
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
