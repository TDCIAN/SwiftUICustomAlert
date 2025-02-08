//
//  CustomAlert.swift
//  SwiftUICustomAlert
//
//  Created by 김정민 on 2/8/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func alert<Content: View, Background: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder background: @escaping () -> Background
    ) -> some View {
        self.modifier(CustomAlertModifier(isPresented: isPresented, alertContent: content, background: background))
    }
}

/// Helper Modifier
fileprivate struct CustomAlertModifier<AlertContent: View, Background: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: AlertContent
    @ViewBuilder var background: Background
    
    //// View Properties
    @State private var showFullScreenCover: Bool = false
    @State private var animatedValue: Bool = false
    @State private var allowsInteraction: Bool = false
    
    func body(content: Content) -> some View {
        content
            /// Using Full Screen Cover to show alert content on top of the current context
            .fullScreenCover(isPresented: $showFullScreenCover) {
                if #available(iOS 16.4, *) {
                    ZStack {
                        if animatedValue {
                            alertContent
                        }
                    }
                    .presentationBackground {
                        background
                            .opacity(animatedValue ? 1 : 0)
                    }
                    .task {
                        try? await Task.sleep(for: .seconds(0.05))
                        withAnimation(.easeInOut(duration: 0.3)) {
                            animatedValue = true
                        }
                        
                        try? await Task.sleep(for: .seconds(0.3))
                        allowsInteraction = true
                    }
                } else {
                    // MARK: Fallback on earlier versions
                    ZStack {
                        background
                            .ignoresSafeArea()
                        
                        alertContent
                    }
                    .background(
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isPresented = false
                            }
                    )
                    .task {
                        self.animateAfterDelay()
                    }
                }
            }
            .onChange(of: isPresented) { newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                if newValue {
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                } else {
                    allowsInteraction = false
                    if #available(iOS 17.0, *) {
                        withAnimation(.easeInOut(duration: 0.3), completionCriteria: .removed) {
                            animatedValue = false
                        } completion: {
                            /// Removing full-screen-cover without animation
                            withTransaction(transaction) {
                                showFullScreenCover = false
                            }
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            animatedValue = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withTransaction(transaction) {
                                showFullScreenCover = false
                            }
                        }
                    }
                }
            }
        
    }
    
    /*
     This method replace
     try? await Task.sleep(for: .seconds(0.05))
     withAnimation(.easeInOut(duration: 0.3)) {
         animatedValue = true
     }
     
     try? await Task.sleep(for: .seconds(0.3))
     allowsInteraction = true
     */
    private func animateAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedValue = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                allowsInteraction = true
            }
        }
    }
}

#Preview {
    ContentView()
}
