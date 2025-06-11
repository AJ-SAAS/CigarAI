import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = true
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showingResetPassword: Bool = false
    @State private var resetEmail: String = ""
    @State private var isVisible = false
    @Binding var isAuthenticated: Bool

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        ProgressBar(currentStep: 3, totalSteps: 9) // Use the imported ProgressBar
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .padding(.top, geometry.size.width > 600 ? 40 : 24)
                            .opacity(isVisible ? 1 : 0)

                        Image("CigarAI_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : -20)
                            .accessibilityLabel("Cigar AI Logo")

                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.system(.title2, design: .default, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")

                        if isSignUp {
                            TextField("Name (optional)", text: $name)
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
                                .accessibilityLabel("Name")
                                .accessibilityHint("Enter your name, optional")
                        }

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("Email")

                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .disableAutocorrection(true)
                            .font(.system(.body, design: .default, weight: .regular))
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("Password")

                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .disableAutocorrection(true)
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding()
                                .background(.gray.opacity(0.1))
                                .cornerRadius(10)
                                .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .opacity(isVisible ? 1 : 0)
                                .accessibilityLabel("Confirm Password")
                        }

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(.subheadline, design: .default, weight: .regular))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                                .opacity(isVisible ? 1 : 0)
                                .accessibilityLabel("Error: \(error)")
                        }

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            isLoading = true
                            errorMessage = nil
                            if isSignUp {
                                if password == confirmPassword {
                                    signUp()
                                } else {
                                    errorMessage = "Passwords do not match."
                                    isLoading = false
                                }
                            } else {
                                signIn()
                            }
                        }) {
                            Text(isLoading ? "Processing..." : (isSignUp ? "Sign Up" : "Sign In"))
                                .font(.system(.headline, design: .default, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                                .padding()
                                .background(
                                    email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) || isLoading
                                        ? .gray
                                        : Color(red: 0.55, green: 0.27, blue: 0.07)
                                )
                                .cornerRadius(10)
                                .opacity(isVisible ? 1 : 0)
                                .scaleEffect(isVisible ? 1 : 0.95)
                        }
                        .disabled(email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty) || isLoading)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel(isSignUp ? "Sign Up" : "Sign In")

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            isSignUp.toggle()
                            errorMessage = nil
                            name = ""
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don’t have an account? Sign Up")
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")

                        Button("Forgot Password?") {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            showingResetPassword = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Forgot Password")
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
                }
                .sheet(isPresented: $showingResetPassword) {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 20) {
                        Text("Reset Password")
                            .font(.system(.title2, design: .default, weight: .bold))
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
                            .cornerRadius(10)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                            .accessibilityLabel("Reset Email")

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            resetPassword()
                        }) {
                            Text("Send Reset Email")
                                .font(.system(.headline, design: .default, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                                .padding()
                                .background(resetEmail.isEmpty ? .gray : Color(red: 0.55, green: 0.27, blue: 0.07))
                                .cornerRadius(10)
                        }
                        .disabled(resetEmail.isEmpty)
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .accessibilityLabel("Send Reset Email")

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            showingResetPassword = false
                            resetEmail = ""
                        }) {
                            Text("Cancel")
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, geometry.size.width > 600 ? 64 : 32)
                        .padding(.bottom, geometry.size.width > 600 ? 60 : 40)
                        .accessibilityLabel("Cancel")
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
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isVisible = true
                }
            }
        }
    }

    private func signUp() {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = handleAuthError(error)
                } else if let user = result?.user {
                    if !name.isEmpty {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = name
                        changeRequest.commitChanges { _ in
                            // Handle error if needed, but proceed regardless
                        }
                    }
                    print("Signed up user: \(user.uid), email: \(user.email ?? "unknown"), name: \(name.isEmpty ? "none" : name)")
                    isAuthenticated = true
                }
            }
        }
    }

    private func signIn() {
        isLoading = true
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
                    errorMessage = "Password reset email sent successfully."
                }
                resetEmail = ""
            }
        }
    }

    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Email already exists."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters long."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        default:
            return "Error: \(nsError.localizedDescription) (Code: \(nsError.code))"
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthView(isAuthenticated: .constant(false))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14 Preview")
            AuthView(isAuthenticated: .constant(false))
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
                .previewDisplayName("iPad Pro Preview")
        }
    }
}
