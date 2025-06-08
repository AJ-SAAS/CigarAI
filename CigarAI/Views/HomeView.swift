import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: CigarViewModel
    @State private var showingLogCigarSheet = false
    @Binding var selectedTab: Int // Bind to TabView selection

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Dashboard Cards
                        GeometryReader { geometry in
                            HStack(spacing: 16) {
                                DashboardCard(
                                    icon: "🔥",
                                    value: "\(viewModel.totalCigarsLogged)",
                                    label: "Total Cigars Logged",
                                    width: geometry.size.width / 3 - 16
                                )
                                DashboardCard(
                                    icon: "📅",
                                    value: viewModel.lastLoggedDate,
                                    label: "Last Logged",
                                    width: geometry.size.width / 3 - 16
                                )
                                DashboardCard(
                                    icon: "🌟",
                                    value: viewModel.flavorProfile.joined(separator: ", "),
                                    label: "Top Flavors",
                                    width: geometry.size.width / 3 - 16
                                )
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 120)

                        // Recent Cigars
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent Cigars Logged")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            if viewModel.recentCigars.isEmpty {
                                Text("No recent cigars logged.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ForEach(viewModel.recentCigars) { cigar in
                                    RecentCigarRow(cigar: cigar)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                }
                            }
                        }

                        // Ask the Cigar Concierge Button
                        Button(action: {
                            selectedTab = 2 // Switch to ChatbotView tab
                        }) {
                            HStack {
                                Image(systemName: "message")
                                Text("Ask the Cigar Concierge")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }

                // Floating Plus Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingLogCigarSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                        .accessibilityLabel("Log a New Cigar")
                        .accessibilityHint("Opens the form to log a new cigar")
                    }
                }
            }
            .navigationTitle("Cigar AI")
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
    let width: CGFloat

    var body: some View {
        VStack {
            Text(icon)
                .font(.title)
            Text(value)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: width)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct RecentCigarRow: View {
    let cigar: Cigar

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cigar.name)
                    .font(.headline)
                Text(cigar.flavorNotes.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(cigar.rating) stars")
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
