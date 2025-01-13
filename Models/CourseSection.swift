//
//  CourseSection.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-04-14.
//

import SwiftUI

struct CourseSection: Identifiable {
    var id = UUID()
    var title: String
    var caption: String
    var color: Color
    var image: Image
}

var courseSections = [
    CourseSection(title: "State Machine", caption: "Watch video - 15 mins", color: Color(#colorLiteral(red: 0.6117647059, green: 0.7725490196, blue: 1, alpha: 1))/*Color(hex: "9CC5FF")*/, image: Image("Topic 2")),
    CourseSection(title: "Animated Menu", caption: "Watch video - 10 mins", color: Color(#colorLiteral(red: 0.431372549, green: 0.4156862745, blue: 0.9098039216, alpha: 1))/*Color(hex: "6E6AE8")*/, image: Image("Topic 1")),
    CourseSection(title: "Tab Bar", caption: "Watch video - 8 mins", color: Color(#colorLiteral(red: 0, green: 0.3725490196, blue: 0.9058823529, alpha: 1))/*Color(hex: "005FE7")*/, image: Image("Topic 2")),
    CourseSection(title: "Button", caption: "Watch video - 9 mins", color: Color(#colorLiteral(red: 0.7333333333, green: 0.6509803922, blue: 1, alpha: 1))/*Color(hex: "BBA6FF")*/, image: Image("Topic 1"))
]
