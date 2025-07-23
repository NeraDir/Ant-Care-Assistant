import SwiftUI

struct MaterialCalculatorView: View {
    @State private var selectedCalculator: CalculatorType = .substrate
    
    var body: some View {
        NavigationView {
            VStack {
                // Calculator type picker
                Picker("Calculator Type", selection: $selectedCalculator) {
                    ForEach(CalculatorType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Calculator content
                Group {
                    switch selectedCalculator {
                    case .substrate:
                        SubstrateCalculatorView()
                    case .volume:
                        VolumeCalculatorView()
                    case .feeding:
                        FeedingCalculatorView()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Material Calculator")
        }
    }
}

enum CalculatorType: String, CaseIterable {
    case substrate = "Substrate"
    case volume = "Volume"
    case feeding = "Feeding"
}

struct SubstrateCalculatorView: View {
    @State private var sandPercentage: Double = 50
    @State private var clayPercentage: Double = 30
    @State private var soilPercentage: Double = 20
    @State private var totalVolume: String = ""
    @State private var results: SubstrateResult?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Substrate Ratio Calculator")
                        .font(.headline)
                    Text("Calculate the perfect substrate mix for your formicarium")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mixture Ratios")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Sand: \(Int(sandPercentage))%")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: $sandPercentage, in: 0...100, step: 5)
                                .accentColor(.yellow)
                        }
                        
                        HStack {
                            Text("Clay: \(Int(clayPercentage))%")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: $clayPercentage, in: 0...100, step: 5)
                                .accentColor(.brown)
                        }
                        
                        HStack {
                            Text("Soil: \(Int(soilPercentage))%")
                                .frame(width: 80, alignment: .leading)
                            Slider(value: $soilPercentage, in: 0...100, step: 5)
                                .accentColor(.green)
                        }
                    }
                    
