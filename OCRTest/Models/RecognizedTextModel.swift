//
//  RecognizedTextModel.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//

import Foundation

struct RecognizedTextModel: Identifiable, Hashable {
    /// 고유 ID (List에서 구분용)
    let id: UUID
    
    /// 인식된 텍스트 내용
    let text: String
    
    /// 이미지 내 bounding box 좌표 (normalized)
    let boundingBox: CGRect
    
    /// Vision이 인식한 신뢰도 (0.0 ~ 1.0)
    let confidence: Float
    
    init(text: String, boundingBox: CGRect, confidence: Float) {
        self.id = UUID()
        self.text = text
        self.boundingBox = boundingBox
        self.confidence = confidence
    }
}

/// OCR 결과 전체를 담는 래퍼 모델(옵션)
/// - SRP에 따라 UI나 ViewModel에서 텍스트들을 그룹핑해서 사용 가능
/// - 텍스트 그룹핑: 추출된 텍스트 결과를 하나의 의미있는 단위로 묶어줌
struct RecognizedTextGroup: Identifiable {
    let id = UUID()
    let items: [RecognizedTextModel]
    let sourceImageSize: CGSize
    
    init(items: [RecognizedTextModel], sourceImageSize: CGSize) {
        self.items = items
        self.sourceImageSize = sourceImageSize
    }
}
