//
//  WeeklySalesChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/23/25.
//

import SwiftUI
import Charts

struct WeeklySalesChartView: View {
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    @State private var scrollPosition: TimeInterval = 0

    @State private var showAverageLine: Bool = false
    @State private var selectedIndex: Int?
     
    enum ChartStyle: String, CaseIterable, Identifiable {
        case bar = "Bar Mark"
        case line = "Line Mark"
        case roundedLineMark = "Line Mark 2"
        
        var id: Self { self }
    }
    @State private var selectedChartStyle: ChartStyle = .bar

    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
        VStack {
            
            ZStack {
                if selectedChartStyle == .bar {
                    barMarkView
                        .transition(.opacity)
                } else if selectedChartStyle == .line {
                    lineMarkView
                        .transition(.opacity)
                }else{
                    roundedLineMarkView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedChartStyle)
            
            Divider()
                .background(Color.secondary.opacity(0.5)) // Boja slična placeholderu
                .frame(height: 1) // Tanak divider
            HStack{
                Text("Average: \(String(format: "%.1f", salesViewModel.averageWeeklySales))")
                    .font(.body)
                    .frame(alignment: .leading)
                    .foregroundStyle(.secondary)
                
                    .fixedSize(horizontal: false, vertical: false)
                Spacer()
                HStack(spacing: 0) {
                    Text("Chart style:")
                        .foregroundStyle(.secondary)
                    
                    Picker("Chart Type", selection: $selectedChartStyle) {
                        ForEach(ChartStyle.allCases) {
                            Text($0.rawValue)
                        }
                    }
                    .frame(alignment: .trailing)
                    .pickerStyle(.menu)
                    .tint(color)
                    
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            Divider()
                .background(Color.secondary.opacity(0.5)) // Boja slična placeholderu
                .frame(height: 1) // Tanak divider
                .padding(.horizontal, -16)
            
            Toggle("Show average line", isOn: $showAverageLine)
            
            HStack {
                Text("Week")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                Text("Sales")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            LazyVStack(alignment: .leading, spacing: 0) { // spacing = 0 jer Divider dodaje razmak
                let sales = salesViewModel.salesByWeek.reversed()
                
                ForEach(Array(sales.enumerated()), id: \.element.id) { index, sale in
                    VStack {
                        HStack {
                            Text(sale.formattedWeek)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            Text("\(sale.sales)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        // Dodaj Divider osim ispod zadnjeg elementa
                        if index < sales.count - 1 {
                            Divider()
                                .background(Color.secondary.opacity(0.2)) // Boja bliska placeholderima
                                .padding(.leading, 16) // Poravnanje sa tekstom
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1)) // Blaga pozadina da odvoji elemente
            .cornerRadius(8)
            
            
            
            
        }
    }

        
        
        
    }
    
    private var headerView: some View {
            HStack {
                Text("Week")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Sales")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 2)
        }
    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    private func debugView(data: WeeklySale) -> some View {
        print("Date rendered: \(formattedDate(for: data.week)), Sales: \(data.sales)")
        return EmptyView()
    }
    
    private var barMarkView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Bla")
                .font(.footnote)
                .foregroundStyle(.clear)
            
            Chart(salesViewModel.salesByWeek, id: \.week) { data in
                
                BarMark(
                    x: .value("Sedmica", data.week, unit: .weekOfYear),
                    y: .value("Prodaja", data.sales)
                )
                .foregroundStyle(color)
                .cornerRadius(5)
                
                
                if showAverageLine {
                    RuleMark(y: .value("Prosjek prodaje", salesViewModel.averageWeeklySales))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(color.darker(by: 0.25))
                }
            }
            
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year())
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $scrollPosition)
            .chartXVisibleDomain(length: chartDomainLength)
            .frame(height: 300)
            .onAppear {
                updateScrollPosition()
            }
        }
    }

    private var chartDomainLength: TimeInterval {
        3600 * 24 * 7 * 7 // 6.5 sedmica
    }

    private func updateScrollPosition() {
        if let lastDate = salesViewModel.salesByWeek.last?.week {
            scrollPosition = lastDate.timeIntervalSinceReferenceDate
        }
    }
    
    private var lineMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("Bla")
                .font(.footnote)
                .foregroundStyle(.clear)
            Chart(salesViewModel.salesByWeek, id: \.week) { data in
                AreaMark(
                    x: .value("Sedmica", data.week, unit: .weekOfYear),
                    y: .value("Prodaja", data.sales)
                )
                    .foregroundStyle(
                        .linearGradient(
                            Gradient(colors: [color.darker(by: 0.25).opacity(0.4), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                LineMark(
                    x: .value("Sedmica", data.week, unit: .weekOfYear),
                    y: .value("Prodaja", data.sales)
                )
                
                .foregroundStyle(color)
                .shadow(color: color.darker(by: 0.25).opacity(0.3), radius: 15, x: 0, y: 30)
                if showAverageLine{
                    RuleMark(
                        y: .value("Average Sales", salesViewModel.averageWeeklySales)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2.5, dash: [6]))
                    .foregroundStyle(color)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year())
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $scrollPosition)
            .chartXVisibleDomain(length: 3600 * 24 * 7 * 8) // Prikazuje 20 sedmica (umjesto samo 8)
            .frame(height: 300)
        }
    }
    
    private var roundedLineMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("Bla")
                .font(.footnote)
                .foregroundStyle(.clear)
            Chart(salesViewModel.salesByWeek, id: \.week) { data in
                AreaMark(
                    x: .value("Sedmica", data.week, unit: .weekOfYear),
                    y: .value("Prodaja", data.sales)
                ).interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            Gradient(colors: [color.darker(by: 0.25).opacity(0.4), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                LineMark(
                    x: .value("Sedmica", data.week, unit: .weekOfYear),
                    y: .value("Prodaja", data.sales)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
                .shadow(color: color.darker(by: 0.25).opacity(0.3), radius: 15, x: 0, y: 30)
                if showAverageLine{
                    RuleMark(
                        y: .value("Average Sales", salesViewModel.averageWeeklySales)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2.5, dash: [6]))
                    .foregroundStyle(color)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).year())
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $scrollPosition)
            .chartXVisibleDomain(length: 3600 * 24 * 7 * 8) // Prikazuje 20 sedmica (umjesto samo 8)
            .frame(height: 300)
        }
    }
}
