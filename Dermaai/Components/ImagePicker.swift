import SwiftUI
import UIKit
import FirebaseDatabase

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    var appointmentId: String?
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.5),
               let appointmentId = parent.appointmentId {
                parent.selectedImage = image
                let base64String = imageData.base64EncodedString()
                let photoUrl = "data:image/jpeg;base64," + base64String
                let ref = Database.database().reference().child("appointments").child(appointmentId)
                ref.child("photos").observeSingleEvent(of: .value) { snapshot in
                    var photos: [String] = []
                    if let existingPhotos = snapshot.value as? [String] {
                        photos = existingPhotos
                    }
                    photos.append(photoUrl)
                    ref.child("photos").setValue(photos)
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// ... Paste ImagePicker here ... 