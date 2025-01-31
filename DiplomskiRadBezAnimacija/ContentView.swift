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
                .tabItem{Label("Statistics", systemImage: "doc.text.fill")}
//            TabThreeView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
//                .tabItem{Label("Recent", systemImage: "clock")}
//            TabFourView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
//                .tabItem{Label("Notifications", systemImage: "bell")}
//            TabFiveView(isMenuOpen: $isMenuOpen, isOnboardingPresented: $isOnboardingPresented)
//                .tabItem{Label("Profile", systemImage: "person")}
            
        }

    }
}

struct TabOneView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isOnboardingPresented: Bool
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                
                    VStack(spacing: 50) {
                        ForEach(courses) { course in
                            let jsonName = course.chart
                            let viewModel = SalesViewModel(jsonName: jsonName)
                            VCard(course: course, viewModel: viewModel)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 10)
                    
                
//                VStack {
//                    Text("Recent")
//                        .font(.title)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    VStack(spacing: 20) {
//                        ForEach(courseSections) { section in
//                            HCard(section: section)
//                        }
//                    }
//                }
//                .padding(20)
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
    @StateObject var earningsViewModel = EarningsViewModel()
    
    @StateObject private var viewModel = SalesViewModel(jsonName: "first-course-monthly-sales")
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                VStack {
                    NavigationLink{
                        SalesPerBookCategoryView(viewModel: highestSalesViewModel)
                    } label: {
                        SectorMarkView(salesViewModel: highestSalesViewModel)
                    }.buttonStyle(PlainButtonStyle())
//                SectorMarkView()
                        .padding()
                        .padding(.horizontal, 10)
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
            .navigationTitle("Statistics")
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
    
    var formattedWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy" // Format datuma
        return formatter.string(from: week)
    }
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
            
            List {
                // Header sekcija
                Section(header: headerView) {
                    ForEach(salesViewModel.salesByWeek.reversed()) { sale in
                        HStack {
                            Text(sale.formattedWeek)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(sale.sales)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle()) // Ili .plain za jednostavniji stil
            // Pozadina celog prikaza
            .frame(maxHeight: 320)
            
            
                
        }
        .onAppear {
            // Skrol pozicija na zadnju sedmicu
            if let lastDate = salesViewModel.salesByWeek.last?.week {
                scrollPosition = lastDate.timeIntervalSinceReferenceDate - 3600 * 24 * 7 * 4 // Pozicionira 4 sedmice unazad
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
    
    private var barMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
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
            .chartXVisibleDomain(length: 3600 * 24 * 7 * 9) // Prikazuje 20 sedmica (umjesto samo 8)
            .frame(height: 300)
        }
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
    
    private func handleToolbarButtonPress() {
            switch selectedChartStyle {
            case .month:
                print("Monthly action triggered")
            case .week:
                print("Weekly action triggered")
            case .day:
                print("Daily action triggered")
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
        
        }
    }


import SwiftUI
import Charts

struct MonthlyMinMaxSalesChartView: View {
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedCourse: String = "course1"
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
    var body: some View {
        VStack {
            
            HStack(spacing: 0) {
                Text("Selected course:")
                    .foregroundStyle(.secondary)
            Picker("Select Course", selection: $selectedCourse) {
                Text("Course 1").tag("course1")
                Text("Course 2").tag("course2")
                Text("Course 3").tag("course3")
            }
            .pickerStyle(.menu)
            .onChange(of: selectedCourse) { newValue in
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
                            alignment: {
                                guard let index = selectedMinMaxIndex else { return .center }
                                let totalCount = viewModel.monthlyMinMaxSales.count

                                if index < 1 {
                                    return .leading // Pomjeri lijevo ako je među prve dvije sedmice
                                } else if index > totalCount - 2 {
                                    return .trailing // Pomjeri desno ako je među zadnje dvije sedmice
                                } else {
                                    return .center // U svim ostalim slučajevima ostaje centrirano
                                }
                            }(),
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
                                    .offset(x: selectedMinMaxIndex == 0 ? -10 : (selectedMinMaxIndex == viewModel.monthlyMinMaxSales.count - 1 ? 10 : 0))
                            
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
            .chartYScale(domain: 0...(Double(viewModel.weeklyMinMaxSales.map { $0.maxSales }.max() ?? 0) * 1.3))
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
    
    enum ChartStyle: String, CaseIterable, Identifiable {
        case month = "Month"
        case week = "Week"
        
        var id: Self { self }
    }
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedChartStyle: ChartStyle = .month
    
    var body: some View {
        VStack{
//            Text("Presented Data is valid for the past year.")
//                .font(.footnote)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundStyle(.secondary)
//                .fontWeight(.semibold)
//                .padding(.bottom, 10)
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
                    MonthlyMinMaxSalesChartView(viewModel: viewModel)
                        .transition(.opacity)
                } else if selectedChartStyle == .week{
                    WeeklyMinMaxSalesChartView(viewModel: viewModel)
                        .transition(.opacity)
                }
                        
                }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
            Spacer()
                
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
    @State private var rawSelectedDate: Date?
    @State private var scrollPosition: TimeInterval = 0
    var selectedMinMaxIndex: Int? {
        guard let selectedMinMax else { return nil }
        return viewModel.weeklyMinMaxSales.firstIndex(where: {
            Calendar.current.isDate($0.week, equalTo: selectedMinMax.week, toGranularity: .weekOfYear)
        })
    }
    var selectedMinMax: WeeklyMinMaxSale? {
        guard let rawSelectedDate else { return nil }
        return viewModel.weeklyMinMaxSales.first {
            Calendar.current.isDate(rawSelectedDate, equalTo: $0.week, toGranularity: .weekOfYear)
        }
    }

    enum ChartStyle: String, CaseIterable, Identifiable {
        case course1 = "Course 1"
        case course2 = "Course 2"
        case course3 = "Course 3"
        
        var id: Self { self }
    }
    @State private var selectedChartStyle: ChartStyle = .course1
    
    var body: some View {
        

        VStack {
            HStack(spacing: 0) {
                Text("Selected course:")
                    .foregroundStyle(.secondary)
                
                Picker("Chart Type", selection: $selectedChartStyle) {
                    ForEach(ChartStyle.allCases) {
                        Text($0.rawValue)
                    }
                }
                .frame(alignment: .leading)
                .pickerStyle(.menu)
                .tint(.blue)
                
                
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            chartView
                .frame(height: 500)
                .padding()
                .onAppear {
                            if let lastDate = viewModel.weeklyMinMaxSales.last?.week {
                                scrollPosition = lastDate.timeIntervalSinceReferenceDate - 3600 * 24 * 7 * 5 // Pozicionira 6 sedmica unazad
                            }
                        }
        }
        .onAppear {
            for sale in viewModel.weeklyMinMaxSales {
                print("📊 Week: \(sale.week), Max: \(sale.maxSales), Min: \(sale.minSales)")
            }
        }
    }

    private var chartView: some View {
        Chart {
            if let selectedMinMax {
                // ✅ RuleMark sada nosi anotaciju
                RuleMark(x: .value("Selected", selectedMinMax.week, unit: .weekOfYear))
                    .foregroundStyle(Color.secondary.opacity(0.5))
                    .annotation(
                        position: .top,
                        alignment: {
                            guard let index = selectedMinMaxIndex else { return .center }
                            let totalCount = viewModel.weeklyMinMaxSales.count

                            if index < 1 {
                                return .leading // Pomjeri lijevo ako je među prve dvije sedmice
                            } else if index > totalCount - 2 {
                                return .trailing // Pomjeri desno ako je među zadnje dvije sedmice
                            } else {
                                return .center // U svim ostalim slučajevima ostaje centrirano
                            }
                        }(),
                        spacing: 10,
                        overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                    ) {
                        annotationView(for: selectedMinMax)
                                            }
            }

            // Prikaz svih podataka
            ForEach(viewModel.weeklyMinMaxSales) { data in
                LineMark(
                    x: .value("Week", data.week, unit: .weekOfYear),
                    y: .value("Max Sales", data.maxSales)
                )
                .foregroundStyle(.green)
                .symbol(Circle())
                .symbolSize(50)
                .symbol(by: .value("Legend", "Maximum"))
                .opacity(rawSelectedDate == nil ? 1 : 0.5)

                LineMark(
                    x: .value("Week", data.week, unit: .weekOfYear),
                    y: .value("Min Sales", data.minSales)
                )
                .foregroundStyle(.red)
                .symbol(Circle())
                .symbolSize(50)
                .symbol(by: .value("Legend", "Minimum"))
                .opacity(rawSelectedDate == nil ? 1 : 0.5)
            }
        }
        .chartLegend(position: .bottom, spacing: 10) { legendView }
        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut(duration: 0.2)))
//        .onChange(of: rawSelectedDate) { oldValue, newValue in
//            print("📅 rawSelectedDate promijenjen: \(String(describing: newValue))")
//        }
        
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 6 * 7 * 24 * 60 * 60)
        .chartScrollPosition(x: $scrollPosition)
        .chartYScale(domain: 0...(Double(viewModel.weeklyMinMaxSales.map { $0.maxSales }.max() ?? 0) * 1.3))
        // Prikazuje 12 sedmica
        .chartYAxis {
            AxisMarks(position: .trailing) {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: 1)) { value in
                if let dateValue = value.as(Date.self) {
                    AxisValueLabel(centered: true) {
                        Text(weekLabel(for: dateValue))
                    }
                }
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
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.green, location: 0.5),
                    .init(color: Color.red, location: 0.5)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(10)
        .shadow(radius: 5)
        .offset(x: selectedMinMaxIndex == 0 ? -25 : (selectedMinMaxIndex == viewModel.weeklyMinMaxSales.count - 1 ? 25 : 0))
    }

    
    func weekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Skraceni format: Jan 5, Feb 12, itd.
        let dateString = formatter.string(from: date)
        
        return "\(dateString)"
    }
    
    private var legendView: some View {
        HStack {
            Circle()
                .fill(.green)
                .frame(width: 10, height: 10)
            Text("Max").foregroundStyle(Color.secondary).font(.footnote)

            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
            Text("Min").foregroundColor(Color.secondary).font(.footnote)
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
    @Published var salesData: [Sale] = [] // Lista prodaja
    @Published var salesByMonth: [MonthlySale] = []
    @Published var salesByWeek: [WeeklySale] = [] // Lista prodaja po sedmicama
    @Published var monthlyMinMaxSales: [MonthlyMinMaxSale] = []
    @Published var weeklyMinMaxSales: [WeeklyMinMaxSale] = []
    

    init(jsonName: String) {
        generateDummyData()
        self.salesByMonth = loadMonthlySales(from: jsonName)
        generateRandomWeeklySalesData()
        generateRandomMonthlyMinMaxData()
        generateRandomWeeklyMinMaxData()
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
    
    func generateRandomWeeklyMinMaxData() {
        let calendar = Calendar.current
        let currentDate = Date()

        // Prva cijela sedmica unazad
        guard let firstFullWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) else {
            return
        }

        weeklyMinMaxSales.removeAll() // Čistimo niz prije punjenja novih podataka

        for weekOffset in 0..<52 {
            if let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: firstFullWeek) {
                let maxSales = Int.random(in: 5000...20000) // Maksimalna prodaja
                let minSales = Int.random(in: 1000...5000)  // Minimalna prodaja
                weeklyMinMaxSales.append(WeeklyMinMaxSale(week: weekDate, maxSales: maxSales, minSales: minSales))
            }
        }

        // Sortiranje od najstarije do najnovije sedmice
        weeklyMinMaxSales.sort { $0.week < $1.week }
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

struct MonthlyMinMaxSale: Identifiable, Equatable, Decodable {
    let id = UUID()
    let month: Date
    let maxSales: Int
    let minSales: Int
}

struct WeeklyMinMaxSale: Identifiable {
    let id = UUID()
    let week: Date
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
    
    @ObservedObject var salesViewModel: SalesViewModel
    let color: Color
    @State var showAverageLine: Bool = false
    
    
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
            .onAppear {
            if let lastDate = salesViewModel.salesData.last?.saleDate {
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
                Text("Average: 123")
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
        }
        

    }
        
    
    private var barMarkView: some View {
        VStack(alignment: .leading, spacing: 5){
            Text("\(scrollPositionString) – \(scrollPositionEndString)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Chart(salesViewModel.salesData, id: \.saleDate) {
                BarMark(
                    x: .value("Day", $0.saleDate, unit: .day),
                    y: .value("Sales", $0.quantity)
                ).foregroundStyle(color)
                
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
            Chart(salesViewModel.salesData, id: \.saleDate) {
                
                LineMark(
                    x: .value("Day", $0.saleDate, unit: .day),
                    y: .value("Sales", $0.quantity)
                    
                ).foregroundStyle(color)
                .interpolationMethod(.catmullRom)
                .shadow(color: color, radius: 4, x: 0, y: 5)
                
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
            PDFTestView()
            Spacer()
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
                VCardDetailsView(color: course.color, viewModel: viewModel)
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
    static func generatePDF(salesData: [WeeklySale], fileName: String) -> URL? {
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
            let title = "Weekly Sales Report"
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
    let salesData: [WeeklySale] = [
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        WeeklySale(week: Date(), sales: 100),
        WeeklySale(week: Date().addingTimeInterval(-604800), sales: 200),
        WeeklySale(week: Date().addingTimeInterval(-1209600), sales: 300),
        
    ]
    
    @State private var showPDF = false
    @State private var pdfURL: URL?
    
    var body: some View {
        VStack {
            // Prikaz podataka kao tabela
            List(salesData) { sale in
                HStack {
                    Text(sale.formattedWeek)
                    Spacer()
                    Text("\(sale.sales)")
                }
            }
            
            // Dugme za generisanje PDF-a
            Button(action: {
                if let pdfURL = PDFTableGenerator.generatePDF(salesData: salesData, fileName: "WeeklySalesReport") {
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
    @ObservedObject var viewModel: EarningsViewModel
    
    func totalGrossEarnings() -> Double {
        viewModel.monthlyEarnings.map { $0.grossEarnings }.reduce(0, +)
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
            .onAppear{
                for sale in viewModel.monthlyEarnings{
                    print("1. \(sale.grossEarnings), 2. \(sale.netEarnings)")
                }
            }
            .chartLegend(position: .bottom, spacing: 10) { legendView }
            
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
            .frame(height: 300)
            .padding(.horizontal).padding(.bottom)
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
                .padding(.horizontal, 20)
            Divider()
                .padding(.bottom)
        }
    }
        
        
        
        
        
        
    }
    private var legendView: some View {
        HStack {
            Circle()
                .strokeBorder(lineWidth: 2)
                .fill(.blue)
                .frame(width: 8, height: 8)
            Text("Gross Earnings").foregroundStyle(Color.secondary).font(.footnote)

            Circle()
                .strokeBorder(lineWidth: 2)
                .fill(.purple)
                .frame(width: 8, height: 8)
            Text("Net Earnings").foregroundColor(Color.secondary).font(.footnote)
        }
    }
}

struct MonthlyEarnings: Identifiable {
    let id = UUID()
    let month: Date
    let grossEarnings: Double
    let netEarnings: Double
}

class EarningsViewModel: ObservableObject {
    @Published var monthlyEarnings: [MonthlyEarnings] = []

    init() {
        generateEarningsData()
    }

    func generateEarningsData() {
        let calendar = Calendar.current
        let currentDate = Date()

        for monthOffset in 0..<12 {
            if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: currentDate) {
                let gross = Double.random(in: 8000...15000) // Bruto zarada
                let net = gross * 0.75                     // Neto zarada (75% bruto)
                monthlyEarnings.append(MonthlyEarnings(month: monthDate, grossEarnings: gross, netEarnings: net))
            }
        }

        // Sortiranje po mjesecima
        monthlyEarnings.sort { $0.month < $1.month }
    }
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

#Preview{
    EarningsLabelChartView(viewModel: EarningsViewModel())
        .padding()
        .padding(.horizontal, 10)
}
