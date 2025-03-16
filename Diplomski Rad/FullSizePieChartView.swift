//
//  FullSizePieChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct FullSizePieChartView: View {
    @ObservedObject var salesViewModel: HighestSalesViewModel
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            //                .font(.headline)
            //                .padding(.bottom, 10)
            
            Chart(salesViewModel.totalSalesPerCategory, id: \.category) { data in
                SectorMark(
                    angle: .value("Prodaja", data.sales),
                    innerRadius: .ratio(0.6), // Širi prikaz grafikona
                    angularInset: 8 // Razmak između sektora
                )
                .cornerRadius(5)
                .foregroundStyle(data.color ?? .gray)
                .opacity(data.category == salesViewModel.bestSellingCategory?.category ? 1 : 0.3)
            }
            
            .chartLegend(.hidden)
            
            
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let plotFrame = chartProxy.plotFrame {
                        let frame = geometry[plotFrame]

                        if let bestSellingCategory = salesViewModel.bestSellingCategory {
                            VStack(spacing: 5) {
                                Text("Most Sold Course")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text(bestSellingCategory.category)
                                    .font(.title.bold())
                                    .foregroundColor(bestSellingCategory.color)
                                Text("\(Int(bestSellingCategory.sales)) sold")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .multilineTextAlignment(.center)
                            .frame(width: frame.width * 0.6)
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            //.frame(width: 360, height: 360) // Veći prikaz
            //.padding()
            customLegend
        }
        
        
    }
    private var customLegend: some View {
        HStack {
            ForEach(Array(salesViewModel.totalSalesPerCategory.sorted(by: { $0.sales > $1.sales }).enumerated()), id: \.element.category) { index, item in
                Label {
                    Text(item.category)
                        .padding(.top)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .padding(.trailing, 3)
                } icon: {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(item.color!)
                        .opacity(index == 0 ? 1 : 0.3)
                }
                
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            
        
    }
     }
