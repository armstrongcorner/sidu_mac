//
//  EmailRegisterScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import SwiftUI

struct EmailRegisterScreen: View {
    @Environment(\.myRoute) private var path
    
    @State private var registerVM = RegisterViewModel()
    
    var body: some View {
        VStack {
            Image("sidu_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .padding(.bottom, 20.0)
            
            HStack {
                Spacer(minLength: 100)
                Image(systemName: "envelope.fill")
                TextField("Email for username to login", text: $registerVM.email)
                    .textFieldStyle(PlainTextFieldStyle())
                // Send veri code button
                Button {
                    print("Send verification email button clicked")
                    registerVM.startCountDown()
                    Task {
                        await registerVM.requestVerificationEmail()
                    }
                } label: {
                    Text(registerVM.resendCountDown > 0 ? "(\(registerVM.resendCountDown)) retry" : "send code")
                        .frame(width: 80, height: 30)
                        .font(.subheadline)
                        .foregroundColor(Color("primaryBgColor"))
                }
                .disabled(registerVM.resendCountDown > 0)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(registerVM.resendCountDown > 0 ? Color("primaryBgColor").opacity(0.5) : Color("primaryBgColor"), lineWidth: 1)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer(minLength: 100)
            }
            .padding(.bottom, 25.0)
            
            HStack {
                Spacer(minLength: 100)
                Text("Please go to your email box to get the verification code and fill the code form, then click 'Verify' button")
                    .font(.subheadline)
                    .foregroundColor(Color("primaryTextColor"))
                Spacer(minLength: 100)
                
            }
            .padding(.bottom, 5)
            
            HStack {
                Spacer(minLength: 100)
                Image(systemName: "checkmark.shield.fill")
                TextField("Verification Code", text: $registerVM.vericode)
                    .onChange(of: registerVM.vericode, { oldValue, newValue in
                        if newValue.count > 6 {
                            registerVM.vericode = String(newValue.prefix(6))
                        }
                        registerVM.vericode = registerVM.vericode.filter({ $0.isNumber })
                    })
                    .cornerRadius(5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color("primaryBgColor"), lineWidth: 1)
                    }
                Spacer(minLength: 100)
            }
            .padding(.bottom, 50.0)
            
            Button {
                Task {
                    let isSuccess = await registerVM.goVerifyRegistration()
                    if isSuccess {
                        path.wrappedValue.append(.completeRegisterScreen)
                    }
                }
            } label: {
                Text("Verify")
                    .frame(width: 260, height: 30)
                    .font(.headline)
                    .foregroundColor(Color.white)
                    .background(Color("primaryBgColor"))
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Registration 1/2")
        .padding()
    }
}

#Preview {
    return Group {
        EmailRegisterScreen().environment(\.locale, .init(identifier: "en"))
//        EmailRegisterScreen().environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
