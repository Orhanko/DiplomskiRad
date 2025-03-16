//
//  MonthlyMinMaxSalesChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct MonthlyMinMaxSalesChartView: View {
    @ObservedObject var viewModel: SalesViewModel
    @Binding var selectedCourse: String
    @Binding var displayValue: String
    @State private var rawSelectedDate: Date?
    var selectedMinMax: MonthlyMinMaxSale? {
        guard let rawSelectedDate else{ return nil}
        return viewModel.monthlyMinMaxSales.first{
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.month, toGranularity: .month)
        }
    }
    var selectedMinMaxIndex: Int? {
        guard let selectedMinMax else { return nil }
        return viewModel.monthlyMinMaxSales.firstIndex(where: {
            Calendar.current.isDate($0.month, equalTo: selectedMinMax.month, toGranularity: .month)
        })
    }
    let courses = ["course1", "course2", "course3"]
        let courseDisplayNames = ["Course 1", "Course 2", "Course 3"]
    var body: some View {
        VStack {
            
            HStack(spacing: 0) {
                Text("Selected course:")
                    .foregroundStyle(.secondary)
                Picker("Select Course", selection: $selectedCourse) {
                                ForEach(0..<courses.count, id: \.self) { index in
                                    Text(courseDisplayNames[index]).tag(courses[index])
                                }
                            }
            .pickerStyle(.menu)
            .onChange(of: selectedCourse) {_, newValue in
                if let selectedIndex = courses.firstIndex(of: newValue) {
                    displayValue = "Course \(selectedIndex+1)"  // Ažuriraj displayValue s indeksom
                }
                
                viewModel.loadMonthlyMinMaxSalesData(for: newValue)
            }
        }
            .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Chart{
                if let selectedMinMax{
                    RuleMark(x: .value("Selected", selectedMinMax.month, unit: .month))
                        .foregroundStyle(Color.secondary).opacity(0.5)
                        .annotation(
                            position: .top,
                            
                            spacing: 10,
                            overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                        ){
                            VStack(spacing: 8) {
                                        Text("\(selectedMinMax.maxSales)") // Max vrijednost
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("\(selectedMinMax.minSales)") // Min vrijednost
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: Color.green, location: 0.5), // Zelena na gornjoj polovici
                                                .init(color: Color.red, location: 0.5)   // Crvena na donjoj polovici
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .offset(x: selectedMinMaxIndex == 0 ? -20 : (selectedMinMaxIndex == viewModel.monthlyMinMaxSales.count - 1 ? -10 : 0))
                            
                        }
                }
                ForEach(viewModel.monthlyMinMaxSales){ data in
                    
                    LineMark(
                        x: .value("Month", data.month, unit: .month),
                        y: .value("Max Sales", data.maxSales)
                    )
                    
                    .foregroundStyle(.green)
                    .symbol(Circle()) // Dodaje tačke na maksimalne vrijednosti
                    .symbolSize(50) // Veličina tačaka
                    .symbol(by: .value("Legend", "Maximum")) // Legenda za plavu liniju
                    .opacity(rawSelectedDate == nil ? 1 : 0.5)
                    
                    LineMark(
                        x: .value("Month", data.month, unit: .month),
                        y: .value("Min Sales", data.minSales)
                    )
                    .foregroundStyle(.red)
                    .symbol(Circle()) // Dodaje tačke na minimalne vrijednosti
                    .symbolSize(50) // Veličina tačaka
                    .symbol(by: .value("Legend", "Minimum")) // Legenda za ljubičastu liniju
                    .opacity(rawSelectedDate == nil ? 1 : 0.5)
                }
            }
            
            .chartLegend(position: .bottom, spacing: 10) {
                HStack {
                    Circle()
                        .fill(.green) // Boja za maksimalne vrijednosti
                        .frame(width: 10, height: 10)
                    Text("Max").foregroundStyle(Color.secondary).font(.footnote)

                    Circle()
                        .fill(.red) // Boja za minimalne vrijednosti
                        .frame(width: 10, height: 10)
                    Text("Min").foregroundColor(Color.secondary).font(.footnote)
                }
            }
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut(duration:0.2)))
            .onChange(of: selectedMinMax) { oldValue, newValue in
                            if let newValue = newValue {
                                print("Max Sales for \(newValue.month.formatted(.dateTime.month(.wide))): \(newValue.maxSales)")
                            }
                        }
            .chartYAxis {
                AxisMarks(position: .trailing) {
                    AxisValueLabel()
                    AxisGridLine()
                        
                }
            }
            .chartYScale(domain: 0...(Double(viewModel.monthlyMinMaxSales.map { $0.maxSales }.max() ?? 0) * 1.3))
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                    AxisGridLine()
                        
                }
            }
            .frame(height: 500)
            .padding()
        }.onAppear{
            viewModel.loadMonthlyMinMaxSalesData(for: selectedCourse)
        }
    }
}
