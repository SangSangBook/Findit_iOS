//
//  ImageProcessingService.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//
/// OCR 기능만을 담당하는 서비스 레이어
/// SOLID 원칙 중 DIP(의존 역전 원칙), ISP(인터페이스 분리 원칙) 적용
import Foundation
import UIKit
import Vision

// MARK: - 프로토콜 정의

/// 텍스트 인식 서비스 인터페이스
/// - D: 상위 ViewModel이 구체 구현이 아닌 이 인터페이스에 의존
protocol TextRecognitionService {
    /// 이미지에서 RecognizedText 목록을 추출
    func recognizeText(in image: UIImage, completion: @escaping (OCRResult) -> Void)
}

struct OCRResult {
    let texts: [RecognizedTextModel]
}

// MARK: - Vision 기반 구현체

/// Vision 프레임워크를 사용한 텍스트 인식기
/// - S: 텍스트 인식만을 담당 (단일 책임)
final class ImageProcessingService: TextRecognitionService {
    func recognizeText(in image: UIImage, completion: @escaping (OCRResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(OCRResult(texts: []))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(OCRResult(texts: []))
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            let results: [RecognizedTextModel] = observations.compactMap { observation in
                guard let candidate = observation.topCandidates(1).first else { return nil }
                print("🔎 인식된 텍스트: \(candidate.string), 신뢰도: \(candidate.confidence)")
                return RecognizedTextModel(
                    text: candidate.string,
                    boundingBox: observation.boundingBox,
                    confidence: candidate.confidence
                )
            }

            let fullText = results.map { $0.text }.joined(separator: "\n")

            completion(OCRResult(texts: results))
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR","en-US"]
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? requestHandler.perform([request])
        }
    }
}
