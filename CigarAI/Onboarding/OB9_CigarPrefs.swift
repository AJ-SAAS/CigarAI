import SwiftUI

struct OB9_CigarPrefs: View {
    @EnvironmentObject private var viewModel: CigarViewModel
    var onNext: () -> Void
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                ProgressBar(currentStep: 7, totalSteps: 9)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, geometry.size.width > 600 ? 40 : 24)
                    .opacity(isVisible ? 1 : 0)

                Text("Cigar Preferences")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel("Cigar Preferences")

                Text("What types of cigars and pairings do you enjoy?")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Preferred cigar sizes? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Robusto", "Toro", "Churchill", "No preference"], id: \.self) { size in
                            Toggle(size, isOn: Binding(
                                get: { viewModel.cigarSizes.contains(size) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.cigarSizes.append(size)
                                    } else {
                                        viewModel.cigarSizes.removeAll { $0 == size }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(size) Toggle")
                        }

                        Text("Preferred wrapper types? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Connecticut", "Maduro", "Habano", "No preference"], id: \.self) { wrapper in
                            Toggle(wrapper, isOn: Binding(
                                get: { viewModel.weights.contains(wrapper) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.weights.append(wrapper)
                                    } else {
                                        viewModel.weights.removeAll { $0 == wrapper }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(wrapper) Toggle")
                        }

                        Text("Preferred origins? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Nicaragua", "Dominican Republic", "Cuba", "No preference"], id: \.self) { origin in
                            Toggle(origin, isOn: Binding(
                                get: { viewModel.originPreferences.contains(origin) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.originPreferences.append(origin)
                                    } else {
                                        viewModel.originPreferences.removeAll { $0 == origin }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(origin) Toggle")
                        }

                        Text("Favorite beverage pairings? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Bourbon", "Coffee", "Wine", "None"], id: \.self) { beverage in
                            Toggle(beverage, isOn: Binding(
                                get: { viewModel.beveragePreferences.contains(beverage) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.beveragePreferences.append(beverage)
                                    } else {
                                        viewModel.beveragePreferences.removeAll { $0 == beverage }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(beverage) Toggle")
                        }

                        Text("Smoking context? (Select all)")
                            .font(.system(.headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)

                        ForEach(["Relaxing", "Social", "Work", "No preference"], id: \.self) { context in
                            Toggle(context, isOn: Binding(
                                get: { viewModel.smokingContext.contains(context) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.smokingContext.append(context)
                                    } else {
                                        viewModel.smokingContext.removeAll { $0 == context }
                                    }
                                }
                            ))
                            .padding(.horizontal)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("\(context) Toggle")
                        }
                    }
                    .padding(.vertical)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        viewModel.cigarSizes = []
                        viewModel.weights = []
                        viewModel.originPreferences = []
                        viewModel.beveragePreferences = []
                        viewModel.smokingContext = []
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
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding()
                            .background(Color(red: 0.55, green: 0.27, blue: 0.07))
                            .cornerRadius(10)
                            .opacity(isVisible ? 1 : 0)
                            .scaleEffect(isVisible ? 1 : 0.95)
                    }
                    .accessibilityLabel("Next Button")
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

struct OB9_CigarPrefs_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OB9_CigarPrefs(onNext: {})
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
            OB9_CigarPrefs(onNext: {})
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro")
        }
    }
}
