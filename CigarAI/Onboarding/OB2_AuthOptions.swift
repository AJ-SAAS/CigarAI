import SwiftUI

struct OB2_AuthOptions: View {
    var onNext: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                ProgressBar(currentStep: 2, totalSteps: 9)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, geometry.size.width > 600 ? 40 : 24)
                    .opacity(isVisible ? 1 : 0)

                Image("CigarAI_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 280))
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .accessibilityLabel("Cigar AI Logo")

                Image("cigar_mockup")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: min(geometry.size.width * 0.9, 400))
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .accessibilityLabel("Cigar AI App Mockup")

                Text("Sign in to unlock all features")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel("Sign in to unlock all features")

                Spacer()

                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onNext()
                }) {
                    Text("Continue with Email")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(Color(red: 0.55, green: 0.27, blue: 0.07))
                        .cornerRadius(10)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.95)
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("Continue with Email")
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.55, green: 0.27, blue: 0.07).opacity(0.2), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isVisible = true
                }
            }
        }
    }
}

struct OB2_AuthOptions_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OB2_AuthOptions(onNext: {})
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OB2_AuthOptions(onNext: {})
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
