import SwiftUI

struct OB3_CigarTrackingValue: View {
    var onNext: () -> Void

    var body: some View {
        ValuePropScreen(
            imageName: "cigar_journal_mockup",
            title: "Log Every Smoke",
            text: "Track your smokes, flavor notes, and ratings in one simple journal.",
            buttonText: "Next",
            onButtonTap: onNext
        )
    }
}

#Preview("iPhone 14") {
    OB3_CigarTrackingValue(onNext: {})
}

#Preview("iPad Pro") {
    OB3_CigarTrackingValue(onNext: {})
}
