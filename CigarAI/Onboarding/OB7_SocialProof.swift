import SwiftUI

struct OB7_SocialProof: View {
    var onContinue: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                ProgressBar(currentStep: 5, totalSteps: 9)
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

                Text("Join Fellow Cigar Enthusiasts")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel("Join Fellow Cigar Enthusiasts")

                Text("Track, rate, and share your cigar discoveries with a growing community.")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)

                Spacer()

                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onContinue()
                }) {
                    Text("Continue")
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
                .accessibilityLabel("Continue Button")
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

struct OB7_SocialProof_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OB7_SocialProof(onContinue: {})
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OB7_SocialProof(onContinue: {})
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
