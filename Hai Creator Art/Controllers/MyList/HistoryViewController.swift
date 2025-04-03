import SnapKit
import UIKit

final class HistoryViewController: UIViewController {
    private let purchaseManager = PaymentManager()

    private let emptyHistoryView = EmptyHistoryView()
    private var selectorView = SelectorView(selectedIndex: 0, frame: .zero)
    private var selectedIndex: Int = 0
    private var videoModels: [GeneratedVideo] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: HistoryCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

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
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()

        view.backgroundColor = UIColor.bgPrimary

        if !purchaseManager.hasUnlockedPro {
            setupRightBarButton()
        }
        setupSettingsButton()

        let titleLabel = UILabel()
        titleLabel.text = L.history()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.CustomFont.largeTitleBold
        titleLabel.textAlignment = .left
        titleLabel.sizeToFit()

        let leftItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftItem
        view.backgroundColor = UIColor.bgMain

        drawSelf()

        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        selectorView.delegate = self

        loadAllVideoModels()
    }

    private func loadAllVideoModels() {
        let allVideoModels = StorageManager.shared.loadGeneratedVideos().reversed()
        if selectedIndex == 0 {
            videoModels = allVideoModels.filter { $0.source == .api1 }
        } else {
            videoModels = allVideoModels.filter { $0.source == .api2 }
        }

        collectionView.reloadData()
        updateViewForEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllVideoModels()
    }

    private func setupRightBarButton() {
        let proButtonView = createCustomProButton()
        let proBarButtonItem = UIBarButtonItem(customView: proButtonView)
        navigationItem.rightBarButtonItems = [proBarButtonItem]
    }

    private func createCustomProButton() -> UIView {
        let customButtonView = UIView()
        customButtonView.layer.cornerRadius = 8
        customButtonView.clipsToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 249 / 255, green: 171 / 255, blue: 251 / 255, alpha: 1).cgColor,
                                UIColor(red: 151 / 255, green: 208 / 255, blue: 248 / 255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 8

        customButtonView.layer.insertSublayer(gradientLayer, at: 0)

        let iconImageView = UIImageView(image: R.image.home_pro_icon())
        iconImageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = L.getPro().uppercased()
        label.textColor = UIColor.labelsPrimaryInverted
        label.font = UIFont.CustomFont.subheadlineSemibold

        let stackView = UIStackView(arrangedSubviews: [label, iconImageView])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center

        customButtonView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(4)
        }

        customButtonView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(113)
        }

        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(customProButtonTapped(_:)))
        customButtonView.addGestureRecognizer(tapGesture)

        DispatchQueue.main.async {
            gradientLayer.frame = customButtonView.bounds
        }

        return customButtonView
    }

    @objc private func customProButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let buttonView = sender.view else { return }

        UIView.animate(withDuration: 0.05, animations: {
            buttonView.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                buttonView.alpha = 1.0
            }
        }

        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }

    private func setupSettingsButton() {
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(R.image.home_set_icon(), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        settingsButton.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)

        if let rightBarButtons = navigationItem.rightBarButtonItems {
            navigationItem.rightBarButtonItems = [settingsBarButtonItem] + rightBarButtons
        } else {
            navigationItem.rightBarButtonItems = [settingsBarButtonItem]
        }
    }

    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    private func drawSelf() {
        selectorView.updateFirstLabel("AiVideo")
        selectorView.updateSecondLabel("AIEffects")

        view.addSubviews(selectorView, collectionView, emptyHistoryView)

        selectorView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(selectorView.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
        }

        emptyHistoryView.snp.makeConstraints { make in
            make.top.equalTo(selectorView.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
            make.height.equalTo(115)
            make.width.equalTo(280)
        }
    }

    private func updateViewForEmptyState() {
        if videoModels.isEmpty {
            emptyHistoryView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyHistoryView.isHidden = true
            collectionView.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HistoryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else {
            return UICollectionViewCell()
        }
        let video = videoModels[indexPath.item]
        cell.configure(with: video)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedVideo = videoModels[indexPath.item]
        if selectedVideo.isFinished {
            let resultVC = ResultViewController(model: selectedVideo, generationCount: 1, fromGeneration: true)
            let navigationController = UINavigationController(rootViewController: resultVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: L.videoNotReady(),
                message: L.videoNotReadyMessage(),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.overrideUserInterfaceStyle = .dark
            present(alert, animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width)
        let height = UIScreen.main.bounds.height * (230.0 / 844.0)
        return CGSize(width: width, height: height)
    }
}

// MARK: - SelectorDelegate
extension HistoryViewController: SelectorDelegate {
    func didSelect(at index: Int) {
        selectedIndex = index
        loadAllVideoModels()
    }
}
