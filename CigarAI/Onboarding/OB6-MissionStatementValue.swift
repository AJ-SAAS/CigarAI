import SwiftUI

struct OB6_MissionStatementValue: View {
    var onNext: () -> Void

    var body: some View {
        ValuePropScreen(
            imageName: "elegant_cigar_scene",
            title: "Support the Craft",
            text: "By using Cigar AI, you're helping improve how cigars are rated, recommended, and enjoyed worldwide.",
            buttonText: "Next",
            onButtonTap: onNext
        )
    }
}

#Preview("iPhone 14") {
    OB6_MissionStatementValue(onNext: {})
}

#Preview("iPad Pro") {
    OB6_MissionStatementValue(onNext: {})
}
