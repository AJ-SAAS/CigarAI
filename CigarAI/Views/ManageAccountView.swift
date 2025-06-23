import SwiftUI
import FirebaseAuth

struct ManageAccountView: View {
    @State private var newEmail: String = ""
    @State private var currentPasswordForEmail: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var currentPasswordForPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading: Bool = false
    @State private var verificationEmailSent: Bool = false // Added to track verification email status
    
    var body: some View {
        GeometryReader { geometry in
            List {
                // Update Email Section
                Section(header: Text("Update Email")
                            .font(.system(.headline, design: .default, weight: .bold))) {
                    TextField("New Email", text: $newEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .accessibilityLabel("New email input")
                    
                    SecureField("Current Password", text: $currentPasswordForEmail)
                        .textContentType(.password)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .accessibilityLabel("Current password for email update")
                    
                    if verificationEmailSent {
                        Text("Verification email sent to \(newEmail). Please check your inbox.")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .accessibilityLabel("Verification email sent")
                    }
                    
                    Button(action: {
                        updateEmail()
                    }) {
                        Text(isLoading ? "Processing..." : "Update Email")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoading ? .gray : Color.cigarBrown)
                            .cornerRadius(10)
                    }
                    .disabled(isLoading || newEmail.isEmpty || currentPasswordForEmail.isEmpty || verificationEmailSent)
                    .accessibilityLabel("Update Email button")
                }
                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                
                // Update Password Section
                Section(header: Text("Update Password")
                            .font(.system(.headline, design: .default, weight: .bold))) {
                    SecureField("New Password", text: $newPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .accessibilityLabel("New password input")
                    
                    SecureField("Confirm New Password", text: $confirmNewPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .accessibilityLabel("Confirm new password input")
                    
                    SecureField("Current Password", text: $currentPasswordForPassword)
                        .textContentType(.password)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .accessibilityLabel("Current password for password update")
                    
                    Button(action: {
                        updatePassword()
                    }) {
                        Text(isLoading ? "Processing..." : "Update Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoading ? .gray : Color.cigarBrown)
                            .cornerRadius(10)
                    }
                    .disabled(isLoading || newPassword.isEmpty || confirmNewPassword.isEmpty || currentPasswordForPassword.isEmpty)
                    .accessibilityLabel("Update Password button")
                }
                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                
                // Messages Section
                if let error = errorMessage {
                    Section {
                        Text("Error: \(error)")
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundStyle(.red)
                            .accessibilityLabel("Error: \(error)")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
                
                if let success = successMessage {
                    Section {
                        Text(success)
                            .font(.system(.subheadline, design: .default, weight: .regular))
                            .foregroundStyle(.green)
                            .accessibilityLabel("Success: \(success)")
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.backgroundCream)
            .listRowBackground(Color.backgroundCream)
            .navigationTitle("Manage Account")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.backgroundCream.ignoresSafeArea())
            .onAppear {
                print("ManageAccountView: Appeared")
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func updateEmail() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            print("ManageAccountView: No user for email update")
            return
        }
        
        if !validateEmail(newEmail) {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Re-authenticate the user
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPasswordForEmail)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = handleAuthError(error)
                    print("ManageAccountView: Re-authentication failed for email update - \(error.localizedDescription)")
                }
                return
            }
            
            // Send verification email
            user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = handleAuthError(error)
                        print("ManageAccountView: Email verification failed - \(error.localizedDescription)")
                    } else {
                        verificationEmailSent = true
                        successMessage = "Verification email sent to \(newEmail). Please check your inbox."
                        print("ManageAccountView: Verification email sent to \(newEmail)")
                    }
                }
            }
        }
    }
    
    private func updatePassword() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            print("ManageAccountView: No user for password update")
            return
        }
        
        if newPassword.count < 6 {
            errorMessage = "New password must be at least 6 characters long"
            return
        }
        
        if newPassword != confirmNewPassword {
            errorMessage = "New passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Re-authenticate the user
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPasswordForPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = handleAuthError(error)
                    print("ManageAccountView: Re-authentication failed for password update - \(error.localizedDescription)")
                }
                return
            }
            
            // Update password
            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = handleAuthError(error)
                        print("ManageAccountView: Password update failed - \(error.localizedDescription)")
                    } else {
                        successMessage = "Password updated successfully"
                        print("ManageAccountView: Password updated successfully")
                    }
                }
            }
        }
    }
    
    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already in use."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect current password."
        case AuthErrorCode.weakPassword.rawValue:
            return "New password must be at least 6 characters long."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return "Please sign in again to update your account."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        default:
            return "Error: \(nsError.localizedDescription) (Code: \(nsError.code))"
        }
    }
}

struct ManageAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManageAccountView()
        }
        .environment(\.colorScheme, .light)
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        .previewDisplayName("iPhone 14 Pro")
    }
}

