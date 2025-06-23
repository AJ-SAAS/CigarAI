import SwiftUI
import RevenueCatUI

struct TabBarView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var selectedTab = 0
    @State private var showingPaywall = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                .accessibilityLabel("Home tab")

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(1)
                .accessibilityLabel("Profile tab")
                .onAppear {
                    if viewModel.shouldShowPaywall(for: .accessProfile) {
                        showingPaywall = true
                        selectedTab = 0
                    }
                }

            ChatbotView()
                .tabItem {
                    Label("Concierge", systemImage: "message")
                }
                .tag(2)
                .accessibilityLabel("Concierge tab")
                .onAppear {
                    if viewModel.shouldShowPaywall(for: .accessChatbot) {
                        showingPaywall = true
                        selectedTab = 0
                    }
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
                .accessibilityLabel("Settings tab")
        }
        .accentColor(.cigarBrown)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.fetchCigars()
            viewModel.fetchUserPreferences()
        }
        .background(Color.backgroundCream.ignoresSafeArea())
    }
}

extension Color {
    static let cigarBrown = Color(red: 0.55, green: 0.27, blue: 0.07)
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabBarView()
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            TabBarView()
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}

