import SwiftUI

struct AppBackgroundView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            content()
        }
    }
}

