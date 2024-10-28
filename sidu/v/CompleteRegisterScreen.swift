//
//  CompleteRegisterScreen.swift
//  sidu
//
//  Created by Armstrong Liu on 28/08/2024.
//

import SwiftUI

struct CompleteRegisterScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.myRoute) private var path
    @Environment(ToastViewObserver.self) var toastViewObserver
//    @Environment(\.modelContext) private var modelContext
    @Environment(\.createUserHandler) private var createUserHandler

    @State private var registerVM = RegisterViewModel()
    
    var email: String
    
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
                SecureField("Password", text: $registerVM.password)
                    .textFieldStyle(.plain)
                    .clearButton(text: $registerVM.password)
                Spacer(minLength: 100)
            }
            .padding(.bottom, 15.0)
            
            HStack {
                Spacer(minLength: 100)
                Image(systemName: "checkmark.seal.fill")
                SecureField("Input again to confirm password", text: $registerVM.confirm)
                    .textFieldStyle(.plain)
                    .clearButton(text: $registerVM.confirm)
                Spacer(minLength: 100)
            }
            .padding(.bottom, 50.0)
            
            Button {
                Task {
                    toastViewObserver.showLoading()
                    registerVM.email = email
                    await registerVM.completeRegistration()
                    toastViewObserver.dismissLoading()
                }
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
        .onAppear() {
//            self.registerVM.modelContext = modelContext
            self.registerVM.createUserHandler = createUserHandler
        }
        .onChange(of: registerVM.isVerified, { oldValue, newValue in
            if newValue == .success {
                toastViewObserver.dismissLoading()
                path.wrappedValue.append(.chatScreen)
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
        .navigationTitle("Registration 2/2")
        .toastView(toastViewObserver: toastViewObserver)
        .padding()
    }
}

#Preview {
    return Group {
        CompleteRegisterScreen(email: "")
            .environment(ToastViewObserver())
            .environment(\.locale, .init(identifier: "en"))
//        CompleteRegisterScreen().environment(\.locale, .init(identifier: "zh"))
    }
}
