import ApphudSDK
import MessageUI
import SafariServices
import StoreKit
import UIKit
import WebKit

final class SettingsViewController: UIViewController {
    // MARK: - Properties

    private let firstStackView = UIStackView()
    private let secondStackView = UIStackView()
    private let thirdStackView = UIStackView()
    
    private let rateView = SettingsView(type: .rate)
    private let upgradeView = SettingsView(type: .upgrade)
    private let cacheView = SettingsView(type: .cache)
    private let restoreView = SettingsView(type: .restore)
    private let contactView = SettingsView(type: .contact)
    private let privacyView = SettingsView(type: .privacyPolicy)
    private let usageView = SettingsView(type: .usagePolicy)
    private let notificationsView = NotificationsView()

    private let supportLabel = UILabel()
    private let purchaseLabel = UILabel()
    private let infoLabel = UILabel()
    private let versionLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let purchaseManager = PaymentManager()

    private let privacyURL: URL = {
        guard let url = URL(string: "https://docs.google.com/document/d/1kelhcY_r-CtKRVDh21FEFIH2dhyR2xRb8ak5T1Fh41Y/edit?usp=sharing") else {
            fatalError("Invalid URL for privacyPolicyURL")
        }
        return url
    }()

    private let usageURL: URL = {
        guard let url = URL(string: "https://docs.google.com/document/d/1QGsDbCsK4-4adHuZOsRfvXE029lc1iVb0vOKiUTH_nM/edit?usp=sharing") else {
            fatalError("Invalid URL for usagePolicyURL")
        }
        return url
    }()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.backgroundColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()

        navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)

        setupTitle()
        setupBackButton()
        if !purchaseManager.hasUnlockedPro {
            setupProButton()
        }

        view.backgroundColor = UIColor.bgPrimary

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        drawSelf()
        configureConstraints()
        
        rateView.delegate = self
        upgradeView.delegate = self
        cacheView.delegate = self
        restoreView.delegate = self
        contactView.delegate = self
        privacyView.delegate = self
        usageView.delegate = self
        notificationsView.delegate = self
    }

    private func setupTitle() {
        navigationItem.title = "Settings"

        if let titleLabel = navigationController?.navigationBar.topItem?.titleView as? UILabel {
            titleLabel.font = UIFont.CustomFont.title1Bold
            titleLabel.textColor = .white
        } else {
            let titleLabel = UILabel()
            titleLabel.text = "Settings"
            titleLabel.font = UIFont.CustomFont.title1Bold
            titleLabel.textColor = .white
            navigationItem.titleView = titleLabel
        }
    }

    private func setupBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "set_back_button"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func setupProButton() {
        let proButton = UIButton(type: .custom)
        proButton.setImage(UIImage(named: "set_pro_button"), for: .normal)
        proButton.addTarget(self, action: #selector(customProButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: proButton)
    }

    private func drawSelf() {
        rateView.configureSettingsView(icon: UIImage(named: "set_rate_icon"), title: "Rate app")
        upgradeView.configureSettingsView(icon: UIImage(named: "set_upgrade_icon"), title: "Upgrade plan")
        cacheView.configureSettingsView(icon: UIImage(named: "set_cashe_icon"), title: "Clear cache")
        restoreView.configureSettingsView(icon: UIImage(named: "set_restore_icon"), title: "Restore purchases")
        contactView.configureSettingsView(icon: UIImage(named: "set_contact_icon"), title: "Contact us")
        privacyView.configureSettingsView(icon: UIImage(named: "set_privacy_icon"), title: "Privacy Policy")
        usageView.configureSettingsView(icon: UIImage(named: "set_usage_icon"), title: "Usage Policy")
        notificationsView.configureNotificationsView(icon: UIImage(named: "set_notifications_icon"), title: "Notifications")
        
        [firstStackView, secondStackView, thirdStackView].forEach { stackView in
            stackView.do { make in
                make.axis = .vertical
                make.spacing = 8
            }
        }

        [supportLabel, purchaseLabel, infoLabel].forEach { label in
            label.do { make in
                make.font = UIFont.CustomFont.headlineRegular
                make.textColor = UIColor.labelsScondary
                make.textAlignment = .left
            }
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.do { make in
                make.text = "\("App Version"): \(version)"
                make.font = UIFont.CustomFont.footnoteRegular
                make.textColor = UIColor.labelsTertiary
                make.textAlignment = .center
            }
        }

        supportLabel.text = "Support us"
        purchaseLabel.text = "Purchases & Actions"
        infoLabel.text = "Info & legal"

        firstStackView.addArrangedSubviews(
            [rateView]
        )

        secondStackView.addArrangedSubviews(
            [upgradeView, notificationsView, cacheView, restoreView]
        )

        thirdStackView.addArrangedSubviews(
            [contactView, privacyView, usageView]
        )

        scrollView.addSubviews(contentView)

        contentView.addSubviews(
            supportLabel,
            firstStackView,
            purchaseLabel,
            secondStackView,
            infoLabel,
            thirdStackView,
            versionLabel
        )

        view.addSubviews(scrollView)
    }

    private func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        supportLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(18)
        }

        firstStackView.snp.makeConstraints { make in
            make.top.equalTo(supportLabel.snp.bottom).offset(14)
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        purchaseLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(firstStackView.snp.bottom).offset(28)
            make.height.equalTo(18)
        }

        secondStackView.snp.makeConstraints { make in
            make.top.equalTo(purchaseLabel.snp.bottom).offset(14)
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }

        infoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(secondStackView.snp.bottom).offset(28)
            make.height.equalTo(18)
        }

        thirdStackView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(14)
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalTo(148)
        }

        [upgradeView, restoreView, notificationsView, cacheView,
         rateView, contactView, privacyView, usageView].forEach { label in
            label.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }

        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(thirdStackView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
    }

    @objc private func customProButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05, animations: {
            sender.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.alpha = 1.0
            }
        }

        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }

    private func sendEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Error", message: "Mail services are not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setToRecipients(["hgrammpfwoah46457@gmail.com"])
        mailComposeVC.setSubject("Support Request")
        let userId = Apphud.userID()
        let messageBody = """
        Please describe your issue here.





        User ID: \(userId)
        """
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        mailComposeVC.mailComposeDelegate = self

        present(mailComposeVC, animated: true, completion: nil)
    }

    // MARK: - Restore Purchases
    private func restorePurchases() {
        let purchaseManager = PaymentManager()
        purchaseManager.restorePurchase { success in
            if success {
                debugPrint("restorePurchase succeed.")
            } else {
                debugPrint("restorePurchase failed.")
                let alert = UIAlertController(title: "No Subscription Found",
                                              message: "We couldn’t find an active subscription for your account",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                alert.overrideUserInterfaceStyle = .dark
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SKPaymentQueueDelegate
extension SettingsViewController: SKPaymentQueueDelegate {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let alert = UIAlertController(title: "Restore Purchases", message: "Your purchases have been restored.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "There was an error restoring your purchases. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - SettingsViewDelegate
extension SettingsViewController: SettingsViewDelegate {
    func tapSettingsView(type: SettingsView.SettingsType) {
        switch type {
        case .rate:
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6743743577?action=write-review") else {
                    return
                }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: "Error",
                                                  message: "Unable to open App Store",
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    alert.overrideUserInterfaceStyle = .dark
                    self.present(alert, animated: true)
                }
            }
        case .upgrade:
            let subscriptionVC = SubscriptionViewController(isFromOnboarding: false)
            subscriptionVC.modalPresentationStyle = .fullScreen
            present(subscriptionVC, animated: true, completion: nil)
        case .cache:
            let alertController = UIAlertController(title: "Delete Data",
                                                    message: "Are you sure you want to delete all data?",
                                                    preferredStyle: .alert)

            let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                StorageManager.shared.clearAllGeneratedVideosAndCache()
            }

            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            alertController.overrideUserInterfaceStyle = .dark
            present(alertController, animated: true, completion: nil)
        case .restore:
            restorePurchases()
        case .contact:
            sendEmail()
        case .privacyPolicy:
            let webView = WKWebView()
            webView.navigationDelegate = self as? WKNavigationDelegate
            webView.load(URLRequest(url: privacyURL))

            let webViewViewController = UIViewController()
            webViewViewController.view = webView

            present(webViewViewController, animated: true, completion: nil)
        case .usagePolicy:
            let webView = WKWebView()
            webView.navigationDelegate = self as? WKNavigationDelegate
            webView.load(URLRequest(url: usageURL))

            let webViewViewController = UIViewController()
            webViewViewController.view = webView

            present(webViewViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - NotificationsViewDelegate
extension SettingsViewController: NotificationsViewDelegate {
    func tapNotificationsView(switchValue: Bool) {
        print("Notifications: \(switchValue)")
    }
}
