//
//  DailySale.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

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
