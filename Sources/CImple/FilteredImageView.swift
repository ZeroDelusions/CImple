//
//  FilteredImageView.swift
//  
//
//  Created by Косоруков Дмитро on 01/08/2024.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
struct FilteredImageView<Content: View>: View {
    let content: Content
    let filterClosure: () -> Any?
    
    @State private var filteredImage: Image?
    
    init(@ViewBuilder content: @escaping () -> Content, filterClosure: @escaping () -> Any?) {
        self.content = content()
        self.filterClosure = filterClosure
    }
    
    var body: some View {
        content
            .opacity(0)
            .overlay(
                Group {
                    if let filtered = filteredImage {
                        filtered
                            .resizable()
                    }
                }
            )
        .onAppear(perform: applyFilter)
        .onChange(of: filterClosure() as? [CIFilter]) { _ in
            applyFilter()
        }
        .onChange(of: filterClosure() as? CIImage) { _ in
            applyFilter()
        }
        
    }
    
    private func applyFilter() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let uiImage = self.content.asUIImage() {
                let filtered = CImple().filters(uiImage, self.filterClosure)
                DispatchQueue.main.async {
                    self.filteredImage = Image(uiImage: filtered)
                }
            }
        }
    }
}

