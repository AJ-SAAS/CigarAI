import SwiftUI

struct OB3_ValueCarousel: View {
    @EnvironmentObject var viewModel: CigarViewModel
    let onGetStarted: () -> Void
    @State private var currentIndex = 0
    @State private var isVisible = true // Initialize to true to prevent flash

    let items: [(image: String, title: String, description: String)] = [
        ("cscreen1", "Welcome to Your Tasting Companion.", "Discover a world of rich taste, tradition, and exploration tailored to your preferences."),
        ("cscreen2", "Track Your Collection", "Log your sticks, monitor your humidor, and keep your inventory organized with ease."),
        ("cscreen3", "Learn from Experts", "Access detailed tasting notes, brand histories, and aging insights to elevate your experience."),
        ("cscreen4", "Your Personal Concierge", "Our AI-powered concierge is here to guide you, answer questions, and enhance your experience.")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundCream
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(items[currentIndex].image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(geometry.size.width * 0.9, 400))
                        .padding(.top, 40)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : -20)

                    Text(items[currentIndex].title)
                        .font(.system(.title, design: .default, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)

                    Text(items[currentIndex].description)
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)

                    Spacer()

                    HStack(spacing: 8) {
                        ForEach(0..<items.count, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(index == currentIndex ? Color.cigarBrown : .gray.opacity(0.3))
                        }
                    }
                    .padding(.bottom, 20)

                    if currentIndex == items.count - 1 {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onGetStarted()
                            print("OB3_ValueCarousel: Get Started tapped")
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
                    } else {
                        Button(action: {
                            withAnimation {
                                currentIndex = min(currentIndex + 1, items.count - 1)
                                isVisible = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isVisible = true
                                }
                            }
                            print("OB3_ValueCarousel: Next slide \(currentIndex + 1)")
                        }) {
                            Text("Next")
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
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50, currentIndex < items.count - 1 {
                            withAnimation {
                                currentIndex += 1
                                isVisible = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isVisible = true
                                }
                            }
                            print("OB3_ValueCarousel: Swiped to next slide \(currentIndex + 1)")
                        } else if value.translation.width > 50, currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                                isVisible = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isVisible = true
                                }
                            }
                            print("OB3_ValueCarousel: Swiped to previous slide \(currentIndex + 1)")
                        }
                    }
            )
            .onAppear {
                print("OB3_ValueCarousel: Appeared on slide \(currentIndex + 1)")
            }
        }
    }
}

struct OB3_ValueCarousel_Previews: PreviewProvider {
    static var previews: some View {
        OB3_ValueCarousel(onGetStarted: {})
            .environmentObject(CigarViewModel(isPreview: true))
    }
}

