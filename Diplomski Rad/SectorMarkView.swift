//
//  SectorMarkView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct SectorMarkView: View {
    @ObservedObject var salesViewModel: HighestSalesViewModel

    var body: some View {
        HStack {
            if let bestSellingCategory = salesViewModel.bestSellingCategory {
                let percentage = (bestSellingCategory.sales / salesViewModel.totalSales) * 100

                VStack(alignment: .leading, spacing: 1) {
                    

                    
                    Text("\(bestSellingCategory.category)")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .font(.headline)
                    + Text(" is the best")
                    Text("selling course with")
                    Text("\(String(format: "%.2f", percentage))%")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                        .font(.headline)
                    + Text(" of total sales.")
                    
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width < 400 ? 160 : nil) // Ograniči širinu SAMO ako je ekran manji
                .padding(.leading, 24)
                .padding(.trailing, 16)
                               
                
                // Padding na cijelu grupu teksta
            } else {
                Text("Nema podataka o prodaji.")
                    .padding() // Dodavanje padding-a i za "fallback" poruku
            }
                


                Chart(salesViewModel.totalSalesPerCategory, id: \.category) { data in
                    SectorMark(
                        angle: .value("Prodaja", data.sales),
                        innerRadius: .ratio(0.5), // Donut izgled
                        angularInset: 1.5 // Razmak između sektora
                    )
                    .foregroundStyle(.blue) // Različite boje po kategorijama
                    .cornerRadius(5.0)
                    .opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.2) // Najprodavaniji kurs ima punu vidljivost
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 85) // Veličina pie chart-a
                
                
                .chartLegend(.hidden)
            
            Spacer()
        }
        
        .frame(maxWidth: .infinity, minHeight: 150)
        
        .background(/*Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))*/.gray.opacity(0.2))
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            Image(systemName: "chevron.compact.right") // Strelica desno
                .foregroundColor(.gray) // Siva boja strelice
                .font(.system(size: 25)) // Veličina fonta
                .frame(maxHeight: .infinity, alignment: .center) // Cijela visina za centriranje
                .padding(.trailing, 16), // Pomjeranje od ivice
            alignment: .trailing
        )
    }
        
}
