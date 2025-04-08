//
//  MinMaxView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI

struct MinMaxView: View {
    @State private var showPDF = false
    @State private var pdfURL: URL?
    enum ChartStyle: String, CaseIterable, Identifiable {
        case month = "Month"
        case week = "Week"
        
        var id: Self { self }
    }
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedChartStyle: ChartStyle = .month
    @State private var selectedWeeklyCourse: String = "course1"
    @State private var selectedMonthlyCourse: String = "course1"
    @State private var displayMonthlyString: String = "Course 1"
    @State private var displayWeeklyString: String = "Course 1"
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
        VStack{
            
            Picker("Chart Type", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases) {
                    Text($0.rawValue)
                }
            }
            .padding([.horizontal, .top])
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            ZStack {
                if selectedChartStyle == .month {
                    
                    MonthlyMinMaxSalesChartView(viewModel: viewModel, selectedCourse: $selectedMonthlyCourse, displayValue: $displayMonthlyString)
                        .transition(.opacity)
                } else if selectedChartStyle == .week{
                    
                    WeeklyMinMaxSalesChartView(viewModel: viewModel, selectedCourse: $selectedWeeklyCourse, displayValue: $displayWeeklyString)
                        .transition(.opacity)
                }
                
            }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
            Spacer()
            
        }
    }
        .navigationTitle("Min & Max Sales")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: configurePDF) {
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
    
    private func presentPDFSharing(pdfURL: URL) {
            let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                rootVC.present(activityViewController, animated: true, completion: nil)
            }
        }

    
    func configurePDF(){
        switch selectedChartStyle{
        case .month:
            if let screenshot = PDFTableGenerator.captureSalesPerCourseCategoryView(
                view: MonthlyMinMaxSalesChartView(viewModel: viewModel, selectedCourse: $selectedMonthlyCourse, displayValue: $displayMonthlyString),
                size: CGSize(width: 532, height: 600)
            ) {
                // Definiraj područje slike ispod odrezanog dijela
                let yOffset = 170.0
                let croppedHeight = screenshot.size.height - yOffset
                let newSize = CGSize(width: screenshot.size.width, height: croppedHeight)

                // Kreiranje nove slike bez gornjeg dijela
                UIGraphicsBeginImageContextWithOptions(newSize, false, screenshot.scale)
                screenshot.draw(at: CGPoint(x: 0, y: -yOffset))
                let finalScreenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                // Generiranje PDF-a s preostalom slikom
                if let finalScreenshot = finalScreenshot,
                   let pdfURL = PDFTableGenerator.generateMonthlyMinMaxSalesPDF(
                       salesData: viewModel.monthlyMinMaxSales,
                       fileName: "Monthly Min-Max Sales Report for \(displayMonthlyString)",
                       courseName: displayMonthlyString,
                       screenshot: finalScreenshot
                   ) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                        print("⚠️ Already presenting: \(String(describing: rootVC))")
                        rootVC.dismiss(animated: true) {
                            self.presentPDFSharing(pdfURL: pdfURL)
                        }
                    } else {
                        presentPDFSharing(pdfURL: pdfURL)
                    }
                } else {
                    print("Failed to generate PDF.")
                }
            }
        case .week:
            print("Sigili: \(displayWeeklyString)")
            if let pdfURL = PDFTableGenerator.generateWeeklyMinMaxSalesPDF(salesData: viewModel.weeklyMinMaxSales.reversed(), fileName: "Weekly Min-Max Sales Report for \(displayWeeklyString)", courseName: displayWeeklyString) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                    print("⚠️ Already presenting: \(String(describing: rootVC))")
                    rootVC.dismiss(animated: true) {
                        self.presentPDFSharing(pdfURL: pdfURL)
                    }
                } else {
                    presentPDFSharing(pdfURL: pdfURL)
                }
                        } else {
                            print("Failed to generate PDF.")
                        }
        }
    }
}
