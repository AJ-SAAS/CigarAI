import Foundation
import FirebaseFirestore
import FirebaseAuth
import RevenueCat

@MainActor
class CigarViewModel: ObservableObject {
    @Published var cigars: [Cigar] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isNewUser: Bool = false
    @Published var isSubscribed: Bool = false

    private let db = Firestore.firestore()
    private let isPreview: Bool
    private var cigarsListener: ListenerRegistration?
    private var preferencesListener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    private var lastFetchTime: Date?
    private let fetchCooldown: TimeInterval = 60

    init(isPreview: Bool = false) {
        self.isPreview = isPreview
        if isPreview {
            self.cigars = [
                Cigar(id: UUID().uuidString, name: "Padron 1964", wrapper: "Maduro", cigarBody: "Full", flavorNotes: ["Earthy", "Nutty"], rating: 5, date: Date().addingTimeInterval(-7 * 24 * 60 * 60), quantity: nil),
                Cigar(id: UUID().uuidString, name: "Cohiba Robusto", wrapper: "Claro", cigarBody: "Medium", flavorNotes: ["Creamy", "Woody"], rating: 4, date: Date().addingTimeInterval(-5 * 24 * 60 * 60), quantity: nil),
                Cigar(id: UUID().uuidString, name: "Montecristo No. 2", wrapper: "Natural", cigarBody: "Medium", flavorNotes: ["Woody", "Spicy"], rating: 4, date: Date().addingTimeInterval(-3 * 24 * 60 * 60), quantity: nil)
            ]
            self.isNewUser = true
            self.isSubscribed = true
            print("CigarViewModel: Preview initialized with \(cigars.count) sticks: \(cigars.map { $0.name })")
        } else {
            print("CigarViewModel: Checking auth state - User ID: \(Auth.auth().currentUser?.uid ?? "nil"), Email: \(Auth.auth().currentUser?.email ?? "nil")")
            self.authListener = Auth.auth().addStateDidChangeListener { auth, user in
                print("CigarViewModel: Auth state changed - User ID: \(user?.uid ?? "nil"), Email: \(user?.email ?? "nil")")
            }
            fetchUserPreferences()
            setupRevenueCat()
            print("CigarViewModel: Initialized for live mode")
        }
    }

    func resetForSignOut() {
        hasCompletedOnboarding = false
        isNewUser = true
        isSubscribed = false
        cigars.removeAll()
        cleanupListeners()
        lastFetchTime = nil
        print("CigarViewModel: Reset for sign-out - hasCompletedOnboarding: \(hasCompletedOnboarding), isNewUser: \(isNewUser)")
    }

