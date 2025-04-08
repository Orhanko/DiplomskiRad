//
//  WeeklyMinMaxSalesChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct WeeklyMinMaxSalesChartView: View {
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedIndex: Int? = nil
    @State private var scrollPosition: Double = 0
    @State private var isAnnotationVisible: Bool = false
    enum ChartStyle: String, CaseIterable, Identifiable {
        case course1 = "Course 1"
        case course2 = "Course 2"
        case course3 = "Course 3"
        
        var id: Self { self }
    }

    let courses = ["course1", "course2", "course3"]
        let courseDisplayNames = ["Course 1", "Course 2", "Course 3"]
    @Binding var selectedCourse: String
    @Binding var displayValue: String
    
    var body: some View {
        VStack {
            // Picker za kurs
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

                                // Poziv API funkcije
                                viewModel.loadWeeklyMinMaxData(for: newValue)
                            }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // Chart sa fiksnim indeksima
            chartView
                .frame(height: 500)
                .onAppear {
                        if let lastIndex = viewModel.weeklyMinMaxSales.indices.last {
                            scrollPosition = Double(lastIndex) + 0.5
                        }
                    }
                    .chartScrollPosition(x: $scrollPosition)
                    .padding()
        }
        .onAppear{
        viewModel.loadWeeklyMinMaxData(for: selectedCourse)
    }
        
    }
    

    private func alignmentForAnnotation(index: Int, totalCount: Int) -> Alignment {
        if index == 0 {
            return .leading
        } else if index == totalCount - 1 {
            return .trailing
        } else {
            return .center
        }
    }
    
    func calculateOffset(for index: Int?) -> CGFloat {
        guard let index = index else { return 0 }
        let totalCount = viewModel.weeklyMinMaxSales.count

        if index == 0 {
            return -25 // Pomjeraj desno ako je prvi
        } else if index == totalCount - 1 {
            return 25 // Pomjeraj lijevo ako je zadnji
        } else {
            return 0 // Ostavi centrirano
        }
    }
    private var chartView: some View {
        Chart {
            if let selectedIndex, selectedIndex < viewModel.weeklyMinMaxSales.count {
                let selectedData = viewModel.weeklyMinMaxSales[selectedIndex]
                
                RuleMark(x: .value("Selected", Double(selectedIndex) + 0.5))
                    .foregroundStyle(Color.secondary.opacity(0.5))
                    .annotation(
                        position: .top,
                        alignment: alignmentForAnnotation(index: selectedIndex, totalCount: viewModel.weeklyMinMaxSales.count),
                        
                        overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                    ) {
                        annotationView(for: selectedData)
                            .offset(x: calculateOffset(for: selectedIndex))
                    }
            }
            
            ForEach(viewModel.weeklyMinMaxSales.indices, id: \.self) { index in
                    let data = viewModel.weeklyMinMaxSales[index]

                    LineMark(
                        x: .value("Week", Double(index) + 0.5),
                        y: .value("Max Sales", data.maxSales)
                    )
                    .foregroundStyle(.green)
                    .opacity(isAnnotationVisible == false ? 1 : 0.5)
                    .symbol(Circle())
                    .symbolSize(50)
                    .symbol(by: .value("Legend", "Max Sales"))  // Dodajemo jedinstveni identifikator liniji

                    LineMark(
                        x: .value("Week", Double(index) + 0.5),
                        y: .value("Min Sales", data.minSales)
                    )
                    .foregroundStyle(.red)
                    .opacity(isAnnotationVisible == false ? 1 : 0.5)
                    
                    .symbol(Circle())
                    .symbolSize(50)
                    .symbol(by: .value("Legend", "Min Sales"))  // Dodajemo jedinstveni identifikator drugoj liniji
                
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
        .chartScrollableAxes(.horizontal)
//        .chartXVisibleDomain(length: 6)  // Broj prikazanih sedmica
        .chartXSelection(value: Binding(
            get: {
                selectedIndex.map { Double($0) + 0.5 }
            },
            set: { newValue in
                if let roundedValue = newValue.map({ Int(round($0 - 0.5)) }),
                   roundedValue >= 0,
                   roundedValue < viewModel.weeklyMinMaxSales.count {
                    selectedIndex = roundedValue
                    
                                   isAnnotationVisible = true
                               
                } else {
                    // Ako nema validnog dodira, resetuj selekciju
                    selectedIndex = nil
                    
                        isAnnotationVisible = false
                               
                }
            }
        ))
        .animation(.easeInOut(duration: 0.2), value: isAnnotationVisible)
        .chartYScale(domain: 0...(Double(viewModel.weeklyMinMaxSales.map { $0.maxSales }.max() ?? 0) * 1.3))
        .chartXAxis {
            AxisMarks(values: viewModel.weeklyMinMaxSales.indices.map { $0 } + [viewModel.weeklyMinMaxSales.count]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel (centered: true) {
                    if let index = value.as(Int.self), index < viewModel.weeklyMinMaxSales.count {
                        let date = viewModel.weeklyMinMaxSales[index].week
                        Text(formattedWeek(for: date))
                    }
                }
            }
        }        .chartXVisibleDomain(length: 6) // Prikazuje dodatnih pola indeksa
        .chartYAxis {
            AxisMarks(position: .trailing) {
                AxisValueLabel()
                AxisGridLine()
            }
        }
    }

    private func annotationView(for data: WeeklyMinMaxSale) -> some View {
        VStack(spacing: 8) {
            Text("\(data.maxSales)")
                .font(.headline)
                .foregroundColor(.white)
            Text("\(data.minSales)")
                .font(.headline)
                .foregroundColor(.white)
        }.animation(.easeInOut(duration: 0.3), value: isAnnotationVisible)
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
    }
        

    private func formattedWeek(for week: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: week)
    }
}
