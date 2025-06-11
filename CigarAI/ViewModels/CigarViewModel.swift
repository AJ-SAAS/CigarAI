import Foundation
import FirebaseFirestore
import FirebaseAuth

class CigarViewModel: ObservableObject {
    // Published Properties
    @Published var cigars: [Cigar] = []
    @Published var smokingFrequency: String = ""
    @Published var experienceLevel: String = ""
    @Published var goals: [String] = []
    @Published var flavorPreferences: [String] = []
    @Published var dislikedFlavors: String = ""
    @Published var cigarStrength: String = ""
    @Published var cigarSizes: [String] = []
    @Published var weights: [String] = []
    @Published var originPreferences: [String] = []
    @Published var beveragePreferences: [String] = []
    @Published var smokingContext: [String] = []
    @Published var hasInventory: String = ""
    @Published var trackingDetail: String? = nil
    @Published var conciergePreferences: [String] = []
    @Published var inferPreferences: Bool = false
    @Published var knownCigars: String = ""
    @Published var joinCommunity: String = ""
    @Published var additionalNotes: String = ""
    
    // Firebase and Configuration
    private let db = Firestore.firestore()
    private let isPreview: Bool
    private var cigarsListener: ListenerRegistration?
    private var preferencesListener: ListenerRegistration?

    init(isPreview: Bool = false) {
        self.isPreview = isPreview
        if isPreview {
            self.cigars = [
                Cigar(id: nil, name: "Padron 1964", wrapper: "Maduro", cigarBody: "Full", flavorNotes: ["Earthy", "Nutty"], rating: 5, date: Date().addingTimeInterval(-7 * 24 * 60 * 60), quantity: nil),
                Cigar(id: nil, name: "Cohiba Robusto", wrapper: "Claro", cigarBody: "Medium", flavorNotes: ["Creamy", "Woody"], rating: 4, date: Date().addingTimeInterval(-5 * 24 * 60 * 60), quantity: nil),
                Cigar(id: nil, name: "Montecristo No. 2", wrapper: "Natural", cigarBody: "Medium", flavorNotes: ["Woody", "Spicy"], rating: 4, date: Date().addingTimeInterval(-3 * 24 * 60 * 60), quantity: nil)
            ]
            self.smokingFrequency = "Weekly"
            self.experienceLevel = "Intermediate"
            self.goals = ["Discover cigars", "Log experiences"]
            self.flavorPreferences = ["Creamy", "Nutty"]
            self.cigarStrength = "Medium"
            self.cigarSizes = ["Robusto"]
            self.weights = ["Maduro"]
            self.beveragePreferences = ["Bourbon"]
            self.originPreferences = ["Nicaragua"]
            self.smokingContext = ["Relaxing"]
            self.hasInventory = "Yes"
            self.trackingDetail = "Moderate"
            self.conciergePreferences = ["Cigar recommendations"]
            self.joinCommunity = "Yes"
            print("Preview: Initialized with \(cigars.count) cigars and sample survey data")
        }
    }

