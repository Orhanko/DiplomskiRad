//
//  ContentView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 13.06.2024..
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var lastLoginDate: Date? = nil
    @State private var isLoggedIn = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()  // Opaque pozadina
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View {
        ZStack{
            if isLoggedIn {
                MainView(lastLoginDate: $lastLoginDate, onLogout: handleLogOut)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                LoginView(lastLoginDate: $lastLoginDate, onLogin: handleLogin)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isLoggedIn)
    }
    private func handleLogin(username: String, password: String) {
            // Simulated login validation
            if username == "1" && password == "1" {
                withAnimation {
                                isLoggedIn = true
                    
                            }
            }
        }
    private func handleLogOut() {
        withAnimation {
                    isLoggedIn = false
                }
    }
}
