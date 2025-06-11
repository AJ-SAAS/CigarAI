import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CigarViewModel

    var body: some View {
        TabBarView()
            .onAppear {
                viewModel.fetchUserPreferences() // Ensure survey data is loaded
                viewModel.fetchCigars() // Ensure cigars are loaded
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            ContentView()
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
