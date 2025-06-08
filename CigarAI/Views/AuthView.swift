import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = true
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showingResetPassword: Bool = false
    @State private var resetEmail: String = ""
    @Binding var isAuthenticated: Bool

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        // Logo
                        Image("CigarAI_logo") // Use your actual logo asset
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .padding(.top, geometry.size.width > 600 ? 40 : 24)
                            .accessibilityLabel("Cigar AI Logo")

                        // Title
                        Text(isSignUp ? "Create an Account" : "Login")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel(isSignUp ? "Create an Account" : "Login")

                        // Name Field (Sign Up only)
                        if isSignUp {
                            TextField("Name", text: $email) // Add name field for Sign-Up
                                .textContentType(.name)
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Name")
                                .accessibilityHint("Enter your name")
                        }

                        // Email Field
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Email")
                            .accessibilityHint("Enter your email address")

                        // Password Field
                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Password")
                            .accessibilityHint("Enter your password")

                        // Confirm Password Field (Sign Up only)
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .disableAutocorrection(true)
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Confirm Password")
                                .accessibilityHint("Re-enter your password")
                        }

                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(.subheadline, design: .default, weight: .regular))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .accessibilityLabel("Error: \(error)")
                        }

                        // Sign Up/Sign In Button
                        Button(action: {
                            isLoading = true
                            errorMessage = nil
                            if isSignUp {
                                if password == confirmPassword {
                                    signUp()
                                } else {
                                    errorMessage = "Passwords do not match"
                                    isLoading = false
                                }
                            } else {
                                signIn()
                            }
                        }) {
                            Text(isLoading ? "Processing..." : (isSignUp ? "Sign Up" : "Login"))
                                .font(.system(.headline, design: .default, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                                .padding()
                                .background(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) || isLoading ? .gray : .blue)
                                .cornerRadius(8)
                        }
                        .disabled(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) || isLoading)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Sign Up" : "Login")
                        .accessibilityHint(isSignUp ? "Creates a new account" : "Logs into your account")

                        // Social Login Buttons
                        Button(action: {
                            // Implement Sign In with Apple
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text(isSignUp ? "Sign Up with Apple" : "Login with Apple")
                            }
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Sign Up with Apple" : "Login with Apple")

                        Button(action: {
                            // Implement Sign In with Facebook
                        }) {
                            HStack {
                                Image(systemName: "f.circle.fill")
                                Text(isSignUp ? "Sign Up with Facebook" : "Login with Facebook")
                            }
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Sign Up with Facebook" : "Login with Facebook")

                        // Toggle Sign Up/Sign In
                        Button(action: {
                            isSignUp.toggle()
                            errorMessage = nil
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }) {
                            Text(isSignUp ? "Already have an account? Login" : "Don’t have an account? Sign Up")
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Switch to Login" : "Switch to Sign Up")

                        // Forgot Password
                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Forgot Password")
                        .accessibilityHint("Opens password reset form")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                }
                .background(Color.white.ignoresSafeArea())
                .sheet(isPresented: $showingResetPassword) {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        Text("Reset Password")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Reset Password")

                        TextField("Email", text: $resetEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Reset Email")
                            .accessibilityHint("Enter email for password reset")

                        Button(action: {
                            resetPassword()
                        }) {
                            Text("Send Reset Email")
                                .font(.system(.headline, design: .default, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                                .padding()
                                .background(resetEmail.isEmpty ? .gray : .blue)
                                .cornerRadius(8)
                        }
                        .disabled(resetEmail.isEmpty)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel("Send Reset Email")

                        Button("Cancel") {
                            showingResetPassword = false
                            resetEmail = ""
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Cancel")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
                    .background(Color.white.ignoresSafeArea())
                }
                .onChange(of: email) { _ in
                    errorMessage = nil
                }
                .onChange(of: isSignUp) { _ in
                    errorMessage = nil
                }
            }
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = handleAuthError(error)
                } else if let user = result?.user {
                    print("Signed up user: \(user.uid), email: \(user.email ?? "unknown")")
                    isAuthenticated = true
                }
            }
        }
    }

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = handleAuthError(error)
                } else if let user = result?.user {
                    print("Signed in user: \(user.uid), email: \(user.email ?? "unknown")")
                    isAuthenticated = true
                }
            }
        }
    }

    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
            DispatchQueue.main.async {
                showingResetPassword = false
                if let error = error {
                    errorMessage = handleAuthError(error)
                } else {
                    errorMessage = "Password reset email sent."
                }
                resetEmail = ""
            }
        }
    }

    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Email already in use."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found for this email."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        default:
            return "Error: \(nsError.localizedDescription)"
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthView(isAuthenticated: .constant(false))
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            AuthView(isAuthenticated: .constant(false))
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}
