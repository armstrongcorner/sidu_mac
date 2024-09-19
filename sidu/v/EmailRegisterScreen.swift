//
//  EmailRegisterScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import SwiftUI

struct EmailRegisterScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.myRoute) private var path
    @Environment(ToastViewObserver.self) var toastViewObserver
    
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
                        toastViewObserver.showLoading()
                        await registerVM.requestVerificationEmail()
                        toastViewObserver.dismissLoading()
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
                    toastViewObserver.showLoading()
                    await registerVM.goVerifyRegistration()
                    toastViewObserver.dismissLoading()
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
        .onChange(of: registerVM.isVerified, { oldValue, newValue in
            if newValue == .success {
                toastViewObserver.dismissLoading()
                path.wrappedValue.append(.completeRegisterScreen)
            } else if newValue == .failed {
                toastViewObserver.showToast(message: registerVM.errMsg)
            }
            registerVM.isVerified = .none
        })
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
        .navigationTitle("Registration 1/2")
        .toastView(toastViewObserver: toastViewObserver)
        .padding()
    }
}

#Preview {
    return Group {
        EmailRegisterScreen()
            .environment(ToastViewObserver())
            .environment(\.locale, .init(identifier: "en"))
//        EmailRegisterScreen().environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
