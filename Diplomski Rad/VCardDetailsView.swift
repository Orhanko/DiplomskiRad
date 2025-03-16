//
//  VCardDetailsView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 2/23/25.
//

import SwiftUI


struct VCardDetailsView: View{
    var courseName: String
    @State private var showPDF = false
    @State private var pdfURL: URL?
    enum ChartStyle: String, CaseIterable, Identifiable {
        case month = "Monthly Insight"
        case week = "Weekly Insight"
        case day = "Daily Insight"
        var id: Self { self }
    }
    
    let color: Color
    
    @ObservedObject var viewModel: SalesViewModel
    @State private var selectedChartStyle: ChartStyle = .month
    
    private func handleToolbarButtonPress() {
            switch selectedChartStyle {
            case .month:
                print("Monthly action triggered")
                if let screenshot = PDFTableGenerator.capturePartialScreenshot(of: MonthlySalesChartView(salesViewModel: viewModel, color: .blue), size: CGSize(width: 612, height: 280)),
                   let pdfURL = PDFTableGenerator.generateMonthlySalesPDF(salesData: viewModel.salesByMonth.reversed(), fileName: "Monthly Sales Report for \(courseName)", courseName: courseName, screenshot: screenshot) {
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
            case .week:
                print("Weekly action triggered")
                if let pdfURL = PDFTableGenerator.generateWeeklySalesPDF(salesData: viewModel.salesByWeek.reversed(), fileName: "Weekly Sales Report for \(courseName)", courseName: courseName) {
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
            case .day:
                print("Daily action triggered")
                if let pdfURL = PDFTableGenerator.generateDailySalesPDF(salesData: viewModel.dailySales.reversed(), fileName: "Daily Sales Report for \(courseName)", courseName: courseName) {
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
    
    var body: some View{
        VStack{
            Text("Presented Data is valid for the past year.")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Picker("Chart Type", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            ZStack {
                if selectedChartStyle == .month {
                    MonthlySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                } else if selectedChartStyle == .week{
                    WeeklySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                } else{
                    DailySalesChartView(salesViewModel: viewModel, color: color)
                        .transition(.opacity)
                }
                        
                }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
            Spacer()
                
        }.padding()
            .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: handleToolbarButtonPress) {
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
    }
