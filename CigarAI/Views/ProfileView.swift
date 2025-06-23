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

    private var topCigarsByRating: [(name: String, rating: Double)] {
        let groupedCigars = Dictionary(grouping: viewModel.cigars, by: { $0.name })
        let cigarsWithRatings = groupedCigars.map { (name, cigars) in
            let totalRating = cigars.map { Double($0.rating) }.reduce(0.0, +)
            let averageRating = totalRating / Double(cigars.count)
            return (name: name, rating: averageRating)
        }
        return cigarsWithRatings
            .sorted { $0.rating > $1.rating }
            .prefix(3)
            .map { $0 }
    }

    private var favoriteThisMonth: Cigar? {
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        return viewModel.cigars
            .filter { $0.date >= oneMonthAgo }
            .max(by: { $0.rating < $1.rating })
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 600 ? 24 : 16) {
                        // Your Palate Section
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
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.width > 600 ? 450 : 300)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color(hex: "#fefbf3"))
                            .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)

                        // Top 3 Flavors Section
                        Section {
                            Text("Top 3 Flavors You Log Most")
                                .font(.title2)
                                .fontWeight(.regular)
                                .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .center, spacing: geometry.size.width > 600 ? 12 : 8) {
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
                                        HStack(spacing: 8) {
                                            Text(flavor)
                                                .font(.subheadline)
                                                .frame(width: geometry.size.width > 600 ? 120 : 80)
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    Rectangle()
                                                        .foregroundColor(Color(hex: "#f2d7bc"))
                                                        .frame(height: geometry.size.width > 600 ? 20.4 : 15.3)
                                                        .cornerRadius(4)
                                                    Rectangle()
                                                        .foregroundColor(Color(hex: "#cb652b"))
                                                        .frame(width: geo.size.width * (CGFloat(count) / CGFloat(viewModel.totalCigarsLogged > 0 ? viewModel.totalCigarsLogged : 1)), height: geometry.size.width > 600 ? 20.4 : 15.3)
                                                        .cornerRadius(4)
                                                }
                                            }
                                            .frame(height: geometry.size.width > 600 ? 20.4 : 15.3)
                                        }
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Top-Rated Cigar This Month
                        Section {
                            VStack(spacing: 4) {
                                Text("Top-Rated This Month:")
                                    .font(.title2)
                                    .fontWeight(.regular)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)

                                if let favorite = favoriteThisMonth {
                                    
                                    Text(favorite.name)
                                        .font(.title2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                } else {
                                    Text("No flavors logged this month.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                }
                            }
                        }


                        // Top Cigars
                        Section {
                            Text("Highest Rated of All Time")
                                .font(.title2)
                                .fontWeight(.regular)
                                .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: geometry.size.width > 600 ? 12 : 8) {
                                if topCigarsByRating.isEmpty {
                                    Text("No cigars logged yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                } else {
                                    ForEach(topCigarsByRating, id: \.name) { cigar in
                                        TopCigarRow(cigar: cigar)
                                            .padding(.horizontal, geometry.size.width > 600 ? 40 : 16)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationTitle("Flavor Profile Summary")
            .navigationBarTitleDisplayMode(.inline)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .toolbar {}
            .background(Color(hex: "#fefbf3"))
        }
    }
}

struct TopCigarRow: View {
    let cigar: (name: String, rating: Double)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(cigar.name)
                    .font(.system(size: 12, weight: .regular, design: .default))
                HStack(spacing: 2) {
                    ForEach(0..<Int(cigar.rating.rounded(.up)), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#5c3b26"))
                            .font(.system(size: 12))
                    }
                }
            }
            
            Spacer()
            
            Text(String(format: "%.1f", cigar.rating))
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(CigarViewModel())
    }
}