                    let totalPercentage = sandPercentage + clayPercentage + soilPercentage
                    if totalPercentage != 100 {
                        Text("Total: \(Int(totalPercentage))% (should be 100%)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("Total: 100% ✓")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Volume Needed")
                        .font(.headline)
                    HStack {
                        TextField("Volume in cups", text: $totalVolume)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("cups")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                Button("Calculate") {
                    calculateSubstrate()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(totalVolume.isEmpty || sandPercentage + clayPercentage + soilPercentage != 100)
                
                if let results = results {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ResultRow(material: "Sand", amount: results.sandCups, color: .yellow)
                            ResultRow(material: "Clay", amount: results.clayCups, color: .brown)
                            ResultRow(material: "Soil", amount: results.soilCups, color: .green)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private func calculateSubstrate() {
        guard let volume = Double(totalVolume) else { return }
        
        results = SubstrateResult(
            sandCups: volume * (sandPercentage / 100),
            clayCups: volume * (clayPercentage / 100),
            soilCups: volume * (soilPercentage / 100)
        )
    }
}

struct VolumeCalculatorView: View {
    @State private var length: String = ""
    @State private var width: String = ""
    @State private var height: String = ""
    @State private var unit: VolumeUnit = .cm
    @State private var results: VolumeResult?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Formicarium Volume Calculator")
                        .font(.headline)
                    Text("Calculate the internal volume of your formicarium")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dimensions")
                        .font(.headline)
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(VolumeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Length")
                                .frame(width: 60, alignment: .leading)
                            TextField("0", text: $length)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text(unit.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Width")
                                .frame(width: 60, alignment: .leading)
                            TextField("0", text: $width)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text(unit.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Height")
                                .frame(width: 60, alignment: .leading)
                            TextField("0", text: $height)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text(unit.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                Button("Calculate Volume") {
                    calculateVolume()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(length.isEmpty || width.isEmpty || height.isEmpty)
                
                if let results = results {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Volume:")
                                    .bold()
                                Spacer()
                                Text("\(results.volume, specifier: "%.2f") \(results.volumeUnit)")
                            }
                            
                            HStack {
                                Text("Substrate needed:")
                                    .bold()
                                Spacer()
                                Text("\(results.substrateVolume, specifier: "%.2f") cups")
                            }
                            
                            HStack {
                                Text("Water capacity:")
                                    .bold()
                                Spacer()
                                Text("\(results.waterCapacity, specifier: "%.2f") ml")
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private func calculateVolume() {
        guard let l = Double(length),
              let w = Double(width),
              let h = Double(height) else { return }
        
        let volume = l * w * h
        let volumeUnit: String
        let substrateVolume: Double
        let waterCapacity: Double
        
        switch unit {
        case .cm:
            volumeUnit = "cm³"
            substrateVolume = volume / 236.6 // Convert cm³ to cups
            waterCapacity = volume // cm³ equals ml
        case .inches:
            volumeUnit = "in³"
            substrateVolume = volume / 14.4 // Convert in³ to cups
            waterCapacity = volume * 16.39 // Convert in³ to ml
        }
        
        results = VolumeResult(
            volume: volume,
            volumeUnit: volumeUnit,
            substrateVolume: substrateVolume,
            waterCapacity: waterCapacity
        )
    }
}

struct FeedingCalculatorView: View {
    @State private var colonySize: String = ""
    @State private var antType: AntType = .small
    @State private var feedingFrequency: FeedingFrequency = .weekly
    @State private var results: FeedingResult?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feeding Calculator")
                        .font(.headline)
                    Text("Calculate optimal feeding amounts for your colony")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Colony Information")
                        .font(.headline)
                    
                    HStack {
                        Text("Colony Size")
                            .frame(width: 100, alignment: .leading)
                        TextField("Number of workers", text: $colonySize)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ant Size")
                        Picker("Ant Type", selection: $antType) {
                            ForEach(AntType.allCases, id: \.self) { type in
                                Text(type.description).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feeding Schedule")
                        Picker("Frequency", selection: $feedingFrequency) {
                            ForEach(FeedingFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding()
                .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .cornerRadius(12)
                
                Button("Calculate Feeding") {
                    calculateFeeding()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(colonySize.isEmpty)
                
                if let results = results {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Feeding Recommendations")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Protein per feeding:")
                                    .bold()
                                Spacer()
                                Text(results.proteinAmount)
                            }
                            
                            HStack {
                                Text("Sugar water:")
                                    .bold()
                                Spacer()
                                Text(results.sugarAmount)
                            }
                            
                            HStack {
                                Text("Feeding frequency:")
                                    .bold()
                                Spacer()
                                Text(results.frequency)
                            }
                        }
                        
                        Text("Notes:")
                            .font(.subheadline)
                            .bold()
                        Text(results.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private func calculateFeeding() {
        guard let size = Int(colonySize) else { return }
        
        let proteinMultiplier = antType.proteinMultiplier
        let proteinAmount = Int(Double(size) * proteinMultiplier)
        
        results = FeedingResult(
            proteinAmount: "\(proteinAmount) small insects or 1-2 larger insects",
            sugarAmount: "2-3 drops of honey water",
            frequency: feedingFrequency.rawValue,
            notes: "Adjust amounts based on colony activity and season. Remove uneaten food after 24-48 hours to prevent mold."
        )
    }
}

// Supporting types and views
struct SubstrateResult {
    let sandCups: Double
    let clayCups: Double
    let soilCups: Double
}

struct VolumeResult {
    let volume: Double
    let volumeUnit: String
    let substrateVolume: Double
    let waterCapacity: Double
}

struct FeedingResult {
    let proteinAmount: String
    let sugarAmount: String
    let frequency: String
    let notes: String
}

enum VolumeUnit: String, CaseIterable {
    case cm = "cm"
    case inches = "in"
}

enum AntType: CaseIterable {
    case small, medium, large
    
    var description: String {
        switch self {
        case .small: return "Small (2-4mm)"
        case .medium: return "Medium (5-8mm)"
        case .large: return "Large (9mm+)"
        }
    }
    
    var proteinMultiplier: Double {
        switch self {
        case .small: return 0.01
        case .medium: return 0.02
        case .large: return 0.03
        }
    }
}

enum FeedingFrequency: String, CaseIterable {
    case daily = "Daily"
    case twiceWeekly = "Twice weekly"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
}

struct ResultRow: View {
    let material: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(material)
                .bold()
            Spacer()
            Text("\(amount, specifier: "%.2f") cups")
        }
    }
}

#Preview {
    MaterialCalculatorView()
} 