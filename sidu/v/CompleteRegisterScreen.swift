//
//  CompleteRegisterScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import SwiftUI

struct CompleteRegisterScreen: View {
    @Environment(\.myRoute) private var path
    
    @State private var password: String = ""
    @State private var confirm: String = ""
    
    var body: some View {
        VStack {
            Image("sidu_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .padding(.bottom, 20.0)
            
            HStack {
                Spacer(minLength: 100)
                Image(systemName: "lock.fill")
                SecureField("Password", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                Spacer(minLength: 100)
            }
            .padding(.bottom, 15.0)
            
            HStack {
                Spacer(minLength: 100)
                Image(systemName: "checkmark.seal.fill")
                SecureField("Input again to confirm password", text: $confirm)
                    .textFieldStyle(PlainTextFieldStyle())
                Spacer(minLength: 100)
            }
            .padding(.bottom, 50.0)
            
            Button {
                path.wrappedValue.append(.splashScreen)
            } label: {
                Text("Complete Register")
                    .frame(width: 260, height: 30)
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .background(Color("primaryBgColor"))
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Registration 2/2")
        .padding()
    }
}

#Preview {
    return Group {
        CompleteRegisterScreen().environment(\.locale, .init(identifier: "en"))
//        CompleteRegisterScreen().environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
