//
//  VisionRequest.swift
//  OCRTest
//
//  Created by 송승윤 on 4/27/25.
//

import Foundation
/// Vision API 요청 모델
struct VisionRequest: Codable {
    struct Image: Codable {
        let content: String
    }
    struct Feature: Codable {
        let type: String = "Text_DETECTION"
    }
    struct Request: Codable {
        let image: Image
        let features: [Feature]
    }
    let requests: [Request]
}
