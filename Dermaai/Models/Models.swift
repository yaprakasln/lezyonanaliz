import Foundation
import SwiftUI

// ... Paste Patient, Appointment here ... 

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
    let timestamp: Int64?
}

struct Patient: Identifiable, Hashable {
    let id: String
    let name: String
    let phone: String
    let email: String
    let lastAppointment: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.id == rhs.id
    }
} 