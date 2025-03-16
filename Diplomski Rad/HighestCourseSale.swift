//
//  HighestCourseSale.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import Foundation
import SwiftUI

struct HighestCourseSale: Identifiable, Codable {
    let id = UUID()
    let category: String
    let sales: Double
    var color: Color? = nil

    enum CodingKeys: String, CodingKey {
        case category
        case sales
    }
}
