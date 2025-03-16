//
//  EarningsLabelChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct EarningsLabelChartView: View {
    func totalGrossEarnings() -> Double {
        viewModel.monthlyEarnings.map { $0.grossEarnings }.reduce(0, +)
    }
    @ObservedObject var viewModel: EarningsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Total earnings: ") +
                Text("$" + String(format: "%.2f", totalGrossEarnings()))
                    .bold()
                    .foregroundStyle(.pink)
                    
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 24).padding(.trailing).padding(.bottom,8)
            Chart (viewModel.monthlyEarnings){ data in
                        AreaMark(x: .value("Date", data.month),
                                 y: .value("Expense", data.grossEarnings))
                    
                
                        .interpolationMethod(.linear)
                .foregroundStyle(.pink)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            
            
            .frame(height: 80)
            .padding(.horizontal, 45)
        }
        .frame(maxWidth: .infinity, minHeight: 170)
        .background(/*Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))*/.gray.opacity(0.2))
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            Image(systemName: "chevron.compact.right") // Strelica desno
                .foregroundColor(.gray) // Siva boja strelice
                .font(.system(size: 25)) // Veličina fonta
                .frame(maxHeight: .infinity, alignment: .center) // Cijela visina za centriranje
                .padding(.trailing, 16), // Pomjeranje od ivice
            alignment: .trailing
        )
    }
    
    let formatter = DateFormatter()
    
    func month(for number: Int) -> String {
        // to short - charts cannot uniquely identify
        // formatter.veryShortMonthSymbols[number - 1]
        formatter.shortStandaloneMonthSymbols[number - 1]
    }
    
}
