//
//  SignInView.swift
//  DiplomskiRadBezAnimacija
//
//  Created by Orhan Pojskic on 1/2/25.
//

import SwiftUI

struct SignInView: View {
    @Binding var isPresented: Bool
    @State var email = ""
    @State var password = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Glavni sadržaj SignInView
            VStack(spacing: 20) {
                Text("Sign in")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top, 20)

                Text("Access to 240+ hours of content. Learn design and code, by building real apps with React and Swift.")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 15) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("E-mail", text: $email)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                        )

                    Text("Password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(.white)
                                .shadow(radius: 1)
                        )
                }

                Button(action: {
                    // Handle sign-in action
                }) {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("Sign in")
                            .fontWeight(.bold)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .foregroundColor(.pink)
                    )
                    .padding([.top, .bottom])
                }
                

                HStack {
                    Rectangle().frame(height: 1).opacity(0.2)
                    Text("OR").font(.subheadline).foregroundColor(.secondary)
                    Rectangle().frame(height: 1).opacity(0.2)
                }

                Text("Sign up with Email, Apple, Google")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    

                HStack {
                    Image(systemName: "envelope.circle")
                        .font(.system(size: 50))
                    Spacer()
                    Image(systemName: "apple.logo")
                        .font(.system(size: 50))
                    Spacer()
                    Image(systemName: "safari")
                        .font(.system(size: 50))
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.8)
            .background(.regularMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Centriranje
                    .padding(.bottom, 20)
            .transition(.move(edge: .top)) // Animacija ulaska

            // Dugme za zatvaranje ispod SignInView
            Button(action: {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                    isPresented = false // Zatvori SignInView
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.primary)
                    .background(
                        Circle()
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    )
                    .padding(.bottom, 22)
            }
            .offset(y: UIScreen.main.bounds.height * 0.4) // Pozicioniranje preko donje ivice
        }
    }
}

#Preview {
    SignInView(isPresented: .constant(true))
}
