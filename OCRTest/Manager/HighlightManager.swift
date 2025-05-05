//
//  HighlightManager.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//

// 인식된 텍스트 중 강조(형광펜) 대상 선정 및 위치 계산 유틸리티
// SRP, OCP 원칙 적용: 강조 필터 로직 분리 및 확장 가능 설계
import Foundation
import CoreGraphics

/// 하이라이트 대상 필터링 및 위치 계산 로직 담당
/// - S: 텍스트 필터링과 강조 위치 계산만 담당 (단일 책임 원칙)
/// - O: 조건 로직 변경 시 이 클래스만 수정하면 됨 (개방-폐쇄 원칙)
final class HighlightManager {
    
    /// 하이라이트할 텍스트 필터링
    /// 예: 길이가 2글자 이상인 책 제목 추정 텍스트만 반환
    static func filteredHighlights(from texts: [RecognizedTextModel]) -> [RecognizedTextModel] {
        return texts.filter { text in
            return text.text.count >= 2 && !isLikelyIrreLevant(text.text)
        }
    }
    
    /// 사용자 입력 키워드에 해당하는 텍스트만 필터링
    static func matchedHighlights(from texts: [RecognizedTextModel], keyword: String) -> [RecognizedTextModel] {
        guard !keyword.isEmpty else { return [] }
        return texts.filter { candidate in
            let similarity = calculateSimilarity(between: candidate.text, and: keyword)
            return similarity >= 0.7 // 70% 이상 비슷하면 매칭
        }
    }
    
    // 간단한 유사도(Levenshtein Distance 기반) 계산 함수
    private static func calculateSimilarity(between a: String, and b: String) -> Double {
        let lowerA = a.lowercased()
        let lowerB = b.lowercased()
        
        let distance = levenshtein(lowerA, lowerB)
        let maxLength = max(lowerA.count, lowerB.count)
        
        guard maxLength > 0 else { return 1.0 }
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    /// Levenshtein 거리 계산
    private static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let (m, n) = (aChars.count, bChars.count)
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1 )
        
        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                if aChars[i - 1] == bChars[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]) + 1
                }
            }
        }
        
        return dp[m][n]
    }
    
    /// 무의미하거나 강조가 불필요한 텍스트를 제거하는 간단한 규칙
    private static func isLikelyIrreLevant(_ text: String) -> Bool {
        let blacklist = ["ISBN", "http", "www", "가격","옮김",","]
        return blacklist.contains { keyword in
            text.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    /// OCR 결과를 화면에 정확하게 맵핑
    static func convert(_ box: CGRect, in originalImageSize: CGSize, to displaySize: CGSize) -> CGRect {
        let widthRatio = displaySize.width / originalImageSize.width
        let heightRatio = displaySize.height / originalImageSize.height
        
        let scale = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: originalImageSize.width * scale,
                                     height: originalImageSize.height * scale)
        
        let offsetX = (displaySize.width - scaledImageSize.width) / 2
        let offsetY = (displaySize.height - scaledImageSize.height) / 2
        
        // ✅ y값을 반전시킵니다
        let flippedOriginY = originalImageSize.height - box.origin.y - box.height
        
        let scaledBox = CGRect(
            x: box.origin.x * scale + offsetX,
            y: flippedOriginY * scale + offsetY,
            width: box.width * scale,
            height: box.height * scale
        )
        
        return scaledBox
    }
}
