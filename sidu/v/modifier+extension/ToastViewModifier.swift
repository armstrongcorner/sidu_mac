//
//  ToastViewModifier.swift
//  sidu
//
//  Created by Armstrong Liu on 31/08/2024.
//

import SwiftUI

enum ToastType {
    case loading
    case toast
}

@Observable
class ToastViewObserver {
    // Show toast
    var isShowing: Bool = false
    // Toast message
    var message: String?
    // Toast with image
    var imageName: String?
    // Toast type
    var toastType: ToastType = .toast
    // Toast disappear duration
    var duration: TimeInterval = 2
    // Animation duration
    private var animationDuration: TimeInterval = 0.2
    
    init(isShowing: Bool = false, message: String? = nil, imageName: String? = nil, duration: TimeInterval = 2, toastType: ToastType = .loading) {
        self.isShowing = isShowing
        self.message = message
        self.imageName = imageName
        self.duration = duration
        self.toastType = toastType
    }
    
    func showLoading() {
        self.isShowing = true
        self.toastType = .loading
    }
    
    func dismissLoading() {
        self.duration = 2
        self.isShowing = false
    }
    
    func showToast(message: String? = nil, imageName: String? = nil, duration: TimeInterval = 2) {
        self.isShowing = true
        self.toastType = .toast
        
        self.message = message
        self.imageName = imageName
        self.duration = duration
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            self.isShowing = false
        }
    }
}

struct ToastContentView: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    var body: some View {
        if toastViewObserver.isShowing {
            ZStack {
                Color("primaryBgColor")
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity).transition(.opacity)
                    .zIndex(0)
                if toastViewObserver.toastType == .loading {
                    // Show loading indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(20)
                        .background(Color("primaryBgColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)
                } else if toastViewObserver.toastType == .toast {
                    if let message = toastViewObserver.message, let imageName = toastViewObserver.imageName {
                        // Show toast with text and image
                        VStack {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                            
                            Text(message)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(nil)
                        }
                        .padding(10)
                        .background(Color("primaryBgColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)

//                        .padding(20)
                    } else {
                        if let message = toastViewObserver.message {
                            // Show toast with text only
                            Text(message)
                                .font(.system(size: 14))
                                .lineLimit(nil)
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color("primaryBgColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 3)
                        } else if let imageName = toastViewObserver.imageName {
                            // Show toast with image only
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
            }
        }
        //        .background(.black)
        //        .cornerRadius(10)
    }
}

struct ToastViewModifier: ViewModifier {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    // Customized view to show toast
    var customView: AnyView
    // Transition when show toast
    var transition: AnyTransition
    
    func body(content: Content) -> some View {
        ZStack {
            content.zIndex(0)
            //            Color("primaryBgColor")
            //                .opacity(0.3)
            //                .edgesIgnoringSafeArea(.all)
            //                .transition(.opacity).transition(.opacity)
            //                .zIndex(1)
            
            customView
                .transition(transition)
                .zIndex(2)
            //            Rectangle()
            //                .fill(.clear)
            //                .overlay(content: {
            //                    self.customView
            //                })
            //                .frame(width: 100, height: 100)
            //                .ignoresSafeArea()
            //                .transition(transition)
            //                .zIndex(2)
            
        }
    }
}

extension View {
    func toastView(toastViewObserver: ToastViewObserver) -> some View {
        self.modifier(ToastViewModifier(customView: AnyView(ToastContentView()), transition: .opacity))
            .onDisappear() {
                toastViewObserver.dismissLoading()
            }
    }
}


#Preview {
    return Group {
        //        ToastContentView()
        //            .environment(ToastViewObserver(isShowing: true, message: "test", toastType: .toast))
        ToastContentView()
            .environment(ToastViewObserver(isShowing: true, message: "test", imageName: "sidu_logo", toastType: .loading))
    }
}
