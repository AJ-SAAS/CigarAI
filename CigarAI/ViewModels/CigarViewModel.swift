import Foundation
import FirebaseFirestore
import FirebaseAuth

class CigarViewModel: ObservableObject {
    @Published var cigars: [Cigar] = []
    private let db = Firestore.firestore()
    private let isPreview: Bool

    init(isPreview: Bool = false) {
        self.isPreview = isPreview
        if isPreview {
            self.cigars = [
                Cigar(id: nil, name: "Padron 1964", wrapper: "Maduro", cigarBody: "Full", flavorNotes: ["Earthy", "Nutty"], rating: 5, date: Date().addingTimeInterval(-7 * 24 * 60 * 60)),
                Cigar(id: nil, name: "Cohiba Robusto", wrapper: "Claro", cigarBody: "Medium", flavorNotes: ["Creamy", "Woody"], rating: 4, date: Date().addingTimeInterval(-5 * 24 * 60 * 60)),
                Cigar(id: nil, name: "Montecristo No. 2", wrapper: "Natural", cigarBody: "Medium", flavorNotes: ["Woody", "Spicy"], rating: 4, date: Date().addingTimeInterval(-3 * 24 * 60 * 60))
            ]
            print("Preview: Initialized with \(cigars.count) cigars")
        }
    }

    func addCigar(_ cigar: Cigar) {
        guard !isPreview else {
            var newCigar = cigar
            newCigar.id = UUID().uuidString
            cigars.append(newCigar)
            print("Preview: Added cigar '\(newCigar.name)' with ID: \(newCigar.id ?? "nil")")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("Error: No authenticated user")
            return
        }
        print("Attempting to save cigar '\(cigar.name)' for user: \(userId), email: \(email)")
        do {
            var newCigar = cigar
            newCigar.id = nil
            let docRef = try db.collection("users").document(userId).collection("cigars").addDocument(from: newCigar)
            print("Saved cigar '\(newCigar.name)' to Firestore with ID: \(docRef.documentID) for user: \(userId)")
        } catch {
            print("Error saving cigar: \(error.localizedDescription) (Code: \((error as NSError).code))")
        }
    }

    func fetchCigars() {
        guard !isPreview else {
            print("Preview: Fetching \(cigars.count) cigars")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("Error: No authenticated user, clearing cigars")
            DispatchQueue.main.async {
                self.cigars = []
            }
            return
        }
        print("Fetching cigars for user: \(userId), email: \(email)")
        db.collection("users").document(userId).collection("cigars").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching cigars: \(error.localizedDescription) (Code: \((error as NSError).code))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No cigars found for user: \(userId)")
                DispatchQueue.main.async {
                    self.cigars = []
                }
                return
            }
            let fetchedCigars = documents.compactMap { document in
                do {
                    let cigar = try document.data(as: Cigar.self)
                    print("Fetched cigar: '\(cigar.name)' with ID: \(cigar.id ?? "nil")")
                    return cigar
                } catch {
                    print("Error decoding cigar \(document.documentID): \(error)")
                    return nil
                }
            }
            DispatchQueue.main.async {
                self.cigars = fetchedCigars
                print("Updated cigars array with \(fetchedCigars.count) items")
            }
        }
    }

    var totalCigarsLogged: Int {
        cigars.count
    }

    var flavorProfile: [String] {
        let allFlavors = cigars.flatMap { $0.flavorNotes }
        let flavorCounts = Dictionary(grouping: allFlavors, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        return flavorCounts.map { $0.key }.prefix(3).map { $0 }
    }

    var lastLoggedDate: String {
        guard let mostRecentDate = cigars.map({ $0.date }).max() else {
            return "Never"
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: mostRecentDate, relativeTo: Date())
    }

    var recentCigars: [Cigar] {
        cigars.sorted { $0.date > $1.date }.prefix(3).map { $0 }
    }

    var computedFlavorProfile: [String: Double] {
        let bodyToIntensity: [String: Double] = ["Mild": 1.0, "Medium": 2.0, "Full": 3.0]
        var flavorIntensities: [String: [Double]] = [:]
        for cigar in cigars {
            let intensity = bodyToIntensity[cigar.cigarBody] ?? 2.0
            for flavor in cigar.flavorNotes {
                flavorIntensities[flavor, default: []].append(intensity)
            }
        }
        return flavorIntensities.mapValues { intensities in
            let average = intensities.reduce(0.0, +) / Double(intensities.count)
            return (average - 1.0) * 2.5
        }
    }
}
