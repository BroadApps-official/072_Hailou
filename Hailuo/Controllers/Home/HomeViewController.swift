import ApphudSDK
import AVFoundation
import MobileCoreServices
import SnapKit
import UIKit
import UniformTypeIdentifiers

final class HomeViewController: UIViewController {
    private let purchaseManager = PurchaseManager()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var filters: [Filter] = []
    private var selectedfilter: Filter?

    private let imageVideoView = UpperView(type: .image)
    private let textVideoView = UpperView(type: .text)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

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
        titleLabel.text = L.home()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.CustomFont.largeTitleBold
        titleLabel.textAlignment = .left
        titleLabel.sizeToFit()

        let leftItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftItem
        view.backgroundColor = UIColor.bgMain

        drawSelf()
        NotificationCenter.default.addObserver(self, selector: #selector(filtersLoaded(_:)), name: NSNotification.Name("FiltersLoaded"), object: nil)

        loadCachedFilters()
        updateFilterGenerations()
        updatePromptGenerations()
    }

    private func loadCachedFilters() {
        if let data = UserDefaults.standard.data(forKey: "cachedFilters") {
            do {
                filters = try JSONDecoder().decode([Filter].self, from: data)
                updateActivityIndicatorVisibility()
                collectionView.reloadData()
            } catch {
                print("Filter decoding error: \(error)")
            }
        }
    }

    @objc private func filtersLoaded(_ notification: Notification) {
        if let filters = notification.userInfo?["filters"] as? [Filter] {
            self.filters = filters
            collectionView.reloadData()
        }
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

    private func drawSelf() {
        activityIndicator.color = UIColor.accentPrimary
        updateActivityIndicatorVisibility()

        imageVideoView.do { make in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageVideoTapped))
            make.addGestureRecognizer(tapGesture)
        }

