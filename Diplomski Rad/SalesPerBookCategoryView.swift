//
//  SalesPerBookCategoryView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import SwiftUI



struct SalesPerBookCategoryView: View {
    @State private var showPDF = false
    @State private var pdfURL: URL?

    enum ChartStyle: String, CaseIterable, Identifiable {
        case pie = "Pie Chart"
        case bar = "Bar Chart"
      
        var id: Self { self }
    }
    
    @ObservedObject var viewModel: HighestSalesViewModel
    @State private var selectedChartStyle: ChartStyle = .pie // Zadano: Pie chart
    
    var body: some View {
        VStack {
            // Picker sa dva izbora
            Picker("Chart Type", selection: $selectedChartStyle) {
                ForEach(ChartStyle.allCases) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            if let bestSellingCategory = viewModel.bestSellingCategory {
                let percentage = (bestSellingCategory.sales / viewModel.totalSales) * 100

                Group { // Grupisanje teksta radi dodavanja padding-a na cijelu rečenicu
                    Text("The best-selling course is ") +
                    Text("\(bestSellingCategory.category)")
                        .foregroundColor(bestSellingCategory.color) // Boja naziva kursa
                        .fontWeight(.heavy) +
                    Text(" with \(String(format: "%.2f", percentage))% of total sales.")
                        .foregroundColor(.primary) // Ostatak teksta u default boji
                }
                
                
                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(nil)
                 // Padding na cijelu grupu teksta
            } else {
                Text("Nema podataka o prodaji.")
                    .padding() // Dodavanje padding-a i za "fallback" poruku
            }
            
//            TEKST
            
            // Prikaz prema odabranom tipu grafikona
            ZStack {
                if selectedChartStyle == .bar {
                    
                    CustomSalesPerBookCategoryBarChartView(salesViewModel: viewModel) // Bar Chart prikaz
                        .transition(.opacity)
                } else if selectedChartStyle == .pie{
                    
                    FullSizePieChartView(salesViewModel: viewModel) // Pie Chart prikaz
                        .padding(.vertical)
                        .transition(.opacity)
                }
                
            }.animation(.easeInOut(duration: 0.25), value: selectedChartStyle)
//            switch selectedChartStyle {
//                case .bar:
//                CustomSalesPerBookCategoryBarChartView(salesViewModel: viewModel) // Bar Chart prikaz
//                case .pie:
//                    FullSizePieChartView(salesViewModel: viewModel) // Pie Chart prikaz
//                    .padding(.vertical)
//                    
//            }
            Spacer()
            
                        
            
            
            
        }
        .padding()
        .navigationTitle("Course Overview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: generatePDF) {
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
    
    func generatePDF(){
        if let screenshot = PDFTableGenerator.captureSalesPerCourseCategoryView(view: CustomSalesPerBookCategoryBarChartView(salesViewModel: viewModel), size: CGSize(width: 532, height: 400)),
           let pdfURL = PDFTableGenerator.generateSalesPerCourseCategoryViewPDF(fileName: "Sales per Course", chartImage: screenshot) {
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
}
