import SwiftUI

struct OB4_PalateFinderValue: View {
    var onNext: () -> Void

    var body: some View {
        ValuePropScreen(
            imageName: "flavor_wheel",
            title: "Find Your Palate",
            text: "Discover what you truly like based on cigars you enjoy and notes you log.",
            buttonText: "Next",
            onButtonTap: onNext
        )
    }
}

#Preview("iPhone 14") {
    OB4_PalateFinderValue(onNext: {})
}

#Preview("iPad Pro") {
    OB4_PalateFinderValue(onNext: {})
}
