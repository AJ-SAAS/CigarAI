import SwiftUI
import FirebaseAuth
import RevenueCat

struct AuthView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignUp: Bool = true
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showingResetPassword: Bool = false
    @State private var resetEmail: String = ""
    @State private var isVisible: Bool = false
    var onAuthComplete: (Bool) -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Image("CigarAILogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(geometry.size.width * 0.4, 200))
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : -20)
                        .accessibilityLabel("Cigar AI Logo")

                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityHeading(.h1)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 32)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Email input")

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Password input")

                    if isSignUp {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: min(geometry.size.width * 0.9, 600))
                            .padding(.horizontal, 32)
                            .opacity(isVisible ? 1 : 0)
                            .accessibilityLabel("Confirm password input")
                    }

                    Button(action: {
                        errorMessage = nil
                        if isSignUp {
                            if let validationError = validateSignUp() {
                                errorMessage = validationError
                                return
                            }
                            signUp()
                        } else {
                            if let validationError = validateSignIn() {
                                errorMessage = validationError
                                return
                            }
                            signIn()
                        }
                    }) {
                        HStack {
                            Text(isLoading ? "Processing..." : (isSignUp ? "Sign Up" : "Sign In"))
                                .font(.headline)
                                .foregroundColor(.white)
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: min(geometry.size.width * 0.8, 400))
                        .padding()
                        .background(isLoading ? .gray : Color.cigarBrown)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 32)
                    .opacity(isVisible ? 1 : 0)
                    .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && confirmPassword.isEmpty))
                    .accessibilityLabel(isSignUp ? "Sign Up button" : "Sign In button")

                    if !isSignUp {
                        Button("Forgot Password?") {
                            showingResetPassword = true
                        }
                        .font(.system(.body, design: .default, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityLabel("Forgot Password button")
                    }

                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            errorMessage = nil
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up")
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 32)
                    .opacity(isVisible ? 1 : 0)
                    .accessibilityLabel(isSignUp ? "Switch to Sign In" : "Switch to Sign Up")

                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(Color.backgroundCream.ignoresSafeArea())
            .sheet(isPresented: $showingResetPassword) {
                VStack(spacing: 20) {
                    Text("Reset Password")
                        .font(.system(.title2, design: .default, weight: .bold))
                        .padding(.top, 20)
                        .accessibilityHeading(.h1)

                    TextField("Enter your email", text: $resetEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .accessibilityLabel("Reset email input")

                    Button("Send Reset Email") {
                        if validateEmail(resetEmail) {
                            resetPassword()
                        } else {
                            errorMessage = "Please enter a valid email address."
                            showingResetPassword = false
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cigarBrown)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(resetEmail.isEmpty)
                    .accessibilityLabel("Send Reset Email button")

                    Button("Cancel") {
                        showingResetPassword = false
                        resetEmail = ""
                    }
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                    .accessibilityLabel("Cancel button")

                    Spacer()
                }
                .background(Color.backgroundCream.ignoresSafeArea())
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isVisible = true
                }
                print("AuthView: Appeared")
            }
        }
    }

    private func validateSignUp() -> String? {
        if !validateEmail(email) {
            return "Please enter a valid email address."
        }
        if password.count < 6 {
            return "Password must be at least 6 characters long."
        }
        if password != confirmPassword {
            return "Passwords do not match."
        }
        return nil
    }

    private func validateSignIn() -> String? {
        if !validateEmail(email) {
            return "Please enter a valid email address."
        }
        if password.isEmpty {
            return "Please enter a password."
        }
        return nil
    }

    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func signUp() {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = handleAuthError(error)
                    print("AuthView: Sign-up failed - \(error.localizedDescription)")
                } else if let user = result?.user {
                    viewModel.isNewUser = true
                    viewModel.hasCompletedOnboarding = false
                    viewModel.saveUserPreferences()
                    Purchases.shared.logIn(user.uid) { customerInfo, created, error in
                        if let error = error {
                            print("AuthView: RevenueCat login failed - \(error.localizedDescription)")
                        } else {
                            print("AuthView: RevenueCat logged in user: \(user.uid), created: \(created)")
                        }
                    }
                    onAuthComplete(true)
                    print("AuthView: Sign-up succeeded, user: \(user.uid)")
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
                    print("AuthView: Sign-in failed - \(error.localizedDescription)")
                } else if let user = result?.user {
                    viewModel.fetchUserPreferences()
                    Purchases.shared.logIn(user.uid) { customerInfo, created, error in
                        if let error = error {
                            print("AuthView: RevenueCat login failed - \(error.localizedDescription)")
                        } else {
                            print("AuthView: RevenueCat logged in user: \(user.uid), created: \(created)")
                        }
                    }
                    onAuthComplete(false)
                    print("AuthView: Sign-in succeeded, user: \(user.uid)")
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
                    print("AuthView: Password reset failed - \(error.localizedDescription)")
                } else {
                    errorMessage = "Password reset email sent successfully."
                    print("AuthView: Password reset email sent")
                }
                resetEmail = ""
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
        AuthView(onAuthComplete: { _ in })
            .environmentObject(CigarViewModel(isPreview: true))
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}

