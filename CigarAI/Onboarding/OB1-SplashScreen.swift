import SwiftUI

struct OB1_SplashScreen: View {
    var onGetStarted: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                Spacer().frame(height: geometry.size.width > 600 ? 40 : 24)

                Image("CigarAI_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 280))
                    .accessibilityLabel("Cigar AI Logo")

                VStack(spacing: 12) {
                    Text("Congratulations!")
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Congratulations!")

                    Text("You’re on your way to mastering your cigar palate.")
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                }
                .padding(.top, geometry.size.width > 600 ? 60 : 40)

                Spacer()

                Button(action: {
                    onGetStarted()
                }) {
                    Text("Get Started")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("Get Started Button")
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

#Preview("iPhone 14") {
    OB1_SplashScreen(onGetStarted: {})
}

#Preview("iPad Pro") {
    OB1_SplashScreen(onGetStarted: {})
}
