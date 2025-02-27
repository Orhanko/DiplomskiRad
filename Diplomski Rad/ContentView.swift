//
//  ContentView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 13.06.2024..
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var lastLoginDate: Date? = nil
    @State private var isLoggedIn = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()  // Opaque pozadina
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    
    var body: some View {
        ZStack{
            if isLoggedIn {
                MainView(lastLoginDate: $lastLoginDate, onLogout: handleLogOut)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                LoginView(lastLoginDate: $lastLoginDate, onLogin: handleLogin)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isLoggedIn)
    }
    private func handleLogin(username: String, password: String) {
            // Simulated login validation
            if username == "user" && password == "password" {
                withAnimation {
                                isLoggedIn = true
                    
                            }
            }
        }
    private func handleLogOut() {
        withAnimation {
                    isLoggedIn = false
                }
    }
}



struct MonthlyMinimizedSalesChartView: View {
    var barColor: Color
    @ObservedObject var salesViewModel: SalesViewModel
    
    var body: some View {
        VStack {
            Chart(salesViewModel.salesByMonth, id: \.month) { data in
                BarMark(
                    x: .value("Month", data.month, unit: .month), // X osa po mjesecima
                    y: .value("Sales", data.sales) // Y osa po prodaji
                )
                .foregroundStyle(barColor) // Boja traka
                .cornerRadius(4) // Zaobljeni rubovi traka
                // RuleMark linija na prosječnu vrijednost prodaje
                RuleMark(
                    y: .value("Average Sales", salesViewModel.averageSales)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6])) // Stil linije (debljina i isprekidanost)
                .foregroundStyle(Color(#colorLiteral(red: 0.922002852, green: 0.9209583402, blue: 0.9954648614, alpha: 1))) // Boja linije
                .annotation(position: .top) { // Tekstualna oznaka iznad linije
                    Text("Average: \(String(format: "%.1f", salesViewModel.averageSales))")
                        .font(.callout)
                        .foregroundColor(Color(#colorLiteral(red: 0.922002852, green: 0.9209583402, blue: 0.9954648614, alpha: 1)))
                }
            }
            .frame(height: 150) // Visina grafikona
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                        .foregroundStyle(Color(#colorLiteral(red: 0.922002852, green: 0.9209583402, blue: 0.9954648614, alpha: 1)))
                }
            }
            .chartYAxis(.hidden)
            Text("COURSE SALE OVERVIEW")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(.white).opacity(0.7)
                .padding(.top, 10)
                .padding(.trailing, 5)
                .fontWeight(.semibold)
                .opacity(0.7)
        }
    }
}

struct WeeklySale: Codable, Identifiable {
    let id = UUID()
    let week: Date
    let sales: Int

    var formattedWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: week)
    }
}

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

struct VCardDetailsView: View{
    var courseName: String
    @State private var showPDF = false
    @State private var pdfURL: URL?
    enum ChartStyle: String, CaseIterable, Identifiable {
        case month = "Monthly Insight"
        case week = "Weekly Insight"
        case day = "Daily Insight"
        var id: Self { self }
    }
    
    let color: Color
    
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedChartStyle: ChartStyle = .month
    
    private func handleToolbarButtonPress() {
            switch selectedChartStyle {
            case .month:
                print("Monthly action triggered")
                if let screenshot = PDFTableGenerator.capturePartialScreenshot(of: MonthlySalesChartView(salesViewModel: viewModel, color: .blue), size: CGSize(width: 612, height: 280)),
                   let pdfURL = PDFTableGenerator.generateMonthlySalesPDF(salesData: viewModel.salesByMonth.reversed(), fileName: "Monthly Sales Report for \(courseName)", courseName: courseName, screenshot: screenshot) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                        print("⚠️ Already presenting: \(String(describing: rootVC))")
                        rootVC.dismiss(animated: true) {
                            self.presentPDFSharing(pdfURL: pdfURL)
                        }
                    } else {
                        presentPDFSharing(pdfURL: pdfURL)
                    }
                }
            case .week:
                print("Weekly action triggered")
                if let pdfURL = PDFTableGenerator.generateWeeklySalesPDF(salesData: viewModel.salesByWeek.reversed(), fileName: "Weekly Sales Report for \(courseName)", courseName: courseName) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                        print("⚠️ Already presenting: \(String(describing: rootVC))")
                        rootVC.dismiss(animated: true) {
                            self.presentPDFSharing(pdfURL: pdfURL)
                        }
                    } else {
                        presentPDFSharing(pdfURL: pdfURL)
                    }
                            } else {
                                print("Failed to generate PDF.")
                            }
            case .day:
                print("Daily action triggered")
                if let pdfURL = PDFTableGenerator.generateDailySalesPDF(salesData: viewModel.dailySales.reversed(), fileName: "Daily Sales Report for \(courseName)", courseName: courseName) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                        print("⚠️ Already presenting: \(String(describing: rootVC))")
                        rootVC.dismiss(animated: true) {
                            self.presentPDFSharing(pdfURL: pdfURL)
                        }
                    } else {
                        presentPDFSharing(pdfURL: pdfURL)
                    }
                            } else {
                                print("Failed to generate PDF.")
                            }
            }
        }
    
    var body: some View{
        VStack{
            Text("Presented Data is valid for the past year.")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Picker("Chart Type", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            ZStack {
                if selectedChartStyle == .month {
                    MonthlySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                } else if selectedChartStyle == .week{
                    WeeklySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                } else{
                    DailySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                }
                        
                }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
            Spacer()
                
        }.padding()
            .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: handleToolbarButtonPress) {
                                Image(systemName: "printer.filled.and.paper")
                            }
                        }
                    }
            .sheet(isPresented: $showPDF) {
                if let pdfURL = pdfURL {
                    PDFPreviewView(url: pdfURL)
                }
            }

        
        }
    
    private func presentPDFSharing(pdfURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
            }
        }
    }


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

struct MinMaxView: View {
    @State private var showPDF = false
    @State private var pdfURL: URL?
    enum ChartStyle: String, CaseIterable, Identifiable {
        case month = "Month"
        case week = "Week"
        
