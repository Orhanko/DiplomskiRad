//
//  ContentView.swift
//  DiplomskiRad
//
//  Created by Orhan Pojskic on 13.06.2024..
//

import SwiftUI
import Charts

extension Color {
    func darker(by percentage: CGFloat = 0.2) -> Color {
        let uiColor = UIColor(self) // Pretvaramo SwiftUI `Color` u `UIColor`
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(UIColor(
                red: max(red - percentage, 0),
                green: max(green - percentage, 0),
                blue: max(blue - percentage, 0),
                alpha: alpha
            ))
        }

        return self // Vraća istu boju ako nije uspjelo
    }
}

struct ContentView: View {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()  // Opaque pozadina
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    @State private var isMenuOpen: Bool = false
    @State private var isOnboardingPresented: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
            tabContent
            .offset(x: isMenuOpen ? 300 : 0) // Pomjeranje TabView-a
            .blur(radius: isOnboardingPresented ? 5 : 0) // Zamagljenje pozadine kada je Onboarding aktivan
            .animation(.easeInOut, value: isMenuOpen)
            .animation(.easeInOut, value: isOnboardingPresented)
            
            // Side Menu
            if isMenuOpen {
                SideMenu(isOpen: $isMenuOpen)
                    .frame(width: 300) // Širina SideMenu-a
                    .transition(.move(edge: .leading)) // Animacija ulaska
                    .zIndex(1)
            }
            
            // Onboarding View
            if isOnboardingPresented {
                Color(colorScheme == .dark ? .gray : .black)
                    .opacity(0.5) // Zamračena pozadina sa transparentnošću
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isOnboardingPresented = false
                        }
                    }
                    .zIndex(2) // Zamračenje ispod modala
                
                OnboardingView(isPresented: $isOnboardingPresented)
                    .zIndex(3) // Prikaz modala iznad svega
                    .transition(.move(edge: .top)) // Ulaz odozgo
            }
        }
        
    
    }
    
    var tabContent: some View {
        TabView {
            TabOneView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
            .tabItem {
                Label("Courses", systemImage: "bubble.left.and.bubble.right")
            }
            TabTwoView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Search", systemImage: "magnifyingglass")}
            TabThreeView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Recent", systemImage: "clock")}
            TabFourView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Notifications", systemImage: "bell")}
            TabFiveView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
                .tabItem{Label("Profile", systemImage: "person")}
            
        }

    }
}

struct TabOneView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(courses) { course in
                            let jsonName = course.chart
                            let viewModel = SalesViewModel(jsonName: jsonName)
                            VCard(course: course, viewModel: viewModel)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 10)
                    
                }
                VStack {
                    Text("Recent")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 20) {
                        ForEach(courseSections) { section in
                            HCard(section: section)
                        }
                    }
                }
                .padding(20)
            }
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Courses")
        }
    }
}

struct TabTwoView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    
    @StateObject var highestSalesViewModel = HighestSalesViewModel()
    @StateObject private var viewModel = SalesViewModel(jsonName: "first-course-monthly-sales")
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                VStack {
                    DailySalesChartView(salesData: viewModel.salesData)
                        .padding()
                    NavigationLink{
                        SalesPerBookCategoryView(viewModel: highestSalesViewModel)
                    } label: {
                        SectorMarkView(salesViewModel: highestSalesViewModel)
                    }.buttonStyle(PlainButtonStyle())
//                SectorMarkView()
                        .padding()
                    MonthlyMinMaxSalesChartView(viewModel: viewModel)
                }
            }
            
            
            
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Search")
        }
        
    }
    func formatDate(date: Date, format: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
}

