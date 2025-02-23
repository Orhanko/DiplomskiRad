//
//  TabTwoView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/22/25.
//

import SwiftUI

struct TabTwoView: View {
    var onLogout: () -> Void
    
    @StateObject var highestSalesViewModel = HighestSalesViewModel()
    @StateObject var earningsViewModel = EarningsViewModel()
    
    @StateObject private var viewModel = SalesViewModel(monthJSON: "", weeklyJSON: "", dailyJSON: "")
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                VStack {
                    NavigationLink{
                        SalesPerBookCategoryView(viewModel: highestSalesViewModel)
                    } label: {
                        SectorMarkView(salesViewModel: highestSalesViewModel)
                    }.buttonStyle(PlainButtonStyle())
                        .padding()
                        .padding(.horizontal, 5)
                    NavigationLink{
                        MinMaxView(viewModel: viewModel)
                    } label: {
                        MinMaxLabelView()
                            
                    }.buttonStyle(PlainButtonStyle())
                    .padding()
                    .padding(.horizontal, 10)
                    NavigationLink{
                        EarningsChartView(viewModel: earningsViewModel)
                    } label: {
                        EarningsLabelChartView(viewModel: earningsViewModel)
                            
                    }.buttonStyle(PlainButtonStyle())
                    .padding()
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                    
                }
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
            .navigationTitle("Statistics")
        }
        
    }
    func formatDate(date: Date, format: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
}
