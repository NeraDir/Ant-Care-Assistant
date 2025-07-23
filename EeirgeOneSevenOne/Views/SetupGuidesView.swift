import SwiftUI

struct SetupGuidesView: View {
    @EnvironmentObject var setupGuideDataManager: SetupGuideDataManager
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    
    @State private var selectedGuide: SetupGuide? = nil
    @State private var showingGenerateGuide = false
    @State private var guidePrompt = ""
    @State private var isGenerating = false
    @State private var generatedGuide: SetupGuide? = nil
    
    private func generateGuide() {
        guard !guidePrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isGenerating = true
        
        // Simulate AI generation with realistic data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let steps = [
                "Prepare a suitable formicarium or test tube setup",
                "Ensure proper temperature (75-80°F) and humidity (50-60%)",
                "Add a small water source and feeding area",
                "Introduce the queen ant carefully to the setup",
                "Monitor daily for signs of egg laying",
                "Maintain consistent environmental conditions",
                "Wait for first workers to emerge (4-8 weeks)",
                "Gradually expand the colony space as needed"
            ]
            
            let setupSteps = steps.map { stepTitle in
                SetupStep(
                    title: stepTitle,
                    description: "Follow this step carefully",
                    isCompleted: false,
                    imageSystemName: "checkmark.circle"
                )
            }
            
            let newGuide = SetupGuide(
                title: "AI Generated: \(guidePrompt)",
                description: "Step-by-step guide generated based on your specific requirements for ant colony setup.",
                steps: setupSteps,
                category: .housing,
                estimatedTime: "2-3 hours setup, 6-10 weeks for development",
                difficulty: .intermediate
            )
            
            setupGuideDataManager.addGuide(newGuide)
            isGenerating = false
            showingGenerateGuide = false
            guidePrompt = ""
        }
    }
    
    var body: some View {
        NavigationView {
            if setupGuideDataManager.guides.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("No Setup Guides Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create step-by-step guides for setting up new colonies, habitats, and equipment to help organize your ant keeping process.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Create First Guide") {
                        // Add new guide functionality would go here
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Setup Guides")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        HStack {
                            Button("Generate") {
                                showingGenerateGuide = true
                            }
                            .foregroundColor(.green)
                            
                            Button("Add") {
                                // Add new guide functionality would go here
                            }
                        }
                    }
                }
            } else {
                List(setupGuideDataManager.guides) { guide in
                    GuideRowView(guide: guide)
                        .onTapGesture {
                            selectedGuide = guide
                        }
                }
                .navigationTitle("Setup Guides")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        HStack {
                            Button("Generate") {
                                showingGenerateGuide = true
                            }
                            .foregroundColor(.green)
                            
                            Button("Add") {
                                // Add new guide functionality would go here
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedGuide) { guide in
            GuideDetailView(guide: guide)
                .environmentObject(setupGuideDataManager)
                .environmentObject(favoritesDataManager)
        }
        .sheet(isPresented: $showingGenerateGuide) {
            GenerateGuideView(
                guidePrompt: $guidePrompt,
                isGenerating: $isGenerating,
                onGenerate: generateGuide
            )
        }
    }
}

struct GuideRowView: View {
    let guide: SetupGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(guide.title)
                        .font(.headline)
                    Text(guide.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack {
                    DifficultyBadge(difficulty: guide.difficulty)
                    Text(guide.estimatedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            HStack {
                ProgressView(value: guide.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 4)
                
                Text("\(Int(guide.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 35)
            }
            
            if guide.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct GuideDetailView: View {
    let guide: SetupGuide
    @EnvironmentObject var setupGuideDataManager: SetupGuideDataManager
    @EnvironmentObject var favoritesDataManager: FavoritesDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var refreshTrigger = false
    
    var currentGuide: SetupGuide {
        _ = refreshTrigger // Force dependency on refreshTrigger
        return setupGuideDataManager.guides.first(where: { $0.id == guide.id }) ?? guide
    }
    
    var isFavorited: Bool {
        favoritesDataManager.isFavorited(referenceId: guide.id.uuidString, type: .guide)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(currentGuide.title)
                                    .font(.title)
                                    .bold()
                                Text(currentGuide.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack {
                            DifficultyBadge(difficulty: currentGuide.difficulty)
                            Text("Category: \(currentGuide.category.rawValue)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                            Text(currentGuide.estimatedTime)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Overall progress
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Overall Progress")
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                                Text("\(Int(currentGuide.progress * 100))%")
                                    .font(.subheadline)
                                    .bold()
                            }
                            ProgressView(value: currentGuide.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Steps
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.headline)
                        
                        ForEach(Array(currentGuide.steps.enumerated()), id: \.element.id) { index, step in
                            StepRowView(
                                step: step,
                                stepNumber: index + 1,
                                onToggle: { isCompleted in
                                    setupGuideDataManager.updateStepCompletion(
                                        guideId: currentGuide.id,
                                        stepId: step.id,
                                        isCompleted: isCompleted
                                    )
                                    refreshTrigger.toggle()
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Guide Detail")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        if isFavorited {
                            if let favorite = favoritesDataManager.favorites.first(where: { 
                                $0.referenceId == guide.id.uuidString && $0.type == .guide 
                            }) {
                                favoritesDataManager.removeFavorite(favorite.id)
                            }
                        } else {
                            let favorite = FavoriteItem(
                                type: .guide,
                                title: guide.title,
                                description: guide.description,
                                dateAdded: Date(),
                                referenceId: guide.id.uuidString
                            )
                            favoritesDataManager.addFavorite(favorite)
                        }
                    } label: {
                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                            .foregroundColor(isFavorited ? .red : .gray)
                    }
                }
            }
        }
    }
}

struct StepRowView: View {
    let step: SetupStep
    let stepNumber: Int
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(step.isCompleted ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                
                if step.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                } else {
                    Text("\(stepNumber)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: step.imageSystemName)
                        .foregroundColor(.blue)
                    Text(step.title)
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Button(step.isCompleted ? "Undo" : "Complete") {
                        onToggle(!step.isCompleted)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(step.isCompleted ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(step.isCompleted ? Color.green.opacity(0.1) : Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .cornerRadius(8)
    }
}

struct GenerateGuideView: View {
    @Binding var guidePrompt: String
    @Binding var isGenerating: Bool
    let onGenerate: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Generate Setup Guide")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Describe what kind of setup guide you need, and AI will generate a comprehensive step-by-step guide for you.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("What kind of setup guide do you need?")
                        .font(.headline)
                    
                    TextField("Example: Setting up a new Lasius niger colony, Building a formicarium, Preparing hibernation setup...", text: $guidePrompt, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if isGenerating {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Generating your custom setup guide...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: onGenerate) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Generate Guide")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(guidePrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating ? Color.gray.opacity(0.3) : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(guidePrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("AI Guide Generator")
        }
    }
}

#Preview {
    SetupGuidesView()
        .environmentObject(SetupGuideDataManager())
        .environmentObject(FavoritesDataManager())
} 