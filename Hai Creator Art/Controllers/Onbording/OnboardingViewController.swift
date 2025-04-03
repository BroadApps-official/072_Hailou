import StoreKit
import UIKit

final class OnboardingViewController: UIViewController {
    // MARK: - Life cycle

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pagesViewControllers = [UIViewController]()

    private var currentPage: OnboardingPageViewController.Page = .effects

    private lazy var first = OnboardingPageViewController(page: .effects)
    private lazy var second = OnboardingPageViewController(page: .photo)
    private lazy var third = OnboardingPageViewController(page: .request)
    private lazy var fourth = OnboardingPageViewController(page: .rate)
    private lazy var fifth = OnboardingPageViewController(page: .notifications)

    private let continueButton = HailuoButton()
    private let laterLabel = UILabel()

    private let firstCircleView = UIView()
    private let secondCircleView = UIView()
    private let thirdCircleView = UIView()
    private let fourthCircleView = UIView()
    private let circleStackView = UIStackView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pagesViewControllers += [first, second, third, fourth, fifth]
        drawSelf()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func drawSelf() {
        view.backgroundColor = UIColor.bgMain
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        addChildController(pageViewController, inside: view)
        if let pageFirst = pagesViewControllers.first {
            pageViewController.setViewControllers([pageFirst], direction: .forward, animated: false)
        }
        pageViewController.dataSource = self

        for subview in pageViewController.view.subviews {
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = false
                break
            }
        }

        firstCircleView.backgroundColor = .white
        secondCircleView.backgroundColor = .white.withAlphaComponent(0.5)
        thirdCircleView.backgroundColor = .white.withAlphaComponent(0.5)
        fourthCircleView.backgroundColor = .white.withAlphaComponent(0.5)

        [firstCircleView, secondCircleView, thirdCircleView,
         fourthCircleView].forEach { view in
            view.do { make in
                make.layer.cornerRadius = 4
            }
        }

        circleStackView.do { make in
            make.axis = .horizontal
            make.spacing = 8
            make.distribution = .fill
        }

        laterLabel.do { make in
            make.text = L.maybeLater()
            make.font = UIFont.CustomFont.subheadlineRegular
            make.textColor = UIColor.textSecondary
            make.isHidden = true
        }

        circleStackView.addArrangedSubviews(
            [firstCircleView, secondCircleView, thirdCircleView,
             fourthCircleView]
        )
        view.addSubviews(continueButton, circleStackView, laterLabel)

        [firstCircleView, secondCircleView, thirdCircleView,
         fourthCircleView].forEach { view in
            view.snp.makeConstraints { make in
                make.size.equalTo(8)
            }
        }

        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        circleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-20)
            make.width.equalTo(56)
            make.height.equalTo(8)
        }

        laterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
}

// MARK: - OnboardingPageViewControllerDelegate
extension OnboardingViewController {
    @objc private func didTapContinueButton() {
        switch currentPage {
        case .effects:
            pageViewController.setViewControllers([second], direction: .forward, animated: true)
            currentPage = .photo
            circleStackView.addArrangedSubviews(
                [secondCircleView, firstCircleView, thirdCircleView, fourthCircleView]
            )
        case .photo:
            pageViewController.setViewControllers([third], direction: .forward, animated: true)
            currentPage = .request
            circleStackView.addArrangedSubviews(
                [secondCircleView, thirdCircleView, firstCircleView, fourthCircleView]
            )
        case .request:
            pageViewController.setViewControllers([fourth], direction: .forward, animated: true)
            currentPage = .rate
            circleStackView.addArrangedSubviews(
                [secondCircleView, thirdCircleView, fourthCircleView, firstCircleView]
            )
        case .rate:
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }

            pageViewController.setViewControllers([fifth], direction: .forward, animated: true)
            currentPage = .notifications
            circleStackView.isHidden = true
            laterLabel.isHidden = false

            continueButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-46)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(48)
            }

        case .notifications:
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.openSubVC()
                }
            }
        }
    }

    @objc private func openSubVC() {
        let subscriptionVC = SubscriptionViewController(isFromOnboarding: true)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index + 1]
    }
}

extension UIViewController {
    func addChildController(_ childViewController: UIViewController, inside containerView: UIView?) {
        childViewController.willMove(toParent: self)
        containerView?.addSubview(childViewController.view)

        addChild(childViewController)

        childViewController.didMove(toParent: self)
    }
}
