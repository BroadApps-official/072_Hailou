import ApphudSDK
import Combine
import Foundation
import StoreKit

class PurchaseManager: NSObject {
    let paywallID = "main"
    var productsApphud: [ApphudProduct] = []

    override init() {
        super.init()
    }

    // MARK: - Return true if subscriptions has been bought
    var hasUnlockedPro: Bool {
        return Apphud.hasPremiumAccess()
    }

    // MARK: - Payment Start
    @MainActor func startPurchase(produst: ApphudProduct, escaping: @escaping (Bool) -> Void) {
        let selectedProduct = produst
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            debugPrint(result)
            if let subscription = result.subscription, subscription.isActive() {
                escaping(true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                escaping(true)
            } else {
                if Apphud.hasActiveSubscription() {
                    escaping(true)
                }
            }
        }
    }

    // MARK: - Restore Purchase
    @MainActor func restorePurchase(escaping: @escaping (Bool) -> Void) {
        Apphud.restorePurchases { subscriptions, _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            if subscriptions?.first?.isActive() ?? false {
                escaping(true)
                return
            }

            if Apphud.hasActiveSubscription() {
                escaping(true)
            }
        }
    }

    // MARK: - Load Paywalls from AppHud
    @MainActor
    func loadPaywalls(completion: @escaping () -> Void) {
        Apphud.paywallsDidLoadCallback { paywalls, _ in
            if let paywall = paywalls.first(where: { $0.identifier == self.paywallID }) {
                self.productsApphud = paywall.products
                for product in self.productsApphud {
                    let id = product.productId
                    let name = product.skProduct?.localizedTitle ?? "No title"
                    let price = product.skProduct?.price.stringValue ?? "No price"
                    let period = product.skProduct?.subscriptionPeriod?.unit.rawValue == 0 ? "Неделя"
                        : product.skProduct?.subscriptionPeriod?.unit.rawValue == 1 ? "Месяц"
                        : "Год"
                }
            } else {
                print("Paywall \(self.paywallID) not found.")
            }
            completion()
        }
    }

    // MARK: - Subscription Expiration Date
    @MainActor func getSubscriptionExpirationDateFormatted() -> String? {
        guard let subscription = Apphud.subscription(), subscription.isActive() else {
            return nil
        }

        let expirationDate = subscription.expiresDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: expirationDate)
    }
}