        var id: Self { self }
    }
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedChartStyle: ChartStyle = .month
    @State private var selectedWeeklyCourse: String = "course1"
    @State private var selectedMonthlyCourse: String = "course1"
    @State private var displayMonthlyString: String = "Course 1"
    @State private var displayWeeklyString: String = "Course 1"
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
        VStack{
            
            Picker("Chart Type", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases) {
                    Text($0.rawValue)
                }
            }
            .padding([.horizontal, .top])
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            ZStack {
                if selectedChartStyle == .month {
                    
                    MonthlyMinMaxSalesChartView(viewModel: viewModel, selectedCourse: $selectedMonthlyCourse, displayValue: $displayMonthlyString)
                        .transition(.opacity)
                } else if selectedChartStyle == .week{
                    
                    WeeklyMinMaxSalesChartView(viewModel: viewModel, selectedCourse: $selectedWeeklyCourse, displayValue: $displayWeeklyString)
                        .transition(.opacity)
                }
                
            }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
            Spacer()
            
        }
    }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: probicaDjo) {
                    Image(systemName: "printer.filled.and.paper")
                }
            }
        }
        .sheet(isPresented: $showPDF) {
            if let pdfURL = pdfURL {
                PDFPreviewView(url: pdfURL)
            }
        }
    }
    
    private func presentPDFSharing(pdfURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
            }
        }

    
    func probicaDjo(){
        switch selectedChartStyle{
        case .month:
            if let screenshot = PDFTableGenerator.captureSalesPerCourseCategoryView(
                view: MonthlyMinMaxSalesChartView(viewModel: viewModel, selectedCourse: $selectedMonthlyCourse, displayValue: $displayMonthlyString),
                size: CGSize(width: 532, height: 600)
            ) {
                // Definiraj područje slike ispod odrezanog dijela
                let yOffset = 170.0
                let croppedHeight = screenshot.size.height - yOffset
                let newSize = CGSize(width: screenshot.size.width, height: croppedHeight)

                // Kreiranje nove slike bez gornjeg dijela
                UIGraphicsBeginImageContextWithOptions(newSize, false, screenshot.scale)
                screenshot.draw(at: CGPoint(x: 0, y: -yOffset))
                let finalScreenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                // Generiranje PDF-a s preostalom slikom
                if let finalScreenshot = finalScreenshot,
                   let pdfURL = PDFTableGenerator.generateMonthlyMinMaxSalesPDF(
                       salesData: viewModel.monthlyMinMaxSales,
                       fileName: "Monthly Min-Max Sales Report for \(displayMonthlyString)",
                       courseName: displayMonthlyString,
                       screenshot: finalScreenshot
                   ) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                        print("⚠️ Already presenting: \(String(describing: rootVC))")
                        rootVC.dismiss(animated: true) {
                            self.presentPDFSharing(pdfURL: pdfURL)
                        }
                    } else {
                        presentPDFSharing(pdfURL: pdfURL)
                    }
                } else {
                    print("Failed to generate PDF.")
                }
            }
        case .week:
            print("Sigili: \(displayWeeklyString)")
            if let pdfURL = PDFTableGenerator.generateWeeklyMinMaxSalesPDF(salesData: viewModel.weeklyMinMaxSales.reversed(), fileName: "Weekly Min-Max Sales Report for \(displayWeeklyString)", courseName: displayWeeklyString) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                    print("⚠️ Already presenting: \(String(describing: rootVC))")
                    rootVC.dismiss(animated: true) {
                        self.presentPDFSharing(pdfURL: pdfURL)
                    }
                } else {
                    presentPDFSharing(pdfURL: pdfURL)
                }
                        } else {
                            print("Failed to generate PDF.")
                        }
        }
    }
}

struct MinMaxLabelView: View {
    let upperLineValues = [34, 36, 27, 30, 38, 33]
    let lowerLineValues = [5, 12, 9, 14, 10, 13]
    
