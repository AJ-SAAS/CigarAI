import SwiftUI
import FirebaseAuth

struct OnboardingFlow: View {
    @EnvironmentObject private var viewModel: CigarViewModel
    @Binding var isAuthenticated: Bool
    @State private var currentScreen: Screen = .splash

    enum Screen {
        case splash
        case cigarTracking
        case palateFinder
        case cigarConcierge
        case missionStatement
        case socialProof
        case authOptions
        case auth
    }

    var body: some View {
        NavigationStack {
            Group {
                switch currentScreen {
                case .splash:
                    OB1_SplashScreen(onGetStarted: {
                        currentScreen = .cigarTracking
                    })
                case .cigarTracking:
                    OB3_CigarTrackingValue(onNext: {
                        currentScreen = .palateFinder
                    })
                case .palateFinder:
                    OB4_PalateFinderValue(onNext: {
                        currentScreen = .cigarConcierge
                    })
                case .cigarConcierge:
                    OB5_CigarConciergeValue(onNext: {
                        currentScreen = .missionStatement
                    })
                case .missionStatement:
                    OB6_MissionStatementValue(onNext: {
                        currentScreen = .socialProof
                    })
                case .socialProof:
                    OB7_SocialProof(onContinue: {
                        currentScreen = .authOptions
                    })
                case .authOptions:
                    OB2_AuthOptions(
                        onContinueWithApple: {
                            // TODO: Implement Sign In with Apple
                            // Example: Authenticate with Firebase
                            // On success:
                            isAuthenticated = true
                            viewModel.fetchCigars()
                        },
                        onContinueWithEmail: {
                            currentScreen = .auth
                        },
                        onContinueWithFacebook: {
                            // TODO: Implement Facebook Login
                            // Example: Authenticate with Firebase
                            // On success:
                            isAuthenticated = true
                            viewModel.fetchCigars()
                        }
                    )
                case .auth:
                    AuthView(isAuthenticated: $isAuthenticated)
                }
            }
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
