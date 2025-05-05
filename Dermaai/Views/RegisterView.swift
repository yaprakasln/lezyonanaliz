import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RegisterView: View {
    @Binding var currentView: String
    @State private var adSoyad = ""
    @State private var email = ""
    @State private var sifre = ""
    @State private var sifreTekrar = ""
    @State private var doctorPhone = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            GeometryReader { geometry in
                ZStack {
                    Path { path in
                        let spacing: CGFloat = 40
                        for x in stride(from: 0, through: geometry.size.width, by: spacing) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        }
                        for y in stride(from: 0, through: geometry.size.height, by: spacing) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(AppColors.accentColor.opacity(0.05), lineWidth: 1)
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.accentColor.opacity(0.1), AppColors.accentColor.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.8)
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                        .blur(radius: 20)
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.secondaryColor.opacity(0.1), AppColors.secondaryColor.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.8)
                        .blur(radius: 20)
                }
            }
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 25) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                                .frame(width: 160, height: 160)
                                .shadow(color: AppColors.shadowColor, radius: 20)
                            Circle()
                                .stroke(AppColors.accentColor.opacity(0.2), lineWidth: 2)
                                .frame(width: 140, height: 140)
                            Circle()
                                .stroke(AppColors.secondaryColor.opacity(0.2), lineWidth: 2)
                                .frame(width: 120, height: 120)
                            Image(systemName: "stethoscope")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(AppColors.accentColor)
                        }
                        .padding(.top, 60)
                        VStack(spacing: 8) {
                            Text("DermaAI")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppColors.accentColor)
                            Text("Dermatoloji Yapay Zeka Asistanı")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor.opacity(0.7))
                        }
                    }
                    VStack(spacing: 25) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ad Soyad")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                TextField("Ad Soyad", text: $adSoyad)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Telefon")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                TextField("Telefon Numarası", text: $doctorPhone)
                                    .keyboardType(.phonePad)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-posta")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                TextField("E-posta adresiniz", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifre")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                SecureField("Şifreniz", text: $sifre)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                            Text("Şifreniz en az 6 karakter olmalıdır.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.leading, 15)
                        }
                        .padding(.horizontal, 20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifre Tekrar")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                SecureField("Şifrenizi tekrar girin", text: $sifreTekrar)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    Button(action: {
                        isLoading = true
                        register()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Hesap Oluştur")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
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
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .disabled(isLoading)
                    Button(action: { currentView = "login" }) {
                        Text("Zaten hesabınız var mı? Giriş Yapın")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColors.accentColor)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
        }
    }
    func register() {
        guard sifre == sifreTekrar else {
            errorMessage = "Şifreler eşleşmiyor"
            showError = true
            isLoading = false
            return
        }
        guard sifre.count >= 6 else {
            errorMessage = "Lütfen en az 6 haneli bir şifre oluşturunuz."
            showError = true
            isLoading = false
            return
        }
        Auth.auth().createUser(withEmail: email, password: sifre) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            } else if let user = authResult?.user {
                let userData: [String: Any] = [
                    "name": adSoyad,
                    "phone": doctorPhone,
                    "email": email,
                    "createdAt": ServerValue.timestamp()
                ]
                Database.database().reference().child("doctors").child(user.uid).setValue(userData) { error, _ in
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showError = true
                    } else {
                        currentView = "login"
                    }
                }
            }
        }
    }
} 