    var body: some View {
        VStack {
            Group{
            Text("Check out the monthly and weekly balance of the ") +
            Text("highest ")
                    .foregroundStyle(.green).fontWeight(.bold)
                
            + Text("and ") +
                Text("lowest ").foregroundStyle(.red).fontWeight(.bold)
                
            + Text("values ​​for sale")
        }
                
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                
            
            
            Chart {
                // Gornji LineMark - PLAVA LINIJA
                ForEach(upperLineValues.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Upper Line", upperLineValues[index]),
                        series: .value("Series", "Upper Line")
                    )
                    .foregroundStyle(.green)
                    .symbol(Circle())
                }

                // Donji LineMark - CRVENA LINIJA
                ForEach(lowerLineValues.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Lower Line", lowerLineValues[index]),
                        series: .value("Series", "Lower Line")
                    )
                    .foregroundStyle(.red)
                    .symbol(Circle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .padding(.horizontal, 24)
            .chartXAxis {
                AxisMarks(values: .stride(by: 1)){AxisGridLine()}
            }
            .chartYAxis {
                AxisMarks {AxisGridLine()}
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .padding(.top)
            .padding(.horizontal, 30)
            .padding(.bottom, 32)
            
            //            .onAppear {
            //                // Generisanje nasumičnih podataka
            //                data = (1...20).map { point in
            //                    (id: point, upperValue: Int.random(in: 30...40), lowerValue: Int.random(in: 10...20))
            //                }
            //            }
            
            
            
            
            
            
        }.background(.gray.opacity(0.2))
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                Image(systemName: "chevron.compact.right") // Strelica desno
                    .foregroundColor(.gray) // Siva boja strelice
                    .font(.system(size: 25)) // Veličina fonta
                    .frame(maxHeight: .infinity, alignment: .center) // Cijela visina za centriranje
                    .padding(.trailing, 16), // Pomjeranje od ivice
                alignment: .trailing
            )
        
    }}

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

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct MonthlySalesChartView: View {
    
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    enum ChartStyle: String, CaseIterable, Identifiable {
        case bar = "Bar Mark"
        case line = "Line Mark"
        case roundedLine = "Line Mark 2"
        
        var id: Self { self }
    }
    
    @State private var selectedChartStyle: ChartStyle = .bar
    @State private var showAnnotation: Bool = false
    @State private var showAverageLine: Bool = false
    
    var body: some View {
        VStack {
            
            // Ovde koristimo funkcije za prikaz grafikona
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
            .animation(.easeInOut(duration: 0.2), value: selectedChartStyle)
            Divider()
                .background(Color.secondary.opacity(0.5)) // Boja slična placeholderu
                .frame(height: 1) // Tanak divider
                         // Horizontalni razmak
            HStack{
                Text("Average: \(String(format: "%.1f", salesViewModel.averageSales))")
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
            
            Toggle("Show average line", isOn: $showAverageLine)
            ZStack{
                if selectedChartStyle == .bar {
                    Toggle("Show sales values", isOn: $showAnnotation)
                        
                        
                        .transition(.opacity)
                } else {
                    EmptyView()
                        .transition(.opacity)
                }
            }.animation(.easeInOut(duration: 0.2), value: selectedChartStyle)
            
            Spacer()
            
        }
        
    }
    
    private var barMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("Bla")
                .font(.footnote)
                .foregroundStyle(.clear)
        Chart(salesViewModel.salesByMonth, id: \.month) { data in
            BarMark(
                x: .value("Mjesec", data.month, unit: .month),
                y: .value("Prodaja", data.sales)
            )
            
            .annotation(position: .top) { // Dodajemo vrednost na vrhu stupca
                if showAnnotation{
                    
                    Text("\(data.sales)")
                    
                    
                        .foregroundStyle(.gray)
                        .font(.caption2.bold())
                    
                    Spacer()
                }
            }
            
            .foregroundStyle(color)
            .cornerRadius(5)
            if showAverageLine{
                RuleMark(
                    y: .value("Average Sales", salesViewModel.averageSales)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(color.darker(by: 0.25))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .frame(height: 300)
    }
    }
    
    private var lineMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("Bla")
                .font(.footnote)
                .foregroundStyle(.clear)
        Chart(salesViewModel.salesByMonth, id: \.month) { data in
            AreaMark(
                x: .value("Mjesec", data.month, unit: .month),
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
                x: .value("Mjesec", data.month, unit: .month),
                y: .value("Prodaja", data.sales)
            )
            
            .foregroundStyle(color)
            .shadow(color: color.darker(by: 0.25).opacity(0.3), radius: 15, x: 0, y: 30)
            if showAverageLine{
                RuleMark(
                    y: .value("Average Sales", salesViewModel.averageSales)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(color)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .frame(height: 300)
    }
    }
    private var roundedlineMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("Bla")
                .font(.footnote)
                .foregroundStyle(.clear)
        Chart(salesViewModel.salesByMonth, id: \.month) { data in
            AreaMark(
                x: .value("Mjesec", data.month, unit: .month),
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
                x: .value("Mjesec", data.month, unit: .month),
                y: .value("Prodaja", data.sales)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(color)
            .shadow(color: color.darker(by: 0.25).opacity(0.3), radius: 15, x: 0, y: 30)
            if showAverageLine{
                RuleMark(
                    y: .value("Average Sales", salesViewModel.averageSales)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(color)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .frame(height: 300)
    }
    }
}

class SalesViewModel: ObservableObject {
    @Published var dailySales: [DailySale] = [] // Lista prodaja
    @Published var salesByMonth: [MonthlySale] = []
    @Published var salesByWeek: [WeeklySale] = [] // Lista prodaja po sedmicama
    @Published var monthlyMinMaxSales: [MonthlyMinMaxSale] = []
    @Published var weeklyMinMaxSales: [WeeklyMinMaxSale] = []
    

    init(monthJSON: String, weeklyJSON: String, dailyJSON: String) {
        loadDailySalesData(from: dailyJSON)
        self.salesByMonth = loadMonthlySales(from: monthJSON)
        loadWeeklySalesData(from: weeklyJSON)
    }

    func loadDailySalesData(from fileName: String) {
            guard let jsonURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("JSON file not found.")
                return
            }

            do {
                let jsonData = try Data(contentsOf: jsonURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter())

                let decodedResponse = try decoder.decode(DailySalesResponse.self, from: jsonData)
                dailySales = decodedResponse.dailySales.reversed()
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    

    func loadMonthlySales(from fileName: String) -> [MonthlySale] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("JSON file not found.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let sales = try decoder.decode([MonthlySale].self, from: data)
            return sales
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
        
    }
    var averageSales: Double {
        let totalSales = salesByMonth.reduce(0) { $0 + $1.sales } // Zbir svih prodaja
        return Double(totalSales) / Double(salesByMonth.count) // Prosjek
        }
    
    func loadWeeklySalesData(from fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("⚠️ JSON file not found.")
                return
            }

        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // Prilagodi format svom JSON-u
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        do {
            let data = try Data(contentsOf: url)
            let decodedData = try decoder.decode(WeeklySalesResponse.self, from: data)
            salesByWeek.removeAll()
            salesByWeek = decodedData.weeklySales
            salesByWeek.sort { $0.week < $1.week }
            print("Successfully loaded sales data.")
        } catch {
            print("Error decoding JSON: \(error)")
        }        }

        var averageWeeklySales: Double {
            guard !salesByWeek.isEmpty else { return 0.0 }
            let totalSales = salesByWeek.reduce(0) { $0 + $1.sales }
            return Double(totalSales) / Double(salesByWeek.count)
        }
    
    var averageDailySales: Double {
            guard !dailySales.isEmpty else { return 0.0 }
            let totalSales = dailySales.reduce(0) { $0 + $1.quantity }
            return Double(totalSales) / Double(dailySales.count)
        }
    
    
    func loadMonthlyMinMaxSalesData(for course: String) {
            guard let url = Bundle.main.url(forResource: "monthlyMinMaxSalesData", withExtension: "json") else {
                print("JSON file not found.")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter())
                let salesData = try decoder.decode([String: [MonthlyMinMaxSale]].self, from: data)
                monthlyMinMaxSales = salesData[course] ?? []
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        private func dateFormatter() -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }
    
    func loadWeeklyMinMaxData(for course: String) {
            guard let url = Bundle.main.url(forResource: "weekly_min_max_sales", withExtension: "json") else {
                print("JSON file not found.")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter())
                let sales = try decoder.decode([String: [WeeklyMinMaxSale]].self, from: data)
                self.weeklyMinMaxSales = sales[course]?.reversed() ?? []
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

    
//    func generateRandomWeeklyMinMaxData() {
//        let calendar = Calendar.current
//        let currentDate = Date()
//
//        // Prva cijela sedmica unazad
//        guard let firstFullWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) else {
//            return
//        }
//
//        weeklyMinMaxSales.removeAll() // Čistimo niz prije punjenja novih podataka
//
//        for weekOffset in 0..<52 {
//            if let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: firstFullWeek) {
//                let maxSales = Int.random(in: 5000...20000) // Maksimalna prodaja
//                let minSales = Int.random(in: 1000...5000)  // Minimalna prodaja
//                weeklyMinMaxSales.append(WeeklyMinMaxSale(week: weekDate, maxSales: maxSales, minSales: minSales))
//            }
//        }
//
//        // Sortiranje od najstarije do najnovije sedmice
//        weeklyMinMaxSales.sort { $0.week < $1.week }
//    }
}

struct MonthlySale: Decodable {
    let month: Date
    let sales: Int
    
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy" // Format za mjesec i godinu, npr. "Feb 2025"
        return formatter.string(from: month)
    }
}

struct DailySale: Identifiable, Codable {
    let id = UUID()
    let saleDate: Date
    let quantity: Int
    
    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: saleDate)
    }
}

struct DailySalesResponse: Codable {
    let dailySales: [DailySale]
}

struct HighestCourseSale: Identifiable, Codable {
    let id = UUID()
    let category: String
    let sales: Double
    var color: Color? = nil

    enum CodingKeys: String, CodingKey {
        case category
        case sales
    }
}

struct WeeklySalesResponse: Codable {
    let weeklySales: [WeeklySale]
}

struct MonthlyMinMaxSale: Identifiable, Equatable, Decodable {
    let id = UUID()
    let month: Date
    let maxSales: Int
    let minSales: Int
    
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // Format za mjesec i godinu, npr. "Feb 2025"
        return formatter.string(from: month)
    }
}

struct WeeklyMinMaxSale: Identifiable, Decodable {
    let id = UUID()
    let week: Date
    let maxSales: Int
    let minSales: Int
    
    var formattedWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: week)
    }
}

import SwiftUI

class HighestSalesViewModel: ObservableObject {
    @Published var totalSalesPerCategory: [HighestCourseSale] = []

    init() {
        loadSalesData()  // Učitavanje podataka iz JSON-a
    }

