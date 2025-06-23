import SwiftUI

struct OB2_AuthOptions: View {
    var onNext: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Image("Cicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.4, 280))
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .accessibilityLabel("Cigar AI Logo")

                Image("cmockup1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: min(geometry.size.width * 0.9, 400))
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .accessibilityLabel("Cigar mockup illustration")

                Text("Sign in to access all of Cigar AI's features")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onNext()
                    print("OB2_AuthOptions: Continue with Email tapped")
                }) {
                    Text("Continue with Email")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(Color.cigarBrown)
                        .cornerRadius(10)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.95)
                }
                .padding(.bottom, 40)
                .accessibilityLabel("Continue with Email button")
            }
            .frame(maxWidth: .infinity)
            .background(Color.backgroundCream.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isVisible = true
                }
                print("OB2_AuthOptions: Appeared")
            }
        }
    }
}

struct OB2_AuthOptions_Previews: PreviewProvider {
    static var previews: some View {
        OB2_AuthOptions(onNext: {})
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}