    func addInventoryItem(name: String, quantity: Int) {
        guard !isPreview else {
            let newCigar = Cigar(id: UUID().uuidString, name: name, wrapper: "", cigarBody: "", flavorNotes: [], rating: 0, date: Date(), quantity: quantity)
            cigars.append(newCigar)
            print("Preview: Added inventory item '\(name)' with quantity: \(quantity)")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("Error: No authenticated user")
            return
        }
        print("Attempting to save inventory item '\(name)' for user: \(userId), email: \(email)")
        let inventoryItem = Cigar(id: nil, name: name, wrapper: "", cigarBody: "", flavorNotes: [], rating: 0, date: Date(), quantity: quantity)
        do {
            let docRef = try db.collection("users").document(userId).collection("inventory").addDocument(from: inventoryItem)
            print("Successfully saved inventory item '\(name)' with ID: \(docRef.documentID) for user: \(userId)")
        } catch {
            print("Error saving inventory item: \(error.localizedDescription) (Code: \((error as NSError).code))")
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
            DispatchQueue.main.async { self.cigars = [] }
            return
        }
        print("Fetching cigars for user: \(userId), email: \(email)")
        cigarsListener?.remove()
        cigarsListener = db.collection("users").document(userId).collection("cigars").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching cigars: \(error.localizedDescription) (Code: \((error as NSError).code))")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No cigars found for user: \(userId)")
                DispatchQueue.main.async { self.cigars = [] }
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
            DispatchQueue.main.async { self.cigars = fetchedCigars }
            print("Updated cigars array with \(fetchedCigars.count) items")
        }
    }

    func saveUserPreferences() {
        guard !isPreview else {
            print("Preview: Saving sample user preferences")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("Error: No authenticated user for saving preferences")
            return
        }
        print("Saving preferences for user: \(userId), email: \(email)")
        let preferences: [String: Any] = [
            "smokingFrequency": smokingFrequency,
            "experienceLevel": experienceLevel,
            "goals": goals,
            "flavorPreferences": flavorPreferences,
            "dislikedFlavors": dislikedFlavors,
            "cigarStrength": cigarStrength,
            "cigarSizes": cigarSizes,
            "weights": weights,
            "originPreferences": originPreferences,
            "beveragePreferences": beveragePreferences,
            "smokingContext": smokingContext,
            "hasInventory": hasInventory,
            "trackingDetail": trackingDetail ?? "",
            "conciergePreferences": conciergePreferences,
            "inferPreferences": inferPreferences,
            "knownCigars": knownCigars,
            "joinCommunity": joinCommunity,
            "additionalNotes": additionalNotes,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(userId).setData(["Preferences": preferences], merge: true) { error in
            if let error = error {
                print("Error saving preferences: \(error.localizedDescription) (Code: \((error as NSError).code))")
            } else {
                print("Successfully saved preferences for user: \(userId)")
            }
        }
    }

    func fetchUserPreferences() {
        guard !isPreview else {
            print("Preview: Fetching sample user preferences")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("Error: No authenticated user for fetching preferences")
            return
        }
        print("Fetching preferences for user: \(userId), email: \(email)")
        preferencesListener?.remove()
        preferencesListener = db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching preferences: \(error.localizedDescription) (Code: \((error as NSError).code))")
                return
            }
            guard let document = snapshot, document.exists, let data = document.data(),
                  let preferences = data["Preferences"] as? [String: Any] else {
                print("No preferences found for user: \(userId)")
                return
            }
            DispatchQueue.main.async {
                self.smokingFrequency = preferences["smokingFrequency"] as? String ?? ""
                self.experienceLevel = preferences["experienceLevel"] as? String ?? ""
                self.goals = preferences["goals"] as? [String] ?? []
                self.flavorPreferences = preferences["flavorPreferences"] as? [String] ?? []
                self.dislikedFlavors = preferences["dislikedFlavors"] as? String ?? ""
                self.cigarStrength = preferences["cigarStrength"] as? String ?? ""
                self.cigarSizes = preferences["cigarSizes"] as? [String] ?? []
                self.weights = preferences["weights"] as? [String] ?? []
                self.originPreferences = preferences["originPreferences"] as? [String] ?? []
                self.beveragePreferences = preferences["beveragePreferences"] as? [String] ?? []
                self.smokingContext = preferences["smokingContext"] as? [String] ?? []
                self.hasInventory = preferences["hasInventory"] as? String ?? ""
                self.trackingDetail = preferences["trackingDetail"] as? String
                self.conciergePreferences = preferences["conciergePreferences"] as? [String] ?? []
                self.inferPreferences = preferences["inferPreferences"] as? Bool ?? false
                self.knownCigars = preferences["knownCigars"] as? String ?? ""
                self.joinCommunity = preferences["joinCommunity"] as? String ?? ""
                self.additionalNotes = preferences["additionalNotes"] as? String ?? ""
                print("Successfully fetched preferences for user: \(userId)")
            }
        }
    }

    func cleanupListeners() {
        cigarsListener?.remove()
        preferencesListener?.remove()
        print("Cleaned up Firestore listeners")
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
            return "None"
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
        if cigars.isEmpty && !flavorPreferences.isEmpty {
            let intensity = bodyToIntensity[cigarStrength] ?? 2.0
            for flavor in flavorPreferences {
                flavorIntensities[flavor, default: []].append(intensity)
            }
        }
        for cigar in cigars {
            let intensity = bodyToIntensity[cigar.cigarBody] ?? 2.0
            for flavor in cigar.flavorNotes {
                flavorIntensities[flavor, default: []].append(intensity)
            }
        }
        return flavorIntensities.mapValues { intensities in
            let average = intensities.reduce(0.0, +) / Double(intensities.count)
            return (average - 1.0) * 50
        }
    }

    func recommendCigars() -> [String] {
        var recommendations: [String] = []
        if flavorPreferences.contains("Creamy") && cigarStrength == "Mild" {
            recommendations.append("Davidoff Signature No. 2")
        }
        if flavorPreferences.contains("Spicy") && cigarStrength.contains("Full") {
            recommendations.append("Partagas Serie D No. 4")
        }
        if weights.contains("Maduro") {
            recommendations.append("Padron 1964 Anniversary")
        }
        if originPreferences.contains("Nicaragua") {
            recommendations.append("Oliva Serie V")
        }
        return recommendations.isEmpty ? ["Try a Cohiba Robusto to start!"] : recommendations
    }
}
