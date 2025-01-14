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
                            VCard(course: course)
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
    @StateObject private var viewModel = SalesViewModel()
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: true){
                VStack {
                    DailySalesChartView(salesData: viewModel.salesData)
                        .padding()
                    MonthlySalesChartView(salesViewModel: viewModel)
                    NavigationLink{
                        SalesPerBookCategoryView(viewModel: highestSalesViewModel)
                    } label: {
                        SectorMarkView(salesViewModel: highestSalesViewModel)
                    }
//                SectorMarkView()
                        .padding()
                    
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
                    Text("Average: \(Int(salesViewModel.averageSales))")
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
            Text("Course blabla overview")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(.white).opacity(0.7)
                .padding(.top, 10)
                .padding(.trailing, 5)
            

        }
            }
}

struct MonthlySalesChartView: View {
    
    @ObservedObject var salesViewModel: SalesViewModel
    
    var body: some View {
        VStack {
            Text("Mjesečna prodaja artikala")
                .font(.title2)
                .padding(.bottom)

            Chart(salesViewModel.salesByMonth) {
                AreaMark(
                    x: .value("Mjesec", $0.month, unit: .month),
                    y: .value("Prodaja", $0.sales)
                ).interpolationMethod(.catmullRom) // Zaobljeni prelazi linije
                .foregroundStyle(
                    .linearGradient(
                        Gradient(colors: [.blue.opacity(0.4), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value("Mjesec", $0.month, unit: .month),
                    y: .value("Prodaja", $0.sales)
                )
                .interpolationMethod(.catmullRom) // Zaobljeni prelazi linije
                .foregroundStyle(.blue)
                .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 30)
                RuleMark(
                    y: .value("Average Sales", salesViewModel.averageSales)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6])) // Stil linije (debljina i isprekidanost)
                .foregroundStyle(Color(#colorLiteral(red: 0.922002852, green: 0.9209583402, blue: 0.9954648614, alpha: 1))) // Boja linije
                .annotation(position: .top) { // Tekstualna oznaka iznad linije
                    Text("Average: \(Int(salesViewModel.averageSales))")
                        .font(.callout)
                        .foregroundColor(Color(#colorLiteral(red: 0.922002852, green: 0.9209583402, blue: 0.9954648614, alpha: 1)))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
                         // Prikaz skraćenog naziva mjeseca (Jan, Feb...)
                }
            }
            .frame(height: 300)
            .padding()
        }
        
    }
}

class SalesViewModel: ObservableObject {
    @Published var salesData: [Sale] = [] // Lista prodaja
    @Published var salesByMonth: [MonthlySale] = [] // Lista prodaja

    init() {
        generateDummyData()
        generateRandomMonthlySalesData()
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
    func generateRandomMonthlySalesData() {
            let calendar = Calendar.current
            var currentDate = Date()
            salesByMonth = (0..<12).map { _ in
                let components = calendar.dateComponents([.year, .month], from: currentDate)
                let monthStart = calendar.date(from: components) ?? Date()
                let salesCount = Int.random(in: 100...500) // Nasumični broj prodaja
                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? Date()
                return MonthlySale(month: monthStart, sales: salesCount)
            }.reversed() // Redoslijed od najstarijeg do najnovijeg
        }
    var averageSales: Double {
        let totalSales = salesByMonth.reduce(0) { $0 + $1.sales } // Zbir svih prodaja
        return Double(totalSales) / Double(salesByMonth.count) // Prosjek
        }
}

struct MonthlySale: Identifiable {
    let id = UUID()
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
                BarMark(
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
            .frame(height: 200)
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
    @ObservedObject private var viewModel = SalesViewModel()
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
                        MonthlySalesChartView(salesViewModel: viewModel)
                            .navigationTitle(course.title)// Modalni prikaz sa istim podacima
                            .navigationBarTitleDisplayMode(.inline)
                    }.presentationDragIndicator(.visible)
                        
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
    
    VCard(course: Course(title: "Animations in SwiftUI", subtitle: "Build and animate an iOS app from scratch", caption: "20 sections - 3 hours", color: Color(#colorLiteral(red: 0.4705882353, green: 0.3137254902, blue: 0.9411764706, alpha: 1)), image: Image("Topic 1")))
}
