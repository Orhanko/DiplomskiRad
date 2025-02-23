//
//  MainView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/22/25.
//

import SwiftUI

struct MainView: View {
    @Binding var lastLoginDate: Date?
    var onLogout: () -> Void
    var body: some View{
        TabView {
            TabOneView(onLogout: onLogout)
            .tabItem {
                Label("Courses", systemImage: "bubble.left.and.bubble.right")
            }
            TabTwoView(onLogout: onLogout)
                .tabItem{Label("Statistics", systemImage: "doc.text.fill")}
            TabThreeView(lastLoginDate: $lastLoginDate, onLogout: onLogout)
                .tabItem{Label("Profile", systemImage: "person.circle.fill")}
        }
    }
}