struct MonthlyMinimizedSalesChartView: View {
    var barColor: Color // Dodana boja kao parametar
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
                        .foregroundStyle(Color(#colorLiteral(red: 0.922002852, green: 0.9209583402, blue: 0.9954648614, alpha: 1)))// Skratnice naziva mjeseci
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

struct WeeklySale: Identifiable {
    let id = UUID()
    let week: Date
    let sales: Int
}

struct WeeklySalesChartView: View {
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    @State private var scrollPosition: TimeInterval = 0
    @State private var showAverageLine: Bool = false
     
    enum ChartStyle: String, CaseIterable, Identifiable {
        case bar = "Bar Mark"
        case line = "Line Mark"
        
        var id: Self { self }
    }
    @State private var selectedChartStyle: ChartStyle = .bar

    var body: some View {
        VStack {
            
            ZStack {
                if selectedChartStyle == .bar {
                    barMarkView
                        .transition(.opacity)
                } else {
                    lineMarkView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedChartStyle)
            
            Divider()
                .background(Color.secondary.opacity(0.5)) // Boja slična placeholderu
                .frame(height: 1) // Tanak divider
            HStack{
                Text("Average: \(Int(salesViewModel.averageWeeklySales))")
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
            
            
                
        }
        .onAppear {
            // Skrol pozicija na zadnju sedmicu
            if let lastDate = salesViewModel.salesByWeek.last?.week {
                scrollPosition = lastDate.timeIntervalSinceReferenceDate - 3600 * 24 * 7 * 4 // Pozicionira 4 sedmice unazad
            }
            
        }
        
        
    }
    private var barMarkView: some View {
        Chart(salesViewModel.salesByWeek, id: \.week) { data in
            BarMark(
                x: .value("Sedmica", data.week, unit: .weekOfYear),
                y: .value("Prodaja", data.sales)
            )
            

            
            
            .foregroundStyle(color)
            .cornerRadius(5)
            if showAverageLine {
                RuleMark(
                    y: .value("Prosjek prodaje", salesViewModel.averageWeeklySales)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundStyle(color.darker(by: 0.25))
            }
        }
        
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 1)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).year(/*.twoDigits*/)) // Prikaz mjeseca i godine
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $scrollPosition)
        .chartXVisibleDomain(length: 3600 * 24 * 7 * 9) // Prikazuje 20 sedmica (umjesto samo 8)
        .frame(height: 300)
    }
    
    private var lineMarkView: some View {
        
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
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
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
        .chartXVisibleDomain(length: 3600 * 24 * 7 * 9) // Prikazuje 20 sedmica (umjesto samo 8)
        .frame(height: 300)
    }
}

struct VCardDetailsView: View{
    enum ChartStyle: String, CaseIterable, Identifiable {
        case month = "Monthly Insight"
        case week = "Weekly Insight"
        case day = "Daily Insight"
        var id: Self { self }
    }
    
    let color: Color
    
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedChartStyle: ChartStyle = .month
    
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
            .padding(.bottom)
            ZStack {
                if selectedChartStyle == .month {
                    MonthlySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                } else if selectedChartStyle == .week{
                    WeeklySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                } else{
                    DailySalesChartView(salesData: viewModel.salesData)
                        .transition(.opacity)
                }
                        
                }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
            Spacer()
                
        }.padding()
        }
    }


import SwiftUI
import Charts

struct MonthlyMinMaxSalesChartView: View {
    @ObservedObject var viewModel: SalesViewModel
    @State private var rawSelectedDate: Date?
    var selectedMinMax: MonthlyMinMaxSale? {
        guard let rawSelectedDate else{ return nil}
        return viewModel.monthlyMinMaxSales.first{
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.month, toGranularity: .month)
        }
    }
    var body: some View {
        VStack {
            
            
            Chart{
                if let selectedMinMax{
                    RuleMark(x: .value("Selected", selectedMinMax.month, unit: .month))
                        .foregroundStyle(Color.secondary).opacity(0.5)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)){
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
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
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
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                    AxisGridLine()
                        
                }
            }
            .frame(height: 300)
            .padding()
        }
    }
}

