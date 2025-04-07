//
//  ContentView.swift
//  Dermaai
//
//  Created by Yaprak on 18.03.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ContentView: View {
    @State private var currentView = "login" // login, register, dashboard
    
    var body: some View {
        NavigationView {
            if currentView == "login" {
                LoginView(currentView: $currentView)
            } else if currentView == "register" {
                RegisterView(currentView: $currentView)
            } else {
                DoctorDashboardView(currentView: $currentView)
            }
        }
    }
}

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

// Ortak renk ve stil tanımlamaları
struct AppColors {
    static let gradient1 = Color(red: 240/255, green: 248/255, blue: 255/255)
    static let gradient2 = Color(red: 230/255, green: 240/255, blue: 255/255)
    static let accentColor = Color(red: 0/255, green: 150/255, blue: 255/255) // Vibrant blue
    static let secondaryColor = Color(red: 255/255, green: 100/255, blue: 100/255) // Soft red
    static let textColor = Color(red: 44/255, green: 62/255, blue: 80/255)
    static let inputBackground = Color.white
    static let shadowColor = Color.black.opacity(0.08)
}

extension View {
    func glassBackground() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 32.5)
                .fill(Color.white)
                .background(
                    RoundedRectangle(cornerRadius: 32.5)
                        .stroke(Color.white, lineWidth: 1)
                        .shadow(color: AppColors.shadowColor, radius: 20, x: 0, y: 10)
                )
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

struct RegisterView: View {
    @Binding var currentView: String
    @State private var adSoyad = ""
    @State private var email = ""
    @State private var sifre = ""
    @State private var sifreTekrar = ""
    @State private var doctorTitle = ""
    @State private var doctorSpecialty = ""
    @State private var doctorPhone = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
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
                        // Ad Soyad
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
                        
                        // Unvan
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unvan")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "star.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                
                                TextField("Unvan (Dr., Prof. Dr., vb.)", text: $doctorTitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Uzmanlık
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Uzmanlık")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "stethoscope")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                
                                TextField("Uzmanlık Alanı", text: $doctorSpecialty)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Telefon
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
                        
                        // Şifre Tekrar
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
                    
                    // Hesap Oluştur butonu
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
                    
                    // Giriş Yap linki
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
        
        Auth.auth().createUser(withEmail: email, password: sifre) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            } else if let user = authResult?.user {
                let userData: [String: Any] = [
                    "name": adSoyad,
                    "title": doctorTitle,
                    "specialty": doctorSpecialty,
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

struct DoctorDashboardView: View {
    @Binding var currentView: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var doctorName = ""
    @State private var doctorTitle = ""
    @State private var doctorSpecialty = ""
    @State private var doctorPhone = ""
    @State private var doctorEmail = ""
    @State private var isLoading = false
    @State private var showAccountSettings = false
    @State private var selectedTab = 0
    @State private var showGreeting = false
    
    var body: some View {
        ZStack {
            // Modern gradient background with animated circles
            GeometryReader { geometry in
                ZStack {
                    // Base gradient
            LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 240/255, green: 244/255, blue: 255/255),
                            Color(red: 250/255, green: 252/255, blue: 255/255)
                        ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
                    // Animated background shapes
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
                    // Modern Header with Profile
                HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hoş Geldiniz,")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .opacity(showGreeting ? 1 : 0)
                                .animation(.easeIn(duration: 0.5).delay(0.3), value: showGreeting)
                            
                            Text(doctorTitle.isEmpty ? "Dr. \(doctorName)" : "\(doctorTitle) \(doctorName)")
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
                
                    // Quick Actions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            QuickActionButton(
                                title: "Yeni Randevu",
                                icon: "calendar.badge.plus",
                                color: AppColors.accentColor
                            ) {
                                // Yeni randevu action
                            }
                            
                            QuickActionButton(
                                title: "Hasta Ara",
                                icon: "magnifyingglass",
                                color: AppColors.secondaryColor
                            ) {
                                // Hasta arama action
                            }
                            
                            QuickActionButton(
                                title: "İstatistikler",
                                icon: "chart.bar.fill",
                                color: Color.purple
                            ) {
                                // İstatistikler action
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.top, 10)
                    
                    // Main Features Grid
                    LazyVGrid(
                        columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                        ],
                        spacing: 20
                    ) {
                    // Fotoğraf Çek
                    NavigationLink(destination: CameraView()) {
                            FeatureCard(
                            title: "Fotoğraf Çek",
                                subtitle: "Yeni hasta fotoğrafı",
                                icon: "camera.fill",
                                color: AppColors.accentColor
                        )
                    }
                    
                    // Fotoğraf Yükle
                    NavigationLink(destination: PhotoGalleryView()) {
                            FeatureCard(
                            title: "Fotoğraf Yükle",
                                subtitle: "Galeriden seç",
                                icon: "photo.fill",
                                color: AppColors.secondaryColor
                        )
                    }
                    
                    // Randevular
                    NavigationLink(destination: AppointmentsView()) {
                            FeatureCard(
                            title: "Randevular",
                                subtitle: "Randevu listesi",
                                icon: "calendar",
                                color: Color.purple
                        )
                    }
                    
                    // Hasta Geçmişi
                    NavigationLink(destination: PatientHistoryView()) {
                            FeatureCard(
                            title: "Hasta Geçmişi",
                                subtitle: "Geçmiş kayıtlar",
                                icon: "list.clipboard",
                                color: Color.green
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

// Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: AppColors.shadowColor, radius: 8)
        }
    }
}

// Feature Card
struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon
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

struct PatientHistoryView: View {
    var body: some View {
        ZStack {
            Color(red: 0.35, green: 0.6, blue: 1.0).ignoresSafeArea()
            Text("Hasta Geçmişi - Çok Yakında")
                .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(false)
    }
}

struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.35, green: 0.6, blue: 1.0).ignoresSafeArea()
            Text("Kamera - Çok Yakında")
                .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(false)
    }
}

struct PhotoGalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.35, green: 0.6, blue: 1.0).ignoresSafeArea()
            Text("Fotoğraf Galerisi - Çok Yakında")
                .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(false)
    }
}

