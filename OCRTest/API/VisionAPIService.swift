//
//  VisionAPIService.swift
//  OCRTest
//
//  Created by 송승윤 on 4/27/25.
//
// GoogleVisionAPIService.swift
import Foundation
import UIKit

// ✅ TextRecognitionService 프로토콜 채택
final class VisionAPIService: TextRecognitionService {

    private let apiKey = "AIzaSyBVZObRlvKtAhqAnxX8fWE2JiB_rsTM5zQ" 

    // ✅ 프로토콜 요구사항 구현
    func recognizeText(in image: UIImage, completion: @escaping (OCRResult) -> Void) {
        recognizeTextFromGoogleAPI(image: image) { result in
            switch result {
            case .success(let annotations):
                let texts = annotations.dropFirst().map { annotation in
                    RecognizedTextModel(
                        text: annotation.description,
                        boundingBox: annotation.boundingPoly.toCGRect(),
                        confidence: 1.0 // Google API는 신뢰도 없으므로 1.0 기본
                    )
                }
                let ocrResult = OCRResult(texts: texts)
                completion(ocrResult)
            case .failure(let error):
                print("❗️Vision API 오류 발생: \(error)")
                completion(OCRResult(texts: []))
            }
        }
    }

    // 내부 Google API 호출
    private func recognizeTextFromGoogleAPI(image: UIImage, completion: @escaping (Result<[VisionTextAnnotation], Error>) -> Void) {
        guard let base64Image = image.toBase64() else {
            completion(.failure(NSError(domain: "Base64 Encoding Failed", code: -1)))
            return
        }

        let request = VisionRequest(requests: [
            .init(image: .init(content: base64Image), features: [.init()])
        ])

        guard let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -2)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let bodyData = try JSONEncoder().encode(request)
            urlRequest.httpBody = bodyData
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -3)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(VisionResponse.self, from: data)
                let annotations = decoded.responses.first?.textAnnotations ?? []
                completion(.success(annotations))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
