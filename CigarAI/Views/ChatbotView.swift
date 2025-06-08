import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

struct ChatbotView: View {
    @State private var userInput = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isLoading = false
    @FocusState private var isInputFocused: Bool
    private let aiService = AIService()

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(chatMessages) { message in
                                    HStack {
                                        if message.isUser {
                                            Spacer()
                                            Text(message.text)
                                                .padding(12)
                                                .background(Color.blue.opacity(0.8))
                                                .foregroundColor(.white)
                                                .cornerRadius(16)
                                                .frame(maxWidth: min(geometry.size.width * 0.6, 250), alignment: .trailing)
                                                .accessibilityLabel("User: \(message.text)")
                                        } else {
                                            Text(message.text)
                                                .padding(12)
                                                .background(Color.gray.opacity(0.2))
                                                .foregroundColor(.black)
                                                .cornerRadius(16)
                                                .frame(maxWidth: min(geometry.size.width * 0.6, 250), alignment: .leading)
                                                .accessibilityLabel("Concierge: \(message.text)")
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                }

                                if isLoading {
                                    HStack {
                                        ProgressView()
                                        Text("Cigar Concierge is thinking...")
                                            .font(.system(.subheadline, design: .default, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                    .accessibilityLabel("Loading response")
                                }
                            }
                            .padding(.vertical, geometry.size.width > 600 ? 24 : 16)
                        }
                        .background(Color(.systemGroupedBackground))
                        .onChange(of: chatMessages.count) { // Updated syntax
                            withAnimation {
                                proxy.scrollTo(chatMessages.last?.id, anchor: .bottom)
                            }
                        }
                    }

                    Divider()

                    HStack(spacing: 12) {
                        TextField("Ask about cigars, suggestions, history...", text: $userInput)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .font(.system(.body, design: .default, weight: .regular))
                            .focused($isInputFocused)
                            .accessibilityLabel("Ask the Cigar Concierge")
                            .accessibilityHint("Enter questions about cigars, suggestions, or history")

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading ? .gray : .black)
                                .accessibilityLabel("Send message")
                        }
                        .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                }
                .navigationTitle("Cigar Concierge")
                .background(Color(.systemBackground).ignoresSafeArea())
                .onAppear {
                    isInputFocused = true
                }
            }
        }
    }

    private func sendMessage() {
        let prompt = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        chatMessages.append(ChatMessage(isUser: true, text: prompt))
        userInput = ""
        isLoading = true
        isInputFocused = true

        aiService.getAIResponse(prompt: prompt) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    chatMessages.append(ChatMessage(isUser: false, text: response))
                case .failure(let error):
                    let errorMsg: String
                    if case NetworkError.apiKeyMissing = error {
                        errorMsg = "Cigar Concierge is unavailable. Please try again later."
                    } else {
                        errorMsg = "Error: Unable to get a response. Please check your internet connection."
                    }
                    chatMessages.append(ChatMessage(isUser: false, text: errorMsg))
                }
            }
        }
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatbotView()
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            ChatbotView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}
