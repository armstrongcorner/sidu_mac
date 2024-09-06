//
//  ChatScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 01/09/2024.
//

import SwiftUI

struct ChatScreen: View {
    @Environment(\.myRoute) var path
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State var chatVM: ChatViewModel = ChatViewModel()
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(0..<10) { index in
                    Text("Chat message \(index)")
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
}
