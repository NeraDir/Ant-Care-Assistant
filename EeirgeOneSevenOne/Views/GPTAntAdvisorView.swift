import SwiftUI

struct GPTAntAdvisorView: View {
    @EnvironmentObject var openAIService: OpenAIService
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage = ""
    @State private var showingKeyboard = false
    
    var body: some View {
        NavigationView {
            VStack {
                if messages.isEmpty {
                    // Welcome screen
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("AI Ant Advisor")
                            .font(.title)
                            .bold()
                        
                        Text("Ask me anything about ant keeping! I'm here to help with colony management, species care, feeding advice, and more.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Try asking:")
                                .font(.headline)
                            
                            SampleQuestionView(question: "Why are my ants climbing the walls?")
                            SampleQuestionView(question: "How often should I feed my colony?")
                            SampleQuestionView(question: "What's the best substrate mix?")
                            SampleQuestionView(question: "My queen isn't laying eggs, what's wrong?")
                        }
                        .padding()
                        .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    // Chat interface
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    ChatBubbleView(message: message, onSaveToFavorites: { message in
                                        saveToFavorites(message)
                                    })
                                }
                                
                                if openAIService.isLoading {
                                    LoadingIndicatorView()
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages.count) { _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: openAIService.isLoading) { _ in
                            if let lastMessage = messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input area
                HStack {
                    TextField("Ask about ant care...", text: $currentMessage, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                        .disabled(openAIService.isLoading)
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || openAIService.isLoading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                                            .background(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || openAIService.isLoading ? Color.gray.opacity(0.3) : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .navigationTitle("AI Ant Advisor")
            .toolbar {
                if !messages.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button("Clear") {
                            messages.removeAll()
                        }
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Add user message
        let userChatMessage = ChatMessage(
            content: userMessage,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userChatMessage)
        currentMessage = ""
        
        // Get AI response
        Task {
            let response = await openAIService.getAntAdvice(question: userMessage)
            
            await MainActor.run {
                let aiMessage = ChatMessage(
                    content: response,
                    isFromUser: false,
                    timestamp: Date()
                )
                messages.append(aiMessage)
            }
        }
    }
    
    private func saveToFavorites(_ message: ChatMessage) {
        let favorite = FavoriteItem(
            type: .advice,
            title: "AI Advice",
            description: String(message.content.prefix(100)),
            dateAdded: Date(),
            referenceId: message.id.uuidString
        )
        favoritesDataManager.addFavorite(favorite)
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct ChatBubbleView: View {
    let message: ChatMessage
    let onSaveToFavorites: (ChatMessage) -> Void
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: 280, alignment: .trailing)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(message.content)
                                .padding()
                                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .cornerRadius(16)
                                .frame(maxWidth: 280, alignment: .leading)
                            
                            HStack {
                                Text(message.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    onSaveToFavorites(message)
                                }) {
                                    Image(systemName: "heart")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct LoadingIndicatorView: View {
    @State private var animationOffset: CGFloat = -100
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.green)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 8, height: 8)
                                .scaleEffect(0.6)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: animationOffset
                                )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(16)
                    
                    Text("AI is thinking...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .onAppear {
            animationOffset = 100
        }
    }
}

struct SampleQuestionView: View {
    let question: String
    
    var body: some View {
        HStack {
            Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text(question)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    GPTAntAdvisorView()
        .environmentObject(OpenAIService())
        .environmentObject(FavoritesDataManager())
} 