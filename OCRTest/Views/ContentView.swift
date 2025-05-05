//
//  ContentView.swift
//  OCRTest
//
//  Created by 송승윤 on 4/23/25.
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TextRecognitionViewModel(service: VisionAPIService())
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isProcessing = false
    @State private var isResultReady = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if selectedImage == nil {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Text("사진 선택")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .padding(.horizontal)
                        }
                    } else if !isResultReady {
                        VStack(spacing: 20) {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)

                            TextField("찾고 싶은 책 제목을 입력하세요", text: $viewModel.searchKeyword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            Button(action: {
                                recognizeAndHighlight()
                            }) {
                                Text("검색")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        if let image = selectedImage {
                            VStack(spacing: 20) {
                                BookShelfImageView(image: image, viewModel: viewModel)
                                    .aspectRatio(contentMode: .fit)
                                    .padding()

                                HStack(spacing: 20) {
                                    Button(action: {
                                        isResultReady = false
                                        viewModel.reset()
                                    }) {
                                        Text("다시 검색")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .padding(.horizontal)
                                    }

                                    Button(action: {
                                        selectedImage = nil
                                        isResultReady = false
                                        viewModel.reset()
                                    }) {
                                        Text("처음으로")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.green)
                                            .foregroundStyle(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }

                if isProcessing {
                    ProgressView("서가를 분석 중입니다...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Find it")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    private func recognizeAndHighlight() {
        guard let image = selectedImage else { return }
        isProcessing = true

        viewModel.recognize(from: image) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isProcessing = false
                self.isResultReady = true
            }
        }
    }
}

#Preview {
    ContentView()
}
