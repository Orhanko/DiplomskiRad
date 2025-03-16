//
//  TabThreeView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI

struct TabThreeView: View {
    @Binding var lastLoginDate: Date?
    var onLogout: () -> Void
    var body: some View {
        NavigationView{
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("Welcome back, Orhan Pojskic!")
                
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .lineLimit(nil)
                if let lastLoginDate = lastLoginDate {
                    HStack {
                        Text("Last Login:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(formattedDate(from: lastLoginDate))
                            .foregroundColor(.gray)
                    }.padding(.horizontal)
                }else {
                    Text("No login data available")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            
            Spacer()
                Spacer()
                Button(action: onLogout) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ADMIN")
                        .foregroundColor(.secondary)
                }
            }
            
            
                    .padding()
            
            .navigationTitle("Profile")
        }

    }
    
    func formattedDate(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d. MMMM yyyy 'at' HH:mm"
            formatter.locale = Locale(identifier: "en_US")
            return formatter.string(from: date)
        }
}
