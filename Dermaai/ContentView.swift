//
//  ContentView.swift
//  Dermaai
//
//  Created by Yaprak on 18.03.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

