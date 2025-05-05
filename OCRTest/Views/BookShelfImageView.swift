//
//  BookShelfImageView.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//

// BookShelfImageView.swift
// 서가 사진 위에 빨간 동그라미로 텍스트 인식 위치 표시

import SwiftUI

struct BookShelfImageView: View {
    let image: UIImage
    let viewModel: TextRecognitionViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                if let sourceSize = viewModel.recognizedGroup?.sourceImageSize {
                    ForEach(viewModel.highlightedResults, id: \.id) { result in
                        let centerPoint = CGPoint(x: result.boundingBox.midX, y: result.boundingBox.midY)
                        let convertedPoint = HighlightManager.convertPoint(centerPoint, in: sourceSize, to: geometry.size)

                        Circle()
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: 20, height: 20)
                            .position(convertedPoint)
                    }
                }
            }
        }
    }
}

// HighlightManager.swift 내부에 이 함수 추가
extension HighlightManager {
    static func convertPoint(_ point: CGPoint, in originalImageSize: CGSize, to displaySize: CGSize) -> CGPoint {
        let widthRatio = displaySize.width / originalImageSize.width
        let heightRatio = displaySize.height / originalImageSize.height
        let scale = min(widthRatio, heightRatio)

        let scaledImageSize = CGSize(width: originalImageSize.width * scale, height: originalImageSize.height * scale)
        let offsetX = (displaySize.width - scaledImageSize.width) / 2
        let offsetY = (displaySize.height - scaledImageSize.height) / 2

        let convertedX = point.x * scale + offsetX
        let convertedY = point.y * scale + offsetY

        return CGPoint(x: convertedX, y: convertedY)
    }
}
