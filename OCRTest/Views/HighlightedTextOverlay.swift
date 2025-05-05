//
//  HighlightedTextOverlay.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//

import SwiftUI

struct HighlightedTextOverlay: View {
    let box: CGRect
    
    var body: some View {
        let isVertical = box.height > box.width
        let frameWidth = isVertical ? box.height : box.width
        let frameHeight = isVertical ? box.width : box.height
        let rotationAngle: Angle = isVertical ? .degrees(-90) : .zero
        
        Rectangle()
            .fill(Color.red)
            .frame(width: box.width, height: box.height)
            .position(x: box.midX, y: box.midY)
            .rotationEffect(rotationAngle)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .allowsHitTesting(false) // 터치 차단
    }
}

// MARK: - 미리보기 예시
#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        HighlightedTextOverlay(box: CGRect(x: 100, y: 100, width: 30, height: 120))
    }
    .frame(width: 300, height: 300)
}
