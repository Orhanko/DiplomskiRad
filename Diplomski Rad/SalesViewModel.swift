//
//  SalesViewModel.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

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
        let totalSales = dailySales.reduce(0) { $0 + $1.sales }
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
}