struct Appointment: Identifiable {
    let id: String
    let userName: String
    let userEmail: String
    let userPhone: String
    let date: String
    let time: String
    let notes: String
    let status: String
    let complaint: String
    let photos: [String]
}

struct AppointmentsView: View {
    @State private var appointments: [Appointment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background
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
        ref.observe(.value) { snapshot in
            isLoading = false
            
            guard snapshot.exists() else {
                appointments = []
                return
            }
            
            do {
                var loadedAppointments: [Appointment] = []
                
                for child in snapshot.children {
                    guard let snapshot = child as? DataSnapshot,
                          let value = snapshot.value as? [String: Any] else { continue }
                    
                    let appointment = Appointment(
                        id: snapshot.key,
                        userName: value["userName"] as? String ?? "",
                        userEmail: value["userEmail"] as? String ?? "",
                        userPhone: value["userPhone"] as? String ?? "",
                        date: value["appointmentDate"] as? String ?? "",
                        time: value["appointmentTime"] as? String ?? "",
                        notes: value["description"] as? String ?? "",
                        status: value["status"] as? String ?? "Beklemede",
                        complaint: value["description"] as? String ?? "",
                        photos: [value["photoUrl"] as? String ?? ""].filter { !$0.isEmpty }
                    )
                    loadedAppointments.append(appointment)
                    print("Loaded appointment: \(appointment)")
                }
                
                appointments = loadedAppointments.sorted { $0.date < $1.date }
                print("Total loaded appointments: \(appointments.count)")
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
            // Header with name and status
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
            
            // Date and Time with labels
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
            
            // Email
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
            
            // Complaint
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
            
            // Notes
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
            
            // Photos
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(photos, id: \.self) { photoUrl in
                        AsyncImage(url: URL(string: photoUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .navigationTitle("Fotoğraflar")
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Geri butonu için NavigationBar düzenlemesi
extension View {
    func customNavigationBar() -> some View {
        self.navigationBarItems(
            leading: Button(action: {
                // Geri gitme işlemi
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                    Text("Geri")
                        .foregroundColor(.blue)
                }
            }
        )
    }
}

// Her ekran için ayrı geri butonu
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Text("Geri")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ResetPasswordView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.accentColor)
                        }
                        Spacer()
                        Text("Şifre Sıfırlama")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.accentColor)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Icon
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.accentColor)
                        .padding(.top, 20)
                    
                    // Description
                    Text("Şifrenizi sıfırlamak için e-posta adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    // Email Field
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
                    .padding(.top, 30)
                    
                    // Reset Button
                    Button(action: resetPassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Şifre Sıfırlama Bağlantısı Gönder")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18))
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
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
        }
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen e-postanızı kontrol edin."),
                dismissButton: .default(Text("Tamam")) {
                    isPresented = false
                }
            )
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin"
            showError = true
            return
        }
        
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                showSuccess = true
            }
        }
    }
}

