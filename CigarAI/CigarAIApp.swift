import SwiftUI
import FirebaseCore
import FirebaseAuth
import RevenueCat

@main
struct CigarAIApp: App {
    @StateObject private var viewModel = CigarViewModel()

    init() {
        FirebaseApp.configure()
        print("Firebase initialized successfully")

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_oKFTXnzRgmkePNnCxpfBkXBBnMz")

        if let user = Auth.auth().currentUser {
            Purchases.shared.logIn(user.uid) { customerInfo, created, error in
                if let error = error {
                    print("RevenueCat login failed: \(error.localizedDescription)")
                } else {
                    print("RevenueCat logged in user with ID: \(user.uid), new user: \(created)")
                }
            }
        } else {
            print("No Firebase user logged in during app init")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(viewModel)
        }
    }
}

enum NavigationDestination: Hashable {
    case ageGate
    case splashScreen
    case authOptions
    case authView
    case onboarding
    case contentView
}

struct AppRootView: View {
    @EnvironmentObject private var viewModel: CigarViewModel
    @State private var navigationPath = NavigationPath()
    @State private var isVerified = false // Initialize as false
    @State private var isSignedIn = Auth.auth().currentUser != nil
    @State private var authListenerHandle: AuthStateDidChangeListenerHandle?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Color.backgroundCream
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .ageGate:
                        AgeGateView {
                            isVerified = true
                            UserDefaults.standard.set(true, forKey: "hasVerifiedAge")
                            navigationPath.append(NavigationDestination.splashScreen)
                            print("AppRootView: Age verified, navigated to splashScreen")
                        }
                        .navigationBarBackButtonHidden(true)
                    case .splashScreen:
                        OB1_SplashScreen {
                            navigationPath.append(NavigationDestination.authOptions)
                            print("AppRootView: Splash screen completed, navigated to authOptions")
                        }
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden(true)
                    case .authOptions:
                        OB2_AuthOptions {
                            navigationPath.append(NavigationDestination.authView)
                            print("AppRootView: Auth options completed, navigated to authView")
                        }
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden(true)
                    case .authView:
                        AuthView { signedUp in
                            if signedUp {
                                viewModel.isNewUser = true
                                viewModel.hasCompletedOnboarding = false
                                viewModel.saveUserPreferences()
                            }
                            navigationPath = NavigationPath([NavigationDestination.onboarding])
                            print("AppRootView: Auth completed, signedUp: \(signedUp), navigated to onboarding")
                        }
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden(true)
                    case .onboarding:
                        OB3_ValueCarousel {
                            viewModel.completeOnboarding()
                            navigationPath = NavigationPath([NavigationDestination.contentView])
                            print("AppRootView: Onboarding completed, navigated to contentView")
                        }
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden(true)
                    case .contentView:
                        ContentView()
                            .environmentObject(viewModel)
                            .navigationBarBackButtonHidden(true)
                    }
                }
        }
        .environmentObject(viewModel)
        .onAppear {
            // Reset age verification on app launch
            UserDefaults.standard.set(false, forKey: "hasVerifiedAge")
            isVerified = false
            print("AppRootView: Reset hasVerifiedAge to false on launch")

            authListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
                DispatchQueue.main.async {
                    isSignedIn = user != nil
                    if user == nil {
                        viewModel.resetForSignOut()
                        // If age is verified (e.g., post-sign-out), go to authView
                        if isVerified || UserDefaults.standard.bool(forKey: "hasVerifiedAge") {
                            navigationPath = NavigationPath([NavigationDestination.authView])
                            print("AppRootView: User signed out, navigated to authView")
                        } else {
                            navigationPath = NavigationPath([NavigationDestination.ageGate])
                            print("AppRootView: User signed out, navigated to ageGate")
                        }
                    } else {
                        viewModel.fetchUserPreferences()
                        viewModel.fetchCigars()
                        if viewModel.hasCompletedOnboarding {
                            navigationPath = NavigationPath([NavigationDestination.contentView])
                            print("AppRootView: Signed in, completed onboarding, navigated to contentView")
                        } else {
                            navigationPath = NavigationPath([NavigationDestination.onboarding])
                            print("AppRootView: Signed in, incomplete onboarding, navigated to onboarding")
                        }
                    }
                    print("AppRootView: Auth state changed - isSignedIn: \(isSignedIn), hasCompletedOnboarding: \(viewModel.hasCompletedOnboarding), navigationPath: \(navigationPath)")
                }
            }
            // Set initial navigation to ageGate if not signed in
            if !isSignedIn {
                navigationPath = NavigationPath([NavigationDestination.ageGate])
                print("AppRootView: Initial navigation set to ageGate")
            }
            print("AppRootView: Appeared - isVerified: \(isVerified), isSignedIn: \(isSignedIn)")
        }
        .onDisappear {
            if let handle = authListenerHandle {
                Auth.auth().removeStateDidChangeListener(handle)
                print("AppRootView: Removed auth state listener")
            }
        }
    }
}

