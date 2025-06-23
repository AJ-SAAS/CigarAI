import SwiftUI
import RevenueCat

struct PaywallView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var purchaseModel: PurchaseModel
    @State private var selectedPackage: Package?

    init() {
        _purchaseModel = StateObject(wrappedValue: PurchaseModel())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Close Button
                    HStack {
                        Spacer()
                        Button(action: {
                            purchaseModel.isPurchasing = false
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    // Logo
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.brown)
                        .padding(.top, 4)
                        .padding(.bottom, 16)
                    
                    // Headline
                    Text("Taste. Track. Master Your Journey.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 8)
                    
                    // Subheadline
                    Text("Go beyond. Learn your palate. Keep every memory:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(text: "Unlimited logs")
                        FeatureRow(text: "Log flavors & ratings")
                        FeatureRow(text: "Find sticks you'll actually enjoy — Instantly")
                        FeatureRow(text: "Get expert notes to sharpen your taste")
                        FeatureRow(text: "Always know what's in your humidor")
                        FeatureRow(text: "Uncover the history behind rare brands")
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                    
                    // Offerings
                    if let error = purchaseModel.errorMessage {
                        VStack {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                            Button("Retry") {
                                purchaseModel.fetchOfferings()
                            }
                        }
                        .padding()
                    } else if let offering = purchaseModel.currentOffering {
                        VStack(spacing: 12) {
                            if let yearly = offering.annual {
                                PackageButton(
                                    title: "Yearly Plan",
                                    price: yearly.localizedPriceString,
                                    crossedOutPrice: "$259.88",
                                    badgeText: "SAVE 60%",
                                    isSelected: selectedPackage?.identifier == yearly.identifier,
                                    isWeeklyPlan: false
                                ) {
                                    selectedPackage = yearly
                                }
                            }
                            
                            if let weekly = offering.weekly {
                                PackageButton(
                                    title: "Weekly Plan",
                                    price: "Try free for 3 days — then just \(weekly.localizedPriceString)/week",
                                    badgeText: "FREE TRIAL",
                                    isSelected: selectedPackage?.identifier == weekly.identifier,
                                    isWeeklyPlan: true
                                ) {
                                    selectedPackage = weekly
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        ProgressView()
                            .padding()
                    }
                    
                    // Purchase Button
                    Button(action: {
                        guard let package = selectedPackage else { return }
                        purchaseModel.purchase(package: package)
                    }) {
                        HStack {
                            Text(purchaseModel.isPurchasing ? "Processing..." : "Unlock Everything")
                            if !purchaseModel.isPurchasing {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedPackage == nil || purchaseModel.isPurchasing ? Color.gray : Color.brown)
                        .cornerRadius(10)
                    }
                    .disabled(selectedPackage == nil || purchaseModel.isPurchasing)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Footer Links (now part of scrollable content)
                    HStack(spacing: 16) {
                        Button("Restore Purchases") {
                            purchaseModel.restorePurchases()
                        }
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .accessibilityLabel("Terms of Use")
                        Link("Privacy Policy", destination: URL(string: "https://www.cigar-ai.app/r/privacy")!)
                            .accessibilityLabel("Privacy Policy")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 32) // Extra padding at the bottom for spacing
                }
                .background(Color(hex: "#fefbf3"))
            }
            .background(Color(hex: "#fefbf3").ignoresSafeArea())
        }
        .onAppear {
            purchaseModel.fetchOfferings()
            if let yearly = purchaseModel.currentOffering?.annual {
                selectedPackage = yearly
            }
            purchaseModel.setCigarViewModel(viewModel)
        }
        .onChange(of: purchaseModel.currentOffering) { _, newValue in
            if selectedPackage == nil, let yearly = newValue?.annual {
                selectedPackage = yearly
            }
        }
        .onChange(of: viewModel.isSubscribed) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.brown)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct PackageButton: View {
    let title: String
    let price: String
    var crossedOutPrice: String?
    let badgeText: String?
    let isSelected: Bool
    let isWeeklyPlan: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        if let crossedOut = crossedOutPrice {
                            HStack(spacing: 4) {
                                Text(crossedOut)
                                    .strikethrough()
                                    .foregroundColor(.gray)
                                Text(price)
                            }
                            .font(.subheadline)
                        } else {
                            Text(price)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()

                    if let badgeText = badgeText {
                        Text(badgeText)
                            .font(isWeeklyPlan ? .subheadline : .caption)
                            .fontWeight(.bold)
                            .foregroundColor(isWeeklyPlan ? .black : .white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isWeeklyPlan ? Color.yellow : Color.red)
                            .cornerRadius(4)
                    }

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.brown)
                    } else {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.brown : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

