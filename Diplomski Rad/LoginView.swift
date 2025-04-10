//
//  LoginView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/22/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @Binding var lastLoginDate: Date?  // Binding za prijenos podataka
    var onLogin: (String, String) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            Spacer()
            Text("Welcome to Login Page")
                .font(.title)
                .fontWeight(.bold)

            TextField("Username", text: $username)
                .padding(.horizontal)
                .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
//                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding(.horizontal)
                .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
//                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    
            } else {
                Spacer().frame(height: 20)  // Rezervirano mjesto
            }

            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isLoading = true
                                    
                                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                if username == "1" && password == "1" {
                                    onLogin(username, password)
                                    lastLoginDate = Date()
                                    errorMessage = ""  // Reset error message on success
                                } else {
                                    errorMessage = "Incorrect username or password. Please try again."
                                }
                                isLoading = false
                            }
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                            }
            
            if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            
            }else{
                Text("errorMessage")
                    .font(.footnote)
                    .foregroundColor(.clear)
            }
        Spacer()
            
            
            
        }
        .padding()
    }
}