    private func setupRevenueCat() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let self else { return }
            if let customerInfo {
                self.isSubscribed = customerInfo.entitlements["premium_access"]?.isActive == true
                print("CigarViewModel: Initial subscription status: \(self.isSubscribed)")
            } else if let error {
                print("CigarViewModel: Error fetching customer info: \(error.localizedDescription)")
            }
        }

        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                self.isSubscribed = customerInfo.entitlements["premium_access"]?.isActive == true
                print("CigarViewModel: Updated subscription status: \(self.isSubscribed)")
            }
        }
    }

    func addInventoryItem(name: String, quantity: Int) {
        guard !isPreview else {
            let newCigar = Cigar(id: UUID().uuidString, name: name, wrapper: "", cigarBody: "", flavorNotes: [], rating: 0, date: Date(), quantity: quantity)
            cigars.append(newCigar)
            print("CigarViewModel: Preview added inventory item '\(name)' with quantity: \(quantity)")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("CigarViewModel: Error: No authenticated user for adding inventory item. Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")
            return
        }
        print("CigarViewModel: Attempting to save inventory item '\(name)' for user: \(userId), email: \(email)")
        let inventoryItem = Cigar(id: nil, name: name, wrapper: "", cigarBody: "", flavorNotes: [], rating: 0, date: Date(), quantity: quantity)
        do {
            let docRef = try db.collection("users").document(userId).collection("inventory").addDocument(from: inventoryItem)
            print("CigarViewModel: Successfully saved inventory item '\(name)' with ID: \(docRef.documentID) for user: \(userId)")
            fetchCigars() // Attempt to refresh UI
        } catch {
            print("CigarViewModel: Error saving inventory item: \(error.localizedDescription) (Code: \((error as NSError).code)), Details: \((error as NSError).userInfo)")
        }
    }

    func addCigar(_ cigar: Cigar) -> Bool {
        guard !isPreview else {
            var newCigar = cigar
            newCigar.id = UUID().uuidString
            cigars.append(newCigar)
            print("CigarViewModel: Preview added stick '\(newCigar.name)' with ID: \(newCigar.id ?? "nil")")
            return true
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("CigarViewModel: Error: No authenticated user for adding stick. Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")
            return false
        }
        if !isSubscribed && totalCigarsLogged >= 5 {
            print("CigarViewModel: Free tier limit reached: \(totalCigarsLogged)/5 sticks")
            return false
        }
        print("CigarViewModel: Attempting to save stick '\(cigar.name)' for user: \(userId), email: \(email)")
        do {
            var newCigar = cigar
            newCigar.id = nil
            let docRef = try db.collection("users").document(userId).collection("sticks").addDocument(from: newCigar)
            print("CigarViewModel: Saved stick '\(newCigar.name)' to Firestore with ID: \(docRef.documentID) for user: \(userId)")
            fetchCigars() // Refresh UI
            return true
        } catch {
            print("CigarViewModel: Error saving stick: \(error.localizedDescription) (Code: \((error as NSError).code)), Details: \((error as NSError).userInfo)")
            return false
        }
    }

    func deleteCigar(cigarId: String) {
        guard !isPreview else {
            cigars.removeAll { $0.id == cigarId }
            print("CigarViewModel: Preview deleted stick with ID: \(cigarId)")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("CigarViewModel: Error: No authenticated user for deleting stick. Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")
            return
        }
        print("CigarViewModel: Attempting to delete stick with ID: \(cigarId) for user: \(userId), email: \(email)")
        db.collection("users").document(userId).collection("sticks").document(cigarId).delete { error in
            if let error {
                print("CigarViewModel: Error deleting stick: \(error.localizedDescription) (Code: \((error as NSError).code)), Details: \((error as NSError).userInfo)")
            } else {
                print("CigarViewModel: Successfully deleted stick with ID: \(cigarId) for user: \(userId)")
                DispatchQueue.main.async {
                    self.cigars.removeAll { $0.id == cigarId }
                }
            }
        }
    }

    func fetchCigars() {
        guard !isPreview else {
            print("CigarViewModel: Preview fetching \(cigars.count) sticks: \(cigars.map { $0.name })")
            return
        }
        guard let lastFetch = lastFetchTime, Date().timeIntervalSince(lastFetch) < fetchCooldown else {
            performCigarFetch()
            return
        }
        print("CigarViewModel: Skipping stick fetch due to cooldown (last fetch: \(lastFetchTime?.description ?? "never"))")
    }

    private func performCigarFetch() {
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("CigarViewModel: Error: No authenticated user, clearing sticks. Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")
            DispatchQueue.main.async { self.cigars = [] }
            return
        }
        print("CigarViewModel: Fetching sticks for user: \(userId), email: \(email)")
        cigarsListener?.remove()
        cigarsListener = db.collection("users").document(userId).collection("sticks").addSnapshotListener { snapshot, error in
            if let error {
                print("CigarViewModel: Error fetching sticks: \(error.localizedDescription) (Code: \((error as NSError).code)), Details: \((error as NSError).userInfo)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("CigarViewModel: No sticks found for user: \(userId)")
                DispatchQueue.main.async { self.cigars = [] }
                return
            }
            let fetchedCigars = documents.compactMap { document in
                do {
                    let cigar = try document.data(as: Cigar.self)
                    print("CigarViewModel: Fetched stick: '\(cigar.name)' with ID: \(cigar.id ?? "nil")")
                    return cigar
                } catch {
                    print("CigarViewModel: Error decoding stick \(document.documentID): \(error.localizedDescription), Details: \((error as NSError).userInfo)")
                    return nil
                }
            }
            DispatchQueue.main.async {
                self.cigars = fetchedCigars
                self.lastFetchTime = Date()
                print("CigarViewModel: Updated sticks array with \(fetchedCigars.count) items: \(fetchedCigars.map { $0.name })")
            }
        }
    }

    func saveUserPreferences() {
        guard !isPreview else {
            print("CigarViewModel: Preview saving sample user preferences")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("CigarViewModel: Error: No authenticated user for saving preferences. Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")
            return
        }
        print("CigarViewModel: Saving preferences for user: \(userId), email: \(email)")
        let preferences: [String: Any] = [
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "isNewUser": isNewUser,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(userId).setData(["Preferences": preferences], merge: true) { error in
            if let error {
                print("CigarViewModel: Error saving preferences: \(error.localizedDescription) (Code: \((error as NSError).code)), Details: \((error as NSError).userInfo)")
            } else {
                print("CigarViewModel: Successfully saved preferences for user: \(userId)")
            }
        }
    }

    func fetchUserPreferences() {
        guard !isPreview else {
            print("CigarViewModel: Preview fetching sample user preferences")
            return
        }
        guard let lastFetch = lastFetchTime, Date().timeIntervalSince(lastFetch) < fetchCooldown else {
            performPreferencesFetch()
            return
        }
        print("CigarViewModel: Skipping preferences fetch due to cooldown (last fetch: \(lastFetchTime?.description ?? "never"))")
    }

    private func performPreferencesFetch() {
        guard let userId = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            print("CigarViewModel: Error: No authenticated user for fetching preferences. Current user ID: \(Auth.auth().currentUser?.uid ?? "nil")")
            return
        }
        print("CigarViewModel: Fetching preferences for user: \(userId), email: \(email)")
        preferencesListener?.remove()
        preferencesListener = db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            if let error {
                print("CigarViewModel: Error fetching preferences: \(error.localizedDescription) (Code: \((error as NSError).code)), Details: \((error as NSError).userInfo)")
                return
            }
            guard let document = snapshot, document.exists, let data = document.data(),
                  let preferences = data["Preferences"] as? [String: Any] else {
                print("CigarViewModel: No preferences found for user: \(userId)")
                return
            }
            DispatchQueue.main.async {
                self.hasCompletedOnboarding = preferences["hasCompletedOnboarding"] as? Bool ?? false
                self.isNewUser = preferences["isNewUser"] as? Bool ?? false
                self.lastFetchTime = Date()
                print("CigarViewModel: Successfully fetched preferences for user: \(userId), hasCompletedOnboarding: \(self.hasCompletedOnboarding)")
            }
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        isNewUser = false
        saveUserPreferences()
        print("CigarViewModel: Onboarding completed - hasCompletedOnboarding: \(hasCompletedOnboarding)")
    }

    func cleanupListeners() {
        cigarsListener?.remove()
        preferencesListener?.remove()
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
        print("CigarViewModel: Cleaned up Firestore and Auth listeners")
    }

    func shouldShowPaywall(for action: PaywallAction) -> Bool {
        switch action {
        case .addCigar:
            return !isSubscribed && totalCigarsLogged >= 5
        case .accessProfile, .accessChatbot:
            return !isSubscribed
        }
    }

    var totalCigarsLogged: Int {
        cigars.count
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
}

enum PaywallAction {
    case addCigar
    case accessProfile
    case accessChatbot
}

