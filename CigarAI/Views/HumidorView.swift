import SwiftUI
import FirebaseFirestore

struct HumidorView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var searchText = ""
    @State private var sortOption = "Date"
    
    var sortedCigars: [Cigar] {
        switch sortOption {
        case "Name":
            return viewModel.cigars.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case "Rating":
            return viewModel.cigars.sorted { $0.rating > $1.rating }
        default: // "Date"
            return viewModel.cigars.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Sort by", selection: $sortOption) {
                Text("Date").tag("Date")
                Text("Name").tag("Name")
                Text("Rating").tag("Rating")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Temporary button to test addInventoryItem
            Button(action: { viewModel.addInventoryItem(name: "Test Inventory", quantity: 5) }) {
                Text("Add Test Inventory")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            List {
                if sortedCigars.isEmpty {
                    Text("No sticks logged.")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                } else {
                    ForEach(sortedCigars.filter {
                        searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
                    }, id: \.id) { cigar in
                        RecentCigarRow(cigar: cigar)
                    }
                    .onDelete(perform: deleteCigars)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("My Collection")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "#fefbf3").ignoresSafeArea())
        .searchable(text: $searchText, prompt: "Search a log")
        .onAppear {
            print("HumidorView: onAppear triggered, fetching cigars")
            viewModel.fetchCigars()
        }
    }
    
    private func deleteCigars(at offsets: IndexSet) {
        let cigarsToDelete = offsets.map { sortedCigars[$0] }
        for cigar in cigarsToDelete {
            if let cigarId = cigar.id {
                viewModel.deleteCigar(cigarId: cigarId)
            }
        }
    }
}

struct HumidorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HumidorView()
                .environmentObject(CigarViewModel(isPreview: true))
        }
    }
}

