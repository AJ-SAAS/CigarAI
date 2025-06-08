import SwiftUI

struct LogCigarView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CigarViewModel
    @State private var cigarName = ""
    @State private var date = Date()
    @State private var rating = 3
    @State private var selectedFlavors: Set<String> = []
    @State private var cigarType = "Robusto"
    @State private var wrapperType = "Connecticut"
    @State private var strength = "Medium"

    private let flavorTags = [
        "Woody", "Creamy", "Spicy", "Earthy",
        "Oak", "Cedar", "Leather", "Chocolate",
        "Caramel", "Peppery", "Nutty", "Coffee"
    ]

    private let cigarTypeOptions = ["Robusto", "Churchill", "Toro", "Corona", "Torpedo", "Belicoso", "Panatela", "Gordo"]
    private let wrapperTypeOptions = ["Connecticut", "Habano", "Maduro", "Corojo", "Sumatra", "Cameroon", "Candela", "Broadleaf"]
    private let strengthOptions = ["Mild", "Medium", "Full"]

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Log a New Cigar")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        Image("CigarImage")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .padding(.horizontal)

                        TextField("E.g. Cohiba Robusto", text: $cigarName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .padding(.horizontal)

                        // Star Rating
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 24))
                                    .onTapGesture {
                                        rating = index
                                    }
                            }
                        }
                        .padding(.horizontal)

                        // Flavor Tags in Grid
                        VStack(alignment: .leading) {
                            Text("Flavors")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 10) {
                                ForEach(flavorTags, id: \.self) { flavor in
                                    Button(action: {
                                        if selectedFlavors.contains(flavor) {
                                            selectedFlavors.remove(flavor)
                                        } else {
                                            selectedFlavors.insert(flavor)
                                        }
                                    }) {
                                        Text(flavor)
                                            .font(.subheadline)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background(selectedFlavors.contains(flavor) ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedFlavors.contains(flavor) ? Color.orange : Color.clear, lineWidth: 1)
                                            )
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Cigar Type & Wrapper Type (MenuPickers)
                        VStack(spacing: 12) {
                            HStack {
                                Text("Cigar Type")
                                Spacer()
                                Menu {
                                    ForEach(cigarTypeOptions, id: \.self) { option in
                                        Button(option) { cigarType = option }
                                    }
                                } label: {
                                    HStack {
                                        Text(cigarType)
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }

                            HStack {
                                Text("Wrapper Type")
                                Spacer()
                                Menu {
                                    ForEach(wrapperTypeOptions, id: \.self) { option in
                                        Button(option) { wrapperType = option }
                                    }
                                } label: {
                                    HStack {
                                        Text(wrapperType)
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Strength Segmented Control
                        VStack(alignment: .leading) {
                            Text("Strength")
                            Picker("Strength", selection: $strength) {
                                ForEach(strengthOptions, id: \.self) { Text($0) }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.horizontal)

                        // Save Button
                        Button(action: { saveCigar() }) {
                            Text("Save Cigar")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cigarName.isEmpty || selectedFlavors.isEmpty ? Color.gray : Color.orange)
                                .cornerRadius(10)
                        }
                        .disabled(cigarName.isEmpty || selectedFlavors.isEmpty)
                        .padding([.horizontal, .bottom])

                        Spacer()
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
            .navigationTitle("Log Cigar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveCigar() {
        let cigar = Cigar(
            id: nil,
            name: cigarName.trimmingCharacters(in: .whitespaces),
            wrapper: wrapperType,
            cigarBody: strength,
            flavorNotes: Array(selectedFlavors),
            rating: rating,
            date: date
        )
        print("Saved cigar: \(cigar.name), \(cigar.rating) stars, flavors: \(cigar.flavorNotes)")
        viewModel.addCigar(cigar)
        dismiss()
    }
}

// MARK: - Previews
struct LogCigarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogCigarView(viewModel: CigarViewModel(isPreview: true))
                .previewDevice("iPhone 14 Pro")

            LogCigarView(viewModel: CigarViewModel(isPreview: true))
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
