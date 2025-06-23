import SwiftUI
import RevenueCatUI

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
    @State private var showingPaywall = false

    private let flavorTags = [
        "Woody", "Creamy", "Spicy", "Earthy",
        "Oak", "Cedar", "Leather", "Chocolate",
        "Caramel", "Peppery", "Nutty", "Coffee"
    ]

    private let cigarTypeOptions = ["Robusto", "Churchill", "Toro", "Corona", "Torpedo", "Belicoso", "Panatela", "Gordo"]
    private let wrapperTypeOptions = ["Connecticut", "Habano", "Maduro", "Corojo", "Sumatra", "Cameroon", "Candela", "Broadleaf"]
    private let strengthOptions = ["Mild", "Medium", "Full"]

    private var cigarCountColor: Color {
        viewModel.totalCigarsLogged >= 5 && !viewModel.isSubscribed ? .red : .black
    }

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 20) {
                        // Cigar Count
                        Text("Cigars Logged: \(viewModel.totalCigarsLogged)/5")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(cigarCountColor)
                            .padding(.horizontal)
                            .accessibilityLabel("Cigars logged: \(viewModel.totalCigarsLogged) out of 5")

                        // Cigar Name
                        VStack(alignment: .leading) {
                            Text("Name")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .padding(.horizontal)
                            TextField("E.g. Cohiba Robusto", text: $cigarName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }

                        // Date
                        DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .padding(.horizontal)

                        // Star Rating
                        VStack(alignment: .leading) {
                            Text("Rating")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .padding(.horizontal)
                            HStack {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .foregroundColor(index <= rating ? Color(hex: "#5c3b26") : Color(hex: "#f1d8be"))
                                        .font(.system(size: 28))
                                        .onTapGesture {
                                            rating = index
                                        }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }

                        // Flavor Notes in Grid
                        VStack(alignment: .leading) {
                            Text("Flavor Notes")
                                .font(.system(size: 14, weight: .regular, design: .default))
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
                                            .font(.system(.callout, design: .default))
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 10)
                                            .background(selectedFlavors.contains(flavor) ? Color.orange.opacity(0.2) : Color(hex: "#fef3e6"))
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

                        // Cigar Type & Wrapper Type
                        VStack(spacing: 12) {
                            HStack {
                                Text("Type")
                                    .font(.system(size: 14, weight: .regular, design: .default))
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
                                    .font(.system(size: 14, weight: .regular, design: .default))
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
                                .font(.system(size: 14, weight: .regular, design: .default))
                            Picker("Strength", selection: $strength) {
                                ForEach(strengthOptions, id: \.self) { Text($0) }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .tint(Color(hex: "#5c3b26"))
                            .background(Color(hex: "#f1d8be"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal)

                        // Save Button
                        Button(action: { saveCigar() }) {
                            Text("Save Log")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(cigarName.isEmpty || selectedFlavors.isEmpty ? Color.gray : Color(hex: "#a8552b"))
                                .cornerRadius(10)
                        }
                        .disabled(cigarName.isEmpty || selectedFlavors.isEmpty)
                        .padding([.horizontal, .bottom])

                        Spacer()
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
            .navigationTitle("Log a New Stick")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(viewModel)
            }
            .background(Color(hex: "#fefbf3"))
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
            date: date,
            quantity: nil
        )
        if viewModel.addCigar(cigar) {
            print("Saved stick: \(cigar.name), \(cigar.rating) stars, flavors: \(cigar.flavorNotes)")
            dismiss()
        } else {
            print("Free tier limit reached, showing paywall")
            showingPaywall = true
        }
    }
}

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


