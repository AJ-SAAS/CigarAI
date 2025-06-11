import SwiftUI
import FirebaseAuth

struct OnboardingFlow: View {
    // Environment and State
    @EnvironmentObject private var viewModel: CigarViewModel
    @Binding var isAuthenticated: Bool
    @State private var currentScreen: Screen = .splash

    // Enum for Screen States
    enum Screen {
        case splash, authOptions, auth, valueCarousel, socialProof, personalization, cigarPrefs, inventoryTracking, conciergePrefs
    }

    var body: some View {
        NavigationStack {
            // Main Content Based on Current Screen
            Group {
                switch currentScreen {
                case .splash:
                    OB1_SplashScreen(onGetStarted: { currentScreen = .authOptions })
                case .authOptions:
                    OB2_AuthOptions(onNext: { currentScreen = .auth })
                case .auth:
                    AuthView(isAuthenticated: Binding(
                        get: { isAuthenticated },
                        set: { newValue in
                            isAuthenticated = newValue
                            if newValue {
                                viewModel.saveUserPreferences()
                                viewModel.fetchUserPreferences()
                                currentScreen = .valueCarousel
                            }
                        }
                    ))
                case .valueCarousel:
                    OB3_ValueCarousel(onNext: { currentScreen = .socialProof })
                case .socialProof:
                    OB7_SocialProof(onContinue: { currentScreen = .personalization })
                case .personalization:
                    OB8_Personalization(onNext: { currentScreen = .cigarPrefs })
                case .cigarPrefs:
                    OB9_CigarPrefs(onNext: { currentScreen = .inventoryTracking })
                case .inventoryTracking:
                    OB12_InventoryTracking(onNext: { currentScreen = .conciergePrefs })
                case .conciergePrefs:
                    OB13_ConciergePrefs(onCompletion: {
                        viewModel.saveUserPreferences()
                        viewModel.fetchUserPreferences()
                        isAuthenticated = true
                    })
                }
            }
            // Navigate to ContentView when Authenticated
            .navigationDestination(isPresented: $isAuthenticated) {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
    }
}

struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingFlow(isAuthenticated: .constant(false))
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OnboardingFlow(isAuthenticated: .constant(false))
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
