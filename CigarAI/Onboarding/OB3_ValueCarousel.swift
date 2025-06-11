import SwiftUI

struct OB3_ValueCarousel: View {
    var onNext: () -> Void
    @State private var isVisible = false
    @State private var selectedIndex = 0

    let valueProps = [
        (imageName: "cigar_journal_mockup", title: "Log Every Smoke", text: "Track your smokes, flavor notes, and ratings in one simple journal."),
        (imageName: "flavor_wheel", title: "Find Your Palate", text: "Discover what you like based on cigars you enjoy and notes you log."),
        (imageName: "ai_chatbot", title: "Your AI Cigar Guide", text: "Get expert suggestions based on your taste — available 24/7."),
        (imageName: "elegant_cigar_scene", title: "Support the Craft", text: "By using Cigar AI, you're helping improve how cigars are rated, recommended, and enjoyed worldwide.")
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                ProgressBar(currentStep: 4, totalSteps: 9)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, geometry.size.width > 600 ? 40 : 24)
                    .opacity(isVisible ? 1 : 0)

                TabView(selection: $selectedIndex) {
                    ForEach(0..<valueProps.count, id: \.self) { index in
                        VStack(spacing: 16) {
                            Text(valueProps[index].title)
                                .font(.system(.title2, design: .default, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .opacity(isVisible ? 1 : 0)
                                .accessibilityLabel(valueProps[index].title)

                            Text(valueProps[index].text)
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .opacity(isVisible ? 1 : 0)

                            Spacer()

                            Image(valueProps[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: min(geometry.size.width * 0.9, 500))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : -20)
                                .accessibilityLabel("\(valueProps[index].title) Illustration")

                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: geometry.size.height * 0.7)

                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onNext()
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

struct OB3_ValueCarousel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OB3_ValueCarousel(onNext: {})
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OB3_ValueCarousel(onNext: {})
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
