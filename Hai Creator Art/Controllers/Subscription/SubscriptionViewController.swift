import ApphudSDK
import UIKit
import WebKit

struct Subscription {
    let name: String
    let price: String
    let weeklyPrice: String?
    let isFirst: Bool
}

final class SubscriptionViewController: UIViewController {
    // MARK: - Properties

    private let subImageView = UIImageView()
    private let shadowImageView = UIImageView()
    private let unrealView = UnrealView()
 
    private let privacyLabel = SFPrivacyButton()
    private let termsOfUseLabel = SFTermsOfUseButton()
    private let restoreLabel = SFRestorePurchaseButton()

    private let continueButton = HailuoButton()
    private let exitButton = UIButton(type: .system)
    private let cancelStackView = UIStackView()
    private let anytimeImageView = UIImageView()
    private let anytimeLabel = UILabel()

    private var plan: Int = 0
    private let isFromOnboarding: Bool
    private var subscriptions: [Subscription] = []
    private var purchaseManager: PaymentManager

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 61)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(SubCell.self, forCellWithReuseIdentifier: SubCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    // MARK: - Initializer

    init(isFromOnboarding: Bool) {
        self.isFromOnboarding = isFromOnboarding
        purchaseManager = PaymentManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bgPrimary
        drawSelf()

        plan = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(continueButtonTapped))
        continueButton.addGestureRecognizer(tapGesture)

        Task {
            await loadPaywallDetails()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            UIView.animate(withDuration: 1.0) {
                self?.exitButton.alpha = 1
            }
        }

        termsOfUseLabel.delegate = self
        privacyLabel.delegate = self
        restoreLabel.delegate = self
    }

    // MARK: - Private methods

    private func drawSelf() {
        subImageView.image = UIImage(named: "sub_upper_image")
        shadowImageView.image = UIImage(named: "sub_shadow_image")
        continueButton.setTitle(to: "Continue")
        anytimeImageView.image = UIImage(named: "sub_anytime_icon")

        exitButton.do { make in
            make.setImage(UIImage(named: "sub_exit_button"), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            make.alpha = 0
        }

        cancelStackView.do { make in
            make.axis = .horizontal
            make.spacing = 4
            make.alignment = .center
            make.distribution = .fill
        }

        anytimeLabel.do { make in
            make.text = "Cancel anytime"
            make.textAlignment = .left
            make.font = UIFont.CustomFont.caption1Regular
            make.textColor = UIColor.labelsQuaternary
        }

        cancelStackView.addArrangedSubviews([anytimeImageView, anytimeLabel])

        view.addSubviews(
            subImageView,
            shadowImageView,
            unrealView,
            collectionView,
            privacyLabel,
            restoreLabel,
            termsOfUseLabel,
            cancelStackView,
            continueButton,
            exitButton
        )

        subImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (487.0 / 844.0))
        }

        shadowImageView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (680.0 / 844.0))
        }

        unrealView.snp.makeConstraints { make in
            make.height.equalTo(130)
            make.leading.trailing.equalToSuperview().inset(16)
            if UIDevice.isIphoneBelowX {
                make.bottom.equalTo(collectionView.snp.top).offset(-8)
            } else {
                make.bottom.equalTo(collectionView.snp.top).offset(-28)
            }
        }

        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(cancelStackView.snp.top).offset(-24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0)
        }

        cancelStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-10)
        }
        
        privacyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(restoreLabel.snp.centerY)
            make.leading.equalToSuperview().offset(16)
        }
        
        restoreLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            make.centerX.equalToSuperview()
        }      
        
        termsOfUseLabel.snp.makeConstraints { make in
            make.centerY.equalTo(restoreLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(restoreLabel.snp.top).offset(-18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        exitButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func updateCollectionViewHeight() {
        let itemHeight: CGFloat = 61
        let spacing: CGFloat = 12
        let count = subscriptions.count
        let totalHeight = count > 0 ? (CGFloat(count) * itemHeight) + (CGFloat(count - 1) * spacing) : 0

        collectionView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }

        view.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        if isFromOnboarding {
            let tabBarController = TabBarController.shared
            let navigationController = UINavigationController(rootViewController: tabBarController)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.isHidden = true
            present(navigationController, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func continueButtonTapped() {
        Task {
            await purchaseSubscription(at: plan)
        }
    }

    private func purchaseSubscription(at index: Int) async {
        guard index >= 0, index < purchaseManager.productsApphud.count else { return }

        let selectedProduct = purchaseManager.productsApphud[index]
        await withCheckedContinuation { continuation in
            var isResumed = false

            purchaseManager.startPurchase(product: selectedProduct) { success in
                guard !isResumed else { return }
                isResumed = true

                if success {
                    print("succseed purchase!")
                } else {
                    print("failed purchase.")
                }

                continuation.resume()
            }
        }
    }

    private func loadPaywallDetails() async {
        await withCheckedContinuation { continuation in
            purchaseManager.loadPaywalls {
                continuation.resume()
            }
        }

        let products = purchaseManager.productsApphud
        guard let firstProduct = products.first(where: { $0.skProduct != nil }),
              let firstSkProduct = firstProduct.skProduct else { return }

        let firstPrice = firstSkProduct.price.doubleValue
        let firstTokens = Double(firstProduct.productId.components(separatedBy: "_").first ?? "0") ?? 0

        subscriptions = products
            .filter { $0.skProduct != nil }
            .enumerated()
            .map { index, product in
                guard let skProduct = product.skProduct else {
                    fatalError("skProduct is expected to be non-nil after filtering.")
                }

                let priceString = skProduct.price.stringValue
                let currencySymbol = skProduct.priceLocale.currencySymbol ?? ""
                let fullProductName = product.productId.components(separatedBy: "_").first ?? "N/A"
                let currentPrice = skProduct.price.doubleValue

                var period = "Unknown"
                var weeklyPrice: String = "N/A"

                if let subscriptionPeriod = skProduct.subscriptionPeriod {
                    let weeksPerMonth = 4.0
                    let weeksPerYear = 52.0

                    switch subscriptionPeriod.unit {
                    case .day:
                        period = "Weekly"
                        weeklyPrice = String(format: "%.2f", currentPrice)
                    case .week:
                        period = "Weekly"
                        weeklyPrice = String(format: "%.2f", currentPrice)
                    case .month:
                        period = "Monthly"
                        weeklyPrice = String(format: "%.2f", currentPrice / (weeksPerMonth * Double(subscriptionPeriod.numberOfUnits)))
                    case .year:
                        period = "Annual"
                        weeklyPrice = String(format: "%.2f", currentPrice / (weeksPerYear * Double(subscriptionPeriod.numberOfUnits)))
                    @unknown default:
                        period = "Unknown"
                        weeklyPrice = "N/A"
                    }
                }

                let weeklyPriceFinal = weeklyPrice ?? "N/A"
                let isFirst = index == 0
                return Subscription(
                    name: period,
                    price: "\(currencySymbol)\(priceString)",
                    weeklyPrice: "\(currencySymbol)\(weeklyPriceFinal)",
                    isFirst: isFirst
                )
            }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateCollectionViewHeight()
            self.selectInitialCell()
        }
    }
}

// MARK: - SFTermsOfUseDelegate
extension SubscriptionViewController: SFTermsOfUseDelegate {
    func termsOfUseTapped() {
        guard let url = URL(string: "https://docs.google.com/document/d/1QGsDbCsK4-4adHuZOsRfvXE029lc1iVb0vOKiUTH_nM/edit?usp=sharing") else {
            print("Invalid URL")
            return
        }

        let webView = WKWebView()
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.load(URLRequest(url: url))

        let webViewViewController = UIViewController()
        webViewViewController.view = webView

        present(webViewViewController, animated: true, completion: nil)
    }
}

// MARK: - SFPrivacyDelegate
extension SubscriptionViewController: SFPrivacyDelegate {
    func privacyTapped() {
        guard let url = URL(string: "https://docs.google.com/document/d/1kelhcY_r-CtKRVDh21FEFIH2dhyR2xRb8ak5T1Fh41Y/edit?usp=sharing") else {
            print("Invalid URL")
            return
        }

        let webView = WKWebView()
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.load(URLRequest(url: url))

        let webViewViewController = UIViewController()
        webViewViewController.view = webView

        present(webViewViewController, animated: true, completion: nil)
    }
}

// MARK: - SFRestrorePurchaseLabelDelegate
extension SubscriptionViewController: SFRestorePurchaseButtonDelegate {
    func didFailToRestorePurchases() {
        let alert = UIAlertController(title: "No Subscription Found",
                                      message: "We couldn’t find an active subscription for your account",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SubscriptionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubCell.identifier, for: indexPath) as? SubCell else {
            return UICollectionViewCell()
        }
        let subscription = subscriptions[indexPath.item]
        cell.configure(name: subscription.name, price: subscription.price, weeklyPrice: subscription.weeklyPrice, isFirst: subscription.isFirst)
        cell.configureAppearance(isSelected: indexPath.item == plan)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? SubCell else { return }

        UIView.animate(withDuration: 0.1, animations: {
            selectedCell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                selectedCell.transform = .identity
            }
        }

        for cell in collectionView.visibleCells {
            guard let subCell = cell as? SubCell else { continue }
            subCell.configureAppearance(isSelected: cell == selectedCell)
        }

        plan = indexPath.item
    }

    private func selectInitialCell() {
        let indexPath = IndexPath(item: plan, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? SubCell {
            cell.configureAppearance(isSelected: true)
        }
    }
}
