import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var showingLogCigarSheet = false
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Section
                        VStack(spacing: 8) {
                            Text("Cigar AI")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Dashboard Cards
                        HStack(spacing: 12) {
                            DashboardCard(
                                icon: "🔥",
                                value: "\(viewModel.totalCigarsLogged)",
                                label: "Total Logged"
                            )
                            
                            DashboardCard(
                                icon: "🌟",
                                value: viewModel.flavorProfile.prefix(2).joined(separator: ", "),
                                label: "Top Flavors"
                            )
                            
                            DashboardCard(
                                icon: "📅",
                                value: viewModel.lastLoggedDate,
                                label: "Last Smoked"
                            )
                        }
                        .padding(.horizontal)
                        .frame(height: 120)
                        
                        // Concierge Button
                        Button(action: { selectedTab = 2 }) {
                            HStack {
                                Image(systemName: "message")
                                Text("Ask the Cigar Concierge")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 205/255, green: 133/255, blue: 63/255))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Recent Cigars Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Cigars Logged")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if viewModel.recentCigars.isEmpty {
                                Text("No recent cigars logged.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(Array(viewModel.recentCigars.prefix(3)), id: \.id) { cigar in
                                    RecentCigarRow(cigar: cigar)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Log New Cigar Button
                        Button(action: { showingLogCigarSheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Log a new cigar")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 205/255, green: 133/255, blue: 63/255))
                            .cornerRadius(10)
                        }
                        .padding([.horizontal, .bottom])
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationTitle("")
            .sheet(isPresented: $showingLogCigarSheet) {
                LogCigarView(viewModel: viewModel)
            }
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
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
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
                    .font(.headline)
                HStack(spacing: 2) {
                    ForEach(0..<Int(cigar.rating), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(cigar.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(cigar.flavorNotes.joined(separator: ", "))
                    .font(.caption)
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
