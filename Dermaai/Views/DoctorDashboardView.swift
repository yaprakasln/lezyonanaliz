import SwiftUI
import FirebaseAuth
import FirebaseDatabase

// ... Paste DoctorDashboardView, QuickActionButton, FeatureCard, DoctorCard here ... 

struct DoctorDashboardView: View {
    @Binding var currentView: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var doctorName = ""
    @State private var doctorTitle = ""
    @State private var doctorSpecialty = ""
    @State private var doctorPhone = ""
    @State private var doctorEmail = ""
    @State private var isLoading = true
    @State private var showAccountSettings = false
    @State private var selectedTab = 0
    @State private var showGreeting = false
    @State private var appointments: [Appointment] = []
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 240/255, green: 244/255, blue: 255/255),
                            Color(red: 250/255, green: 252/255, blue: 255/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.accentColor.opacity(0.1),
                                    AppColors.accentColor.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.8)
                        .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
                        .blur(radius: 30)
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColors.secondaryColor.opacity(0.1),
                                    AppColors.secondaryColor.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: -geometry.size.width * 0.3, y: geometry.size.height * 0.2)
                        .blur(radius: 30)
                }
            }
            ScrollView {
                VStack(spacing: 25) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hoş Geldiniz,")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .opacity(showGreeting ? 1 : 0)
                                .animation(.easeIn(duration: 0.5).delay(0.3), value: showGreeting)
                            Text("Dr. \(doctorName)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColors.accentColor)
                                .opacity(showGreeting ? 1 : 0)
                                .animation(.easeIn(duration: 0.5).delay(0.5), value: showGreeting)
                        }
                        Spacer()
                        HStack(spacing: 16) {
                            Button(action: { showAccountSettings = true }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: AppColors.shadowColor, radius: 8)
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(AppColors.accentColor)
                                }
                            }
                            Button(action: {
                                do {
                                    try Auth.auth().signOut()
                                    currentView = "login"
                                } catch {
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: AppColors.shadowColor, radius: 8)
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.secondaryColor)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 60)
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.accentColor.opacity(0.8),
                                        AppColors.accentColor
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppColors.shadowColor, radius: 10)
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DermaAI")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Yapay Zeka Destekli\nDermatoloji Asistanı")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            ZStack {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                        .frame(width: 50 + CGFloat(index * 20), height: 50 + CGFloat(index * 20))
                                        .scaleEffect(showGreeting ? 1 : 0.5)
                                        .opacity(showGreeting ? 0.2 : 0.8)
                                        .animation(
                                            Animation.easeInOut(duration: 1.5)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.2),
                                            value: showGreeting
                                        )
                                }
                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(showGreeting ? 360 : 0))
                                    .animation(
                                        Animation.linear(duration: 5)
                                            .repeatForever(autoreverses: false),
                                        value: showGreeting
                                    )
                            }
                            .frame(width: 100)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 20)
                    }
                    .frame(height: 100)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    NavigationLink(destination: PatientSearchView()) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                            Text("Hasta Ara")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.accentColor, AppColors.accentColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: AppColors.accentColor.opacity(0.3), radius: 10)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 20
                    ) {
                        NavigationLink(destination: AppointmentsView()) {
                            FeatureCard(
                                title: "Randevular",
                                subtitle: "Randevu listesi",
                                icon: "calendar",
                                color: Color.purple
                            )
                        }
                        NavigationLink(destination: PatientAnalysisView()) {
                            FeatureCard(
                                title: "Hasta Analizi",
                                subtitle: "Yapay Zeka Analizi",
                                icon: "waveform.path.ecg",
                                color: AppColors.accentColor
                            )
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Hata"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .sheet(isPresented: $showAccountSettings) {
            AccountSettingsView(
                isPresented: $showAccountSettings,
                doctorName: $doctorName,
                doctorTitle: $doctorTitle,
                doctorSpecialty: $doctorSpecialty,
                doctorPhone: $doctorPhone,
                doctorEmail: $doctorEmail,
                isLoading: $isLoading
            )
        }
        .onAppear {
            loadDoctorProfile()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showGreeting = true
            }
        }
    }
    private func loadDoctorProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("doctors").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                doctorName = value["name"] as? String ?? ""
                doctorTitle = value["title"] as? String ?? ""
                doctorSpecialty = value["specialty"] as? String ?? ""
                doctorPhone = value["phone"] as? String ?? ""
                doctorEmail = value["email"] as? String ?? ""
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textColor)
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: AppColors.shadowColor, radius: 8)
        )
    }
}

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.textColor)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: AppColors.shadowColor, radius: 8)
    }
}

struct DoctorCard: View {
    let name: String
    let title: String
    let specialty: String
    var formattedName: String {
        if title.isEmpty {
            return "Dr. \(name)"
        } else {
            return "\(title) \(name)"
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.accentColor)
            Text(specialty)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textColor.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: AppColors.shadowColor, radius: 5)
    }
} 