struct MonthlySalesChartView: View {
    
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    enum ChartStyle: String, CaseIterable, Identifiable {
        case bar = "Bar Mark"
        case line = "Line Mark"
        
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
                } else {
                    lineMarkView
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
    
    private var lineMarkView: some View {
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

class SalesViewModel: ObservableObject {
    @Published var salesData: [Sale] = [] // Lista prodaja
    @Published var salesByMonth: [MonthlySale] = []
    @Published var salesByWeek: [WeeklySale] = [] // Lista prodaja po sedmicama
    @Published var monthlyMinMaxSales: [MonthlyMinMaxSale] = []

    init(jsonName: String) {
        generateDummyData()
        self.salesByMonth = loadMonthlySales(from: jsonName)
        generateRandomWeeklySalesData()
        generateRandomMonthlyMinMaxData()
    }

    func generateDummyData() {
            let calendar = Calendar.current
            let currentDate = Date()

            // Dodajemo nasumične prodaje za svaki dan unazad 365 dana
            for dayOffset in 0..<365 {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: currentDate) {
                    let randomQuantity = Int.random(in: 0...100) // Nasumična količina prodaje po danu
                    salesData.append(Sale(saleDate: date, quantity: randomQuantity))
                }
            }

            // Sortiramo podatke po datumu
            salesData.sort { $0.saleDate < $1.saleDate }
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
    
    func generateRandomWeeklySalesData() {
        let calendar = Calendar.current
        let currentDate = Date()

        // Pronalazak početka trenutne sedmice
        guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) else {
            return
        }

        // Generiši podatke za 52 sedmice unazad (uključujući trenutnu sedmicu)
        salesByWeek = (0..<52).map { weekOffset in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: startOfCurrentWeek) ?? Date()
            let salesCount = Int.random(in: 200...1000) // Nasumična količina prodaja
            return WeeklySale(week: weekStart, sales: salesCount)
        }.reversed() // Od najstarijeg ka najnovijem
    }
        var averageWeeklySales: Double {
            let totalSales = salesByWeek.reduce(0) { $0 + $1.sales }
            return Double(totalSales) / Double(salesByWeek.count)
        }
    
    func generateRandomMonthlyMinMaxData() {
            let calendar = Calendar.current
            let currentDate = Date()

            for monthOffset in 0..<12 {
                if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: currentDate) {
                    let maxSales = Int.random(in: 5000...20000) // Maksimalna prodaja
                    let minSales = Int.random(in: 1000...5000)  // Minimalna prodaja
                    monthlyMinMaxSales.append(MonthlyMinMaxSale(month: monthDate, maxSales: maxSales, minSales: minSales))
                }
            }

            // Sortiramo podatke po mjesecima
        monthlyMinMaxSales.sort { $0.month < $1.month }
        }
}

struct MonthlySale: Decodable {
    let month: Date
    let sales: Int
}

struct Sale: Identifiable {
    let id = UUID()
    let saleDate: Date
    let quantity: Int
}

struct HighestCourseSale: Identifiable {
    let id = UUID()
    let category: String
    let sales: Double
    let color: Color
}

struct MonthlyMinMaxSale: Identifiable, Equatable {
    let id = UUID()
    let month: Date
    let maxSales: Int
    let minSales: Int
}

class HighestSalesViewModel: ObservableObject {
    @Published var totalSalesPerCategory: [HighestCourseSale] = []

    init() {
        generateRandomSalesData() // Generisanje nasumičnih podataka
    }

    func generateRandomSalesData() {
        let coursesWithColors: [(String, Color)] = [
                    ("Kurs 1", .blue),
                    ("Kurs 2", .green),
                    ("Kurs 3", .orange),
                    ("Kurs 4", .purple)
                ]
        totalSalesPerCategory = coursesWithColors.map { (courseName, color) in
            HighestCourseSale(category: courseName, sales: Double.random(in: 100...500), color: color)
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
            // Tekst sa informacijom o najprodavanijem kursu
//            Text(salesViewModel.bestSellingPercentageText)
            if let bestSellingCategory = salesViewModel.bestSellingCategory {
                let percentage = (bestSellingCategory.sales / salesViewModel.totalSales) * 100

                Group { // Grupisanje teksta radi dodavanja padding-a na cijelu rečenicu
                    Text("Najprodavaniji kurs je ") +
                    Text("\(bestSellingCategory.category)")
                        .foregroundColor(.blue) // Boja naziva kursa
                        .fontWeight(.heavy) +
                    Text(" sa \(String(format: "%.2f", percentage))% ukupnih prodaja.")
                        .foregroundColor(.primary) // Ostatak teksta u default boji
                }
                .padding() // Padding na cijelu grupu teksta
            } else {
                Text("Nema podataka o prodaji.")
                    .padding() // Dodavanje padding-a i za "fallback" poruku
            }
                

            // SectorMark Chart
            if #available(macOS 14.0, *) {
                Chart(salesViewModel.totalSalesPerCategory, id: \.category) { data in
                    SectorMark(
                        angle: .value("Prodaja", data.sales),
                        innerRadius: .ratio(0.5), // Donut izgled
                        angularInset: 1.5 // Razmak između sektora
                    )
                    .foregroundStyle(.blue/*by: .value("Kategorija", data.category)*/) // Različite boje po kategorijama
                    .cornerRadius(5.0)
                    .opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.2) // Najprodavaniji kurs ima punu vidljivost
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 70) // Veličina pie chart-a
                .padding()
                .chartLegend(.hidden)
            }
            Image(systemName: "chevron.right") // Strelica desno
                            .foregroundColor(.gray) // Siva boja strelice
                            .font(.system(size: 16)) // Prilagođena veličina i težina
                            .padding(.trailing,5)
        }
        
        .frame(maxWidth: .infinity, maxHeight: 110)
        
        .background(/*Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))*/.gray.opacity(0.2))
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
        
}

