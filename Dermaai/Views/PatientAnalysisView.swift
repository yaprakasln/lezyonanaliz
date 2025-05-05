import SwiftUI
import UIKit
import FirebaseDatabase

struct PatientAnalysisView: View {
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var analysisResult: String?
    @State private var showImagePicker = false
    @State private var showCamera = false
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(15)
                        Button(action: analyzeImage) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                Text("Analiz Et")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.accentColor)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    HStack(spacing: 15) {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                Text("Fotoğraf Seç")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.accentColor)
                            .cornerRadius(10)
                        }
                        Button(action: {
                            showCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Fotoğraf Çek")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.accentColor)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    if isAnalyzing {
                        ProgressView("Analiz ediliyor...")
                    }
                    if let result = analysisResult {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Analiz Sonucu:")
                                .font(.headline)
                            Text(result)
                                .font(.body)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Hasta Analizi")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
    }
    func analyzeImage() {
        guard selectedImage != nil else { return }
        isAnalyzing = true
        analysisResult = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isAnalyzing = false
            analysisResult = "Lezyon analizi tamamlandı. Sonuç: ..."
        }
    }
} 