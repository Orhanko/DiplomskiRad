//
//  TabOneView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/22/25.
//

import SwiftUI

struct TabOneView: View {
    var onLogout: () -> Void
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                
                    VStack(spacing: 50) {
                        ForEach(courses) { course in
                            let monthJSON = course.monthChart
                            let weeklyJSON = course.weeklyChart
                            let dailyJSON = course.dailyChart
                            let viewModel = SalesViewModel(monthJSON: monthJSON, weeklyJSON: weeklyJSON, dailyJSON: dailyJSON)
                            VCard(course: course, viewModel: viewModel)
                        }
                    }
//                    .padding(.vertical)
//                    .padding(.horizontal, 20)
                    .padding()
                    .padding(.horizontal, 5)
                    
                    .padding(.bottom, 10)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("ADMIN")
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onLogout) {
                        Text("Log out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Courses")
        }
    }
}
