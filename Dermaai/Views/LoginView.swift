import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(PlainTextFieldStyle())
            .padding(16)
            .background(Color.white)
            .cornerRadius(25)
    }
}

struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color(red: 65/255, green: 140/255, blue: 255/255))
            .foregroundColor(.white)
            .cornerRadius(25)
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 20)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let systemImage: String
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecured {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: { isSecured.toggle() }) {
                Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct LoginView: View {
    @Binding var currentView: String
    @State private var email = ""
    @State private var sifre = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var rememberMe = false
    @State private var showResetPassword = false
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Modern background pattern
            GeometryReader { geometry in
                ZStack {
                    // Subtle grid pattern
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
                    
                    // Modern shapes
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
                    // Logo Container
                    VStack(spacing: 25) {
                        ZStack {
                            // Modern logo container
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                                .frame(width: 160, height: 160)
                                .shadow(color: AppColors.shadowColor, radius: 20)
                            
                            // Decorative circles
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
                    
                    // Form Container
                    VStack(spacing: 25) {
                        // E-posta
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
                        
                        // Şifre
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
                        }
                        .padding(.horizontal, 20)
                        
                        // Beni Hatırla ve Şifremi Unuttum
                        HStack {
                            Button(action: { rememberMe.toggle() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                        .foregroundColor(rememberMe ? AppColors.accentColor : AppColors.textColor.opacity(0.5))
                                        .font(.system(size: 20))
                                    
                                    Text("Beni Hatırla")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(AppColors.textColor.opacity(0.7))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { showResetPassword = true }) {
                                Text("Şifremi Unuttum")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppColors.accentColor)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.top, 20)
                    
                    // Giriş Yap butonu
                    Button(action: {
                        isLoading = true
                        login()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Giriş Yap")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right.circle.fill")
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
                    
                    // Kayıt Ol linki
                    Button(action: { currentView = "register" }) {
                        Text("Hesabınız yok mu? Hemen Kayıt Olun")
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
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordView(isPresented: $showResetPassword)
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: sifre) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                if rememberMe {
                    // Kullanıcı bilgilerini UserDefaults'a kaydet
                    UserDefaults.standard.set(email, forKey: "savedEmail")
                    UserDefaults.standard.set(sifre, forKey: "savedPassword")
                    UserDefaults.standard.set(true, forKey: "rememberMe")
                } else {
                    // Kayıtlı bilgileri temizle
                    UserDefaults.standard.removeObject(forKey: "savedEmail")
                    UserDefaults.standard.removeObject(forKey: "savedPassword")
                    UserDefaults.standard.removeObject(forKey: "rememberMe")
                }
                currentView = "dashboard"
            }
        }
    }
    
    // View yüklendiğinde kayıtlı bilgileri kontrol et
    private func checkSavedCredentials() {
        if UserDefaults.standard.bool(forKey: "rememberMe") {
            email = UserDefaults.standard.string(forKey: "savedEmail") ?? ""
            sifre = UserDefaults.standard.string(forKey: "savedPassword") ?? ""
            rememberMe = true
        }
    }
} 