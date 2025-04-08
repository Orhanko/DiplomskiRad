//
//  PDFTableGenerator.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import PDFKit
import SwiftUI

class PDFTableGenerator {
    static func generateWeeklySalesPDF(salesData: [WeeklySale], fileName: String, courseName: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Weekly Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [contentWidth / 2, contentWidth / 2]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: WeeklySale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            // Naizmenične boje za redove
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst u redu
            let week = sale.formattedWeek
            let sales = "\(sale.sales)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [week, sales].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            // Linije između kolona
            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }
        
        func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
            // Pozadina zaglavlja
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst zaglavlja
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Week", "Sales"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }
        
        func drawTableBorder(context: UIGraphicsPDFRendererContext, margin: CGFloat, tableTopYPosition: CGFloat, tableBottomYPosition: CGFloat) {
            let borderPath = UIBezierPath(rect: CGRect(x: margin, y: tableTopYPosition, width: contentWidth, height: tableBottomYPosition - tableTopYPosition))
            borderPath.lineWidth = 1
            UIColor.black.setStroke()
            borderPath.stroke()
        }
        
        func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
            // Header sa naslovom
            let title = "Weekly Sales Report for \(courseName)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)
            let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

                let pageText = "Page \(currentPage) of \(totalPages)"
                let pageAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: pageAttributes)
        }
        
        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let totalPages = Int(ceil(Double(salesData.count) / 20)) // Prilagodite broj redova po stranici
            let columnWidths = [CGFloat(contentWidth / 2), CGFloat(contentWidth / 2)]
            var yPosition = margin + 50

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
            drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
            yPosition += 30

            var tableTopYPosition = yPosition
            
            salesData.enumerated().forEach { (index, sale) in
                if yPosition + 30 > pageHeight - margin - 50 {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                    drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += 30
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
    
    
    
    static func generateMonthlySalesPDF(salesData: [MonthlySale], fileName: String, courseName: String, screenshot: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Monthly Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let maxRowsPerPage = Int((pageHeight - (2 * margin) - 200) / rowHeight)
            let totalPages = Int(ceil(Double(salesData.count) / Double(maxRowsPerPage)))
            
            context.beginPage()
            
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Sales Report for \(courseName)")

            if let screenshot = screenshot {
                let imageHeight = 210.0
                let imageWidth = contentWidth/1.2
                let centerX = (pageWidth - imageWidth) / 2
                print("Probicaaaaaa: \(contentWidth/1.2)")
                let imageRect = CGRect(x: centerX, y: margin + 49, width: imageWidth, height: imageHeight)
                screenshot.draw(in: imageRect)
            }
            
            drawTableHeader(context: context, margin: margin, yPosition: margin + 270)
            var yPosition = margin + 300
            
            salesData.enumerated().forEach { (index, sale) in
                if yPosition + rowHeight > pageHeight - margin {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Sales Report for \(courseName)")
                    drawTableHeader(context: context, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += rowHeight
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }

    // Helper functions
    private static func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlySale, margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
        let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
        rowBackgroundColor.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: 532, height: 30)).fill()

        let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]
        sale.formattedMonth.draw(at: CGPoint(x: margin + 10, y: yPosition + 8), withAttributes: textAttributes)
        "\(sale.sales)".draw(at: CGPoint(x: margin + 300, y: yPosition + 8), withAttributes: textAttributes)
    }

    private static func drawTableHeader(context: UIGraphicsPDFRendererContext, margin: CGFloat, yPosition: CGFloat) {
        UIColor.systemBlue.setFill()
        UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: 532, height: 30)).fill()

        let headerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.white]
        "Month".draw(at: CGPoint(x: margin + 10, y: yPosition + 8), withAttributes: headerAttributes)
        "Sales".draw(at: CGPoint(x: margin + 300, y: yPosition + 8), withAttributes: headerAttributes)
    }

    private static func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int, courseName: String, title: String) {
        let title = title
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.black]
        let titleSize = title.size(withAttributes: titleAttributes)
        title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)

        let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
        let footerAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.gray]
        footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

        let pageText = "Page \(currentPage) of \(totalPages)"
        pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: footerAttributes)
    }
    
    static func capturePartialScreenshot<Content: View>(of view: Content, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.overrideUserInterfaceStyle = .light
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    static func generateWeeklyMinMaxSalesPDF(salesData: [WeeklyMinMaxSale], fileName: String, courseName: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Weekly Min-Max Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [CGFloat(contentWidth / 3), CGFloat(contentWidth / 3), CGFloat(contentWidth / 3)]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: WeeklyMinMaxSale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

            let week = sale.formattedWeek
            let maxSales = "\(sale.maxSales)"
            let minSales = "\(sale.minSales)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [week, maxSales, minSales].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + rowHeight))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }

        func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Week", "Max Sales", "Min Sales"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }

        func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
            let title = "Weekly Min-Max Sales Report for \(courseName)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)

            let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

            let pageText = "Page \(currentPage) of \(totalPages)"
            pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: footerAttributes)
        }

        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let totalPages = Int(ceil(Double(salesData.count) / 20))
            var yPosition = margin + 50

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
            drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
            yPosition += rowHeight

            salesData.enumerated().forEach { (index, sale) in
                if yPosition + rowHeight > pageHeight - margin - 50 {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                    drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += rowHeight
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
    
    static func generateMonthlyMinMaxSalesPDF(salesData: [MonthlyMinMaxSale], fileName: String, courseName: String, screenshot: UIImage?) -> URL? {
            let pdfMetaData = [
                kCGPDFContextCreator: "ImeAplikacije",
                kCGPDFContextAuthor: "ImeAplikacije",
                kCGPDFContextTitle: "Weekly Min-Max Sales Report"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]

            let pageWidth = 612.0
            let pageHeight = 792.0
            let margin = 40.0
            let contentWidth = pageWidth - 2 * margin
            let rowHeight = 30.0
            let columnWidths = [CGFloat(contentWidth / 3), CGFloat(contentWidth / 3), CGFloat(contentWidth / 3)]

            let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

            func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlyMinMaxSale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
                let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
                rowBackgroundColor.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

                let week = sale.formattedMonth
                let maxSales = "\(sale.maxSales)"
                let minSales = "\(sale.minSales)"
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]

                [week, maxSales, minSales].enumerated().forEach { (index, value) in
                    value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
                }

                for i in 1..<columnWidths.count {
                    let lineX = margin + columnWidths[0] * CGFloat(i)
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: lineX, y: yPosition))
                    linePath.addLine(to: CGPoint(x: lineX, y: yPosition + rowHeight))
                    linePath.lineWidth = 1
                    UIColor.lightGray.setStroke()
                    linePath.stroke()
                }
            }

            func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
                UIColor.systemBlue.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: rowHeight)).fill()

                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white
                ]
                ["Week", "Max Sales", "Min Sales"].enumerated().forEach { (index, header) in
                    header.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
                }
            }

            func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
                let title = "Monthly Min-Max Sales Report for \(courseName)"
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ]
                let titleSize = title.size(withAttributes: titleAttributes)
                title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)

                let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

                let pageText = "Page \(currentPage) of \(totalPages)"
                pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: footerAttributes)
            }

            let pdfData = pdfRenderer.pdfData { context in
                var currentPage = 1
                let totalPages = 2
                var yPosition = margin + 50

                context.beginPage()
                drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                
                if let screenshot = screenshot {
                    let imageHeight = 450.0
                    let imageWidth = contentWidth
                    let centerX = (pageWidth - imageWidth) / 2
                    let imageRect = CGRect(x: centerX, y: margin + 135, width: imageWidth, height: imageHeight)
                    screenshot.draw(in: imageRect)
                    yPosition = margin + 70  // Postavljanje yPosition ispod slike
                }

                // Novi početak stranice za tabelu
                context.beginPage()
                currentPage += 1
                drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)

                drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
                yPosition += rowHeight

                salesData.enumerated().forEach { (index, sale) in
                    if yPosition + rowHeight > pageHeight - margin - 50 {
                        context.beginPage()
                        currentPage += 1
                        drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                        drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                        yPosition = margin + 80
                    }

                    drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                    yPosition += rowHeight
                }
            }

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
            do {
                try pdfData.write(to: url)
                return url
            } catch {
                print("Error writing PDF: \(error)")
                return nil
            }
        }


    
    static func captureSalesPerCourseCategoryView<Content: View>(view: Content, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.overrideUserInterfaceStyle = .light
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    static func generateSalesPerCourseCategoryViewPDF(fileName: String, chartImage: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Sales per Category Report with Chart"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let totalPages = 1

            context.beginPage()

            // Header i footer
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: "courseName", title: "Sales per Course Report")

            // Prikaz grafikona na sredini stranice
            if let chartImage = chartImage {
                let imageHeight = 400.0
                let imageWidth = contentWidth
                print("Proba u sales per course za sirinu: \(imageWidth)")
                print("Proba u sales per course za visinu: \(imageHeight)")
                
                let centerX = (pageWidth - imageWidth) / 2
                
                let imageRect = CGRect(x: centerX, y: margin + 130, width: imageWidth, height: imageHeight)
                chartImage.draw(in: imageRect)
            }

        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }

    static func generateMonthlyEarningsSalesPDF(salesData: [MonthlyEarnings], fileName: String, courseName: String, screenshot: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Monthly Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [CGFloat(contentWidth / 4), CGFloat(contentWidth / 4), CGFloat(contentWidth / 4), CGFloat(contentWidth / 4)]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let pdfData = pdfRenderer.pdfData { context in
            func drawTableHeader(context: UIGraphicsPDFRendererContext, margin: CGFloat, yPosition: CGFloat) {
                UIColor.systemBlue.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: contentWidth, height: 30)).fill()

                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white
                ]
                ["Month", "Gross Earnings", "Net Earnings", "Difference"].enumerated().forEach { (index, header) in
                    header.draw(at: CGPoint(x: margin + CGFloat(index) * columnWidths[index] + 10, y: yPosition + 8), withAttributes: headerAttributes)
                }
            }

            func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlyEarnings, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
                let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
                rowBackgroundColor.setFill()
                UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                let month = formatter.string(from: sale.month)
                let grossEarnings = String(format: "%.2f", sale.grossEarnings)
                let netEarnings = String(format: "%.2f", sale.netEarnings)
                let difference = String(format: "%.2f", sale.grossEarnings - sale.netEarnings)

                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]

                [month, grossEarnings, netEarnings, difference].enumerated().forEach { (index, value) in
                    value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
                }

                for i in 1..<columnWidths.count {
                    let lineX = margin + columnWidths[0] * CGFloat(i)
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: lineX, y: yPosition))
                    linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                    linePath.lineWidth = 1
                    UIColor.lightGray.setStroke()
                    linePath.stroke()
                }
            }

            var currentPage = 1
            let maxRowsPerPage = Int((pageHeight - (2 * margin) - 200) / rowHeight)
            let totalPages = Int(ceil(Double(salesData.count) / Double(maxRowsPerPage)))

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Earnings Report")

            if let screenshot = screenshot {
                let imageHeight = 250.0
                let imageWidth = 350.0
                print("SigiliMigili: \(imageWidth)")
                let centerX = (pageWidth - imageWidth) / 2
                let imageRect = CGRect(x: centerX, y: margin, width: imageWidth, height: imageHeight)
                screenshot.draw(in: imageRect)
            }

            drawTableHeader(context: context, margin: margin, yPosition: margin + 270)
            var yPosition = margin + 300

            salesData.enumerated().forEach { (index, sale) in
                if yPosition + rowHeight > pageHeight - margin {
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages, courseName: courseName, title: "Monthly Earnings Report")
                    drawTableHeader(context: context, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += rowHeight
            }
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }

        func drawTableHeader(context: UIGraphicsPDFRendererContext, margin: CGFloat, yPosition: CGFloat) {
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: 532, height: 30)).fill()

            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Month", "Gross Earnings", "Net Earnings", "Difference"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + CGFloat(index) * (532 / 4) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: MonthlyEarnings, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let month = formatter.string(from: sale.month)
            let grossEarnings = String(format: "%.2f", sale.grossEarnings)
            let netEarnings = String(format: "%.2f", sale.netEarnings)
            let difference = String(format: "%.2f", sale.grossEarnings - sale.netEarnings)

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [month, grossEarnings, netEarnings, difference].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[index] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }

    
    static func generateDailySalesPDF(salesData: [DailySale], fileName: String, courseName: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ImeAplikacije",
            kCGPDFContextAuthor: "ImeAplikacije",
            kCGPDFContextTitle: "Daily Sales Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin = 40.0
        let contentWidth = pageWidth - 2 * margin
        let rowHeight = 30.0
        let columnWidths = [contentWidth / 2, contentWidth / 2]

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        func drawTableRow(context: UIGraphicsPDFRendererContext, sale: DailySale, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat, isOddRow: Bool) {
            // Naizmenične boje za redove
            let rowBackgroundColor = isOddRow ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.lightGray.withAlphaComponent(0.1)
            rowBackgroundColor.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst u redu
            let week = sale.formattedDay
            let sales = "\(sale.sales)"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]

            [week, sales].enumerated().forEach { (index, value) in
                value.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: textAttributes)
            }

            // Linije između kolona
            for i in 1..<columnWidths.count {
                let lineX = margin + columnWidths[0] * CGFloat(i)
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: lineX, y: yPosition))
                linePath.addLine(to: CGPoint(x: lineX, y: yPosition + 30))
                linePath.lineWidth = 1
                UIColor.lightGray.setStroke()
                linePath.stroke()
            }
        }
        
        func drawTableHeader(context: UIGraphicsPDFRendererContext, columnWidths: [CGFloat], margin: CGFloat, yPosition: CGFloat) {
            // Pozadina zaglavlja
            UIColor.systemBlue.setFill()
            UIBezierPath(rect: CGRect(x: margin, y: yPosition, width: columnWidths.reduce(0, +), height: 30)).fill()

            // Tekst zaglavlja
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.white
            ]
            ["Day", "Sales"].enumerated().forEach { (index, header) in
                header.draw(at: CGPoint(x: margin + columnWidths[0] * CGFloat(index) + 10, y: yPosition + 8), withAttributes: headerAttributes)
            }
        }
        
        func drawTableBorder(context: UIGraphicsPDFRendererContext, margin: CGFloat, tableTopYPosition: CGFloat, tableBottomYPosition: CGFloat) {
            let borderPath = UIBezierPath(rect: CGRect(x: margin, y: tableTopYPosition, width: contentWidth, height: tableBottomYPosition - tableTopYPosition))
            borderPath.lineWidth = 1
            UIColor.black.setStroke()
            borderPath.stroke()
        }
        
        func drawHeaderFooter(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, currentPage: Int, totalPages: Int) {
            // Header sa naslovom
            let title = "Daily Sales Report for \(courseName)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: margin), withAttributes: titleAttributes)
            let footerText = "Author: ImeAplikacije | Created on: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin - 20), withAttributes: footerAttributes)

                let pageText = "Page \(currentPage) of \(totalPages)"
                let pageAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                pageText.draw(at: CGPoint(x: pageWidth - margin - 100, y: pageHeight - margin - 20), withAttributes: pageAttributes)
        }
        
        let pdfData = pdfRenderer.pdfData { context in
            var currentPage = 1
            let availableHeight = pageHeight - (2 * margin) - 50
            let maxRowsPerPage = Int(availableHeight / rowHeight)
            let totalPages = 20
            let columnWidths = [CGFloat(contentWidth / 2), CGFloat(contentWidth / 2)]
            var yPosition = margin + 50

            context.beginPage()
            drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
            drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: yPosition)
            yPosition += 30

            var tableTopYPosition = yPosition
            var rowCount = 0
            salesData.enumerated().forEach { (index, sale) in
                if yPosition + 30 > pageHeight - margin - 50 {
                    print("Page \(currentPage) had \(rowCount) rows before starting new page.")
                    context.beginPage()
                    currentPage += 1
                    drawHeaderFooter(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, currentPage: currentPage, totalPages: totalPages)
                    drawTableHeader(context: context, columnWidths: columnWidths, margin: margin, yPosition: margin + 50)
                    yPosition = margin + 80
                    rowCount = 0
                }

                drawTableRow(context: context, sale: sale, columnWidths: columnWidths, margin: margin, yPosition: yPosition, isOddRow: index % 2 == 0)
                yPosition += 30
                rowCount += 1
            }
            print("Page \(currentPage) had \(rowCount) rows at the end.")
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error writing PDF: \(error)")
            return nil
        }
    }
    
    

}
