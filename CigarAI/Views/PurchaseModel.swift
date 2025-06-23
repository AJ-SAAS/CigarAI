import Combine
import RevenueCat
import SwiftUI

@MainActor
class PurchaseModel: ObservableObject {
    @Published var currentOffering: Offering?
    @Published var errorMessage: String?
    @Published var isPurchasing: Bool = false // Tracks purchase/restore state
    private var cigarViewModel: CigarViewModel?

    init() {
        fetchOfferings()
    }

    func fetchOfferings() {
        Purchases.shared.getOfferings { (offerings, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
                self.currentOffering = offerings?.current
                self.errorMessage = nil
            }
        }
    }

    func purchase(package: Package) {
        isPurchasing = true
        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
            DispatchQueue.main.async {
                self.isPurchasing = false
                if userCancelled {
                    print("Purchase cancelled by user")
                } else if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let customerInfo = customerInfo, customerInfo.activeSubscriptions.count > 0 {
                    self.cigarViewModel?.isSubscribed = true
                }
            }
        }
    }

    func restorePurchases() {
        isPurchasing = true
        Purchases.shared.restorePurchases { (customerInfo, error) in
            DispatchQueue.main.async {
                self.isPurchasing = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let customerInfo = customerInfo, customerInfo.activeSubscriptions.count > 0 {
                    self.cigarViewModel?.isSubscribed = true
                }
            }
        }
    }

    func setCigarViewModel(_ viewModel: CigarViewModel) {
        self.cigarViewModel = viewModel
    }
}

