import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct CigarAIApp: App {
    @StateObject private var viewModel = CigarViewModel()
    @State private var isAuthenticated = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    ContentView()
                        .environmentObject(viewModel)
                } else {
                    OnboardingFlow(isAuthenticated: $isAuthenticated)
                        .environmentObject(viewModel)
                        .onAppear {
                            let _ = Auth.auth().addStateDidChangeListener { _, user in
                                DispatchQueue.main.async {
                                    if let user = user {
                                        print("User authenticated: \(user.uid), email: \(user.email ?? "none")")
                                        isAuthenticated = true
                                        viewModel.fetchCigars()
                                    } else {
                                        print("No user authenticated")
                                        isAuthenticated = false
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
}
