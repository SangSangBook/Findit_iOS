//
//  TextRecognitionViewModel.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//

// TextRecognitionViewModel.swift
// OCR 결과 상태를 관리하고 UI와 연결하는 뷰모델 계층

import Foundation
import UIKit
import Combine

/// - S: 텍스트 인식 결과 상태 관리 책임만 담당 (단일 책임 원칙)
/// - D: TextRecognitionService 프로토콜에 의존 (구현체 분리)
/// - O: 서비스 구현 변경 없이 확장 가능 (예: ML 기반 텍스트 인식으로 교체)
final class TextRecognitionViewModel: ObservableObject {
    
    // MARK: - Published 상태
    @Published var recognizedGroup: RecognizedTextGroup?
    @Published var isProcessiong: Bool = false
    @Published var searchKeyword: String = ""
    
    // MARK: - 내부 서비스
    private let recognitionService: TextRecognitionService
    
    // MARK: - Init
    init(service: TextRecognitionService) {
        self.recognitionService = service
    }
    
    // MARK: - 이미지 처리 함수
    /// ✅ completion 클로저 추가한 recognize 함수
    func recognize(from image: UIImage, completion: @escaping () -> Void) {
        isProcessiong = true
        
        recognitionService.recognizeText(in: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.recognizedGroup = RecognizedTextGroup(
                    items: result.texts,
                    sourceImageSize: image.size
                )
                self.isProcessiong = false
                completion()  // ✅ OCR 끝난 후 호출
            }
        }
    }
    
    // MARK: - 하이라이팅 대상 필터
    /// 사용자 입력 키워드를 포함하는 텍스트만 반환
    var highlightedResults: [RecognizedTextModel] {
        guard let group = recognizedGroup, !searchKeyword.isEmpty else { return [] }
        return HighlightManager.matchedHighlights(from: group.items, keyword: searchKeyword)
    }
    
    // MARK: - 테스트 및 디버깅용 임시 함수
    /// 강제로 뷰모델 초기 상태를 리셋합니다
    func reset() {
        recognizedGroup = nil
        isProcessiong = false
        searchKeyword = ""
    }
}
