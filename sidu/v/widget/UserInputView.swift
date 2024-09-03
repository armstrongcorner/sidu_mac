//
//  UserInputView.swift
//  sidu
//
//  Created by Armstrong Liu on 02/09/2024.
//

import SwiftUI

struct UserInputView: View {
    @Binding var chatContexts: [ChatMessageModel]
    
    @State private var userMessage: String = ""
    
    var body: some View {
        HStack(alignment: .bottom) {
            // Attach image
            Button {
                print("111")
            } label: {
                Image(systemName: "photo.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 8)
                    .padding(.bottom, 12)
            }
            .buttonStyle(PlainButtonStyle())
            // User input area
            VStack(alignment: .leading) {
                // User picked image
                
                // User text input
                TextEditor(text: $userMessage)
                    .font(.body)
                    .scrollIndicators(.never)
                    .frame(minHeight: 30, maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(.bottom, 8)
            }
            // Send message
            Button {
                sendChat()
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 8)
                    .padding(.bottom, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    func sendChat() {
        if !userMessage.isEmpty && !userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let chatContext = ChatMessageModel(
                id: UUID().uuidString,
                role: "user",
                content: userMessage,
                type: "text",
                createAt: Int(Date().timeIntervalSince1970),
                status: .sending,
                isCompleteChatFlag: false
            )
            chatContexts.append(chatContext)
            userMessage = ""
        }
    }
}

#Preview {
    UserInputView(chatContexts: .constant([]))
}
