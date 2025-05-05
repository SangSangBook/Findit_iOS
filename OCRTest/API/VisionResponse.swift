//
//  VisionResponse.swift
//  OCRTest
//
//  Created by 송승윤 on 4/27/25.
//

import Foundation

struct VisionResponse: Codable {
    let responses: [Response]

    struct Response: Codable {
        let textAnnotations: [VisionTextAnnotation]?
    }
}

struct VisionTextAnnotation: Codable {
    let description: String
    let boundingPoly: BoundingPoly
}

struct BoundingPoly: Codable {
    let vertices: [Vertex]
}

struct Vertex: Codable {
    let x: Int?
    let y: Int?
}
