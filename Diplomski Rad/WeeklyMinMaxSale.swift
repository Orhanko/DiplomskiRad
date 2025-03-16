//
//  WeeklyMinMaxSale.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

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
