//
//  ShadowAndRoundedCornerModifier.swift
//  sidu
//
//  Created by Armstrong Liu on 31/08/2024.
//

import SwiftUI

struct ShadowAndRoundedCornerModifier: ViewModifier {
    var color: Color = .gray
    var radius: CGFloat = 10.0
    var shadowRadius: CGFloat = 5.0
    
    func body(content: Content) -> some View {
        content
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(radius: shadowRadius)
    }
}

extension View {
    func shadowAndRoundedCorner(color: Color = .gray, radius: CGFloat = 10.0, shadowRadius: CGFloat = 5.0) -> some View {
        self.modifier(ShadowAndRoundedCornerModifier(color: color, radius: radius, shadowRadius: shadowRadius))
    }
}
