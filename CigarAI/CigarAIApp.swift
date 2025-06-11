import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct CigarAIApp: App {
    // State and Dependencies
    @StateObject private var viewModel = CigarViewModel()
    @State private var isAuthenticated = false
    @State private var authListenerHandle: AuthStateDidChangeListenerHandle?

    // Initialization
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            // Main Content Based on Authentication State
            Group {
                if isAuthenticated {
                    ContentView()
                        .environmentObject(viewModel)
                } else {
                    OnboardingFlow(isAuthenticated: $isAuthenticated)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                // Set up the auth state listener
                authListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
                    DispatchQueue.main.async {
                        self.isAuthenticated = user != nil
                        if let user = user {
                            print("User authenticated: \(user.uid), email: \(user.email ?? "none")")
                            self.viewModel.fetchCigars()
                            self.viewModel.fetchUserPreferences()
                        } else {
                            print("No user authenticated")
                        }
                    }
                }
                // Initial check (replaced with boolean test)
                if Auth.auth().currentUser != nil {
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.viewModel.fetchCigars()
                        self.viewModel.fetchUserPreferences()
                    }
                }
            }
            .onDisappear {
                if let handle = authListenerHandle {
                    Auth.auth().removeStateDidChangeListener(handle)
                }
            }
        }
    }
}
