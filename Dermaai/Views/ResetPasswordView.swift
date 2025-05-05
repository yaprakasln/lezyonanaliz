import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
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
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.accentColor)
                        .padding(.top, 20)
                    Text("Şifrenizi sıfırlamak için e-posta adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
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