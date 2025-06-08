import SwiftUI

struct ValuePropScreen: View {
    let imageName: String
    let title: String
    let text: String
    let buttonText: String
    let onButtonTap: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                Text(title)
                    .font(.system(.largeTitle, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel(title)

                Text(text)
                    .font(.system(.subheadline, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                Spacer()

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: min(geometry.size.width * 0.9, 500))
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("\(title) Illustration")

                Spacer()

                Button(action: {
                    onButtonTap()
                }) {
                    Text(buttonText)
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("\(buttonText) Button")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    ValuePropScreen(
        imageName: "cigar_journal_mockup",
        title: "Log Every Smoke",
        text: "Track your smokes, flavor notes, and ratings in one simple journal.",
        buttonText: "Next",
        onButtonTap: {}
    )
}

#Preview("iPad Pro") {
    ValuePropScreen(
        imageName: "cigar_journal_mockup",
        title: "Log Every Smoke",
        text: "Track your smokes, flavor notes, and ratings in one simple journal.",
        buttonText: "Next",
        onButtonTap: {}
    )
}
