import SwiftUI
import FirebaseAuth
import FirebaseDatabase

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
    @State private var isUpdating = false
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
                        Text("Hesap Ayarları")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.accentColor)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.accentColor)
                        .padding(.top, 20)
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
                    Button(action: {
                        isUpdating = true
                        updateAccount()
                    }) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Bilgileri Güncelle")
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
                    .disabled(isUpdating)
                }
                .padding(.bottom, 30)
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .alert("Başarılı", isPresented: $showSuccess) {
            Button("Tamam", role: .cancel) {
                showSuccess = false
                isPresented = false
            }
        } message: {
            Text("Bilgileriniz başarıyla güncellendi.")
        }
    }
    private func updateAccount() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Kullanıcı oturumu bulunamadı"
            showError = true
            isUpdating = false
            return
        }
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
            if let error = error {
                isUpdating = false
                errorMessage = "Güncelleme sırasında bir hata oluştu: \(error.localizedDescription)"
                showError = true
            } else {
                if let currentUser = Auth.auth().currentUser, currentUser.email != doctorEmail {
                    currentUser.updateEmail(to: doctorEmail) { error in
                        isUpdating = false
                        if let error = error {
                            errorMessage = "E-posta güncellenirken hata oluştu: \(error.localizedDescription)"
                            showError = true
                        } else {
                            showSuccess = true
                        }
                    }
                } else {
                    isUpdating = false
                    showSuccess = true
                }
            }
        }
        if !currentPassword.isEmpty && !newPassword.isEmpty {
            guard newPassword == confirmPassword else {
                errorMessage = "Yeni şifreler eşleşmiyor"
                showError = true
                isUpdating = false
                return
            }
            guard let user = Auth.auth().currentUser else { return }
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
            user.reauthenticate(with: credential) { _, error in
                if let error = error {
                    errorMessage = "Mevcut şifre yanlış: \(error.localizedDescription)"
                    showError = true
                    isUpdating = false
                    return
                }
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = "Şifre güncellenirken hata oluştu: \(error.localizedDescription)"
                        showError = true
                    } else {
                        currentPassword = ""
                        newPassword = ""
                        confirmPassword = ""
                        showSuccess = true
                    }
                    isUpdating = false
                }
            }
        }
    }
} 