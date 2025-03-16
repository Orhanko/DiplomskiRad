//
//  MinMaxLabelView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct MinMaxLabelView: View {
    let upperLineValues = [34, 36, 27, 30, 38, 33]
    let lowerLineValues = [5, 12, 9, 14, 10, 13]
    
    var body: some View {
        VStack {
            Group{
            Text("Check out the monthly and weekly balance of the ") +
            Text("highest ")
                    .foregroundStyle(.green).fontWeight(.bold)
                
            + Text("and ") +
                Text("lowest ").foregroundStyle(.red).fontWeight(.bold)
                
            + Text("values ​​for sale")
        }
                
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                
            
            
            Chart {
                // Gornji LineMark - PLAVA LINIJA
                ForEach(upperLineValues.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Upper Line", upperLineValues[index]),
                        series: .value("Series", "Upper Line")
                    )
                    .foregroundStyle(.green)
                    .symbol(Circle())
                }

                // Donji LineMark - CRVENA LINIJA
                ForEach(lowerLineValues.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Lower Line", lowerLineValues[index]),
                        series: .value("Series", "Lower Line")
                    )
                    .foregroundStyle(.red)
                    .symbol(Circle())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 200)
            .padding(.horizontal, 24)
            .chartXAxis {
                AxisMarks(values: .stride(by: 1)){AxisGridLine()}
            }
            .chartYAxis {
                AxisMarks {AxisGridLine()}
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .padding(.top)
            .padding(.horizontal, 30)
            .padding(.bottom, 32)

            
        }.background(.gray.opacity(0.2))
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                Image(systemName: "chevron.compact.right") // Strelica desno
                    .foregroundColor(.gray) // Siva boja strelice
                    .font(.system(size: 25)) // Veličina fonta
                    .frame(maxHeight: .infinity, alignment: .center) // Cijela visina za centriranje
                    .padding(.trailing, 16), // Pomjeranje od ivice
                alignment: .trailing
            )
        
    }}
