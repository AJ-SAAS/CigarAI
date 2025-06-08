import SwiftUI

struct OB5_CigarConciergeValue: View {
    var onNext: () -> Void

    var body: some View {
        ValuePropScreen(
            imageName: "ai_chatbot",
            title: "Your AI Cigar Guide",
            text: "Get expert suggestions based on your taste — available 24/7.",
            buttonText: "Next",
            onButtonTap: onNext
        )
    }
}

#Preview("iPhone 14") {
    OB5_CigarConciergeValue(onNext: {})
}

#Preview("iPad Pro") {
    OB5_CigarConciergeValue(onNext: {})
}
