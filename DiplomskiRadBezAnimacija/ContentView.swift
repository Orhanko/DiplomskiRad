//
//  ContentView.swift
//  DiplomskiRad
//
//  Created by Orhan Pojskic on 13.06.2024..
//

import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen: Bool = false
    @State private var isOnboardingPresented: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .leading) {
            // Glavni sadržaj sa TabView
            TabView {
                ForEach(0..<5) { index in
                    NavigationView {
                        VStack {
                            Text("Tab \(index + 1) Content")
                                .font(.largeTitle)
                                .padding()
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
                    .tabItem {
                        Label("Tab \(index + 1)", systemImage: "circle.fill")
                    }
                }
            }
            .offset(x: isMenuOpen ? 250 : 0) // Pomjeranje TabView-a
            .blur(radius: isOnboardingPresented ? 5 : 0) // Zamagljenje pozadine kada je Onboarding aktivan
            .animation(.easeInOut, value: isMenuOpen)
            .animation(.easeInOut, value: isOnboardingPresented)

            // Side Menu
            if isMenuOpen {
                SideMenu(isOpen: $isMenuOpen)
                    .frame(width: 250) // Širina SideMenu-a
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
}

#Preview{
    ContentView()
}
