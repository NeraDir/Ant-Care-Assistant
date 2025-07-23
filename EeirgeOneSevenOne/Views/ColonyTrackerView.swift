import SwiftUI

struct ColonyTrackerView: View {
    @EnvironmentObject var colonyDataManager: ColonyDataManager
    @State private var selectedColony: Colony? = nil
    @State private var showingAddColony = false
    
    var body: some View {
        NavigationView {
            if colonyDataManager.colonies.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("No Colonies Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start tracking your ant colonies by adding your first colony to monitor their growth and health.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("Add First Colony") {
                        showingAddColony = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(colonyDataManager.colonies) { colony in
                    ColonyRowView(colony: colony)
                        .onTapGesture {
                            selectedColony = colony
                        }
                }
                .navigationTitle("My Colonies")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Add") {
                            showingAddColony = true
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedColony) { colony in
            ColonyDetailView(colony: colony)
                .environmentObject(colonyDataManager)
        }
        .sheet(isPresented: $showingAddColony) {
            AddColonyView()
                .environmentObject(colonyDataManager)
        }
    }
}

struct ColonyRowView: View {
    let colony: Colony
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(colony.name)
                        .font(.headline)
                    Text(colony.species)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Founded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(colony.foundedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                PopulationBadge(title: "Queens", count: colony.queenCount, color: .purple)
                PopulationBadge(title: "Workers", count: colony.workerCount, color: .blue)
                PopulationBadge(title: "Larvae", count: colony.larvae, color: .orange)
                PopulationBadge(title: "Eggs", count: colony.eggs, color: .green)
                Spacer()
            }
            
            if let lastFed = colony.lastFed {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                    Text("Last fed: \(lastFed, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PopulationBadge: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.caption)
                .bold()
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(6)
    }
}

struct ColonyDetailView: View {
    let colony: Colony
    @EnvironmentObject var colonyDataManager: ColonyDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddLog = false
    @State private var newLogActivity: LogActivity = .feeding
    @State private var newLogNotes = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Colony header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(colony.name)
                                    .font(.title)
                                    .bold()
                                Text(colony.species)
                                    .font(.title3)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Founded")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(colony.foundedDate, style: .date)
                                    .font(.subheadline)
                                    .bold()
                            }
                        }
                        
                        if !colony.notes.isEmpty {
                            Text(colony.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Population stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Population")
                            .font(.headline)
                        
                        HStack {
                            PopulationDetailCard(title: "Queens", count: colony.queenCount, color: .purple)
                            PopulationDetailCard(title: "Workers", count: colony.workerCount, color: .blue)
                        }
                        
                        HStack {
                            PopulationDetailCard(title: "Larvae", count: colony.larvae, color: .orange)
                            PopulationDetailCard(title: "Pupae", count: colony.pupae, color: .red)
                        }
                        
                        HStack {
                            PopulationDetailCard(title: "Eggs", count: colony.eggs, color: .green)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Environment
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Environment")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Temperature")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(colony.temperatureRange)
                                    .font(.subheadline)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Humidity")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(colony.humidityRange)
                                    .font(.subheadline)
                                    .bold()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                    
                    // Recent activity
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Activity Log")
                                .font(.headline)
                            Spacer()
                            Button("Add Log") {
                                showingAddLog = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        ForEach(colony.logs.prefix(5)) { log in
                            LogRowView(log: log)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Colony Detail")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddLog) {
            NavigationView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Type")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(LogActivity.allCases, id: \.self) { activity in
                                Button(action: {
                                    newLogActivity = activity
                                }) {
                                    Text(activity.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(newLogActivity == activity ? Color.blue : Color.white)
                                        .foregroundColor(newLogActivity == activity ? .white : .primary)
                                        .cornerRadius(12)
                                        .shadow(color: newLogActivity == activity ? Color.clear : Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(newLogActivity == activity ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        TextField("Enter notes about this activity...", text: $newLogNotes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Add Log Entry")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Cancel") {
                            showingAddLog = false
                            newLogNotes = ""
                        }
                    }
                    
                    ToolbarItem(placement: .automatic) {
                        Button("Save") {
                            let log = ColonyLog(
                                date: Date(),
                                activity: newLogActivity,
                                notes: newLogNotes
                            )
                            colonyDataManager.addLog(to: colony.id, log: log)
                            showingAddLog = false
                            newLogNotes = ""
                        }
                        .disabled(newLogNotes.isEmpty)
                    }
                }
            }
        }
    }
}

struct PopulationDetailCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct LogRowView: View {
    let log: ColonyLog
    
    var body: some View {
        HStack {
            Image(systemName: iconForActivity(log.activity))
                .foregroundColor(colorForActivity(log.activity))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.activity.rawValue)
                    .font(.subheadline)
                    .bold()
                Text(log.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(log.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func iconForActivity(_ activity: LogActivity) -> String {
        switch activity {
        case .feeding: return "leaf.fill"
        case .cleaning: return "sparkles"
        case .observation: return "eye.fill"
        case .breeding: return "heart.fill"
        case .maintenance: return "wrench.fill"
        case .medical: return "cross.fill"
        }
    }
    
    private func colorForActivity(_ activity: LogActivity) -> Color {
        switch activity {
        case .feeding: return .green
        case .cleaning: return .blue
        case .observation: return .orange
        case .breeding: return .pink
        case .maintenance: return .gray
        case .medical: return .red
        }
    }
}

struct AddColonyView: View {
    @EnvironmentObject var colonyDataManager: ColonyDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var species = ""
    @State private var queenCount = 1
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Colony Name", text: $name)
                    TextField("Species", text: $species)
                    Stepper("Queens: \(queenCount)", value: $queenCount, in: 1...10)
                }
                
                Section("Notes") {
                    TextField("Additional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Colony")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        let colony = Colony(
                            name: name,
                            species: species,
                            foundedDate: Date(),
                            queenCount: queenCount,
                            workerCount: 0,
                            larvae: 0,
                            pupae: 0,
                            eggs: 0,
                            notes: notes,
                            logs: [],
                            temperatureRange: "22-25°C",
                            humidityRange: "60-70%"
                        )
                        colonyDataManager.addColony(colony)
                        dismiss()
                    }
                    .disabled(name.isEmpty || species.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ColonyTrackerView()
        .environmentObject(ColonyDataManager())
} 