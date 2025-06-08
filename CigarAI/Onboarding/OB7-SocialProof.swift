import SwiftUI

struct OB7_SocialProof: View {
    var onContinue: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                Spacer().frame(height: geometry.size.width > 600 ? 40 : 24)

                Image("CigarAI_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 280))
                    .accessibilityLabel("Cigar AI Logo")

                Text("Cigar lovers are discovering their perfect smokes…")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("Cigar lovers are discovering their perfect smokes")

                Text("Be part of the new wave of cigar enthusiasts who track, rate, and share their palate discoveries.")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)

                Spacer()

                Button(action: {
                    onContinue()
                }) {
                    Text("Continue")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("Continue Button")
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    OB7_SocialProof(onContinue: {})
}

#Preview("iPad Pro") {
    OB7_SocialProof(onContinue: {})
}
