//
//  SwiftUIView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/18/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        Text("👋")
            .font(.system(size: 50))
            .padding(.bottom, 10)
        Text("Hello, World!")
            .font(.largeTitle.bold())
    }
}

#Preview {
    SwiftUIView()
}
