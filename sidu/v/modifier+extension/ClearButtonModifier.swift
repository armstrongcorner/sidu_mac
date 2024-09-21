//
//  ClearButtonModifier.swift
//  sidu
//
//  Created by Armstrong Liu on 21/09/2024.
//

import SwiftUI

struct ClearButtonModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            
            if !text.isEmpty {
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)

                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 5)
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        self.modifier(ClearButtonModifier(text: text))
    }
}
