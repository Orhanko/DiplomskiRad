//
//  PDFPreviewView.swift
//  Diplomski Rad
//
//  Created by Orhan Pojskic on 3/16/25.
//

import PDFKit
import SwiftUI

struct PDFPreviewView: View {
    let url: URL
    
    var body: some View {
        VStack {
            if let document = PDFDocument(url: url) {
                PDFKitView(document: document)
            } else {
                Text("Failed to load PDF")
                    .foregroundColor(.red)
            }
        }
    }
}
