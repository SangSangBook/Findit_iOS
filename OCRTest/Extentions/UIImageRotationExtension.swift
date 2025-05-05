//
//  UIImageRotationExtension.swift
//  OCRTest
//
//  Created by 송승윤 on 4/27/25.
//

import UIKit

extension UIImage {
    /// UIImage를 시계 방향으로 90도 회전시키기.
    func rotated90Degrees() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let rotatedSize = CGSize(width: self.size.height, height: self.size.width)
        let renderer = UIGraphicsImageRenderer(size: rotatedSize)

        let rotatedImage = renderer.image { context in
            let ctx = context.cgContext

            ctx.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            ctx.rotate(by: .pi / 2)
            ctx.scaleBy(x: 1.0, y: -1.0)
            let rect = CGRect(
                x: -self.size.width / 2,
                y: -self.size.height / 2,
                width: self.size.width,
                height: self.size.height
            )
            ctx.draw(cgImage, in: rect)
        }

        return rotatedImage
    }
    
    /// 사진을 Base64 문자열로 변환하는 메서드
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
}
