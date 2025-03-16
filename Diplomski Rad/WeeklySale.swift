//
//  WeeklySale.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

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

struct WeeklySalesResponse: Codable {
    let weeklySales: [WeeklySale]
}
