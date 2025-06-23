import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import RevenueCat

struct SettingsView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var errorMessage: String?
    @State private var showingPaywall = false

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    // Account Section
                    Section(header: Text("Account")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        if let user = Auth.auth().currentUser {
                            Text("Email: \(user.email ?? "N/A")")
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding(.vertical, 4)
                        }

                        NavigationLink(destination: ManageAccountView()) {
                            Text("Manage Account")
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding(.vertical, 4)
                        }

                        // Conditional Premium Button or Status
                        if viewModel.isSubscribed {
                            Button(action: {
                                showingPaywall = true
                            }) {
                                HStack {
                                    Text("Premium Member 👑")
                                        .font(.system(.body, design: .default, weight: .regular))
                                        .padding(.vertical, 4)
                                    Spacer()
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .accessibilityLabel("Manage your Premium Membership")
                        } else {
                            Button(action: {
                                showingPaywall = true
                            }) {
                                HStack {
                                    Text("Go Premium 👑")
                                        .font(.system(.body, design: .default, weight: .regular))
                                        .padding(.vertical, 4)
                                    Spacer()
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .accessibilityLabel("Go Premium to unlock all features")
                        }

                        Button(action: {
                            showingPaywall = true
                        }) {
                            HStack {
                                Text("Manage Subscriptions")
                                    .font(.system(.body, design: .default, weight: .regular))
                                    .padding(.vertical, 4)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.gray)
                            }
                        }
                        .accessibilityLabel("Manage your subscriptions")

                        Button(action: {
                            restorePurchases()
                        }) {
                            Text("Restore Purchases")
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding(.vertical, 4)
                        }
                        .accessibilityLabel("Restore your purchases")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // Support Section
                    Section(header: Text("Support")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Contact Support", destination: URL(string: "mailto:cigaraiapp@gmail.com")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Contact Support via Email")
                        Link("Visit Our Website", destination: URL(string: "https://www.cigar-ai.app")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Visit Website")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // Legal Section
                    Section(header: Text("Legal")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Terms of Use")
                        Link("Privacy Policy", destination: URL(string: "https://www.cigar-ai.app/r/privacy")!)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("Privacy Policy")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // Account Actions Section
                    Section(header: Text("Account Actions")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Button("Sign Out") {
                            showingLogoutAlert = true
                        }
                        .foregroundStyle(.red)
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding(.vertical, 4)
                        .alert("Sign Out", isPresented: $showingLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Sign Out", role: .destructive, action: signOut)
                        } message: {
                            Text("Are you sure you want to sign out?")
                        }

                        Button("Delete Account") {
                            showingDeleteAccountAlert = true
                        }
                        .foregroundStyle(.red)
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding(.vertical, 4)
                        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive, action: deleteAccount)
                        } message: {
                            Text("This will permanently delete your account and all associated data. Are you sure?")
                        }

                        if let error = errorMessage {
                            Text("Error: \(error)")
                                .font(.system(.subheadline, design: .default, weight: .regular))
                                .foregroundStyle(.red)
                        }

                        Button("Reset App State") {
                            resetAppState()
                            print("SettingsView: Debug reset app state triggered")
                        }
                        .foregroundStyle(.blue)
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // App Info Section
                    Section(header: Text("App Info")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // Disclaimer Section
                    Section(header: Text("Disclaimer")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Text("Cigar AI is intended solely for responsible adult cigar enthusiasts aged 18+. This app does not sell, promote, or encourage tobacco use. It exists to help users log and understand their cigar preferences for educational and record-keeping purposes.")
                            .font(.system(.footnote, design: .default, weight: .regular))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 6)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.backgroundCream)
                .listRowBackground(Color.backgroundCream)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.backgroundCream.ignoresSafeArea())
                .sheet(isPresented: $showingPaywall) {
                    PaywallView()
                        .environmentObject(viewModel)
                }
                .onAppear {
                    UITableView.appearance().sectionHeaderHeight = 8
                    UITableView.appearance().sectionFooterHeight = 8
                    print("SettingsView: Appeared")
                    // Sync subscription status
                    Purchases.shared.getCustomerInfo { customerInfo, error in
                        if let error = error {
                            print("SettingsView: Failed to fetch customer info - \(error.localizedDescription)")
                        } else if let customerInfo = customerInfo {
                            viewModel.isSubscribed = customerInfo.entitlements["premium_access"]?.isActive == true
                            print("SettingsView: Synced isSubscribed - \(viewModel.isSubscribed)")
                        }
                    }
                }
            }
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            resetAppState()
            print("SettingsView: User signed out, currentUser: \(Auth.auth().currentUser?.uid ?? "nil")")
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print("SettingsView: Sign-out failed - \(error.localizedDescription)")
        }
    }

    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            print("SettingsView: No user for deleteAccount")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("cigars").getDocuments { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                print("SettingsView: Delete account fetch failed - \(error.localizedDescription)")
                return
            }

            snapshot?.documents.forEach { document in
                document.reference.delete()
            }

            user.delete { error in
                if let error = error {
                    self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    print("SettingsView: Delete account failed - \(error.localizedDescription)")
                } else {
                    self.resetAppState()
                    print("SettingsView: Account deleted: \(user.uid)")
                }
            }
        }
    }

    private func restorePurchases() {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            } else if customerInfo?.entitlements["premium_access"]?.isActive == true {
                errorMessage = "Purchases restored successfully."
                self.viewModel.isSubscribed = true
            } else {
                errorMessage = "No active subscriptions found."
                self.viewModel.isSubscribed = false
            }
            print("SettingsView: Restore purchases - isSubscribed: \(self.viewModel.isSubscribed)")
        }
    }

    private func resetAppState() {
        viewModel.resetForSignOut()
        Firestore.firestore().clearPersistence { error in
            if let error = error {
                print("SettingsView: Failed to clear Firestore cache - \(error.localizedDescription)")
            } else {
                print("SettingsView: Cleared Firestore cache")
            }
        }
        // Set hasVerifiedAge to true to skip AgeGateView post-sign-out
        UserDefaults.standard.set(true, forKey: "hasVerifiedAge")
        Purchases.shared.logOut { customerInfo, error in
            if let error = error {
                print("RevenueCat logout failed: \(error.localizedDescription)")
            } else {
                print("RevenueCat logged out")
            }
        }
        print("SettingsView: Reset app state - hasCompletedOnboarding: \(viewModel.hasCompletedOnboarding)")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                SettingsView()
                    .environmentObject(CigarViewModel(isPreview: true))
            }
            .environment(\.colorScheme, .light)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .previewDisplayName("iPhone 14 Pro")

            NavigationView {
                SettingsView()
                    .environmentObject(CigarViewModel(isPreview: true))
            }
            .environment(\.colorScheme, .light)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .previewDisplayName("iPad Pro")
        }
    }
}

