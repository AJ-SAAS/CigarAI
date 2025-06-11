import SwiftUI

struct OB12_InventoryTracking: View {
    // Environment and State
    @EnvironmentObject private var viewModel: CigarViewModel
    var onNext: () -> Void
    @State private var isVisible = false
    @State private var cigarName = ""
    @State private var quantity = ""

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                // Progress Bar
                ProgressBar(currentStep: 12, totalSteps: 12)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .padding(.top, geometry.size.width > 600 ? 40 : 24)
                    .opacity(isVisible ? 1 : 0)

                // Header
                Text("Set Up Inventory Tracking")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel("Set Up Inventory Tracking")

                // Subheader
                Text("Add your first cigar to start tracking your collection.")
                    .font(.system(.body, design: .default, weight: .regular))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                    .opacity(isVisible ? 1 : 0)

                // Input Fields
                VStack(spacing: 16) {
                    TextField("Cigar Name", text: $cigarName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Cigar Name")

                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Quantity")
                }
                .padding(.vertical)

                // Spacer
                Spacer()

                // Finish Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    if let qty = Int(quantity), !cigarName.isEmpty, qty > 0 {
                        viewModel.addInventoryItem(name: cigarName, quantity: qty)
                        onNext()
                    }
                }) {
                    Text("Finish")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(
                            cigarName.isEmpty || quantity.isEmpty || Int(quantity) == nil || (Int(quantity) ?? 0) <= 0
                                ? .gray
                                : Color(red: 0.55, green: 0.27, blue: 0.07)
                        )
                        .cornerRadius(10)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.95)
                }
                .disabled(cigarName.isEmpty || quantity.isEmpty || Int(quantity) == nil || (Int(quantity) ?? 0) <= 0)
                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                .accessibilityLabel("Finish Button")
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

struct OB12_InventoryTracking_Previews: PreviewProvider {
    static var previews: some View {
        OB12_InventoryTracking(onNext: {})
            .environmentObject(CigarViewModel(isPreview: true))
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