struct SalesPerBookCategoryView: View {
    
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
                    Text("Najprodavaniji kurs je ") +
                    Text("\(bestSellingCategory.category)")
                        .foregroundColor(bestSellingCategory.color) // Boja naziva kursa
                        .fontWeight(.heavy) +
                    Text(" sa \(String(format: "%.2f", percentage))% ukupnih prodaja.")
                        .foregroundColor(.primary) // Ostatak teksta u default boji
                }
                
                .padding(.bottom)
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
            }
            Spacer()
            Button(action: {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                viewModel.generateRandomSalesData() // Generiše nove random podatke
                            }
                        }, label: {
                            Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                                .padding(.bottom, 50)
                        })
                        
            
            
            
        }
        .padding()
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
            .foregroundStyle(data.category == salesViewModel.bestSellingCategory?.category ? data.color.opacity(1) : data.color.opacity(0.6)) // Prilagođena boja za najbolju kategoriju
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
            .chartLegend(alignment: .center) {
                HStack {
                    ForEach(Array(salesViewModel.totalSalesPerCategory.sorted(by: { $0.sales > $1.sales }).enumerated()), id: \.element.category) { index, item in
                        Label {
                            Text(item.category)
                                .padding(.top)
                                .font(.body)
                                .foregroundColor(.primary)
                        } icon: {
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(item.color)
                                .opacity(index == 0 ? 1 : 0.3)
                            // Boja na osnovu kategorije
                        }
                        .padding(.trailing)
                    }
                }.padding(.leading)
            }// Prikazuje legendu ispod grafikona
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    
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
                        .frame(width: frame.width * 0.6) // Ograničimo širinu teksta unutar kruga
                        .position(x: frame.midX, y: frame.midY) // Centriramo tekst unutar grafikona
                    }
                }
            }
            .frame(width: 380, height: 380) // Veći prikaz
            //.padding()
        }
        //.padding()
    }
}



struct DailySalesChartView: View {

    let salesData: [Sale]
    

    init(salesData: [Sale]) {
        self.salesData = salesData

        guard let lastDate = salesData.last?.saleDate else { return }
            self._scrollPosition = State(initialValue: lastDate.timeIntervalSinceReferenceDate)

    }

    let numberOfDisplayedDays = 31

    @State var scrollPosition: TimeInterval = TimeInterval()

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

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            Text("\(scrollPositionString) – \(scrollPositionEndString)")
                .font(.callout)
                .foregroundStyle(.secondary)

            Chart(salesData, id: \.saleDate) {
                LineMark(
                    x: .value("Day", $0.saleDate, unit: .day),
                    y: .value("Sales", $0.quantity)
                )
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
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 3")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Recent")
        }

    }
}

struct TabFourView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 4")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Notifications")
        }

    }
}

struct TabFiveView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    var body: some View {
        NavigationView{
            Text("Nesto 5")
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                },
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85, blendDuration: 0.4)) {
                        isOnboardingPresented = true
                    }
                }) {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
            .navigationTitle("Profile")
        }

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
        .frame(width: 360, height: 460)
        .background(.linearGradient(colors: [course.color.opacity(1), course.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
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
                    .font(.system(size: 20)) // Prilagođena veličina i težina
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
                //VStack{
                VCardDetailsView(color: course.color, viewModel: viewModel)
                    .navigationTitle(course.title)// Modalni prikaz sa istim podacima
                    .navigationBarTitleDisplayMode(.inline)
                //}
                
                //                                .toolbar {
                //                                            ToolbarItem(placement: .navigationBarTrailing) {
                //                                                Button(action: {
                //                                                    isModalPresented = false
                //                                                }) {
                //                                                    Image(systemName: "xmark.circle")
                //                                                }
                //                                            }
                //                                        }
                //}
            }.presentationDragIndicator(.visible)
            
            //.interactiveDismissDisabled(true)
        }

        //}
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


#Preview{
    
    MonthlySalesChartView(salesViewModel: SalesViewModel(jsonName: "blabla"), color: .blue)
}
