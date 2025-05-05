//
//  BoundingPoly.swift
//  OCRTest
//
//  Created by 송승윤 on 4/27/25.
//

import Foundation

extension BoundingPoly {
    func toCGRect() -> CGRect {
        guard vertices.count == 4 else { return .zero }

        let xCoords = vertices.compactMap { $0.x }
        let yCoords = vertices.compactMap { $0.y }

        guard
            let minX = xCoords.min(),
            let minY = yCoords.min(),
            let maxX = xCoords.max(),
            let maxY = yCoords.max()
        else {
            return .zero
        }

        let rect = CGRect(x: CGFloat(minX), y: CGFloat(minY),
                          width: CGFloat(maxX - minX),
                          height: CGFloat(maxY - minY))
        
        return rect
    }
}
