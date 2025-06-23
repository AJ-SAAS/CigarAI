import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let errorMessage = errorMessage {
                VStack {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityLabel("Error: \(errorMessage)")
                    Button("Retry") {
                        fetchData()
                    }
                    .padding()
                    .background(Color(red: 0.55, green: 0.27, blue: 0.07))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .accessibilityLabel("Retry button")
                }
            } else if isLoading {
                ProgressView("Loading your journal...")
                    .accessibilityLabel("Loading")
            } else {
                TabBarView()
            }
        }
        .onAppear {
            print("ContentView appeared")
            fetchData()
        }
    }

    private func fetchData() {
        guard Auth.auth().currentUser != nil else {
            isLoading = false
            errorMessage = "Please sign in to continue."
            return
        }
        isLoading = true
        errorMessage = nil
        if viewModel.cigars.isEmpty {
            viewModel.fetchCigars()
        }
        viewModel.fetchUserPreferences()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            if viewModel.cigars.isEmpty && !viewModel.hasCompletedOnboarding {
                errorMessage = "Failed to load data. Please check your connection."
            }
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
