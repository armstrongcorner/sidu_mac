//
//  ChatScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 01/09/2024.
//

import SwiftUI
import SwiftData

struct ChatScreen: View {
    @Environment(AppSize.self) var appSize
    @Environment(\.myRoute) var path
    @Environment(ToastViewObserver.self) var toastViewObserver
//    @Environment(\.modelContext) var modelContext
    @Environment(\.createTopicHandler) private var createTopicHandler
    @Environment(\.createChatHandler) private var createChatHandler
    
    @State var chatVM: ChatViewModel = ChatViewModel()
    
    var body: some View {
        ZStack(alignment: .trailing) {
            NavigationSplitView {
                // Topic list
                List(chatVM.topicList, id: \.id) { topicMessage in
                    Button {
                        chatVM.selectedTopicIndex = chatVM.topicList.firstIndex(where: { $0.id == topicMessage.id }) ?? 0
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(topicMessage.isComplete ?? false ? .gpt : .gray)
                            Text(topicMessage.title ?? "")
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(chatVM.selectedTopicIndex == chatVM.topicList.firstIndex(where: { $0.id == topicMessage.id }) ?? 0 ? .gray.opacity(0.5) : .clear)
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
                            chatVM.deleteTopic(topicId: topicMessage.id ?? "")
                        } label: {
                            Text("Delete")
                        }
                    }))
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
//                    self.chatVM.modelContext = modelContext
                    self.chatVM.createTopicHandler = createTopicHandler
                    self.chatVM.createChatHandler = createChatHandler
                    await self.chatVM.getTopicAndChat()
                    // Select the first topic by default if topic list is not empty
                    if chatVM.topicList.count > 0 {
                        chatVM.selectedTopicIndex = 0
                    }
                }
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigation) {
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
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation {
                            chatVM.isShowingSetting.toggle()
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17)
                            .padding(.horizontal, 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .toastView(toastViewObserver: toastViewObserver)
            
            if chatVM.isShowingSetting {
                SettingScreen(chatVM: $chatVM)
                    .zIndex(1)
            }
        }
    }
}

#Preview {
    ChatScreen()
        .environment(AppSize(CGSize(width: 1024, height: 768)))
        .environment(ToastViewObserver())
        .modelContainer(for: [User.self, Topic.self, Chat.self])
}
