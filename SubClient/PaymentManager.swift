import ApphudSDK
import Combine
import Foundation
import StoreKit

class PaymentManager: NSObject {
    let paywallID = "main"
    var productsApphud: [ApphudProduct] = []

    override init() {
        super.init()
    }

    // MARK: - Return true if subscriptions have been bought
    var hasUnlockedPro: Bool {
        return Apphud.hasPremiumAccess()
    }

    // MARK: - Start Purchase
    @MainActor func startPurchase(product: ApphudProduct, completion: @escaping (Bool) -> Void) {
        Apphud.purchase(product) { result in
            self.handlePurchaseResult(result, completion: completion)
        }
    }

    private func handlePurchaseResult(_ result: ApphudPurchaseResult, completion: @escaping (Bool) -> Void) {
        if let error = result.error {
            debugPrint(error.localizedDescription)
            completion(false)
            return
        }

        debugPrint(result)
        if let subscription = result.subscription, subscription.isActive() {
            completion(true)
        } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
            completion(true)
        } else {
            completion(Apphud.hasActiveSubscription())
        }
    }

    // MARK: - Restore Purchase
    @MainActor func restorePurchase(completion: @escaping (Bool) -> Void) {
        Apphud.restorePurchases { subscriptions, _, error in
            self.handleRestorePurchaseResult(subscriptions, error: error, completion: completion)
        }
    }

    private func handleRestorePurchaseResult(_ subscriptions: [ApphudSubscription]?, error: Error?, completion: @escaping (Bool) -> Void) {
        if let error = error {
            debugPrint(error.localizedDescription)
            completion(false)
            return
        }

        if subscriptions?.first?.isActive() ?? false || Apphud.hasActiveSubscription() {
            completion(true)
        } else {
            completion(false)
        }
    }

    // MARK: - Load Paywalls from AppHud
    @MainActor
    func loadPaywalls(completion: @escaping () -> Void) {
        Apphud.paywallsDidLoadCallback { paywalls, _ in
            self.processPaywalls(paywalls)
            completion()
        }
    }

    private func processPaywalls(_ paywalls: [ApphudPaywall]?) {
        guard let paywall = paywalls?.first(where: { $0.identifier == self.paywallID }) else {
            print("Paywall \(self.paywallID) not found.")
            return
        }

        self.productsApphud = paywall.products
        for product in self.productsApphud {
            self.logProductDetails(product)
        }
    }

    private func logProductDetails(_ product: ApphudProduct) {
        let id = product.productId
        let name = product.skProduct?.localizedTitle ?? "No title"
        let price = product.skProduct?.price.stringValue ?? "No price"
        let period = self.getSubscriptionPeriod(from: product)
        debugPrint("Product ID: \(id), Name: \(name), Price: \(price), Period: \(period)")
    }

    private func getSubscriptionPeriod(from product: ApphudProduct) -> String {
        switch product.skProduct?.subscriptionPeriod?.unit.rawValue {
        case 0: return "Неделя"
        case 1: return "Месяц"
        default: return "Год"
        }
    }

    // MARK: - Subscription Expiration Date
    @MainActor func getSubscriptionExpirationDateFormatted() -> String? {
        guard let subscription = Apphud.subscription(), subscription.isActive() else {
            return nil
        }

        let expirationDate = subscription.expiresDate
        return formatDate(expirationDate)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}