    func loadSalesData() {
        guard let url = Bundle.main.url(forResource: "pie_chart_data", withExtension: "json") else {
            print("❌ Nije pronađen JSON fajl.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode([HighestCourseSale].self, from: data)

            // Dodavanje boja svakom Course-u
            let coursesWithColors: [String: Color] = [
                "Course 1": .blue,
                "Course 2": .green,
                "Course 3": .orange,
                "Course 4": .purple
            ]

            totalSalesPerCategory = decodedData.map { sale in
                var saleWithColor = sale
                saleWithColor.color = coursesWithColors[sale.category] ?? .gray
                return saleWithColor
            }

        } catch {
            print("❌ Greška prilikom dekodiranja JSON-a: \(error)")
        }
    }

    var bestSellingCategory: HighestCourseSale? {
        totalSalesPerCategory.max(by: { $0.sales < $1.sales })
    }

    var totalSales: Double {
        totalSalesPerCategory.reduce(0) { $0 + $1.sales }
    }

    var bestSellingPercentageText: String {
        guard let best = bestSellingCategory else { return "Nema podataka" }
        let percentage = (best.sales / totalSales) * 100
        return "\(best.category) ima najviše prodaja sa \(String(format: "%.2f", percentage))% ukupnih prodaja."
    }
}


struct TaskProgress: Identifiable {
    let id = UUID()
    let label: String
    let percentage: Double
    let color: Color
}


class RandomProgressViewModel: ObservableObject {
    @Published var completedPercentage: Double

    init() {
        // Generiše nasumičan procenat između 0% i 100% pri inicijalizaciji
        self.completedPercentage = Double.random(in: 0...100)
    }

    // Podaci za `Chart`
    var progressData: [TaskProgress] {
        [
            TaskProgress(label: "Completed", percentage: completedPercentage, color: .blue),
            TaskProgress(label: "Remaining", percentage: 100.0 - completedPercentage, color: .blue.opacity(0.2))
        ]
    }
}




struct SectorMarkView: View {
    @ObservedObject var salesViewModel: HighestSalesViewModel

    var body: some View {
        HStack {
            if let bestSellingCategory = salesViewModel.bestSellingCategory {
                let percentage = (bestSellingCategory.sales / salesViewModel.totalSales) * 100

                VStack(alignment: .leading, spacing: 1) {
                    

                    
                    Text("\(bestSellingCategory.category)")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .font(.headline)
                    + Text(" is the best")
                    Text("selling course with")
                    Text("\(String(format: "%.2f", percentage))%")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .font(.headline)
                    + Text(" of total sales.")
                    
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width < 400 ? 160 : nil) // Ograniči širinu SAMO ako je ekran manji
                .padding(.leading, 24)
                .padding(.trailing, 16)
                               
                
                // Padding na cijelu grupu teksta
            } else {
                Text("Nema podataka o prodaji.")
                    .padding() // Dodavanje padding-a i za "fallback" poruku
            }
                


                Chart(salesViewModel.totalSalesPerCategory, id: \.category) { data in
                    SectorMark(
                        angle: .value("Prodaja", data.sales),
                        innerRadius: .ratio(0.5), // Donut izgled
                        angularInset: 1.5 // Razmak između sektora
                    )
                    .foregroundStyle(.blue) // Različite boje po kategorijama
                    .cornerRadius(5.0)
                    .opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.2) // Najprodavaniji kurs ima punu vidljivost
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 85) // Veličina pie chart-a
                
                
                .chartLegend(.hidden)
            
            Spacer()
        }
        
        .frame(maxWidth: .infinity, minHeight: 150)
        
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
        
}

struct SalesPerBookCategoryView: View {
    @State private var showPDF = false
    @State private var pdfURL: URL?

    enum ChartStyle: String, CaseIterable, Identifiable {
        case pie = "Pie Chart"
        case bar = "Bar Chart"
      
        var id: Self { self }
    }
    
    @ObservedObject var viewModel: HighestSalesViewModel
    @State private var selectedChartStyle: ChartStyle = .pie // Zadano: Pie chart
    
    var body: some View {
        VStack {
            // Picker sa dva izbora
            Picker("Chart Type", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            if let bestSellingCategory = viewModel.bestSellingCategory {
                let percentage = (bestSellingCategory.sales / viewModel.totalSales) * 100

                Group { // Grupisanje teksta radi dodavanja padding-a na cijelu rečenicu
                    Text("The best-selling course is ") +
                    Text("\(bestSellingCategory.category)")
                        .foregroundColor(bestSellingCategory.color) // Boja naziva kursa
                        .fontWeight(.heavy) +
                    Text(" with \(String(format: "%.2f", percentage))% of total sales.")
                        .foregroundColor(.primary) // Ostatak teksta u default boji
                }
                
                
                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(nil)
                 // Padding na cijelu grupu teksta
            } else {
                Text("Nema podataka o prodaji.")
                    .padding() // Dodavanje padding-a i za "fallback" poruku
            }
            
//            TEKST
            
            // Prikaz prema odabranom tipu grafikona
            switch selectedChartStyle {
                case .bar:
                CustomSalesPerBookCategoryBarChartView(salesViewModel: viewModel) // Bar Chart prikaz
                case .pie:
                    FullSizePieChartView(salesViewModel: viewModel) // Pie Chart prikaz
                    .padding(.vertical)
                    
            }
            Spacer()
            
                        
            
            
            
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: generatePDF) {
                            Image(systemName: "printer.filled.and.paper")
                        }
                    }
                }
        .sheet(isPresented: $showPDF) {
            if let pdfURL = pdfURL {
                PDFPreviewView(url: pdfURL)
            }
        }
    }
    
    func generatePDF(){
        if let screenshot = PDFTableGenerator.captureSalesPerCourseCategoryView(view: CustomSalesPerBookCategoryBarChartView(salesViewModel: viewModel), size: CGSize(width: 532, height: 400)),
           let pdfURL = PDFTableGenerator.generateSalesPerCourseCategoryViewPDF(fileName: "Sales per Course", chartImage: screenshot) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                print("⚠️ Already presenting: \(String(describing: rootVC))")
                rootVC.dismiss(animated: true) {
                    self.presentPDFSharing(pdfURL: pdfURL)
                }
            } else {
                presentPDFSharing(pdfURL: pdfURL)
            }
        }
    }
    
    private func presentPDFSharing(pdfURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
            }
        }
}

struct CustomSalesPerBookCategoryBarChartView: View {
    
    @ObservedObject var salesViewModel: HighestSalesViewModel
    
    var body: some View {
        VStack(spacing: 20){
            
            
        Chart(salesViewModel.totalSalesPerCategory, id: \.category) { data in
            // Horizontalne BarMark trake
            BarMark(
                x: .value("Prodaja", data.sales),
                y: .value("Kategorija", data.category)
            )
            .foregroundStyle(data.category == salesViewModel.bestSellingCategory?.category
                             ? data.color?.opacity(1) ?? Color.gray
                             : data.color?.opacity(0.6) ?? Color.gray) // Prilagođena boja za najbolju kategoriju
            .cornerRadius(5) // Zaobljeni rubovi trake
            .opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.5) // Smanjena vidljivost za ostale kategorije
            
            .annotation(position: .trailing) { // Dodavanje vrijednosti prodaje na kraj trake
                Text("\(Int(data.sales))")
                    .font(.body)
                    .foregroundColor(.primary).opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.5)
                    
            }
        }
        
        .chartLegend(.hidden) // Sakriva legendu
        .frame(maxHeight: 380) // Ograničena visina grafikona
        //.padding(10) // Dodaje padding oko grafikona
    }
    }
}

