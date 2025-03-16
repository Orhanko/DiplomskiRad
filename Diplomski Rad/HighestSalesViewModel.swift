//
//  HighestSalesViewModel.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation
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
                "Course 1": Color(#colorLiteral(red: 0.4705882353, green: 0.3137254902, blue: 0.9411764706, alpha: 1)),
                "Course 2": Color(#colorLiteral(red: 0.4039215686, green: 0.5725490196, blue: 1, alpha: 1)),
                "Course 3": Color(#colorLiteral(red: 0.8705882353, green: 0.5594107557, blue: 0.8495429422, alpha: 1)),
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
