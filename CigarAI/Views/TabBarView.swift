import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "chart.bar")
                }
                .tag(1)
            
            ChatbotView()
                .tabItem {
                    Label("Concierge", systemImage: "message")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .onAppear {
            viewModel.fetchCigars()
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .environmentObject(CigarViewModel(isPreview: true))
            .previewDevice("iPhone 14 Pro")
        TabBarView()
            .environmentObject(CigarViewModel(isPreview: true))
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
