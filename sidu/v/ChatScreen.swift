//
//  ChatScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 01/09/2024.
//

import SwiftUI

struct ChatScreen: View {
    @Environment(\.myRoute) var path
    
    @State private var userMessage: String = ""
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(0..<10) { index in
                    Text("Chat message \(index)")
                }
            }
        } detail: {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    Button {
                        print("aaa")
                    } label: {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.leading, 8)
                            .padding(.bottom, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    VStack(alignment: .leading) {
                        Image("muscle_minion")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        TextEditor(text: $userMessage)
                            .font(.body)
                            .scrollIndicators(.never)
                            .frame(minHeight: 30, maxHeight: 100)
                            .fixedSize(horizontal: false, vertical: true)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.bottom, 8)
                    }
                    
                    Button {
                        print("aaa")
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
    }
}

#Preview {
    ChatScreen()
}
