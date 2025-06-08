import SwiftUI

struct OB2_AuthOptions: View {
    var onContinueWithApple: () -> Void
    var onContinueWithEmail: () -> Void
    var onContinueWithFacebook: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                Spacer().frame(height: geometry.size.width > 600 ? 40 : 24)

                Image("CigarAI_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 280))
                    .accessibilityLabel("Cigar AI Logo")

                Image("cigar_mockup")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: min(geometry.size.width * 0.9, 500))
                    .accessibilityLabel("Cigar AI App Mockup")

                Text("Sign in to access all of Cigar AI’s features")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .accessibilityLabel("Sign in to access all features")

                Spacer()

                Button(action: {
                    onContinueWithApple()
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Continue with Apple")
                    }
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                    .padding()
                    .background(.black)
                    .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .accessibilityLabel("Continue with Apple")

                Button(action: {
                    onContinueWithEmail()
                }) {
                    Text("Continue with Email")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .accessibilityLabel("Continue with Email")

                Button(action: {
                    onContinueWithFacebook()
                }) {
                    HStack {
                        Image(systemName: "f.circle.fill")
                        Text("Continue with Facebook")
                    }
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                    .padding()
                    .background(.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("Continue with Facebook")
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    OB2_AuthOptions(onContinueWithApple: {}, onContinueWithEmail: {}, onContinueWithFacebook: {})
}

#Preview("iPad Pro") {
    OB2_AuthOptions(onContinueWithApple: {}, onContinueWithEmail: {}, onContinueWithFacebook: {})
}
