//
//  LiveChatScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 02/09/2024.
//

import SwiftUI

struct LiveChatScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Live Chat")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 20)
                        .padding(.horizontal, 10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("Live Chat")
    }
}

#Preview {
    LiveChatScreen()
}
