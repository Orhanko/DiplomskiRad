//
//  SideMenu.swift
//  DiplomskiRadBezAnimacija
//
//  Created by Orhan Pojskic on 12/28/24.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Orhan Pojskic")
                .padding(.top, 100)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.blue)
        .foregroundColor(.white)
        .ignoresSafeArea(edges: .vertical)
    }
}

#Preview {
    SideMenu(isOpen: .constant(true))
}
