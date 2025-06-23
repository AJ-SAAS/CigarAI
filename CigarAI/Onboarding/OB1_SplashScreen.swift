import SwiftUI

struct OB1_SplashScreen: View {
    var onGetStarted: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundCream
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.2)

                    Image("Cicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.4, 280))
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : -20)

                    Spacer()
                        .frame(height: geometry.size.height * 0.05)

                    Text("Congratulations")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .opacity(isVisible ? 1 : 0)

                    Text("Your personal concierge is ready!")
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)

                    Spacer()

                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onGetStarted()
                        print("OB1_SplashScreen: Get Started tapped")
                    }) {
                        Text("Get Started")
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
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isVisible = true
                }
                print("OB1_SplashScreen: Appeared")
            }
        }
    }
}

struct OB1_SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        OB1_SplashScreen(onGetStarted: {})
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}

