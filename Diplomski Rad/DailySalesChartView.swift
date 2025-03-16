//
//  DailySalesChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct DailySalesChartView: View {
    
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    let numberOfDisplayedDays = 31
    
    @State var scrollPosition: TimeInterval = 0
    
    var scrollPositionStart: Date {
        Date(timeIntervalSinceReferenceDate: scrollPosition)
    }
    
    var scrollPositionEnd: Date {
        scrollPositionStart.addingTimeInterval(3600 * 24 * 30)
    }
    
    var scrollPositionString: String {
        scrollPositionStart.formatted(.dateTime.month().day().year())
    }
    
    var scrollPositionEndString: String {
        scrollPositionEnd.formatted(.dateTime.month().day().year())
    }
    enum ChartStyle: String, CaseIterable, Identifiable {
        case bar = "Bar Mark"
        case line = "Line Mark"
        case roundedLine = "Line Mark 2"
        
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
                        roundedlineMarkView
                            .transition(.opacity)
                    }
                }
                .onAppear {
                    if let lastDate = salesViewModel.dailySales.last?.saleDate {
                        // Postavljanje scroll pozicije tako da započne na desnoj strani (zadnji datum)
                        scrollPosition = lastDate.timeIntervalSinceReferenceDate
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: selectedChartStyle)
                
                Divider()
                    .background(Color.secondary.opacity(0.5)) // Boja slična placeholderu
                    .frame(height: 1) // Tanak divider
                // Horizontalni razmak
                HStack{
                    Text("Average: \(String(format: "%.1f", salesViewModel.averageDailySales))")
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
                // Horizontalni razmak
                    .padding(.horizontal, -16)
                HStack {
                    Text("Day")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    Text("Sales")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                LazyVStack(alignment: .leading, spacing: 0) { // spacing = 0 jer Divider dodaje razmak
                    let sales = salesViewModel.dailySales.reversed()
                    
                    ForEach(Array(sales.enumerated()), id: \.element.id) { index, sale in
                        VStack {
                            HStack {
                                Text(sale.formattedDay)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                                Text("\(sale.quantity)")
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
                //Toggle("Show average line", isOn: $showAverageLine)
                //            List {
                //                // Header sekcija
                //                Section(header: headerView) {
                //                    ForEach(Array(salesViewModel.dailySales.reversed()), id: \.saleDate) { sale in
                //                        HStack {
                //                            Text(sale.formattedDay)
                //                                .frame(maxWidth: .infinity, alignment: .leading)
                //                            Text("\(sale.quantity)")
                //                                .frame(maxWidth: .infinity, alignment: .leading)
                //                        }
                //                    }
                //                }
                //            }
                //            .listStyle(PlainListStyle()) // Ili .plain za jednostavniji stil
                //            // Pozadina celog prikaza
                //            .frame(maxHeight: 320)
                
            }
        }
        

    }
        
    private var headerView: some View {
            HStack {
                Text("Day")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Sales")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 2)
        }
    private var barMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("\(scrollPositionString) – \(scrollPositionEndString)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Chart(salesViewModel.dailySales, id: \.saleDate) {
                BarMark(
                    x: .value("Day", $0.saleDate, unit: .day),
                    y: .value("Sales", $0.quantity)
                ).foregroundStyle(color)
//                if showAverageLine {
//                    RuleMark(y: .value("Prosjek prodaje", salesViewModel.averageDailySales))
//                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
//                        .foregroundStyle(color.darker(by: 0.25))
//                }

                
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 10)) { value in
                    AxisGridLine() // Prikazuje linije svake 7. oznake (jednom sedmično)
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    
                    
                }
            }
            .chartScrollableAxes(.horizontal)
            
            .chartXVisibleDomain(length: 3600 * 24 * Double(numberOfDisplayedDays))
            // shows 30 days
            // snap to begining of month when release scrolling
            .chartScrollTargetBehavior(
                .valueAligned(
                    matching: .init(hour: 0),
                    majorAlignment: .matching(.init(day: 1))))
            .chartScrollPosition(x: $scrollPosition)
            .frame(height: 300)
            
        }
    }
    
    private var lineMarkView: some View{
        VStack(alignment: .leading, spacing: 5){
            Text("\(scrollPositionString) – \(scrollPositionEndString)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Chart(salesViewModel.dailySales, id: \.saleDate) {
                
                LineMark(
                    x: .value("Day", $0.saleDate, unit: .day),
                    y: .value("Sales", $0.quantity)
                    
                ).foregroundStyle(color)
                
                .shadow(color: color, radius: 4, x: 0, y: 5)
//                if showAverageLine {
//                    RuleMark(y: .value("Prosjek prodaje", salesViewModel.averageDailySales))
//                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
//                        .foregroundStyle(color.darker(by: 0.25))
//                }

                
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 10)) { value in
                    AxisGridLine() // Prikazuje linije svake 7. oznake (jednom sedmično)
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    
                    
                }
            }
            .chartScrollableAxes(.horizontal)
            
            .chartXVisibleDomain(length: 3600 * 24 * Double(numberOfDisplayedDays))
            // shows 30 days
            // snap to begining of month when release scrolling
            .chartScrollTargetBehavior(
                .valueAligned(
                    matching: .init(hour: 0),
                    majorAlignment: .matching(.init(day: 1))))
            .chartScrollPosition(x: $scrollPosition)
            .frame(height: 300)
        }
    }
    
    private var roundedlineMarkView: some View{
        VStack(alignment: .leading, spacing: 5){
            Text("\(scrollPositionString) – \(scrollPositionEndString)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Chart(salesViewModel.dailySales, id: \.saleDate) {
                
                LineMark(
                    x: .value("Day", $0.saleDate, unit: .day),
                    y: .value("Sales", $0.quantity)
                    
                ).foregroundStyle(color)
                .interpolationMethod(.catmullRom)
                .shadow(color: color, radius: 4, x: 0, y: 5)
//                if showAverageLine {
//                    RuleMark(y: .value("Prosjek prodaje", salesViewModel.averageDailySales))
//                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
//                        .foregroundStyle(color.darker(by: 0.25))
//                }

                
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 10)) { value in
                    AxisGridLine() // Prikazuje linije svake 7. oznake (jednom sedmično)
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    
                    
                }
            }
            .chartScrollableAxes(.horizontal)
            
            .chartXVisibleDomain(length: 3600 * 24 * Double(numberOfDisplayedDays))
            // shows 30 days
            // snap to begining of month when release scrolling
            .chartScrollTargetBehavior(
                .valueAligned(
                    matching: .init(hour: 0),
                    majorAlignment: .matching(.init(day: 1))))
            .chartScrollPosition(x: $scrollPosition)
            .frame(height: 300)
        }
    }
}