struct FullSizePieChartView: View {
    @ObservedObject var salesViewModel: HighestSalesViewModel
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            //                .font(.headline)
            //                .padding(.bottom, 10)
            
            Chart(salesViewModel.totalSalesPerCategory, id: \.category) { data in
                SectorMark(
                    angle: .value("Prodaja", data.sales),
                    innerRadius: .ratio(0.6), // Širi prikaz grafikona
                    angularInset: 8 // Razmak između sektora
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("Naziv", data.category))
                .opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.3)
            }
            
            .chartLegend(.hidden)
            
            
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let plotFrame = chartProxy.plotFrame {
                        let frame = geometry[plotFrame]

                        if let bestSellingCategory = salesViewModel.bestSellingCategory {
                            VStack(spacing: 5) {
                                Text("Most Sold Course")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text(bestSellingCategory.category)
                                    .font(.title.bold())
                                    .foregroundColor(bestSellingCategory.color)
                                Text("\(Int(bestSellingCategory.sales)) sold")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .multilineTextAlignment(.center)
                            .frame(width: frame.width * 0.6)
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            //.frame(width: 360, height: 360) // Veći prikaz
            //.padding()
            customLegend
        }
        
        
    }
    private var customLegend: some View {
        HStack {
            ForEach(Array(salesViewModel.totalSalesPerCategory.sorted(by: { $0.sales > $1.sales }).enumerated()), id: \.element.category) { index, item in
                Label {
                    Text(item.category)
                        .padding(.top)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .padding(.trailing, 3)
                } icon: {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(item.color!)
                        .opacity(index == 0 ? 1 : 0.3)
                }
                
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            
        
    }
     }



struct DailySalesChartView: View {
    
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    //@State var showAverageLine: Bool = false
    
    
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


struct VCard: View {
    var course: Course
    @ObservedObject var viewModel: SalesViewModel
    @State private var isModalPresented = false
    var body: some View {
        //NavigationLink(destination: MonthlySalesChartView(salesViewModel: viewModel)){
        ZStack{
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.title2)
                .fontWeight(.heavy)
                .frame(maxWidth: 300, alignment: .leading)
                .multilineTextAlignment(.leading)// Centriranje teksta unutar linija
                .padding(.top,25)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                .padding(.top, 25)
                .padding(.leading, 25)
            Text(course.subtitle)
                .lineLimit(nil)
                .opacity(0.7)
                .frame(maxWidth: 300, alignment: .leading)
                .multilineTextAlignment(.leading) // Centriranje teksta unutar linija
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 25)
            
            Text(course.caption.uppercased())
                .font(.footnote)
                .padding(.leading, 25)
                .fontWeight(.semibold)
                .opacity(0.7)
                .padding(.top, 10)
            Spacer()
            MonthlyMinimizedSalesChartView(barColor: course.color.darker(by: 0.25), salesViewModel: viewModel)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
        }
        .foregroundColor(.white)
        //        .padding(30)
        .frame(height: 460)
//        .background(.linearGradient(colors: [course.color.opacity(1), course.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .background(course.color)
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: course.color.opacity(0.3), radius: 8, x: 0, y: 12)
        
        .shadow(color: course.color.opacity(0.3), radius: 2, x: 0, y: 1)
        .overlay(
            ZStack{
                course.image
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(20)
                Image(systemName: "chevron.compact.up") // Strelica desno
                    .foregroundColor(.white) // Siva boja strelice
                    .font(.system(size: 25)) // Prilagođena veličina i težina
                    .padding(.top,20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        )
        
    }
        
        .onTapGesture{
            isModalPresented = true
        }
            
        
        .sheet(isPresented: $isModalPresented) {
            NavigationView{
                //ScrollView{
                VStack{
                    VCardDetailsView(courseName: course.courseID, color: course.color, viewModel: viewModel)
                    .navigationTitle(course.title)// Modalni prikaz sa istim podacima
                    .navigationBarTitleDisplayMode(.inline)
                }
                
                                                .toolbar {
                                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                                Button(action: {
                                                                    isModalPresented = false
                                                                }) {
                                                                    Image(systemName: "xmark.circle")
                                                                }
                                                            }
                                                        }
                //}
            }.presentationDragIndicator(.visible)
            
            .interactiveDismissDisabled(true)
        }

        }
    }


struct HCard: View {
    var section = courseSections[1]
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading, spacing: 10) {
                Text(section.title)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    
                Text(section.caption)
                    .font(.body)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(30)
            
            Spacer()
            RandomTaskProgressChartView(viewModel: RandomProgressViewModel(), chartColor: section.color.darker(by: 0.35))
                .fixedSize(horizontal: true, vertical: false)
                .padding(.vertical, 10)
                .padding(.trailing, 20)
            
        }
        
        
        .frame(maxWidth: .infinity, maxHeight: 130)
        .foregroundColor(.white)
        .background(section.color)
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

struct RandomTaskProgressChartView: View {
    
    @ObservedObject var viewModel: RandomProgressViewModel
    var chartColor: Color
    
    var body: some View {
        
        // Prikaz grafikona sa procentom
        Chart{
            SectorMark(
                angle: .value("Completed", viewModel.completedPercentage),
                innerRadius: .ratio(0.60), // Donut oblik
                angularInset: 1.5
            )
            .cornerRadius(3.0)
            .foregroundStyle(chartColor)
            
            SectorMark(
                angle: .value("Remaining", 100 - viewModel.completedPercentage),
                innerRadius: .ratio(0.75), // Donut oblik
                angularInset: 1.5
            )
            .foregroundStyle(chartColor.opacity(0.3))
            
            .cornerRadius(3.0)
            
        }
        .frame(height: 100)
        
        
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                
                //if let completedPercentage = viewModel.completedPercentage {
                
                Text("\(Int(viewModel.completedPercentage))%")
                    .font(.body)
                
                
                
                
                
                    .multilineTextAlignment(.center)
                    .frame(width: frame.width * 1) // Ograničimo širinu teksta unutar kruga
                    .position(x: frame.midX, y: frame.midY) // Centriramo tekst unutar grafikona
                    .foregroundStyle(chartColor)
                    .fontWeight(.bold)
                
            }
        }
        
        
        //            Text("\(Int(viewModel.completedPercentage))% Completed")
        //                .font(.headline)
        //                .padding(.top)
        
        //.padding()
    }
}

import PDFKit

 

class PDFTableGenerator {
    static func generateWeeklySalesPDF(salesData: [WeeklySale], fileName: String, courseName: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Weekly Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [contentWidth / 2, contentWidth / 2]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: WeeklySale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            // Naizmenične boje za redove
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst u redu
            let week = sale.formattedWeek
            let sales = "\(sale.sales)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [week, sales].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            // Linije između kolona
            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }
        
        func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
            // Pozadina zaglavlja
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst zaglavlja
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Week", "Sales"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }
        
        func drawTableBorder(context: UIGraphicsPDFRendererContext, margin: CGFloat, tableTopYPosition: CGFloat, tableBottomYPosition: CGFloat) {
            let borderPath = UIBezierPath(rect: CGRect(x: margin, y: tableTopYPosition, width: contentWidth, height: tableBottomYPosition - tableTopYPosition))
            borderPath.lineWidth = 1
            UIColor.black.setStroke()
            borderPath.stroke()
        }
        