struct AccountSettingsView: View {
    @Binding var isPresented: Bool
    @Binding var doctorName: String
    @Binding var doctorTitle: String
    @Binding var doctorSpecialty: String
    @Binding var doctorPhone: String
    @Binding var doctorEmail: String
    @Binding var isLoading: Bool
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showPasswordFields = false
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.accentColor)
                        }
                        Spacer()
                        Text("Hesap Ayarları")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.accentColor)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Profile Icon
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.accentColor)
                        .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 25) {
                        // Ad Soyad
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
                                
                                TextField("Ad Soyad", text: $doctorName)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
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
                                
                                TextField("E-posta adresiniz", text: $doctorEmail)
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
                        
                        // Unvan
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unvan")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "star.fill")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                
                                TextField("Unvan (Dr., Prof. Dr., vb.)", text: $doctorTitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Uzmanlık
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Uzmanlık")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textColor)
                                .padding(.leading, 25)
                            
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.accentColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "stethoscope")
                                        .foregroundColor(AppColors.accentColor)
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                
                                TextField("Uzmanlık Alanı", text: $doctorSpecialty)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textColor)
                            }
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: AppColors.shadowColor, radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Telefon
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
                        
                        // Şifre Değiştirme Butonu
                        Button(action: { showPasswordFields.toggle() }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Şifre Değiştir")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.accentColor)
                        }
                        .padding(.top, 10)
                        
                        if showPasswordFields {
                            // Mevcut Şifre
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mevcut Şifre")
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
                                    
                                    SecureField("Mevcut şifreniz", text: $currentPassword)
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.textColor)
                                }
                                .frame(height: 55)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: AppColors.shadowColor, radius: 5)
                            }
                            .padding(.horizontal, 20)
                            
                            // Yeni Şifre
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Yeni Şifre")
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
                                    
                                    SecureField("Yeni şifreniz", text: $newPassword)
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.textColor)
                                }
                                .frame(height: 55)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: AppColors.shadowColor, radius: 5)
                            }
                            .padding(.horizontal, 20)
                            
                            // Yeni Şifre Tekrar
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Yeni Şifre Tekrar")
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
                                    
                                    SecureField("Yeni şifrenizi tekrar girin", text: $confirmPassword)
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
                    }
                    .padding(.top, 30)
                    
                    // Update Button
                    Button(action: updateAccount) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Değişiklikleri Kaydet")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
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
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
        }
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Hesap bilgileriniz başarıyla güncellendi."),
                dismissButton: .default(Text("Tamam")) {
                    isPresented = false
                }
            )
        }
    }
    
    private func updateAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        isLoading = true
        
        // E-posta değişikliği varsa
        if doctorEmail != user.email {
            user.updateEmail(to: doctorEmail) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                    return
                }
                updateProfileData()
            }
        } else {
            updateProfileData()
        }
        
        // Şifre değişikliği varsa
        if !newPassword.isEmpty {
            if newPassword == confirmPassword {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showError = true
                        isLoading = false
                    }
                }
            } else {
                errorMessage = "Yeni şifreler eşleşmiyor"
                showError = true
                isLoading = false
            }
        }
    }
    
    private func updateProfileData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("doctors").child(userId)
        let profileData: [String: Any] = [
            "name": doctorName,
            "title": doctorTitle,
            "specialty": doctorSpecialty,
            "phone": doctorPhone,
            "email": doctorEmail,
            "updatedAt": ServerValue.timestamp()
        ]
        
        ref.updateChildValues(profileData) { error, _ in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                showSuccess = true
            }
        }
    }
}

// Doktor kartı için yeni bir view
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

