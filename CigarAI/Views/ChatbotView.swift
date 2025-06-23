import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

struct ChatbotView: View {
    private let aiService: AIService
    @State private var userInput = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var errorToast: String?
    @FocusState private var isInputFocused: Bool

    init(aiService: AIService = AIService()) {
        self.aiService = aiService
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(chatMessages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }

                            if isLoading {
                                LoadingView()
                            }
                        }
                        .padding(.vertical, 24)
                    }
                    .background(Color.appBackground)
                    .onChange(of: chatMessages.count) {
                        withAnimation {
                            proxy.scrollTo(chatMessages.last?.id, anchor: .bottom)
                        }
                    }
                }

                // Suggested Questions
                SuggestedQuestionsView(userInput: $userInput, sendMessage: sendMessage)

                // Input Area
                InputAreaView(
                    userInput: $userInput,
                    isInputFocused: _isInputFocused,
                    isLoading: isLoading,
                    sendMessage: sendMessage
                )
            }
            .navigationTitle("Concierge")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.appBackground)
            .onAppear {
                isInputFocused = true
                if chatMessages.isEmpty {
                    chatMessages.append(ChatMessage(isUser: false, text: """
                    Welcome to the Concierge! I'm here to educate you about sticks, flavor profiles, pairings, and storage tips. Ask about characteristics, wrapper types, or tap a suggested question below to learn more. This app is for informational purposes only and does not promote cigar use.
                    """))
                }
            }
            .overlay(
                errorToast != nil ?
                    VStack {
                        Text(errorToast!)
                            .padding()
                            .background(.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 20)
                        Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            errorToast = nil
                        }
                    }
                    .onTapGesture {
                        errorToast = nil
                    }
                : nil
            )
        }
    }

    private func sendMessage() {
        let prompt = userInput.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty else { return }

        chatMessages.append(ChatMessage(isUser: true, text: prompt))
        userInput = ""
        isLoading = true
        isInputFocused = true

        let timeout = DispatchWorkItem {
            if isLoading {
                isLoading = false
                errorToast = "Request timed out. Please try again."
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeout)

        aiService.getAIResponse(prompt: prompt) { result in
            DispatchQueue.main.async {
                timeout.cancel()
                isLoading = false
                switch result {
                case .success(let response):
                    chatMessages.append(ChatMessage(isUser: false, text: response))
                case .failure(let error):
                    let errorMessage: String
                    switch error {
                    case NetworkError.apiKeyMissing:
                        errorMessage = "Configuration issue. Please contact support."
                    case NetworkError.unauthorized:
                        errorMessage = "Invalid API key. Please check your OpenAI configuration."
                    case NetworkError.rateLimitExceeded:
                        errorMessage = "API limit reached. Please top up your OpenAI account."
                    case NetworkError.invalidURL, NetworkError.invalidResponse, NetworkError.noData:
                        errorMessage = "Network issue. Please check your connection and try again."
                    case NetworkError.decodingError:
                        errorMessage = "Unable to process response. Try again later."
                    default:
                        errorMessage = "Something went wrong. Try a suggested question or ask again."
                    }
                    errorToast = errorMessage
                }
            }
        }
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(.brown)
                    .foregroundColor(.white)
                    .font(.system(.body, design: .default, weight: .bold))
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.leading, 80)
                    .accessibilityLabel("You: \(message.text)")
                    .accessibilityAddTraits(.isStaticText)
            } else {
                Text(message.text)
                    .padding(12)
                    .background(.white)
                    .foregroundColor(.textDark)
                    .font(.system(.body, design: .default, weight: .regular))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.brown.opacity(0.2), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 80)
                    .accessibilityLabel("Concierge: \(message.text)")
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .padding(.horizontal, 24)
    }
}

struct LoadingView: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.brown)
            Text("Concierge is preparing a response...")
                .font(.system(.callout, design: .default, weight: .regular))
                .foregroundColor(.textDark.opacity(0.6))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .accessibilityLabel("Loading response")
    }
}

struct SuggestedQuestionsView: View {
    @Binding var userInput: String
    let sendMessage: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([
                    "What are beginner-friendly characteristics?",
                    "How to pair with whiskey?",
                    "How to store sticks properly?",
                    "What’s a Macanudo Cafe like?"
                ], id: \.self) { question in
                    Button(action: {
                        userInput = question
                        sendMessage()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Text(question)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.suggestedChip)
                            .foregroundColor(.textDark)
                            .font(.system(.callout, design: .default, weight: .medium))
                            .cornerRadius(20)
                            .minimumScaleFactor(0.8)
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                    .accessibilityLabel("Suggested question: \(question)")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(.white)
    }
}

struct InputAreaView: View {
    @Binding var userInput: String
    @FocusState var isInputFocused: Bool
    let isLoading: Bool
    let sendMessage: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask about flavors, pairings, or tips...", text: $userInput)
                .padding(12)
                .background(.white)
                .foregroundColor(.textDark)
                .font(.system(.body, design: .default, weight: .regular))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isInputFocused ? .brown : .textDark.opacity(0.2), lineWidth: 1)
                )
                .focused($isInputFocused)
                .accessibilityLabel("Ask the Concierge")
                .accessibilityHint("Enter questions about flavors, pairings, or tips")

            Button(action: {
                sendMessage()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .background(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading ? .gray.opacity(0.3) : .brown)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .frame(minWidth: 48, minHeight: 48)
            .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ChatbotView(aiService: MockAIService())
            }
            .previewDevice("iPhone 14 Pro")
            .previewDisplayName("iPhone 14 Pro")
            
            NavigationView {
                ChatbotView(aiService: MockAIService())
            }
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewDisplayName("iPad Pro")
        }
    }
}