        func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
            // Header sa naslovom
            let title = "Weekly Sales Report for \(courseName)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)
            let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

                let pageText = "Page \(currentPage) of \(totalPages)"
                let pageAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: pageAttributes)
        }
        
        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let totalPages = Int(ceil(Double(salesData.count) / 20)) // Prilagodite broj redova po stranici
            let columnWidths = [CGFloat(contentWidth / 2), CGFloat(contentWidth / 2)]
            var yPosition = margin + 50

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
            drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
            yPosition += 30

            var tableTopYPosition = yPosition
            
            salesData.enumerated().forEach { (index, sale) in
                if yPosition + 30 > pageHeight - margin - 50 {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                    drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += 30
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
    
    
    
    static func generateMonthlySalesPDF(salesData: [MonthlySale], fileName: String, courseName: String, screenshot: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Monthly Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let maxRowsPerPage = Int((pageHeight - (2 * margin) - 200) / rowHeight)
            let totalPages = Int(ceil(Double(salesData.count) / Double(maxRowsPerPage)))
            
            context.beginPage()
            
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Sales Report for \(courseName)")

            if let screenshot = screenshot {
                let imageHeight = 210.0
                let imageWidth = contentWidth/1.2
                let centerX = (pageWidth - imageWidth) / 2
                print("Probicaaaaaa: \(contentWidth/1.2)")
                let imageRect = CGRect(x: centerX, y: margin + 49, width: imageWidth, height: imageHeight)
                screenshot.draw(in: imageRect)
            }
            
            drawTableHeader(context: context, margin: margin, yPosition: margin + 270)
            var yPosition = margin + 300
            
            salesData.enumerated().forEach { (index, sale) in
                if yPosition + rowHeight > pageHeight - margin {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Sales Report for \(courseName)")
                    drawTableHeader(context: context, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += rowHeight
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }

    // Helper functions
    private static func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlySale, margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
        let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
        rowBackgroundColor.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: 532, height: 30)).fill()

        let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]
        sale.formattedMonth.draw(at: CGPoint(x: margin + 10, y: yPosition + 8), withAttributes: textAttributes)
        "\(sale.sales)".draw(at: CGPoint(x: margin + 300, y: yPosition + 8), withAttributes: textAttributes)
    }

    private static func drawTableHeader(context: UIGraphicsPDFRendererContext, margin: CGFloat, yPosition: CGFloat) {
        UIColor.systemBlue.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: 532, height: 30)).fill()

        let headerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white]
        "Month".draw(at: CGPoint(x: margin + 10, y: yPosition + 8), withAttributes: headerAttributes)
        "Sales".draw(at: CGPoint(x: margin + 300, y: yPosition + 8), withAttributes: headerAttributes)
    }

    private static func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int, courseName: String, title: String) {
        let title = title
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.black]
        let titleSize = title.size(withAttributes: titleAttributes)
        title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)

        let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
        let footerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.gray]
        footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

        let pageText = "Page \(currentPage) of \(totalPages)"
        pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: footerAttributes)
    }
    
    static func capturePartialScreenshot<Content: View>(of view: Content, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.overrideUserInterfaceStyle = .light
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    static func generateWeeklyMinMaxSalesPDF(salesData: [WeeklyMinMaxSale], fileName: String, courseName: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Weekly Min-Max Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [CGFloat(contentWidth / 3), CGFloat(contentWidth / 3), CGFloat(contentWidth / 3)]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: WeeklyMinMaxSale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

            let week = sale.formattedWeek
            let maxSales = "\(sale.maxSales)"
            let minSales = "\(sale.minSales)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [week, maxSales, minSales].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + rowHeight))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }

        func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Week", "Max Sales", "Min Sales"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }

        func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
            let title = "Weekly Min-Max Sales Report for \(courseName)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)

            let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

            let pageText = "Page \(currentPage) of \(totalPages)"
            pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: footerAttributes)
        }

        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let totalPages = Int(ceil(Double(salesData.count) / 20))
            var yPosition = margin + 50

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
            drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
            yPosition += rowHeight

            salesData.enumerated().forEach { (index, sale) in
                if yPosition + rowHeight > pageHeight - margin - 50 {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                    drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += rowHeight
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
    
    static func generateMonthlyMinMaxSalesPDF(salesData: [MonthlyMinMaxSale], fileName: String, courseName: String, screenshot: UIImage?) -> URL? {
            let pdfMetaData = [
                kCGPDFContextCreator: "ImeAplikacije",
                kCGPDFContextAuthor: "ImeAplikacije",
                kCGPDFContextTitle: "Weekly Min-Max Sales Report"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]

            let pageWidth = 612.0
            let pageHeight = 792.0
            let margin = 40.0
            let contentWidth = pageWidth - 2 * margin
            let rowHeight = 30.0
            let columnWidths = [CGFloat(contentWidth / 3), CGFloat(contentWidth / 3), CGFloat(contentWidth / 3)]

            let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

            func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlyMinMaxSale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
                let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
                rowBackgroundColor.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

                let week = sale.formattedMonth
                let maxSales = "\(sale.maxSales)"
                let minSales = "\(sale.minSales)"
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]

                [week, maxSales, minSales].enumerated().forEach { (index, value) in
                    value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
                }

                for i in 1..<columnWidths.count {
                    let lineX = margin + columnWidths[0] * CGFloat(i)
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: lineX, y: yPosition))
                    linePath.addLine(to: CGPoint(x: lineX, y: yPosition + rowHeight))
                    linePath.lineWidth = 1
                    UIColor.lightGray.setStroke()
                    linePath.stroke()
                }
            }

            func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
                UIColor.systemBlue.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white
                ]
                ["Week", "Max Sales", "Min Sales"].enumerated().forEach { (index, header) in
                    header.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
                }
            }

            func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
                let title = "Monthly Min-Max Sales Report for \(courseName)"
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ]
                let titleSize = title.size(withAttributes: titleAttributes)
                title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)

                let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

                let pageText = "Page \(currentPage) of \(totalPages)"
                pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: footerAttributes)
            }

            let pdfData = pdfRenderer.pdfData { context in
                var currentPage = 1
                let totalPages = 2
                var yPosition = margin + 50

                context.beginPage()
                drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                
                if let screenshot = screenshot {
                    let imageHeight = 450.0
                    let imageWidth = contentWidth
                    let centerX = (pageWidth - imageWidth) / 2
                    let imageRect = CGRect(x: centerX, y: margin + 135, width: imageWidth, height: imageHeight)
                    screenshot.draw(in: imageRect)
                    yPosition = margin + 70  // Postavljanje yPosition ispod slike
                }

                // Novi početak stranice za tabelu
                context.beginPage()
                currentPage += 1
                drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)

                drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
                yPosition += rowHeight

                salesData.enumerated().forEach { (index, sale) in
                    if yPosition + rowHeight > pageHeight - margin - 50 {
                        context.beginPage()
                        currentPage += 1
                        drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                        drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                        yPosition = margin + 80
                    }

                    drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                    yPosition += rowHeight
                }
            }

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
            do {
                try pdfData.write(to: url)
                return url
            } catch {
                print("Error writing PDF: \(error)")
                return nil
            }
        }


    
    static func captureSalesPerCourseCategoryView<Content: View>(view: Content, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.overrideUserInterfaceStyle = .light
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    static func generateSalesPerCourseCategoryViewPDF(fileName: String, chartImage: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Sales per Category Report with Chart"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let totalPages = 1

            context.beginPage()

            // Header i footer
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: "courseName", title: "Sales per Course Report")

            // Prikaz grafikona na sredini stranice
            if let chartImage = chartImage {
                let imageHeight = 400.0
                let imageWidth = contentWidth
                print("Proba u sales per course za sirinu: \(imageWidth)")
                print("Proba u sales per course za visinu: \(imageHeight)")
                
                let centerX = (pageWidth - imageWidth) / 2
                
                let imageRect = CGRect(x: centerX, y: margin + 130, width: imageWidth, height: imageHeight)
                chartImage.draw(in: imageRect)
            }

        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }

    static func generateMonthlyEarningsSalesPDF(salesData: [MonthlyEarnings], fileName: String, courseName: String, screenshot: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Monthly Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [CGFloat(contentWidth / 4), CGFloat(contentWidth / 4), CGFloat(contentWidth / 4), CGFloat(contentWidth / 4)]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let pdfData = pdfRenderer.pdfData { context in
            func drawTableHeader(context: UIGraphicsPDFRendererContext, margin: CGFloat, yPosition: CGFloat) {
                UIColor.systemBlue.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: contentWidth, height: 30)).fill()

                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white
                ]
                ["Month", "Gross Earnings", "Net Earnings", "Difference"].enumerated().forEach { (index, header) in
                    header.draw(at: CGPoint(x: margin + CGFloat(index) * columnWidths[index] + 10, y: yPosition + 8), withAttributes: headerAttributes)
                }
            }

            func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlyEarnings, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
                let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
                rowBackgroundColor.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                let month = formatter.string(from: sale.month)
                let grossEarnings = String(format: "%.2f", sale.grossEarnings)
                let netEarnings = String(format: "%.2f", sale.netEarnings)
                let difference = String(format: "%.2f", sale.grossEarnings - sale.netEarnings)

                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]

                [month, grossEarnings, netEarnings, difference].enumerated().forEach { (index, value) in
                    value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
                }

                for i in 1..<columnWidths.count {
                    let lineX = margin + columnWidths[0] * CGFloat(i)
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: lineX, y: yPosition))
                    linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                    linePath.lineWidth = 1
                    UIColor.lightGray.setStroke()
                    linePath.stroke()
                }
            }

            var currentPage = 1
            let maxRowsPerPage = Int((pageHeight - (2 * margin) - 200) / rowHeight)
            let totalPages = Int(ceil(Double(salesData.count) / Double(maxRowsPerPage)))

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Earnings Report")

            if let screenshot = screenshot {
                let imageHeight = 250.0
                let imageWidth = 350.0
                print("SigiliMigili: \(imageWidth)")
                let centerX = (pageWidth - imageWidth) / 2
                let imageRect = CGRect(x: centerX, y: margin, width: imageWidth, height: imageHeight)
                screenshot.draw(in: imageRect)
            }

            drawTableHeader(context: context, margin: margin, yPosition: margin + 270)
            var yPosition = margin + 300

            salesData.enumerated().forEach { (index, sale) in
                if yPosition + rowHeight > pageHeight - margin {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Earnings Report")
                    drawTableHeader(context: context, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += rowHeight
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }

        func drawTableHeader(context: UIGraphicsPDFRendererContext, margin: CGFloat, yPosition: CGFloat) {
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: 532, height: 30)).fill()

            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Month", "Gross Earnings", "Net Earnings", "Difference"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + CGFloat(index) * (532 / 4) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlyEarnings, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let month = formatter.string(from: sale.month)
            let grossEarnings = String(format: "%.2f", sale.grossEarnings)
            let netEarnings = String(format: "%.2f", sale.netEarnings)
            let difference = String(format: "%.2f", sale.grossEarnings - sale.netEarnings)

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [month, grossEarnings, netEarnings, difference].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }

    
    static func generateDailySalesPDF(salesData: [DailySale], fileName: String, courseName: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Daily Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [contentWidth / 2, contentWidth / 2]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: DailySale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            // Naizmenične boje za redove
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst u redu
            let week = sale.formattedDay
            let sales = "\(sale.quantity)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [week, sales].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            // Linije između kolona
            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }
        
        func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
            // Pozadina zaglavlja
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst zaglavlja
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Day", "Sales"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }
        
        func drawTableBorder(context: UIGraphicsPDFRendererContext, margin: CGFloat, tableTopYPosition: CGFloat, tableBottomYPosition: CGFloat) {
            let borderPath = UIBezierPath(rect: CGRect(x: margin, y: tableTopYPosition, width: contentWidth, height: tableBottomYPosition - tableTopYPosition))
            borderPath.lineWidth = 1
            UIColor.black.setStroke()
            borderPath.stroke()
        }
        
        func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
            // Header sa naslovom
            let title = "Daily Sales Report for \(courseName)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)
            let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

                let pageText = "Page \(currentPage) of \(totalPages)"
                let pageAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: pageAttributes)
        }
        
        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let availableHeight = pageHeight - (2 * margin) - 50
            let maxRowsPerPage = Int(availableHeight / rowHeight)
            let totalPages = 20
            let columnWidths = [CGFloat(contentWidth / 2), CGFloat(contentWidth / 2)]
            var yPosition = margin + 50

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
            drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
            yPosition += 30

            var tableTopYPosition = yPosition
            var rowCount = 0
            salesData.enumerated().forEach { (index, sale) in
                if yPosition + 30 > pageHeight - margin - 50 {
                    print("Page \(currentPage) had \(rowCount) rows before starting new page.")
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                    drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                    rowCount = 0
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += 30
                rowCount += 1
            }
            print("Page \(currentPage) had \(rowCount) rows at the end.")
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
    
    

}

