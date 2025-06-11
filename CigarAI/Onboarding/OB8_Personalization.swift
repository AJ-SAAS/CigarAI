import SwiftUI

struct OB8_Personalization: View {
    @EnvironmentObject private var viewModel: CigarViewModel
    var onNext: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: .zero) {
                ProgressBar(currentStep: 6, totalSteps: 9) // No import needed if in same target
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, geometry.size.width > 600 ? 40 : 24)
                    .opacity(isVisible ? 1 : 0)

                Text("Personalize Your Journey")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel("Personalize Your Journey")

                Text("Tell us about your cigar experience and flavor preferences.")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)

                ScrollView {
                    VStack(spacing: 16) {
                        Picker("How often do you smoke cigars?", selection: $viewModel.smokingFrequency) {
                            Text("Select").tag("")
                            Text("Daily").tag("Daily")
                            Text("Weekly").tag("Weekly")
                            Text("Monthly").tag("Monthly")
                            Text("Occasionally").tag("Occasionally")
                            Text("Rarely").tag("Rarely")
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Smoking Frequency Picker")

                        Picker("What's your experience level?", selection: $viewModel.experienceLevel) {
                            Text("Select").tag("")
                            Text("Beginner").tag("Beginner")
                            Text("Intermediate").tag("Intermediate")
                            Text("Advanced").tag("Advanced")
                            Text("Expert").tag("Expert")
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Experience Level Picker")

                        Text("Your goals? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Track inventory", "Log experiences", "Discover cigars", "Learn about cigars"], id: \.self) { goal in
                            Toggle(goal, isOn: Binding(
                                get: { viewModel.goals.contains(goal) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.goals.append(goal)
                                    } else {
                                        viewModel.goals.removeAll { $0 == goal }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(goal) Toggle")
                        }

                        Text("Favorite flavors? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Earthy", "Chocolate", "Spicy", "Creamy"], id: \.self) { flavor in
                            Toggle(flavor, isOn: Binding(
                                get: { viewModel.flavorPreferences.contains(flavor) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.flavorPreferences.append(flavor)
                                    } else {
                                        viewModel.flavorPreferences.removeAll { $0 == flavor }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(flavor) Toggle")
                        }

                        Picker("Preferred cigar strength?", selection: $viewModel.cigarStrength) {
                            Text("Select").tag("")
                            Text("Mild").tag("Mild")
                            Text("Medium").tag("Medium")
                            Text("Full").tag("Full")
                            Text("No preference").tag("No preference")
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Cigar Strength Picker")
                    }
                    .padding(.vertical)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        viewModel.smokingFrequency = ""
                        viewModel.experienceLevel = ""
                        viewModel.goals = []
                        viewModel.flavorPreferences = []
                        viewModel.cigarStrength = ""
                        onNext()
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
                        onNext()
                    }) {
                        Text("Next")
                            .font(.system(.headline, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding()
                            .background(
                                viewModel.smokingFrequency.isEmpty || viewModel.experienceLevel.isEmpty || viewModel.cigarStrength.isEmpty
                                    ? .gray
                                    : Color(red: 0.55, green: 0.27, blue: 0.07)
                            )
                            .cornerRadius(10)
                            .opacity(isVisible ? 1 : 0)
                            .scaleEffect(isVisible ? 1.0 : 0.95)
                    }
                    .disabled(viewModel.smokingFrequency.isEmpty || viewModel.experienceLevel.isEmpty || viewModel.cigarStrength.isEmpty)
                    .accessibilityLabel("Next Button")
                }
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.height > 600 ? 60 : 40)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.27, blue: 0.07).opacity(0.2), .white],
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

struct OB8_Personalization_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OB8_Personalization(onNext: {})
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OB8_Personalization(onNext: {})
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
