import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var viewModel: CigarViewModel

    private let flavorTags = [
        "Woody", "Creamy", "Spicy", "Earthy",
        "Oak", "Cedar", "Leather", "Chocolate",
        "Caramel", "Peppery", "Nutty", "Coffee"
    ]

    private var flavorFrequencies: [String: Int] {
        let allFlavors = viewModel.cigars.flatMap { $0.flavorNotes }
        return flavorTags.reduce(into: [String: Int]()) { result, flavor in
            result[flavor] = allFlavors.filter { $0 == flavor }.count
        }
    }

    private var top6Flavors: [String] {
        flavorFrequencies.sorted { $0.value > $1.value }
            .prefix(6)
            .map { $0.key }
    }

    private var flavorIntensities: [String: Double] {
        let bodyToIntensity: [String: Double] = ["Mild": 1.0, "Medium": 2.0, "Full": 3.0]
        var flavorIntensities: [String: [Double]] = [:]
        for cigar in viewModel.cigars {
            let intensity = bodyToIntensity[cigar.cigarBody] ?? 2.0
            for flavor in cigar.flavorNotes {
                flavorIntensities[flavor, default: []].append(intensity)
            }
        }
        return flavorIntensities.mapValues { intensities in
            let average = intensities.reduce(0.0, +) / Double(intensities.count)
            return (average - 1.0) * 50 // Normalize to 0-100 scale
        }
    }

    private var radarData: [RadarData] {
        top6Flavors.map { flavor in
            RadarData(flavor: flavor, intensity: flavorIntensities[flavor] ?? 0)
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
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                        Text("Flavor Profile Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, geometry.size.width > 600 ? 30 : 20)

                        VStack(alignment: .center, spacing: geometry.size.width > 600 ? 8 : 4) {
                            Text("Your Palate")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Average intensity per flavor")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)

                        // Radar Chart for Top 6 Flavors
                        RadarChartView(data: radarData, top6Flavors: top6Flavors)
                            .frame(height: geometry.size.width > 600 ? 400 : 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)

                        Section {
                            Text("Top 3 Flavors You Log Most")
                                .font(.title2)
                                .fontWeight(.regular)
                                .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: geometry.size.width > 600 ? 12 : 8) {
                                let sortedFlavors = flavorFrequencies.sorted { $0.value > $1.value }
                                    .prefix(3)
                                    .map { ($0.key, $0.value) }

                                if sortedFlavors.isEmpty {
                                    Text("No flavors logged yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                } else {
                                    ForEach(sortedFlavors, id: \.0) { flavor, count in
                                        HStack(spacing: 0) {
                                            Text("\(flavor)")
                                                .font(.subheadline)
                                                .frame(width: geometry.size.width > 600 ? 120 : 80, alignment: .leading)
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    Rectangle()
                                                        .foregroundColor(Color(red: 101/255, green: 67/255, blue: 33/255))
                                                        .frame(height: geometry.size.width > 600 ? 24 : 18)
                                                    Rectangle()
                                                        .foregroundColor(Color(red: 205/255, green: 133/255, blue: 63/255))
                                                        .frame(width: geo.size.width * (CGFloat(count) / CGFloat(viewModel.totalCigarsLogged > 0 ? viewModel.totalCigarsLogged : 1)), height: geometry.size.width > 600 ? 24 : 18)
                                                }
                                            }
                                            .frame(height: geometry.size.width > 600 ? 24 : 18)
                                            .padding(.horizontal, geometry.size.width > 600 ? 12 : 8)
                                        }
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                    }
                                }
                            }
                        }

                        // Favorite Cigar This Week
                        Section {
                            VStack(spacing: 4) {
                                Text("Your favorite cigar this week:")
                                    .font(.title2)
                                    .fontWeight(.regular)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)

                                if let favorite = favoriteThisWeek {
                                    Image("CigarImage")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: geometry.size.width > 600 ? 150 : 100)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)

                                    Text(favorite.name)
                                        .font(.title2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                } else {
                                    Text("No cigars logged this week.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                }
                            }
                        }

                        // Top Cigars
                        Section {
                            Text("Top Cigars")
                                .font(.headline)
                                .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: geometry.size.width > 600 ? 12 : 8) {
                                if topCigarsByCount.isEmpty && topCigarsByRating.isEmpty {
                                    Text("No cigars logged yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                } else {
                                    if !topCigarsByCount.isEmpty {
                                        ForEach(topCigarsByCount, id: \.name) { cigar in
                                            Text("\(cigar.name): \(cigar.count) time\(cigar.count == 1 ? "" : "s")")
                                                .font(.subheadline)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    if !topCigarsByRating.isEmpty {
                                        ForEach(topCigarsByRating, id: \.name) { cigar in
                                            Text("\(cigar.name): \(cigar.rating) star\(cigar.rating == 1 ? "" : "s")")
                                                .font(.subheadline)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    if let favorite = favoriteThisMonth {
                                        Text("\(favorite.name): \(favorite.rating) stars")
                                            .font(.subheadline)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }

                        // Recent Cigars
                        Section {
                            Text("Recent Cigars")
                                .font(.headline)
                                .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if viewModel.recentCigars.isEmpty {
                                Text("No recent cigars logged.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: geometry.size.width > 600 ? 24 : 16),
                                    GridItem(.flexible(), spacing: geometry.size.width > 600 ? 24 : 16)
                                ], spacing: geometry.size.width > 600 ? 24 : 16) {
                                    ForEach(viewModel.recentCigars) { cigar in
                                        RecentCigarCard(cigar: cigar, geometry: geometry)
                                    }
                                }
                                .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                            }
                        }

                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationTitle("")
            .toolbar {}
        }
    }
}

struct RecentCigarCard: View {
    let cigar: Cigar
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.width > 600 ? 12 : 8) {
            Text(cigar.name)
                .font(.headline)
                .lineLimit(2)
            Text(cigar.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                ForEach(0..<Int(cigar.rating), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Spacer()
                Text(cigar.flavorNotes.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(geometry.size.width > 600 ? 12 : 8)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