struct PDFPreviewView: View {
    let url: URL
    
    var body: some View {
        VStack {
            if let document = PDFDocument(url: url) {
                PDFKitView(document: document)
            } else {
                Text("Failed to load PDF")
                    .foregroundColor(.red)
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct PDFTestView: View {
    @ObservedObject var salesViewModel: SalesViewModel
    
    @State private var showPDF = false
    @State private var pdfURL: URL?
    
    var body: some View {
        VStack {
            // Prikaz podataka kao tabela
            List(salesViewModel.salesByWeek) { sale in
                HStack {
                    Text(sale.formattedWeek)
                    Spacer()
                    Text("\(sale.sales)")
                }
            }
            
            // Dugme za generisanje PDF-a
            Button(action: {
                if let pdfURL = PDFTableGenerator.generateWeeklySalesPDF(salesData: salesViewModel.salesByWeek.reversed(), fileName: "WeeklySalesReport for Course 1", courseName: "Proba") {
                    let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = scene.windows.first?.rootViewController {
                        rootVC.present(activityViewController, animated: true, completion: nil)
                    }
                } else {
                    print("Failed to generate PDF.")
                }
            }) {
                Text("Generate & Share PDF")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .sheet(isPresented: $showPDF) {
            if let pdfURL = pdfURL {
                PDFPreviewView(url: pdfURL)
            }
        }
    }
}

struct EarningsDetailGridView: View {
    
    @ObservedObject var viewModel: EarningsViewModel

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 10) {
            // Header row
            GridRow {
                Color.clear
                    .gridCellUnsizedAxes([.vertical, .horizontal])
                Text("Gross Earnings")
                    .gridCellAnchor(.center)
                    
                Text("Net Earnings")
                    .gridCellAnchor(.center)
                    
                Text("Difference")
                    .bold()
                    .gridCellAnchor(.trailing)
            }

            Divider()
                .gridCellUnsizedAxes([.vertical, .horizontal])

            // Data rows for each month
            ForEach(viewModel.monthlyEarnings) { data in
                GridRow {
                    Text(month(for: data.month))
                       
                        
                    Text(String(format: "%.2f", data.grossEarnings))
                        
                    Text(String(format: "%.2f", data.netEarnings))
                    Text(String(format: "%.2f", data.grossEarnings - data.netEarnings))
                        .bold()
                }
            }

            Divider()
                .gridCellUnsizedAxes([.vertical, .horizontal])

            // Total row
            GridRow {
                Text("Total")
                    .bold()

                Color.clear
                    .gridCellUnsizedAxes([.vertical, .horizontal])
                    .gridCellColumns(2)

                Text("$" + String(format: "%.2f", totalGrossEarnings()))
                    .bold()
                    .foregroundStyle(.pink)
                    .fixedSize()
            }
            
        }
    }

    // Helper function to format month names
    func month(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    // Calculate total gross earnings
    func totalGrossEarnings() -> Double {
        viewModel.monthlyEarnings.map { $0.grossEarnings }.reduce(0, +)
    }
}


struct EarningsChartView: View {
    @State private var showPDF = false
    @State private var pdfURL: URL?
    @ObservedObject var viewModel: EarningsViewModel
    
    func totalGrossEarnings() -> Double {
        viewModel.monthlyEarnings.map { $0.grossEarnings }.reduce(0, +)
    }
    func printanje(){
        if let screenshot = PDFTableGenerator.captureSalesPerCourseCategoryView(view: EarningsChart(viewModel: viewModel), size: CGSize(width: 350, height: 250)),
           let pdfURL = PDFTableGenerator.generateMonthlyEarningsSalesPDF(salesData: viewModel.monthlyEarnings.reversed(), fileName: "Monthly Earnings Report", courseName: "Proba", screenshot: screenshot) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                print("⚠️ Already presenting: \(String(describing: rootVC))")
                rootVC.dismiss(animated: true) {
                    self.presentPDFSharing(pdfURL: pdfURL)
                }
            } else {
                presentPDFSharing(pdfURL: pdfURL)
            }
        }

    }
    
    private func presentPDFSharing(pdfURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
            }
        }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
        VStack {
            Group {
                Text("Your total earnings for the last year are: ") +
                Text("$" + String(format: "%.2f", totalGrossEarnings()))
                    .bold()
                    .foregroundStyle(.pink)
                    
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.top)
            
            EarningsChart(viewModel: viewModel)
            .frame(height: 300)
            .padding(.horizontal).padding(.bottom).padding(.top)
            Divider()
                
                .frame(height: 1) // Debljina linije postavljena na 3 piksela
                .background(.gray.opacity(0.3))
                    // Postavi boju linije
                    .padding(.vertical)
                    
                    // Smanjuje širinu sa svake strane za 50 piksela
            Text("Detailed Breakdown of Your Earnings per Month")
                .bold()
                
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            EarningsDetailGridView(viewModel: viewModel)
                .padding(.horizontal, 10)
            Divider()
                .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: printanje) {
                            Image(systemName: "printer.filled.and.paper")
                        }
                    }
                }
        .sheet(isPresented: $showPDF) {
            if let pdfURL = pdfURL {
                PDFPreviewView(url: pdfURL)
            }
        }
        
            
            

    }
        
        
        
        
        
        
    }
}

