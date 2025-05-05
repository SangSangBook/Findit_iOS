//
//  ImagePicker.swift
//  OCRTest
//
//  Created by 송승윤 on 4/24/25.
//
//  이 파일은 SwiftUI에서 최신 방식(PHPickerViewController)으로
//  이미지를 선택할 수 있도록 래핑한 뷰입니다.
//  UIKit 기반 PHPicker를 SwiftUI에서 사용할 수 있도록 연결하고,
//  선택한 이미지는 바인딩을 통해 외부에서 접근 가능합니다.

import SwiftUI
import PhotosUI

/// SwiftUI에서 사용할 수 있는 이미지 선택기 (photo library 전용)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage? // 선택된 이미지를 바인딩으로 전달
    
    // Coordinator는 UIKit 델리게이트를 SwiftUI와 연결해줌
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // PHPickerViewController 생성 및 설정
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // 이미지만 선택
        configuration.selectionLimit = 1 // 하나만 선택 가능
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator // 델리게이트 연결
        return picker
    }
    
    // 업데이트 필요 없음 (정적 동작)
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    // Coordinator 클래스는 델리게이트 역할을 수행 (이미지 선택 결과 수신)
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // 사용자가 이미지를 선택했을 때 호출됨
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // 선택된 첫 번째 항목을 UIImage로 변환
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) {  image, error in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage // 결과 전달
                }
            }
        }
    }
}
