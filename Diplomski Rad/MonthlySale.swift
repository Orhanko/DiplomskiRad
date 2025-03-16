//
//  MonthlySale.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

struct MonthlySale: Decodable {
    let month: Date
    let sales: Int
    
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy" // Format za mjesec i godinu, npr. "Feb 2025"
        return formatter.string(from: month)
    }
}
