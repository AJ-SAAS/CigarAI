import SwiftUI

struct OB13_ConciergePrefs: View {
    @EnvironmentObject private var viewModel: CigarViewModel
    var onCompletion: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                ProgressBar(currentStep: 9, totalSteps: 9)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, geometry.size.width > 600 ? 40 : 24)
                    .opacity(isVisible ? 1 : 0)

                Text("Cigar Concierge")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel("Cigar Concierge")

                Text("How can our AI concierge assist you?")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)

                ScrollView {
                    VStack(spacing: 16) {
                        Text("What assistance do you want? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Cigar recommendations", "Pairing suggestions", "Cigar education"], id: \.self) { pref in
                            Toggle(pref, isOn: Binding(
                                get: { viewModel.conciergePreferences.contains(pref) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.conciergePreferences.append(pref)
                                    } else {
                                        viewModel.conciergePreferences.removeAll { $0 == pref }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(pref) Toggle")
                        }
                    }
                    .padding(.vertical)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        viewModel.conciergePreferences = []
                        viewModel.saveUserPreferences()
                        onCompletion()
                    }) {
                        Text("Skip")
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                            .opacity(isVisible ? 1 : 0)
                            .scaleEffect(isVisible ? 1 : 0.95)
                    }
                    .accessibilityLabel("Skip Button")

                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        viewModel.saveUserPreferences()
                        onCompletion()
                    }) {
                        Text("Finish")
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding()
                            .background(Color(red: 0.55, green: 0.27, blue: 0.07))
                            .cornerRadius(10)
                            .opacity(isVisible ? 1 : 0)
                            .scaleEffect(isVisible ? 1 : 0.95)
                    }
                    .accessibilityLabel("Finish Button")
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
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

struct OB13_ConciergePrefs_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OB13_ConciergePrefs(onCompletion: {})
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OB13_ConciergePrefs(onCompletion: {})
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
