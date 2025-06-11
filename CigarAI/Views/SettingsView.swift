import SwiftUI
import FirebaseAuth
import FirebaseFirestore // Added import

struct SettingsView: View {
    @State private var showingLogoutAlert: Bool = false
    @State private var showingDeleteAccountAlert: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                List {
                    // Account Section
                    Section(header: Text("Account")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        if let user = Auth.auth().currentUser {
                            Text("Email: \(user.email ?? "N/A")")
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding(.vertical, 4)
                                .accessibilityLabel("Email: \(user.email ?? "Not available")")
                        }
                        NavigationLink("Manage Account") {
                            Text("Manage Account (Coming Soon)")
                                .font(.system(.title2, design: .default, weight: .bold))
                                .padding()
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .padding(.vertical, 4)
                        .accessibilityLabel("Manage Account")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // Support Section
                    Section(header: Text("Support")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Link("Contact Support", destination: URL(string: "mailto:support@cigarai.com")!)
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

                    // Account Actions
                    Section(header: Text("Account Actions")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Button("Sign Out") {
                            showingLogoutAlert = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Sign Out")
                        .alert("Sign Out", isPresented: $showingLogoutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Sign Out", role: .destructive) {
                                signOut()
                            }
                        } message: {
                            Text("Are you sure you want to sign out?")
                                .font(.system(.body, design: .default, weight: .regular))
                        }

                        Button("Delete Account") {
                            showingDeleteAccountAlert = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.red)
                        .padding(.vertical, 4)
                        .accessibilityLabel("Delete Account")
                        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                deleteAccount()
                            }
                        } message: {
                            Text("This will permanently delete your account and all associated data. Are you sure?")
                                .font(.system(.body, design: .default, weight: .regular))
                        }

                        if let error = errorMessage {
                            Text("Error: \(error)")
                                .font(.system(.subheadline, design: .default, weight: .regular))
                                .foregroundColor(.red)
                                .padding(.vertical, 4)
                                .accessibilityLabel("Error: \(error)")
                        }
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)

                    // App Info
                    Section(header: Text("App Info")
                                .font(.system(.headline, design: .default, weight: .bold))) {
                        Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding(.vertical, 4)
                            .accessibilityLabel("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
                .navigationTitle("Settings")
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                .background(Color.white.ignoresSafeArea())
            }
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out")
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print("Sign out error: \(error)")
        }
    }

    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            print("Delete account error: No user")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("cigars").getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                    print("Fetch cigars error: \(error)")
                }
                return
            }
            snapshot?.documents.forEach { document in
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting cigar \(document.documentID): \(error)")
                    }
                }
            }
            user.delete { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                        print("Delete account error: \(error)")
                    } else {
                        print("Account deleted: \(user.uid)")
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            SettingsView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}
