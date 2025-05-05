import SwiftUI

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