import SwiftUI
import FirebaseAuth

struct OnboardingFlow: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        EmptyView() // Navigation handled by AppRootView
            .onAppear {
                if Auth.auth().currentUser != nil { // Replaced 'if let user' with boolean check
                    if viewModel.hasCompletedOnboarding {
                        navigationPath = NavigationPath([NavigationDestination.contentView])
                    } else {
                        navigationPath = NavigationPath([NavigationDestination.onboarding])
                    }
                } else {
                    navigationPath = NavigationPath([NavigationDestination.splashScreen])
                }
                print("OnboardingFlow: Appeared - user: \(Auth.auth().currentUser?.uid ?? "nil"), hasCompletedOnboarding: \(viewModel.hasCompletedOnboarding), navigationPath: \(navigationPath)")
            }
            .onChange(of: Auth.auth().currentUser) { oldValue, newValue in // Updated to two-parameter closure
                print("OnboardingFlow: User changed to \(newValue?.uid ?? "nil")")
                if newValue == nil {
                    viewModel.resetForSignOut()
                    navigationPath = NavigationPath([NavigationDestination.authView])
                    print("OnboardingFlow: Reset navigation to authView due to sign-out")
                }
            }
    }
}

struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlow(navigationPath: .constant(NavigationPath()))
            .environmentObject(CigarViewModel(isPreview: true))
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}

