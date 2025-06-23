import SwiftUI

struct AgeGateView: View {
    @State private var showWarning = false
    var onVerified: () -> Void

    var body: some View {
        ZStack {
            Color.backgroundCream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Are you over 18?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 16) {
                    Button(action: {
                        onVerified()
                        print("AgeGateView: Verified over 18")
                    }) {
                        Text("Yes, I am over 18")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cigarBrown)
                            .cornerRadius(12)
                    }
                    .accessibilityLabel("Yes, I am over 18 button")

                    Button(action: {
                        withAnimation {
                            showWarning = true
                        }
                        print("AgeGateView: Selected under 18")
                    }) {
                        Text("No, I am under 18")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .accessibilityLabel("No, I am under 18 button")
                }

                if showWarning {
                    Text("You must be over 18 to use this app.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .transition(.opacity.combined(with: .scale))
                        .accessibilityLabel("Age restriction warning")
                }

                Spacer()

                Text("Disclaimer: Cigar AI is intended solely for responsible adult cigar enthusiasts aged 18+. This app does not sell, promote, or encourage tobacco use. It exists to help users log and understand their cigar preferences for educational and record-keeping purposes.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .accessibilityLabel("App disclaimer")
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("AgeGateView: Appeared")
        }
    }
}

struct AgeGateView_Previews: PreviewProvider {
    static var previews: some View {
        AgeGateView(onVerified: {})
    }
}

