//
//  EarningsChartView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI
import Charts

struct EarningsChartView: View {
    @State private var showPDF = false
    @State private var pdfURL: URL?
    @ObservedObject var viewModel: EarningsViewModel
    
    func totalGrossEarnings() -> Double {
        viewModel.monthlyEarnings.map { $0.grossEarnings }.reduce(0, +)
    }
    func printanje(){
        if let screenshot = PDFTableGenerator.captureSalesPerCourseCategoryView(view: EarningsChart(viewModel: viewModel), size: CGSize(width: 350, height: 250)),
           let pdfURL = PDFTableGenerator.generateMonthlyEarningsSalesPDF(salesData: viewModel.monthlyEarnings.reversed(), fileName: "Monthly Earnings Report", courseName: "Proba", screenshot: screenshot) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                print("⚠️ Already presenting: \(String(describing: rootVC))")
                rootVC.dismiss(animated: true) {
                    self.presentPDFSharing(pdfURL: pdfURL)
                }
            } else {
                presentPDFSharing(pdfURL: pdfURL)
            }
        }

    }
    
    private func presentPDFSharing(pdfURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
            }
        }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
        VStack {
            Group {
                Text("Your total earnings for the last year are: ") +
                Text("$" + String(format: "%.2f", totalGrossEarnings()))
                    .bold()
                    .foregroundStyle(.pink)
                    
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.top)
            
            EarningsChart(viewModel: viewModel)
            .frame(height: 300)
            .padding(.horizontal).padding(.bottom).padding(.top)
            Divider()
                
                .frame(height: 1) // Debljina linije postavljena na 3 piksela
                .background(.gray.opacity(0.3))
                    // Postavi boju linije
                    .padding(.vertical)
                    
                    // Smanjuje širinu sa svake strane za 50 piksela
            Text("Detailed Breakdown of Your Earnings per Month")
                .bold()
                
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            EarningsDetailGridView(viewModel: viewModel)
                .padding(.horizontal, 10)
            Divider()
                .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: printanje) {
                            Image(systemName: "printer.filled.and.paper")
                        }
                    }
                }
        .sheet(isPresented: $showPDF) {
            if let pdfURL = pdfURL {
                PDFPreviewView(url: pdfURL)
            }
        }
        
            
            

    }
        .navigationTitle("Earnings")
        .navigationBarTitleDisplayMode(.inline)
        
        
        
        
        
    }
}

struct EarningsDetailGridView: View {
    
    @ObservedObject var viewModel: EarningsViewModel

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 10) {
            // Header row
            GridRow {
                Color.clear
                    .gridCellUnsizedAxes([.vertical, .horizontal])
                Text("Gross Earnings")
                    .gridCellAnchor(.center)
                    
                Text("Net Earnings")
                    .gridCellAnchor(.center)
                    
                Text("Difference")
                    .bold()
                    .gridCellAnchor(.trailing)
            }

            Divider()
                .gridCellUnsizedAxes([.vertical, .horizontal])

            // Data rows for each month
            ForEach(viewModel.monthlyEarnings) { data in
                GridRow {
                    Text(month(for: data.month))
                       
                        
                    Text(String(format: "%.2f", data.grossEarnings))
                        
                    Text(String(format: "%.2f", data.netEarnings))
                    Text(String(format: "%.2f", data.grossEarnings - data.netEarnings))
                        .bold()
                }
            }

            Divider()
                .gridCellUnsizedAxes([.vertical, .horizontal])

            // Total row
            GridRow {
                Text("Total")
                    .bold()

                Color.clear
                    .gridCellUnsizedAxes([.vertical, .horizontal])
                    .gridCellColumns(2)

                Text("$" + String(format: "%.2f", totalGrossEarnings()))
                    .bold()
                    .foregroundStyle(.pink)
                    .fixedSize()
            }
            
        }
    }

    // Helper function to format month names
    func month(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    // Calculate total gross earnings
    func totalGrossEarnings() -> Double {
        viewModel.monthlyEarnings.map { $0.grossEarnings }.reduce(0, +)
    }
}

struct EarningsChart: View {
    @ObservedObject var viewModel: EarningsViewModel
    var body: some View {
        Chart(viewModel.monthlyEarnings) { data in
            
            LineMark(
                x: .value("Month", data.month),
                y: .value("Gross Earnings", data.grossEarnings)
            )
            .foregroundStyle(.blue)
            .symbol(by: .value("Legend", "Gross Earnings"))
            .interpolationMethod(.catmullRom)
            
            LineMark(
                x: .value("Month", data.month),
                y: .value("Net Earnings", data.netEarnings)
            )
            .foregroundStyle(.purple)
            .symbol(Circle())
            .interpolationMethod(.catmullRom)
            AreaMark(
                x: .value("Month", data.month),
                yStart: .value("Net Earnings", data.netEarnings),
                yEnd: .value("Gross Earnings", data.grossEarnings)
            )
            .foregroundStyle(
                .linearGradient(
                    Gradient(colors: [.purple.opacity(0.3), .blue.opacity(0.5)]), // Boje gradijenta
                    startPoint: .bottom,
                    endPoint: .top
                )
            ) // Boja prostora između linija
            .interpolationMethod(.catmullRom)
        }
        
        .chartLegend(position: .bottom, spacing: 10) {
            HStack {
                Circle()
                    .fill(.blue) // Boja za maksimalne vrijednosti
                    .frame(width: 10, height: 10)
                Text("Gross Earnings").foregroundStyle(Color.secondary).font(.footnote)

                Circle()
                    .fill(.purple) // Boja za minimalne vrijednosti
                    .frame(width: 10, height: 10)
                Text("Net Earnings").foregroundColor(Color.secondary).font(.footnote)
            }
        }
        .chartXAxis {
            AxisMarks(values: viewModel.monthlyEarnings.enumerated().compactMap { index, data in
                index.isMultiple(of: 2) ? data.month : nil
            }) { value in
                AxisGridLine() // Grid linija za odabrane mjesece
                AxisTick() // Tick oznaka ispod mjeseca
                AxisValueLabel(centered: false, anchor: .top) {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month(.abbreviated))
                    }
                }
            }
        }
    }
    
    
}