        textVideoView.do { make in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textVideoTapped))
            make.addGestureRecognizer(tapGesture)
        }

        view.addSubviews(imageVideoView, textVideoView, collectionView, activityIndicator)

        imageVideoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(91)
            make.width.equalToSuperview().dividedBy(2).offset(-22)
        }

        textVideoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(91)
            make.width.equalToSuperview().dividedBy(2).offset(-22)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(textVideoView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func updateActivityIndicatorVisibility() {
        if filters.isEmpty {
            activityIndicator.startAnimating()
            navigationController?.navigationBar.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            navigationController?.navigationBar.isHidden = false
        }
    }

    @objc func imageVideoTapped() {
        let createVC = CreateViewController(selectedIndex: 0)
        let navigationController = UINavigationController(rootViewController: createVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    @objc func textVideoTapped() {
        let createVC = CreateViewController(selectedIndex: 1)
        let navigationController = UINavigationController(rootViewController: createVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Update Last Promp Generations
    private func updatePromptGenerations() {
        var recentVideos = getLastGeneratedPromptVideos()
        if var lastVideo = recentVideos.last {
            Task {
                let isFinished = await checkVideoTaskStatus(videoId: lastVideo.id, generatedVideo: &lastVideo, prompt: lastVideo.prompt)

                if isFinished {
                    if let index = recentVideos.firstIndex(where: { $0.id == lastVideo.id }) {
                        recentVideos[index] = lastVideo
                    }
                }
            }
        }
    }

    private func getLastGeneratedPromptVideos() -> [GeneratedVideo] {
        guard let data = UserDefaults.standard.data(forKey: "lastGeneratedVideoDataWithPrompt") else { return [] }
        return (try? JSONDecoder().decode([GeneratedVideo].self, from: data)) ?? []
    }

    private func removePromptGeneratedVideo(_ video: GeneratedVideo) {
        var lastGeneratedVideos = getLastGeneratedPromptVideos()
        lastGeneratedVideos.removeAll { $0.id == video.id }

        if let encodedData = try? JSONEncoder().encode(lastGeneratedVideos) {
            UserDefaults.standard.set(encodedData, forKey: "lastGeneratedVideoDataWithPrompt")
        }
    }

    private func checkVideoTaskStatus(videoId: String, generatedVideo: inout GeneratedVideo, prompt: String?) async -> Bool {
        while true {
            do {
                let videoStatus = try await NetworkService.shared.checkVideoTaskStatus(videoId: videoId)

                if let isFinished = videoStatus["is_finished"] as? Bool, isFinished {
                    let videoUrl = try await NetworkService.shared.downloadVideoFile(videoId: videoId, prompt: prompt ?? "")
                    generatedVideo.isFinished = true
                    CacheManager.shared.saveGeneratedVideoModel(generatedVideo)
                    removePromptGeneratedVideo(generatedVideo)
                    await navigateToResultViewController(generatedVideo: generatedVideo)
                    return true
                }

                if let isInvalid = videoStatus["is_invalid"] as? Bool, isInvalid {
                    CacheManager.shared.deleteVideoModel(generatedVideo)
                    removePromptGeneratedVideo(generatedVideo)
                    showErrorAlert()
                    return true
                }

            } catch {
                CacheManager.shared.deleteVideoModel(generatedVideo)
                removePromptGeneratedVideo(generatedVideo)
                showErrorAlert()
                return true
            }

            try? await Task.sleep(nanoseconds: 5000000000)
        }
    }

    private func navigateToResultViewController(generatedVideo: GeneratedVideo) async {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
            var currentVC = rootViewController
            while let presentedVC = currentVC.presentedViewController {
                currentVC = presentedVC
            }
            let resultVC = ResultViewController(model: generatedVideo, generationCount: 1, fromGeneration: true)
            if let navigationController = currentVC as? UINavigationController {
                resultVC.modalPresentationStyle = .fullScreen
                navigationController.pushViewController(resultVC, animated: true)
            } else {
                let navigationController = UINavigationController(rootViewController: resultVC)
                navigationController.modalPresentationStyle = .fullScreen
                currentVC.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    private func showErrorAlert() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

            guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }

            var currentVC = rootViewController
            while let presentedVC = currentVC.presentedViewController {
                currentVC = presentedVC
            }

            let alert = UIAlertController(
                title: L.videoGenerationError(),
                message: L.tryDifferentPhoto(),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.overrideUserInterfaceStyle = .dark

            currentVC.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Update Last Filter Generations
    private func updateFilterGenerations() {
        let recentVideos = getLastFilterGeneratedVideos()
        if let lastVideo = recentVideos.last {
            Task {
                let updatedVideo = await pollGenerationStatus(generationId: Int(lastVideo.id) ?? 0, videoModel: lastVideo)
            }
        }
    }

    private func getLastFilterGeneratedVideos() -> [GeneratedVideo] {
        guard let data = UserDefaults.standard.data(forKey: "lastGeneratedVideoData") else { return [] }
        return (try? JSONDecoder().decode([GeneratedVideo].self, from: data)) ?? []
    }

    private func removeFilterGeneratedVideo(_ video: GeneratedVideo) {
        var lastGeneratedVideos = getLastFilterGeneratedVideos()
        lastGeneratedVideos.removeAll { $0.id == video.id }

        if let encodedData = try? JSONEncoder().encode(lastGeneratedVideos) {
            UserDefaults.standard.set(encodedData, forKey: "lastGeneratedVideoData")
        }
    }

    private func pollGenerationStatus(generationId: Int, videoModel: GeneratedVideo) async -> GeneratedVideo {
        var updatedVideoModel = videoModel
        while true {
            do {
                let statusData = try await NetworkService.shared.getGenerationStatus(generationId: generationId)
                if updatedVideoModel.id != String(generationId) {
                    removeFilterGeneratedVideo(updatedVideoModel)
                    showErrorAlert()
                    CacheManager.shared.deleteVideoModel(updatedVideoModel)
                    return updatedVideoModel
                }

                if statusData.status == 3 {
                    updatedVideoModel.isFinished = true
                    updatedVideoModel.videoURL = statusData.result

                    CacheManager.shared.saveGeneratedVideoModel(updatedVideoModel)
                    removeFilterGeneratedVideo(updatedVideoModel)
                    await navigateToResultViewController(generatedVideo: updatedVideoModel)
                    return updatedVideoModel
                } else if statusData.status == -1 || statusData.status == 4 {
                    removeFilterGeneratedVideo(updatedVideoModel)
                    showErrorAlert()
                    CacheManager.shared.deleteVideoModel(updatedVideoModel)
                    return updatedVideoModel
                }
            } catch {
                showErrorAlert()
                CacheManager.shared.deleteVideoModel(updatedVideoModel)
                return updatedVideoModel
            }

            try? await Task.sleep(nanoseconds: 5000000000)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell else {
            return UICollectionViewCell()
        }
        let filter = filters[indexPath.item]
        cell.configure(with: filter)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.item]
        selectedfilter = selectedFilter

        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = CGAffineTransform.identity
                }
            }
        }

        let filterVC = OpenFilterViewController(model: selectedFilter)
        let navigationController = UINavigationController(rootViewController: filterVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 2) - 6
        return CGSize(width: width, height: 230)
    }
}
