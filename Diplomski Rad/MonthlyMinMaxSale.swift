//
//  MonthlyMinMaxSale.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

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
