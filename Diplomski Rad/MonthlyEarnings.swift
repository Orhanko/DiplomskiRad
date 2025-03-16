//
//  MonthlyEarnings.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation

struct MonthlyEarnings: Identifiable, Codable {
    let id = UUID()
    let month: Date
    let grossEarnings: Double
    let netEarnings: Double
}

struct MonthlyEarningsResponse: Codable {
    let monthlyEarnings: [MonthlyEarnings]
}
