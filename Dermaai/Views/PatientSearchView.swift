import SwiftUI
import FirebaseDatabase

// ... Paste PatientSearchView, PatientCard here ... 

struct PatientSearchView: View {
    @State private var searchText = ""
    @State private var patients: [Patient] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [AppColors.gradient1, AppColors.gradient2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.accentColor)
                    TextField("Hasta Adı veya Telefon", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: AppColors.shadowColor, radius: 2)
                    Button(action: searchPatients) {
                        Text("Ara")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(AppColors.accentColor)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: AppColors.shadowColor, radius: 5)
                .padding(.horizontal)
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if patients.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.accentColor)
                        Text("Hasta bulunamadı")
                            .font(.headline)
                            .foregroundColor(AppColors.textColor)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(patients) { patient in
                                PatientCard(patient: patient)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Hasta Arama")
        .alert(isPresented: $showError) {
            Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
        }
    }
    func searchPatients() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        patients.removeAll()
        let ref = Database.database().reference().child("appointments")
        ref.queryOrdered(byChild: "userName")
            .queryStarting(atValue: searchText)
            .queryEnding(atValue: searchText + "\u{f8ff}")
            .observeSingleEvent(of: .value) { snapshot in
                isLoading = false
                guard snapshot.exists() else {
                    return
                }
                do {
                    let appointmentSnapshots = snapshot.children.allObjects as! [DataSnapshot]
                    for snapshot in appointmentSnapshots {
                        guard let value = snapshot.value as? [String: Any] else { continue }
                        let patient = Patient(
                            id: snapshot.key,
                            name: value["userName"] as? String ?? "",
                            phone: value["userPhone"] as? String ?? "",
                            email: value["userEmail"] as? String ?? "",
                            lastAppointment: "\(value["appointmentDate"] as? String ?? "") \(value["appointmentTime"] as? String ?? "")"
                        )
                        if !patients.contains(where: { $0.id == patient.id }) {
                            patients.append(patient)
                        }
                    }
                } catch {
                    errorMessage = "Hasta arama sırasında bir hata oluştu"
                    showError = true
                }
            }
    }
}

struct PatientCard: View {
    let patient: Patient
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    Text(patient.phone)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Son Randevu")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(patient.lastAppointment)
                        .font(.subheadline)
                        .foregroundColor(AppColors.accentColor)
                }
            }
            if !patient.email.isEmpty {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    Text(patient.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: AppColors.shadowColor, radius: 5)
    }
} 