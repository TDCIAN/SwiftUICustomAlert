//
//  ContentView.swift
//  SwiftUICustomAlert
//
//  Created by 김정민 on 2/8/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Button("Show Alert") {
                    showAlert.toggle()
                }
                .alert(isPresented: $showAlert) {
                    if #available(iOS 17.0, *) {
                        CustomDialog(
                            title: "Folder Name",
                            content: "Enter a file Name",
                            image: .init(content: "folder.fill.badge.plus", tint: .blue, foreground: .white),
                            button1: .init(
                                content: "Save Folder",
                                tint: .blue,
                                foreground: .white,
                                action: { folder in
                                    print("### input folder  name: \(folder)")
                                    showAlert = false
                                }
                            ),
                            button2: .init(
                                content: "Cancel",
                                tint: .red,
                                foreground: .white,
                                action: { _ in
                                    showAlert = false
                                }
                            ),
                            addsTextField: true,
                            textFieldHint: "Personal Documents"
                        )
                        .transition(.blurReplace.combined(with: .push(from: .bottom)))
                    } else {
                        // MARK: Fallback on earlier versions
                        CustomDialog(
                            title: "Folder Name",
                            content: "Enter a file Name",
                            image: .init(content: "folder.fill.badge.plus", tint: .blue, foreground: .white),
                            button1: .init(
                                content: "Save Folder",
                                tint: .blue,
                                foreground: .white,
                                action: { folder in
                                    print("### input folder  name: \(folder)")
                                    showAlert = false
                                }
                            ),
                            button2: .init(
                                content: "Cancel",
                                tint: .red,
                                foreground: .white,
                                action: { _ in
                                    showAlert = false
                                }
                            ),
                            addsTextField: true,
                            textFieldHint: "Personal Documents"
                        )
                        .transition( // MARK: This code replaces '.transition(.blurReplace.combined(with: .push(from: .bottom)))'
                            .asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity.combined(with: .move(edge: .bottom))
                            )
                        )
                    }
                } background: {
                    Rectangle()
                        .fill(.primary.opacity(0.35))
                }
            }
            .navigationTitle("Custom Alert")
        }
    }
}

struct CustomDialog: View {
    
    var title: String
    var content: String?
    var image: Config
    var button1: Config
    var button2: Config?
    var addsTextField: Bool = false
    var textFieldHint: String = ""
    
    /// State Properties
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: image.content)
                .font(.title)
                .foregroundStyle(image.foreground)
                .frame(width: 65, height: 65)
                .background(backgroundView)
                .background {
                    Circle()
                        .stroke(.background, lineWidth: 8)
                }
            
            Text(title)
                .font(.title3.bold())
            
            if let content {
                Text(content)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
            }
            
            if addsTextField {
                TextField(textFieldHint, text: $text)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.1))
                    }
                    .padding(.bottom, 5)
            }
            
            ButtonView(button1)
            
            if let button2 {
                ButtonView(button2)
                    .padding(.top, -5)
            }
        }
        .padding([.horizontal, .bottom], 15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .padding(.top, 30)
        }
        .frame(maxWidth: 310)
        .compositingGroup()
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            Circle()
                .fill(image.tint)
            
            if #available(iOS 16.0, *) {
                Circle()
                    .fill(image.tint.gradient)
            } else {
                RadialGradient(
                    gradient: Gradient(colors: [.white.opacity(0.3), image.tint]),
                    center: UnitPoint(x: 0.7, y: 0),
                    startRadius: 0,
                    endRadius: 100
                )
                .clipShape(Circle())
            }
        }
    }
    
    /// Button View
    @ViewBuilder
    private func ButtonView(_ config: Config) -> some View {
        Button {
            config.action(addsTextField ? text : "")
        } label: {
            Text(config.content)
                .fontWeight(.bold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(buttonBackground(for: config))
        }
    }
    
    @ViewBuilder
    private func buttonBackground(for config: Config) -> some View {
        if #available(iOS 16.0, *) {
            RoundedRectangle(cornerRadius: 10)
                .fill(config.tint.gradient)
        } else {
            LinearGradient(
                gradient: Gradient(colors: [config.tint.opacity(0.8), config.tint]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}

#Preview {
    ContentView()
}