struct EarningsChart: View {
    @ObservedObject var viewModel: EarningsViewModel
    var body: some View {
        Chart(viewModel.monthlyEarnings) { data in
            
            LineMark(
                x: .value("Month", data.month),
                y: .value("Gross Earnings", data.grossEarnings)
            )
            .foregroundStyle(.blue)
            .symbol(by: .value("Legend", "Gross Earnings"))
            .interpolationMethod(.catmullRom)
            
            LineMark(
                x: .value("Month", data.month),
                y: .value("Net Earnings", data.netEarnings)
            )
            .foregroundStyle(.purple)
            .symbol(Circle())
            .interpolationMethod(.catmullRom)
            AreaMark(
                x: .value("Month", data.month),
                yStart: .value("Net Earnings", data.netEarnings),
                yEnd: .value("Gross Earnings", data.grossEarnings)
            )
            .foregroundStyle(
                .linearGradient(
                    Gradient(colors: [.purple.opacity(0.3), .blue.opacity(0.5)]), // Boje gradijenta
                    startPoint: .bottom,
                    endPoint: .top
                )
            ) // Boja prostora između linija
            .interpolationMethod(.catmullRom)
        }
        
        .chartLegend(position: .bottom, spacing: 10) {
            HStack {
                Circle()
                    .fill(.blue) // Boja za maksimalne vrijednosti
                    .frame(width: 10, height: 10)
                Text("Gross Earnings").foregroundStyle(Color.secondary).font(.footnote)

                Circle()
                    .fill(.purple) // Boja za minimalne vrijednosti
                    .frame(width: 10, height: 10)
                Text("Net Earnings").foregroundColor(Color.secondary).font(.footnote)
            }
        }
        .chartXAxis {
            AxisMarks(values: viewModel.monthlyEarnings.enumerated().compactMap { index, data in
                index.isMultiple(of: 2) ? data.month : nil
            }) { value in
                AxisGridLine() // Grid linija za odabrane mjesece
                AxisTick() // Tick oznaka ispod mjeseca
                AxisValueLabel(centered: false, anchor: .top) {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated))
                    }
                }
            }
        }
    }
    
    
}

struct MonthlyEarnings: Identifiable, Codable {
    let id = UUID()
    let month: Date
    let grossEarnings: Double
    let netEarnings: Double
}

class EarningsViewModel: ObservableObject {
    @Published var monthlyEarnings: [MonthlyEarnings] = []

    init() {
        loadEarningsData()
    }

    func loadEarningsData() {
        guard let url = Bundle.main.url(forResource: "earnings_data", withExtension: "json") else {
            print("JSON file not found.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter())

            // Dekodiraj objekat umesto niza
            let jsonResponse = try decoder.decode(MonthlyEarningsResponse.self, from: data)
            monthlyEarnings = jsonResponse.monthlyEarnings.sorted { $0.month < $1.month }

        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

struct MonthlyEarningsResponse: Codable {
    let monthlyEarnings: [MonthlyEarnings]
}

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

extension UIView {
    func takeScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

#Preview{
    EarningsDetailGridView(viewModel: EarningsViewModel())
}
