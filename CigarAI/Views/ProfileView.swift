import SwiftUI
import Charts
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var viewModel: CigarViewModel

    private let flavorOptions = ["Woody", "Creamy", "Earthy", "Spicy", "Nutty"]

    private var flavorFrequencies: [String: Int] {
        let allFlavors = viewModel.cigars.flatMap { $0.flavorNotes }
        return flavorOptions.reduce(into: [String: Int]()) { result, flavor in
            result[flavor] = allFlavors.filter { $0 == flavor }.count
        }
    }

    private var topCigarsByCount: [(name: String, count: Int)] {
        Dictionary(grouping: viewModel.cigars, by: { $0.name })
            .map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }

    private var topCigarsByRating: [(name: String, rating: Int)] {
        Dictionary(grouping: viewModel.cigars, by: { $0.name })
            .map { (name: $0.key, rating: $0.value.map { $0.rating }.max() ?? 0) }
            .sorted { $0.rating > $1.rating }
            .prefix(3)
            .map { $0 }
    }

    private var favoriteThisMonth: Cigar? {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return viewModel.cigars
            .filter { $0.date >= oneMonthAgo }
            .max(by: { $0.rating < $1.rating })
    }

    private var favoriteThisWeek: Cigar? {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return viewModel.cigars
            .filter { $0.date >= oneWeekAgo }
            .max(by: { $0.rating < $1.rating })
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: geometry.size.width > 600 ? 24 : 16) {
                    // User Summary
                    VStack(alignment: .leading, spacing: 8) {
                        if let email = Auth.auth().currentUser?.email {
                            Text(email)
                                .font(.system(.title2, design: .default, weight: .bold))
                                .accessibilityLabel("User Email: \(email)")
                        }
                        Text("Total Cigars Logged: \(viewModel.totalCigarsLogged)")
                            .font(.system(.headline, design: .default, weight: .regular))
                            .foregroundColor(.gray)
                            .accessibilityLabel("Total Cigars Logged: \(viewModel.totalCigarsLogged)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                    .padding(.top, geometry.size.width > 600 ? 24 : 16)

                    // Flavor Distribution
                    Section {
                        Text("Flavor Distribution")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            .accessibilityLabel("Flavor Distribution Section")
                        Chart {
                            ForEach(flavorOptions, id: \.self) { flavor in
                                BarMark(
                                    x: .value("Flavor", flavor),
                                    y: .value("Count", flavorFrequencies[flavor] ?? 0)
                                )
                                .foregroundStyle(.orange)
                            }
                        }
                        .frame(height: geometry.size.width > 600 ? 300 : 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                        .accessibilityLabel("Flavor Distribution Chart")
                        .accessibilityValue(flavorFrequencies.map { "\($0.key): \($0.value) times" }.joined(separator: ", "))
                    }

                    // Top Cigars
                    Section {
                        Text("Top Cigars")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            .accessibilityLabel("Top Cigars Section")
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Most Logged")
                                .font(.system(.subheadline, design: .default, weight: .medium))
                                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            if topCigarsByCount.isEmpty {
                                Text("No cigars logged yet.")
                                    .font(.system(.body, design: .default, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            } else {
                                ForEach(topCigarsByCount, id: \.name) { cigar in
                                    Text("\(cigar.name): \(cigar.count) time\(cigar.count == 1 ? "" : "s")")
                                        .font(.system(.body, design: .default, weight: .regular))
                                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                        .accessibilityLabel("\(cigar.name) logged \(cigar.count) time\(cigar.count == 1 ? "" : "s")")
                                }
                            }
                            Text("Highest Rated")
                                .font(.system(.subheadline, design: .default, weight: .medium))
                                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                .padding(.top, 8)
                            if topCigarsByRating.isEmpty {
                                Text("No cigars rated yet.")
                                    .font(.system(.body, design: .default, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            } else {
                                ForEach(topCigarsByRating, id: \.name) { cigar in
                                    Text("\(cigar.name): \(cigar.rating) star\(cigar.rating == 1 ? "" : "s")")
                                        .font(.system(.body, design: .default, weight: .regular))
                                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                        .accessibilityLabel("\(cigar.name) rated \(cigar.rating) star\(cigar.rating == 1 ? "" : "s")")
                                }
                            }
                            Text("Favorite This Month")
                                .font(.system(.subheadline, design: .default, weight: .medium))
                                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                .padding(.top, 8)
                            if let favorite = favoriteThisMonth {
                                Text("\(favorite.name): \(favorite.rating) stars")
                                    .font(.system(.body, design: .default, weight: .regular))
                                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                                    .accessibilityLabel("Favorite cigar this month: \(favorite.name), \(favorite.rating) stars")
                            } else {
                                Text("No cigars logged this month.")
                                    .font(.system(.body, design: .default, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Your favorite cigar this week
                    Section {
                        Text("Your favorite cigar this week:")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .padding(.horizontal, geometry.size.width > 600 ? 16 : 8) // Reduced horizontal padding
                            .accessibilityLabel("Favorite Cigar This Week Section")
                        if let favorite = favoriteThisWeek {
                            Image("CigarImage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100) // Adjust height as needed
                                .padding(.horizontal, geometry.size.width > 600 ? 16 : 8) // Reduced horizontal padding
                                .padding(.top, 4) // Reduced top padding
                            Text(favorite.name)
                                .font(.system(.body, design: .default, weight: .regular))
                                .padding(.horizontal, geometry.size.width > 600 ? 16 : 8) // Reduced horizontal padding
                                .padding(.top, 4) // Reduced top padding
                        } else {
                            Text("No cigars logged this week.")
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.horizontal, geometry.size.width > 600 ? 16 : 8) // Reduced horizontal padding
                                .padding(.top, 4) // Reduced top padding
                        }
                    }
                    .padding(.vertical, 4) // Reduced vertical padding for the entire section

                    // Recent Cigars
                    Section {
                        Text("Recent Cigars")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            .accessibilityLabel("Recent Cigars Section")
                        if viewModel.recentCigars.isEmpty {
                            Text("No recent cigars logged.")
                                .font(.system(.body, design: .default, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                            .accessibilityLabel("No recent cigars")
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ],
                                spacing: 16
                            ) {
                                ForEach(viewModel.recentCigars) { cigar in
                                    CigarCard(cigar: cigar, geometry: geometry)
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("Cigar: \(cigar.name), Rating: \(cigar.rating) stars")
                                }
                            }
                            .padding(.horizontal, geometry.size.width > 600 ? 32 : 16)
                        }
                    }
                    .padding(.vertical, 8)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, geometry.size.width > 600 ? 40 : 24)
            }
            .navigationTitle("Profile")
            .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
}

struct CigarCard: View {
    let cigar: Cigar
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(cigar.name)
                .font(.system(.headline, weight: .bold))
                .lineLimit(2)
            Text("Wrapper: \(cigar.wrapper)")
                .font(.system(.caption, weight: .regular))
                .foregroundColor(.gray)
            Text("Body: \(cigar.cigarBody)")
                .font(.system(.caption, weight: .regular))
                .foregroundColor(.gray)
            Text("Flavors: \(cigar.flavorNotes.joined(separator: ", "))")
                .font(.system(.caption, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(2)
            HStack {
                Text("\(cigar.rating) stars")
                    .font(.system(.caption, weight: .regular))
                    .foregroundColor(.yellow)
                Spacer()
                Text(cigar.date, style: .relative)
                    .font(.system(.caption, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .frame(maxWidth: min(geometry.size.width * 0.45, 300))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView()
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice("iPhone 14 Pro")
                .previewDisplayName("iPhone 14 Pro")
            ProfileView()
                .environmentObject(CigarViewModel(isPreview: true))
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}
