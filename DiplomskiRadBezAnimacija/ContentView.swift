//
//  ContentView.swift
//  DiplomskiRad
//
//  Created by Orhan Pojskic on 13.06.2024..
//

import SwiftUI

struct ContentView: View {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()  // Opaque pozadina
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    @State private var isMenuOpen: Bool = false
    @State private var isOnboardingPresented: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
            tabContent
            .offset(x: isMenuOpen ? 300 : 0) // Pomjeranje TabView-a
            .blur(radius: isOnboardingPresented ? 5 : 0) // Zamagljenje pozadine kada je Onboarding aktivan
            .animation(.easeInOut, value: isMenuOpen)
            .animation(.easeInOut, value: isOnboardingPresented)
            
            // Side Menu
            if isMenuOpen {
                SideMenu(isOpen: $isMenuOpen)
                    .frame(width: 300) // Širina SideMenu-a
                    .transition(.move(edge: .leading)) // Animacija ulaska
                    .zIndex(1)
            }
            
            // Onboarding View
            if isOnboardingPresented {
                Color(colorScheme == .dark ? .gray : .black)
                    .opacity(0.5) // Zamračena pozadina sa transparentnošću
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isOnboardingPresented = false
                        }
                    }
                    .zIndex(2) // Zamračenje ispod modala
                
                OnboardingView(isPresented: $isOnboardingPresented)
                    .zIndex(3) // Prikaz modala iznad svega
                    .transition(.move(edge: .top)) // Ulaz odozgo
            }
        }
        
    
    }
    
    var tabContent: some View {
        TabView {
            TabOneView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
            .tabItem {
                Label("Courses", systemImage: "bubble.left.and.bubble.right")
            }
            TabTwoView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Search", systemImage: "magnifyingglass")}
            TabThreeView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Recent", systemImage: "clock")}
            TabFourView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Notifications", systemImage: "bell")}
            TabFiveView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Profile", systemImage: "person")}
            
        }

    }
}

struct TabOneView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    
    var body: some View {
        NavigationView{
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(courses) { course in
                        VCard(course: course)
                    }
                }
                .padding(20)
                .padding(.bottom, 10)
            }
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Courses")
        }
    }
}

struct TabTwoView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 2")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Search")
        }
    }
}

struct TabThreeView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 3")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Recent")
        }

    }
}

struct TabFourView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 4")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Notifications")
        }

    }
}

struct TabFiveView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 5")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Profile")
        }

    }
}

struct VCard: View {
    var course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.title2)
                .fontWeight(.heavy)
                .frame(maxWidth: 170, alignment: .leading)
                .layoutPriority(1)
            Text(course.subtitle)
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(course.caption.uppercased())
                .font(.footnote)
                .fontWeight(.semibold)
                .opacity(0.7)
                .padding(.top, 10)
            Spacer()
            HStack {
                ForEach(Array([4, 5, 6].shuffled().enumerated()), id: \.offset) { index, number in
                    Image("Avatar \(number)")
                        .resizable()
                        .mask(Circle())
                        .frame(width: 44, height: 44)
                        .offset(x: CGFloat(index * -20))
                }
            }
        }
        .foregroundColor(.white)
        .padding(30)
        .frame(width: 260, height: 310)
        .background(.linearGradient(colors: [course.color.opacity(1), course.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: course.color.opacity(0.3), radius: 8, x: 0, y: 12)
        .shadow(color: course.color.opacity(0.3), radius: 2, x: 0, y: 1)
        .overlay(
            course.image
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(20)
        )
    }
}


#Preview{
    
    ContentView()
}
