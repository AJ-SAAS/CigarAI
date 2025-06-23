import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var showingLogCigarSheet = false
    @Binding var selectedTab: Int
    
    private var topFlavors: String {
        let allFlavors = viewModel.cigars.flatMap { $0.flavorNotes }
        let flavorCounts = allFlavors.reduce(into: [:]) { counts, flavor in
            counts[flavor, default: 0] += 1
        }
        let sortedFlavors = flavorCounts.sorted { $0.value > $1.value || ($0.value == $1.value && $0.key < $1.key) }
        return sortedFlavors.prefix(2).map { $0.key }.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        
                        HStack(spacing: 12) {
                            DashboardCard(
                                icon: "🔥",
                                value: "\(viewModel.totalCigarsLogged)",
                                label: "Total Logged"
                            )
                            
                            DashboardCard(
                                icon: "🌟",
                                value: topFlavors.isEmpty ? "None" : topFlavors,
                                label: "Top Flavors"
                            )
                            
                            DashboardCard(
                                icon: "📅",
                                value: viewModel.lastLoggedDate,
                                label: "Last entry"
                            )
                        }
                        .padding(.horizontal)
                        .frame(height: 120)
                        
                        NavigationLink(destination: HumidorView()) {
                            HStack {
                                Image(systemName: "archivebox")
                                Text("My Collection")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#1B4F26"))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Button(action: { selectedTab = 2 }) {
                            HStack {
                                Image(systemName: "message")
                                Text("Ask the Concierge")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recently Logged")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            if viewModel.recentCigars.isEmpty {
                                Text("No recent logs.")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(Array(viewModel.recentCigars.prefix(3)), id: \.id) { cigar in
                                    RecentCigarRow(cigar: cigar)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: { showingLogCigarSheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Log a new stick")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#a8552b"))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
                .font(.title2)
                .fontWeight(.regular)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#fefbf3").ignoresSafeArea())
                .onAppear {
                    print("HomeView: onAppear triggered, fetching cigars")
                    viewModel.fetchCigars()
                }
            }
        }
        .sheet(isPresented: $showingLogCigarSheet) {
            LogCigarView(viewModel: viewModel)
        }
    }
}

struct DashboardCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title)
            Text(value)
                .font(.system(size: 12, weight: .regular, design: .default))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct RecentCigarRow: View {
    let cigar: Cigar
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(cigar.name)
                    .font(.system(size: 12, weight: .regular, design: .default))
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= cigar.rating ? "star.fill" : "star")
                            .foregroundColor(index <= cigar.rating ? Color(hex: "#5c3b26") : Color(hex: "#f1d8be"))
                            .font(.system(size: 12))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(cigar.date, style: .date)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray)
                Text(cigar.flavorNotes.joined(separator: ", "))
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView(selectedTab: .constant(0))
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice("iPhone 14 Pro")
            
            HomeView(selectedTab: .constant(0))
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}

