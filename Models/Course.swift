//
//  Course.swift
//  DiplomskiRadBezAnimacija
//
//  Created by Orhan Pojskic on 1/9/25.
//

import SwiftUI

struct Course: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var caption: String
    var color: Color
    var image: Image
    var chart: String
}

var courses = [
    Course(title: "Animations in SwiftUI", subtitle: "Build and animate an iOS app from scratch", caption: "20 sections - 3 hours", color: Color(#colorLiteral(red: 0.4705882353, green: 0.3137254902, blue: 0.9411764706, alpha: 1)), image: Image("Topic 1"), chart: "first-course-monthly-sales"),
    Course(title: "Build Quick Apps with SwiftUI", subtitle: "Apply your Swift and SwiftUI knowledge by building real, quick and various applications from scratch", caption: "47 sections - 11 hours", color: Color(#colorLiteral(red: 0.4039215686, green: 0.5725490196, blue: 1, alpha: 1)), image: Image("Topic 2"), chart: "second-course-monthly-sales"),
    Course(title: "Build a SwiftUI app for iOS 15", subtitle: "Design and code a SwiftUI 3 app with custom layouts, animations and gestures using Xcode 13, SF Symbols 3, Concurrency and Searchable", caption: "21 sections - 4 hours", color: Color(#colorLiteral(red: 0.7333333333, green: 0.6509803922, blue: 1, alpha: 1)), image: Image("Topic 1"), chart: "third-course-monthly-sales")
]
