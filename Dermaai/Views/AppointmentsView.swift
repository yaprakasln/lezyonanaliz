import SwiftUI
import FirebaseDatabase

// ... Paste AppointmentsView, AppointmentCard, PhotoGallerySheet, StatusBadge here ... 

struct AppointmentsView: View {
    @State private var appointments: [Appointment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text(error)
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if appointments.isEmpty {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.accentColor)
                    Text("Henüz randevu bulunmuyor")
                        .font(.system(size: 16, weight: .medium))
                        .padding()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(appointments) { appointment in
                            AppointmentCard(appointment: appointment)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Randevular")
        .onAppear {
            loadAppointments()
        }
    }
    private func loadAppointments() {
        isLoading = true
        errorMessage = nil
        let ref = Database.database().reference().child("appointments")
        ref.queryOrdered(byChild: "timestamp").observe(.value) { snapshot in
            isLoading = false
            guard snapshot.exists() else {
                appointments = []
                return
            }
            do {
                var loadedAppointments: [Appointment] = []
                let appointmentSnapshots = snapshot.children.allObjects as! [DataSnapshot]
                for snapshot in appointmentSnapshots {
                    guard let value = snapshot.value as? [String: Any] else { continue }
                    let appointment = Appointment(
                        id: snapshot.key,
                        userName: value["userName"] as? String ?? "",
                        userEmail: value["userEmail"] as? String ?? "",
                        userPhone: value["userPhone"] as? String ?? "",
                        date: value["appointmentDate"] as? String ?? "",
                        time: value["appointmentTime"] as? String ?? "",
                        notes: value["notes"] as? String ?? "",
                        status: value["status"] as? String ?? "Beklemede",
                        complaint: value["description"] as? String ?? "",
                        photos: [value["photoUrl"] as? String ?? ""].filter { !$0.isEmpty },
                        timestamp: value["timestamp"] as? Int64 ?? 0
                    )
                    loadedAppointments.append(appointment)
                }
                self.appointments = loadedAppointments.sorted { ($0.timestamp ?? 0) > ($1.timestamp ?? 0) }
            } catch {
                errorMessage = "Randevular yüklenirken bir hata oluştu: \(error.localizedDescription)"
                print("Error loading appointments: \(error)")
            }
        }
    }
}

struct AppointmentCard: View {
    let appointment: Appointment
    @State private var showPhotos = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.userName)
                        .font(.system(size: 18, weight: .bold))
                    Text(appointment.userPhone)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                StatusBadge(status: appointment.status)
            }
            Divider()
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tarih:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColors.accentColor)
                        Text(appointment.date)
                    }
                    .font(.system(size: 14))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saat:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(AppColors.accentColor)
                        Text(appointment.time)
                    }
                    .font(.system(size: 14))
                }
            }
            if !appointment.userEmail.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("E-posta:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(AppColors.accentColor)
                        Text(appointment.userEmail)
                    }
                    .font(.system(size: 14))
                }
                .padding(.top, 4)
            }
            if !appointment.complaint.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Şikayet:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(appointment.complaint)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.leading, 4)
                }
                .padding(.top, 4)
            }
            if !appointment.notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(appointment.notes)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.leading, 4)
                }
                .padding(.top, 4)
            }
            if !appointment.photos.isEmpty {
                Button(action: { showPhotos = true }) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(AppColors.accentColor)
                        Text("\(appointment.photos.count) Fotoğraf")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.accentColor)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .sheet(isPresented: $showPhotos) {
            PhotoGallerySheet(photos: appointment.photos)
        }
    }
}

struct PhotoGallerySheet: View {
    let photos: [String]
    @Environment(\.presentationMode) var presentationMode
    @State private var loadedImages: [UIImage] = []
    @State private var selectedImage: UIImage?
    @State private var isShowingFullScreen = false
    var body: some View {
        NavigationView {
            ScrollView {
                if loadedImages.isEmpty {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Fotoğraflar yükleniyor...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(loadedImages.indices, id: \.self) { index in
                            Button(action: {
                                selectedImage = loadedImages[index]
                                isShowingFullScreen = true
                            }) {
                                Image(uiImage: loadedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 600)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Fotoğraflar")
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .fullScreenCover(isPresented: $isShowingFullScreen, content: {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.all)
                }
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingFullScreen = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                                .padding(25)
                        }
                    }
                    Spacer()
                }
            }
        })
        .onAppear {
            loadBase64Images()
        }
    }
    private func loadBase64Images() {
        for photoString in photos {
            if !photoString.isEmpty {
                let base64String = photoString.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
                if let imageData = Data(base64Encoded: base64String),
                   let image = UIImage(data: imageData) {
                    loadedImages.append(image)
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: String
    var statusColor: Color {
        switch status.lowercased() {
        case "onaylandı":
            return .green
        case "reddedildi":
            return .red
        default:
            return .orange
        }
    }
    var body: some View {
        Text(status)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(10)
    }
} 