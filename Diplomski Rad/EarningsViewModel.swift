//
//  EarningsViewModel.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

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
        for entry in monthlyEarnings {
            print(entry.month)
        }
    }

    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
