//
//  SelectedImageView.swift
//  sidu
//
//  Created by Armstrong Liu on 02/09/2024.
//

import SwiftUI

struct SelectedImageView: View {
    var body: some View {
        ZStack {
            // Image btn
            Button {
                print("111")
            } label: {
                Image("muscle_minion")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())
            .zIndex(0)
            // Clear btn
            Button {
                print("222")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 13, height: 13)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: 20, y: -20)
            .zIndex(1)
        }
    }
}

#Preview {
    SelectedImageView()
}
