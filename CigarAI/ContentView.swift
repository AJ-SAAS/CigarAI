import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CigarViewModel

    var body: some View {
        TabBarView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CigarViewModel(isPreview: true))
            .previewDevice("iPhone 14 Pro")
    }
}
