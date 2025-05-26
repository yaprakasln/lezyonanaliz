import SwiftUI
import UIKit
import FirebaseDatabase
import CoreML
import Vision

struct PatientAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var analysisResult: String?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var confidence: Float = 0.0
    @State private var showResultCard = false
    @State private var urgencyLevel: UrgencyLevel = .normal
    @State private var showingUrgencyAlert = false
    @State private var earlyAppointmentRequestSent = false
    @State private var animationAmount: Double = 0
    @State private var showImageFilter: Bool = false
    @State private var contrast: Double = 1.0
    @State private var brightness: Double = 0.0
    @State private var isMeasuring: Bool = false
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    @State private var showMeasurementTool: Bool = false
    @State private var measurementSize: Double = 0.0
    @State private var showSizeCalibration: Bool = false
    @State private var referenceSizeCm: Double = 2.0  // Referans boyut (cm)
    @State private var isCalibrated: Bool = false
    @State private var pixelPerCm: Double = 50.0  // Varsayılan piksel/cm oranı
    @State private var showTimeline: Bool = false
    @State private var timelineNote: String = ""
    @State private var timelineEntries: [TimelineEntry] = []
    
    enum UrgencyLevel: String {
        case low = "Düşük"
        case normal = "Normal"
        case high = "Yüksek"
        case urgent = "Acil"
        
        var color: Color {
            switch self {
            case .low: return Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
            case .normal: return Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
            case .high: return Color(#colorLiteral(red: 0.9372549057, green: 0.5490196347, blue: 0, alpha: 1))
            case .urgent: return Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
            }
        }
        
        var description: String {
            switch self {
            case .low:
                return "Bu tür lezyonlar genellikle bekleyebilir, rutin kontrolünüzde değerlendirilmesi uygundur."
            case .normal:
                return "Mevcut randevunuzu korumanız önerilir. Acil bir durum gözükmemektedir."
            case .high:
                return "Bu tür lezyonlar yakın zamanda değerlendirilmelidir. Randevunuzun erkene alınması önerilir."
            case .urgent:
                return "Bu lezyon tipi acil tıbbi değerlendirme gerektirebilir. En kısa sürede doktorunuza başvurmanızı öneririz."
            }
        }
        
        static func forResult(_ result: String) -> UrgencyLevel {
            let lowercaseResult = result.lowercased()
            
            if lowercaseResult.contains("melanom") || 
               lowercaseResult.contains("malign") {
                return .urgent
            } else if lowercaseResult.contains("bazal") || 
                      lowercaseResult.contains("skuamöz") || 
                      lowercaseResult.contains("prekanser") {
                return .high
            } else if lowercaseResult.contains("atipik") || 
                      lowercaseResult.contains("displastik") {
                return .normal
            } else {
                return .low
            }
        }
    }
    
    struct TimelineEntry: Identifiable {
        let id = UUID()
        let date: Date
        let note: String
        let imageData: Data?
    }
    
    var body: some View {
        ZStack {
            // Profesyonel gradient arka plan
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9686274529, green: 0.9764705896, blue: 0.9921568627, alpha: 1)), Color(#colorLiteral(red: 0.9882352941, green: 0.9921568627, blue: 1, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // İçerik
            VStack(spacing: 0) {
                // Sayfa başlığı ve geri tuşu
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("Lezyon Analizi")
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                    
                    Spacer()
                    
                    // Boş alan (geri tuşunu dengelemek için)
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                        .padding(.trailing)
                }
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profesyonel kart tasarımı
                        VStack(spacing: 0) {
                            if let image = selectedImage {
                                // Seçilen görüntü
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.2)), lineWidth: 1)
                                        )
                                        .brightness(brightness)
                                        .contrast(contrast)
                                    
                                    // Ölçüm çizgisi
                                    if isMeasuring && showMeasurementTool {
                                        Path { path in
                                            path.move(to: startPoint)
                                            path.addLine(to: endPoint)
                                        }
                                        .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        
                                        // Başlangıç noktası
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .position(startPoint)
                                        
                                        // Bitiş noktası
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .position(endPoint)
                                        
                                        // Ölçüm değeri
                                        let midPoint = CGPoint(
                                            x: (startPoint.x + endPoint.x) / 2,
                                            y: (startPoint.y + endPoint.y) / 2
                                        )
                                        
                                        Text(String(format: "%.1f cm", measurementSize))
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(4)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(4)
                                            .position(midPoint)
                                    }
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if showMeasurementTool {
                                                if !isMeasuring {
                                                    startPoint = value.location
                                                    endPoint = value.location
                                                    isMeasuring = true
                                                } else {
                                                    endPoint = value.location
                                                    
                                                    // Mesafeyi hesapla
                                                    let distance = sqrt(
                                                        pow(endPoint.x - startPoint.x, 2) +
                                                        pow(endPoint.y - startPoint.y, 2)
                                                    )
                                                    
                                                    // Pikseli cm'ye çevir
                                                    measurementSize = distance / pixelPerCm
                                                }
                                            }
                                        }
                                        .onEnded { _ in
                                            // Ölçüm tamamlandı
                                        }
                                )
                                .overlay(
                                    HStack(spacing: 8) {
                                        Button(action: { showImageFilter.toggle() }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "slider.horizontal.3")
                                                    .font(.system(size: 12, weight: .medium))
                                                Text("Görüntü Ayarla")
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.8)))
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                                        }
                                        
                                        Button(action: { 
                                            showMeasurementTool.toggle()
                                            if !showMeasurementTool {
                                                isMeasuring = false
                                            }
                                            
                                            // Kalibre edilmemişse kalibrasyon ekranını göster
                                            if showMeasurementTool && !isCalibrated {
                                                showSizeCalibration = true
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "ruler")
                                                    .font(.system(size: 12, weight: .medium))
                                                Text("Ölçüm")
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background(showMeasurementTool ? Color.green.opacity(0.8) : Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.8)))
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                                        }
                                        
                                        Button(action: { 
                                            showTimeline.toggle()
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "clock.arrow.circlepath")
                                                    .font(.system(size: 12, weight: .medium))
                                                Text("Takip")
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background(showTimeline ? Color.purple.opacity(0.8) : Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.8)))
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                                        }
                                    }
                                    .padding(8),
                                    alignment: .bottomTrailing
                                )
                            } else {
                                // Modern fotoğraf seçim alanı
                                ZStack {
                                    // Arkaplan
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .frame(height: 220)
                                        .cornerRadius(16, corners: [.topLeft, .topRight])
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.1)), lineWidth: 1)
                                                .cornerRadius(16, corners: [.topLeft, .topRight])
                                        )
                                    
                                    // Modern Medikal Icon
                                    VStack(spacing: 16) {
                                        ZStack {
                                            // Dış daire
                                            Circle()
                                                .fill(Color(#colorLiteral(red: 0.9607843161, green: 0.9764705896, blue: 0.9921568627, alpha: 1)))
                                                .frame(width: 110, height: 110)
                                                .shadow(color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.1)), radius: 10, x: 0, y: 5)
                                            
                                            // İç daire
                                            Circle()
                                                .stroke(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.2)), lineWidth: 2)
                                                .frame(width: 90, height: 90)
                                            
                                            // Gölge efekti
                                            Image(systemName: "plus.viewfinder")
                                                .font(.system(size: 32, weight: .light))
                                                .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.8)))
                                        }
                                        
                                        Text("Lezyon fotoğrafı ekleyin")
                                            .font(.system(size: 15, weight: .medium, design: .default))
                                            .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.7)))
                                        
                                        Text("Daha doğru analiz için net ve yakın çekim görüntü yükleyin")
                                            .font(.system(size: 13, weight: .regular, design: .default))
                                            .foregroundColor(Color.gray.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                }
                            }
                            
                            // Butonlar kısmı - daha profesyonel stil
                            HStack(spacing: 15) {
                                // Fotoğraf Seç butonu
                                Button(action: { showImagePicker = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Galeri")
                                            .font(.system(size: 16, weight: .medium, design: .default))
                                    }
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                }
                                
                                // Fotoğraf Çek butonu
                                Button(action: { showCamera = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Kamera")
                                            .font(.system(size: 16, weight: .medium, design: .default))
                                    }
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(20)
                            .background(
                                Rectangle()
                                    .foregroundColor(.white)
                                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.1)), lineWidth: 1)
                                            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                                    )
                            )
                        }
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Kalibrasyon Alanı
                        if showSizeCalibration {
                            VStack(spacing: 12) {
                                Text("Ölçüm Kalibrasyonu")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                
                                Text("Doğru ölçüm için kalibre edin")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                
                                HStack {
                                    Text("Referans boyut (cm):")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Slider(value: $referenceSizeCm, in: 0.5...10.0, step: 0.5)
                                        .accentColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    
                                    Text(String(format: "%.1f", referenceSizeCm))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                        .frame(width: 30)
                                }
                                
                                Text("Ekranda bir bozuk para gibi bildiğiniz bir nesneyi ölçün ve gerçek boyutu girin.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    // Kalibrasyonu tamamla
                                    let distance = sqrt(
                                        pow(endPoint.x - startPoint.x, 2) +
                                        pow(endPoint.y - startPoint.y, 2)
                                    )
                                    
                                    pixelPerCm = distance / referenceSizeCm
                                    isCalibrated = true
                                    showSizeCalibration = false
                                    
                                    // Yeni ölçüm başlat
                                    isMeasuring = false
                                }) {
                                    Text("Kalibrasyonu Tamamla")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: showSizeCalibration)
                        }
                        
                        // Görüntü Filtreleme Alanı
                        if let _ = selectedImage, showImageFilter {
                            VStack(spacing: 15) {
                                HStack {
                                    Text("Görüntü Netleştirme")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        contrast = 1.0
                                        brightness = 0.0
                                    }) {
                                        Text("Sıfırla")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    }
                                }
                                
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Kontrast")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Slider(value: $contrast, in: 0.5...2.0)
                                            .accentColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                        
                                        Text(String(format: "%.1f", contrast))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                            .frame(width: 30)
                                    }
                                    
                                    HStack {
                                        Text("Parlaklık")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Slider(value: $brightness, in: -0.5...0.5)
                                            .accentColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                        
                                        Text(String(format: "%.1f", brightness))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                            .frame(width: 30)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: showImageFilter)
                        }
                        
                        // Zaman Takibi Paneli
                        if let image = selectedImage, showTimeline {
                            VStack(spacing: 15) {
                                HStack {
                                    Text("Lezyon Takibi")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Yeni takip girişi ekle
                                        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
                                        let newEntry = TimelineEntry(
                                            date: Date(), 
                                            note: timelineNote.isEmpty ? "Takip başlangıcı" : timelineNote, 
                                            imageData: imageData
                                        )
                                        timelineEntries.append(newEntry)
                                        timelineNote = ""
                                    }) {
                                        Text("Kaydet")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    }
                                }
                                
                                // Not ekleme alanı
                                TextField("Lezyon ile ilgili notlar ekleyin...", text: $timelineNote)
                                    .padding()
                                    .background(Color(#colorLiteral(red: 0.9607843161, green: 0.9764705896, blue: 0.9921568627, alpha: 1)))
                                    .cornerRadius(10)
                                
                                Divider()
                                    .padding(.vertical, 8)
                                
                                // Kayıtlı takip listesi
                                if timelineEntries.isEmpty {
                                    VStack(spacing: 10) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 30))
                                            .foregroundColor(Color.gray.opacity(0.5))
                                        
                                        Text("Henüz takip kaydı yok")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gray)
                                        
                                        Text("Lezyonu takip etmek ve değişimlerini kaydetmek için 'Kaydet' butonuna basın")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.gray.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                    }
                                    .padding(.vertical, 20)
                                } else {
                                    ScrollView {
                                        VStack(spacing: 15) {
                                            ForEach(timelineEntries.sorted(by: { $0.date > $1.date })) { entry in
                                                HStack(alignment: .top, spacing: 10) {
                                                    // Tarih gösterimi
                                                    VStack(spacing: 2) {
                                                        Text(formatDate(entry.date, format: "dd MMM"))
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                                        
                                                        Text(formatDate(entry.date, format: "yyyy"))
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)
                                                    }
                                                    .frame(width: 60)
                                                    
                                                    // Küçük resim
                                                    if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 50, height: 50)
                                                            .cornerRadius(8)
                                                    }
                                                    
                                                    // Not
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(formatDate(entry.date, format: "HH:mm"))
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)
                                                        
                                                        Text(entry.note)
                                                            .font(.system(size: 14))
                                                            .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                                                            .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .padding()
                                                .background(Color(#colorLiteral(red: 0.9764705896, green: 0.9764705896, blue: 0.9764705896, alpha: 1)).opacity(0.5))
                                                .cornerRadius(10)
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 200)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: showTimeline)
                        }
                        
                        // Analiz butonu - daha profesyonel tasarım
                        if selectedImage != nil {
                            Button(action: analyzeImage) {
                                HStack(spacing: 12) {
                                    Image(systemName: "waveform.path.ecg")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Analiz Et")
                                        .font(.system(size: 18, weight: .semibold, design: .default))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)).opacity(0.4), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: 1)
                                        .blur(radius: 0.5)
                                        .padding(.horizontal)
                                )
                            }
                        }
                        
                        // Analiz yükleniyor göstergesi - profesyonel animasyon
                        if isAnalyzing {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.95))
                                    .frame(height: 140)
                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                
                                VStack(spacing: 20) {
                                    // Profesyonel dönen daire
                                    ZStack {
                                        Circle()
                                            .stroke(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)).opacity(0.15), lineWidth: 5)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: 0.7)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                                            )
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(Angle(degrees: animationAmount))
                                            .onAppear {
                                                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                                    animationAmount = 360
                                                }
                                            }
                                        
                                        Image(systemName: "stethoscope")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    }
                                    
                                    Text("Analiz yapılıyor...")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)))
                                    
                                    Text("Görüntü detaylı şekilde inceleniyor")
                                        .font(.system(size: 14, design: .default))
                                        .foregroundColor(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.7)))
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.3), value: isAnalyzing)
                        }
                        
                        // Analiz sonuçları - daha modern tasarım
                        if let result = analysisResult, !isAnalyzing {
                            VStack(alignment: .leading, spacing: 0) {
                                // Sonuç başlığı
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Analiz Sonucu")
                                            .font(.system(size: 20, weight: .bold, design: .default))
                                            .foregroundColor(Color(#colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)))
                                        
                                        Spacer()
                                        
                                        // Güven oranı göstergesi
                                        if confidence > 0 {
                                            HStack(spacing: 4) {
                                                Text("Güven:")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                                
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(width: 50, height: 8)
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(
                                                            confidence > 0.8 ? Color.green : 
                                                                (confidence > 0.5 ? Color.orange : Color.red)
                                                        )
                                                        .frame(width: 50 * CGFloat(confidence), height: 8)
                                                }
                                                
                                                Text("\(Int(confidence * 100))%")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(
                                                        confidence > 0.8 ? Color.green : 
                                                            (confidence > 0.5 ? Color.orange : Color.red)
                                                    )
                                            }
                                        }
                                    }
                                    
                                    // Aciliyet durumu
                                    HStack(spacing: 10) {
                                        Image(systemName: urgencyLevel == .urgent || urgencyLevel == .high ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                            .foregroundColor(urgencyLevel.color)
                                            .font(.system(size: 16))
                                        
                                        Text("\(urgencyLevel.rawValue) Öncelik")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(urgencyLevel.color)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(urgencyLevel.color.opacity(0.15))
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                                
                                Divider()
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 20)
                                
                                // Sonuç detayları
                                VStack(alignment: .leading, spacing: 16) {
                                    // Teşhis
                                    Text(result)
                                        .font(.system(size: 16, design: .default))
                                        .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                                        .padding(.horizontal, 20)
                                    
                                    // Aciliyet açıklaması
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Öneri:")
                                            .font(.system(size: 14, weight: .semibold, design: .default))
                                            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                                        
                                        Text(urgencyLevel.description)
                                            .font(.system(size: 14, design: .default))
                                            .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(.leading, 2)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                    
                                    // Randevu erkene alma talebi
                                    if urgencyLevel == .high || urgencyLevel == .urgent {
                                        if earlyAppointmentRequestSent {
                                            HStack(spacing: 12) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 16))
                                                
                                                Text("Randevu erkene alma talebiniz gönderildi")
                                                    .font(.system(size: 14, weight: .medium, design: .default))
                                                    .foregroundColor(.green)
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.green.opacity(0.1))
                                        } else {
                                            Button(action: sendEarlyAppointmentRequest) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "calendar.badge.clock")
                                                        .font(.system(size: 16))
                                                    Text("Randevu Erkene Alma Talebi Gönder")
                                                        .font(.system(size: 15, weight: .medium, design: .default))
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 50)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [urgencyLevel.color, urgencyLevel.color.opacity(0.8)]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .clipShape(Capsule())
                                                .shadow(color: urgencyLevel.color.opacity(0.4), radius: 5, x: 0, y: 3)
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 5)
                                        }
                                    }
                                    
                                    // Uyarı notu
                                    HStack(spacing: 10) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(Color.gray.opacity(0.7))
                                            .font(.system(size: 12))
                                        
                                        Text("Not: Bu sonuç ön değerlendirmedir ve kesin tanı için doktorunuza başvurunuz.")
                                            .font(.system(size: 12, design: .default))
                                            .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)
                                    .padding(.bottom, 20)
                                }
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.1)), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 10)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5), value: showResultCard)
                            .onAppear {
                                showResultCard = true
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .alert(isPresented: $showingUrgencyAlert) {
            Alert(
                title: Text("Erken Randevu Talebi"),
                message: Text("Lezyon analizi sonucunuza göre mevcut randevunuzun erkene alınması önerilmektedir. Randevunuzu erkene almak için talep göndermek istiyor musunuz?"),
                primaryButton: .default(Text("Evet")) {
                    sendEarlyAppointmentRequest()
                },
                secondaryButton: .cancel(Text("Hayır"))
            )
        }
        .alert(isPresented: Binding<Bool>(
            get: { self.analysisResult?.contains("Hata") ?? false },
            set: { _ in }
        )) {
            Alert(
                title: Text("Hata"),
                message: Text(analysisResult ?? ""),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    func sendEarlyAppointmentRequest() {
        guard let image = selectedImage, let result = analysisResult else { return }
        
        // Görüntüyü base64'e çevirme
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        let base64Image = "data:image/jpeg;base64," + imageData.base64EncodedString()
        
        // Firebase Realtime Database'e bildirim gönderme
        let ref = Database.database().reference().child("mail_notifications").childByAutoId()
        
        let mailData: [String: Any] = [
            "to": "44yprk@gmail.com", // Doktor e-posta adresi
            "subject": "Acil Randevu Talebi: \(urgencyLevel.rawValue) Öncelikli Lezyon",
            "message": """
            ⚠️ RANDEVU ERKENE ALMA TALEBİ ⚠️
            
            Sayın Doktor,
            
            Hasta, yapay zeka analizi sonrasında randevusunun erkene alınması için talepte bulunmuştur.
            
            ACİLİYET SEVİYESİ: \(urgencyLevel.rawValue.uppercased())
            
            Analiz Sonucu: \(result)
            
            Yapay zeka algoritması, ekteki lezyon fotoğrafını \(urgencyLevel.rawValue) öncelikli olarak değerlendirmiştir. Hastanın mevcut randevusunun mümkün olan en kısa süreye alınması için değerlendirmenizi rica ederiz.
            
            Lezyonun özelliklerine göre, daha erken bir tıbbi müdahalenin gerekli olabileceği düşünülmektedir.
            
            Saygılarımızla,
            Dermaai Sistemi
            """,
            "photoUrl": base64Image,
            "urgencyLevel": urgencyLevel.rawValue,
            "status": "pending",
            "createdAt": ServerValue.timestamp()
        ]
        
        ref.setValue(mailData) { (error, _) in
            if error != nil {
                print("Hata: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            } else {
                self.earlyAppointmentRequestSent = true
                self.showingUrgencyAlert = true
            }
        }
    }
    
    func analyzeImage() {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        analysisResult = nil
        confidence = 0.0
        showResultCard = false
        earlyAppointmentRequestSent = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Model konumlarını kontrol et ve yükle
            print("Model aranıyor...")
            let paths = [
                Bundle.main.path(forResource: "LesionClassifier", ofType: "mlmodelc"), // Önce derlenmiş sürüm
                Bundle.main.path(forResource: "LesionClassifier", ofType: "mlmodel"),
                "Dermaai/LesionClassifier.mlmodel",
                "Dermaai/Models/LesionClassifier.mlmodel"
            ]
            
            var modelURL: URL? = nil
            for path in paths {
                if let path = path, FileManager.default.fileExists(atPath: path) {
                    modelURL = URL(fileURLWithPath: path)
                    print("Model bulundu: \(path)")
                    break
                }
            }
            
            guard let validModelURL = modelURL else {
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.analysisResult = "Hata: Model dosyası bulunamadı."
                }
                print("HATA: Model hiçbir konumda bulunamadı")
                print("Aranan konumlar: \(paths.compactMap { $0 })")
                return
            }
            
            // Modeli yükle
            do {
                print("Model yükleniyor...")
                let mlModel = try MLModel(contentsOf: validModelURL)
                let visionModel = try VNCoreMLModel(for: mlModel)
                
                // Görüntüyü işle
                guard let ciImage = CIImage(image: image) else {
                    DispatchQueue.main.async {
                        self.isAnalyzing = false
                        self.analysisResult = "Hata: Görüntü işlenemedi."
                    }
                    return
                }
                let resizedCiImage = ciImage.transformed(by: CGAffineTransform(scaleX: 224.0 / ciImage.extent.width, y: 224.0 / ciImage.extent.height))
                
                // Vision isteğini oluştur
                print("Görüntü analiz ediliyor...")
                let request = VNCoreMLRequest(model: visionModel) { (request, error) in
                    if let error = error {
                        print("Vision hatası: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isAnalyzing = false
                            self.analysisResult = "Hata: \(error.localizedDescription)"
                        }
                        return
                    }
                    
                    guard let results = request.results as? [VNClassificationObservation],
                          let topResult = results.first else {
                        print("HATA: Sonuçlar alınamadı")
                        DispatchQueue.main.async {
                            self.isAnalyzing = false
                            self.analysisResult = "Hata: Sonuçlar alınamadı"
                        }
                        return
                    }
                    
                    // Sonuçları konsola yazdır
                    print("Sonuçlar:")
                    for (index, result) in results.prefix(10).enumerated() {
                        print("  \(index+1). \(result.identifier): \(result.confidence * 100)%")
                    }
                    
                    DispatchQueue.main.async {
                        self.isAnalyzing = false
                        
                        // Doğrudan en yüksek güvenirliğe sahip sonucu bul
                        var bestResult = results.first!
                        for result in results {
                            if result.confidence > bestResult.confidence {
                                bestResult = result
                            }
                        }
                        
                        // Konsola en yüksek güvenirliğe sahip sonucu yazdır
                        print("En yüksek güvenirliğe sahip: \(bestResult.identifier) - \(bestResult.confidence * 100)%")
                        
                        // En yüksek güvenirliğe sahip sınıfı ve güven oranını göster
                        self.confidence = bestResult.confidence
                        let confidencePercent = Int(self.confidence * 100)
                        self.analysisResult = "Teşhis: \(bestResult.identifier) (\(confidencePercent)%)"
                        
                        // Aciliyet seviyesini belirle
                        self.urgencyLevel = UrgencyLevel.forResult(bestResult.identifier)
                        
                        // Alternatif teşhisleri göster - en yüksek olan hariç
                        var alternatives: [(identifier: String, confidence: Float)] = []
                        for result in results {
                            if result.identifier != bestResult.identifier {
                                alternatives.append((result.identifier, result.confidence))
                            }
                        }
                        
                        // En yüksek güvenirliğe sahip 2 alternatifi göster
                        alternatives.sort { $0.confidence > $1.confidence }
                        if alternatives.count > 0 {
                            self.analysisResult! += "\n\nAlternatif Teşhisler:"
                            for i in 0..<min(2, alternatives.count) {
                                let alt = alternatives[i]
                                let confidence = Int(alt.confidence * 100)
                                self.analysisResult! += "\n\(alt.identifier) (\(confidence)%)"
                                
                                // Alternatifler arasında acil durum varsa aciliyet seviyesini güncelle
                                let altUrgency = UrgencyLevel.forResult(alt.identifier)
                                if altUrgency.rawValue == "Acil" && alt.confidence > 0.3 {
                                    self.urgencyLevel = .urgent
                                } else if altUrgency.rawValue == "Yüksek" && alt.confidence > 0.4 && self.urgencyLevel != .urgent {
                                    self.urgencyLevel = .high
                                }
                            }
                        }
                    }
                }
                
                // İsteği gerçekleştir
                let handler = VNImageRequestHandler(ciImage: resizedCiImage)
                try handler.perform([request])
                
            } catch {
                print("Model yükleme/işleme hatası: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.analysisResult = "Hata: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Tarih biçimlendirme fonksiyonu
    func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

// Bir extension ekle - özel köşe yuvarlama için
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}