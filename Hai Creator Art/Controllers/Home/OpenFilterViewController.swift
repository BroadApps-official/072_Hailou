import ApphudSDK
import AVKit
import SnapKit
import StoreKit
import UIKit

final class OpenFilterViewController: UIViewController {
    private let model: Filter
    private var modelURL: String?

    private let videoView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isVideoPlaying = false

    private var selectorView = SelectorView(selectedIndex: 0, frame: .zero)
    private var selectedIndex: Int = 0

    private let createButton = HailuoButton()
    private let selectImageView = SelectImageView()
    private let selectFirstDoubleImageView = SelectImageView()
    private let selectSecondDoubleImageView = SelectImageView()
    private var activeImageViewTag: Int?
    private let purchaseManager = PaymentManager()

    private var selectedImage: UIImage?
    private var selectedFirstDoubleImage: UIImage?
    private var selectedSecondDoubleImage: UIImage?
    private var selectedImagePath: String?
    private var selectedFirstDoubleImagePath: String?
    private var selectedSecondDoubleImagePath: String?

    private let maxGenerationCount = 2

    init(model: Filter) {
        self.model = model
        modelURL = model.preview
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        view.backgroundColor = UIColor.bgPrimary
        setupBackButton()
        drawself()
        updateCreateButtonState()

        selectImageView.delegate = self
        selectFirstDoubleImageView.delegate = self
        selectSecondDoubleImageView.delegate = self
        selectorView.delegate = self

        selectImageView.tag = 1
        selectFirstDoubleImageView.tag = 2
        selectSecondDoubleImageView.tag = 3
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }

    private func layoutSubviews() {
        DispatchQueue.main.async { [weak self] in
            self?.playerLayer?.frame = self?.videoView.bounds ?? CGRect.zero
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoView.snp.updateConstraints { make in
            make.height.equalTo(UIScreen.main.bounds.height - 324 - view.safeAreaInsets.bottom)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCreateButtonState()
    }
    
    private func drawself() {
        selectorView.updateFirstLabel(L.singlePhoto())
        selectorView.updateSecondLabel(L.groupPhoto())

        let template = model
        setupVideo(for: model)

        createButton.do { make in
            if purchaseManager.hasUnlockedPro {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startGeneration))
                make.addGestureRecognizer(tapGesture)
            } else {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSubVC))
                make.addGestureRecognizer(tapGesture)
            }
        }
        selectFirstDoubleImageView.isHidden = true
        selectSecondDoubleImageView.isHidden = true

        view.addSubviews(
            videoView, createButton, selectorView,
            selectImageView, selectFirstDoubleImageView,
            selectSecondDoubleImageView, createButton
        )

        videoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height - 324 - view.safeAreaInsets.bottom)
        }

        createButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        selectorView.snp.makeConstraints { make in
            make.bottom.equalTo(selectImageView.snp.top).offset(-12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        selectFirstDoubleImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(createButton.snp.top).offset(-20)
            make.height.equalTo(160)
            make.width.equalTo(selectorView.snp.width).dividedBy(2).offset(-6)
        }

        selectSecondDoubleImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(createButton.snp.top).offset(-20)
            make.height.equalTo(160)
            make.width.equalTo(selectorView.snp.width).dividedBy(2).offset(-6)
        }
        selectImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(createButton.snp.top).offset(-20)
            make.height.equalTo(160)
        }

        createButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(48)
        }
    }

    private func updateViewVisibility() {
        if selectedIndex == 0 {
            selectFirstDoubleImageView.isHidden = true
            selectSecondDoubleImageView.isHidden = true
            selectImageView.isHidden = false
        } else if selectedIndex == 1 {
            selectFirstDoubleImageView.isHidden = false
            selectSecondDoubleImageView.isHidden = false
            selectImageView.isHidden = true
        }
    }

    private func updateCreateButtonState() {
        if getActiveGenerationCount() >= maxGenerationCount {
            createButton.createOffMode()
            return
        }

        if selectedIndex == 0 {
            if selectedImage == nil {
                createButton.createOffMode()
            } else {
                createButton.createOnMode()
            }
        } else if selectedIndex == 1 {
            if selectedFirstDoubleImage != nil && selectedSecondDoubleImage != nil {
                createButton.createOnMode()
            } else {
                createButton.createOffMode()
            }
        }
    }

    private func setupBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(R.image.set_back_button(), for: .normal)
        backButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func openExampleVC() {
        let hasOpenedExample = UserDefaults.standard.bool(forKey: "hasOpenedExample")
        if hasOpenedExample {
            return
        }

        let exampleVC = ExampleViewController()
        if let sheet = exampleVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(exampleVC, animated: true)
        UserDefaults.standard.set(true, forKey: "hasOpenedExample")
    }

    @objc private func openSubVC() {
        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }

    @objc private func openGeneration() {
        let generationVC = GenerationTimeViewController()
        let navigationController = UINavigationController(rootViewController: generationVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }

    // MARK: - Video Logic
    private func setupVideo(for filter: Filter) {
        guard let videoURL = StorageManager.shared.loadVideoURLFromCache(fileName: "\(filter.id)_preview.mp4") else {
            return
        }
        playVideo(from: videoURL)
    }

    private func playVideo(from url: URL) {
        guard !isVideoPlaying else {
            return
        }

        if player == nil {
            player = AVPlayer(url: url)
        }
        player?.volume = 0
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            DispatchQueue.main.async { [weak self] in
                self?.playerLayer?.frame = self?.videoView.bounds ?? CGRect.zero
                if self?.playerLayer?.superlayer == nil {
                    self?.videoView.layer.addSublayer(self?.playerLayer ?? CALayer())
                }
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }

    @objc private func restartVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    private func prepareForReuse() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        isVideoPlaying = false
    }

    // MARK: - Generation Work
    @objc private func startGeneration() {
        var finalImage: UIImage?
        var finalImagePath: String?
        var filterId = "\(model.id)"

        if getActiveGenerationCount() >= maxGenerationCount {
            generationCountReached()
            return
        }

        if selectedIndex == 1 {
            guard let firstImage = selectedFirstDoubleImage, let secondImage = selectedSecondDoubleImage else {
                print("Both images must be selected for double mode")
                return
            }

            if let mergedImage = mergeImagesHorizontally(leftImage: firstImage, rightImage: secondImage) {
                finalImage = mergedImage
                finalImagePath = saveImageToTemporaryDirectory(mergedImage)?.path
            } else {
                print("Failed to merge images")
                return
            }
        } else {
            guard let selectedImage = selectedImage, let selectedImagePath = selectedImagePath else {
                print("No image selected")
                return
            }
            finalImage = selectedImage
            finalImagePath = selectedImagePath
        }

        guard let finalImage else {
            print("Error: No final image")
            return
        }

        var generatedVideo: GeneratedVideo?

        Task {
            do {
                let generationId = try await DataClient.shared.generateVideo(from: finalImage, filterID: filterId)
                generatedVideo = GeneratedVideo(
                    id: String(generationId),
                    prompt: nil,
                    isFinished: false,
                    source: .api2,
                    name: model.title
                )

                if let generatedVideo = generatedVideo {
                    saveLastGeneratedVideoData(video: generatedVideo)
                    StorageManager.shared.saveGeneratedVideoModel(generatedVideo)
                }
                openGeneration()

                if let generatedVideo = generatedVideo {
                    await pollGenerationStatus(generationId: generationId, videoModel: generatedVideo)
                }
            } catch {
                generationError()
                if let generatedVideo = generatedVideo {
                    StorageManager.shared.deleteVideoModel(generatedVideo)
                    removeGeneratedVideo(generatedVideo)
                }
            }
        }
    }

    private func pollGenerationStatus(generationId: Int, videoModel: GeneratedVideo) async -> GeneratedVideo {
        var updatedVideoModel = videoModel
        while true {
            do {
                let statusData = try await DataClient.shared.getGenerationStatus(generationId: generationId)
                if updatedVideoModel.id != String(generationId) {
                    removeGeneratedVideo(updatedVideoModel)
                    generationError()
                    StorageManager.shared.deleteVideoModel(updatedVideoModel)
                    updateCreateButtonState()
                    return updatedVideoModel
                }
                if statusData.status == 3 {
                    updatedVideoModel.isFinished = true
                    updatedVideoModel.videoURL = statusData.result

                    StorageManager.shared.saveGeneratedVideoModel(updatedVideoModel)
                    removeGeneratedVideo(updatedVideoModel)
                    updateCreateButtonState()
                    await navigateToResultViewController(generatedVideo: updatedVideoModel)
                    return updatedVideoModel
                } else if statusData.status == -1 || statusData.status == 4 {
                    removeGeneratedVideo(updatedVideoModel)
                    generationError()
                    StorageManager.shared.deleteVideoModel(updatedVideoModel)
                    updateCreateButtonState()
                    return updatedVideoModel
                }
            } catch {
                generationError()
                StorageManager.shared.deleteVideoModel(updatedVideoModel)
                updateCreateButtonState()
                return updatedVideoModel
            }

            try? await Task.sleep(nanoseconds: 5000000000)
        }
    }

    private func generationError() {
        let alert = UIAlertController(
            title: L.videoGenerationError(),
            message: L.tryDifferentPhoto(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true, completion: nil)
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

    // MARK: - Last Two Generation
    private func getLastGeneratedVideos() -> [GeneratedVideo] {
        guard let data = UserDefaults.standard.data(forKey: "lastGeneratedVideoData") else { return [] }
        return (try? JSONDecoder().decode([GeneratedVideo].self, from: data)) ?? []
    }

    private func saveLastGeneratedVideoData(video: GeneratedVideo) {
        var lastGeneratedVideos = getLastGeneratedVideos()
        if lastGeneratedVideos.count == 2 {
            lastGeneratedVideos.removeFirst()
        }
        lastGeneratedVideos.append(video)
        if let encodedData = try? JSONEncoder().encode(lastGeneratedVideos) {
            UserDefaults.standard.set(encodedData, forKey: "lastGeneratedVideoData")
        }
    }

    private func removeGeneratedVideo(_ video: GeneratedVideo) {
        var lastGeneratedVideos = getLastGeneratedVideos()
        lastGeneratedVideos.removeAll { $0.id == video.id }

        if let encodedData = try? JSONEncoder().encode(lastGeneratedVideos) {
            UserDefaults.standard.set(encodedData, forKey: "lastGeneratedVideoData")
        }
    }

    // MARK: - Active Two Generations
    private func getActiveGenerationCount() -> Int {
        return getLastGeneratedVideos().filter { !$0.isFinished }.count
    }

    private func generationCountReached() {
        let alert = UIAlertController(
            title: L.generationLimitReached(),
            message: L.generationLimitReachedMessage(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Image Logic
    @objc private func selectButtonTapped(sender: SelectImageView) {
        activeImageViewTag = sender.tag
        showImagePickerController(sourceType: .photoLibrary)
    }

    @objc private func photoButtonTapped(sender: SelectImageView) {
        activeImageViewTag = sender.tag
        showImagePickerController(sourceType: .camera)
    }

    private func mergeImagesHorizontally(leftImage: UIImage, rightImage: UIImage) -> UIImage? {
        let newWidth = leftImage.size.width + rightImage.size.width
        let newHeight = max(leftImage.size.height, rightImage.size.height)

        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)

        leftImage.draw(in: CGRect(x: 0, y: 0, width: leftImage.size.width, height: newHeight))
        rightImage.draw(in: CGRect(x: leftImage.size.width, y: 0, width: rightImage.size.width, height: newHeight))

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage
    }

    private func saveImageToTemporaryDirectory(_ image: UIImage) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: fileURL)
                return fileURL
            } else {
                print("Failed to convert image to JPEG")
            }
        } catch {
            print("Failed to save image to temporary directory: \(error)")
        }

        return nil
    }

    private func saveImageToPermanentDirectory(_ image: UIImage) -> URL? {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpg"

        let fileURL = cachesDirectory.appendingPathComponent(fileName)

        do {
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: fileURL)
                return fileURL
            } else {
                print("Failed to convert image to JPEG")
            }
        } catch {
            print("Failed to save image to caches directory: \(error)")
        }

        return nil
    }
}

// MARK: - SelectImageViewDelegate
extension OpenFilterViewController: SelectImageViewDelegate {
    func didTapAddPhoto(sender: SelectImageView) {
        if !purchaseManager.hasUnlockedPro {
            openSubVC()
        } else {
            if selectedIndex == 1 {
                openExampleVC()
            }

            let alert = UIAlertController(
                title: L.selectAction(),
                message: L.selectActionSublabel(),
                preferredStyle: .actionSheet
            )

            alert.overrideUserInterfaceStyle = .dark

            let selectFromGalleryAction = UIAlertAction(
                title: L.selectGallery(),
                style: .default
            ) { _ in
                self.selectButtonTapped(sender: sender)
            }

            let takePhotoAction = UIAlertAction(
                title: L.takePhoto(),
                style: .default
            ) { _ in
                self.photoButtonTapped(sender: sender)
            }

            let cancelAction = UIAlertAction(
                title: L.cancel(),
                style: .cancel
            )

            alert.addAction(selectFromGalleryAction)
            alert.addAction(takePhotoAction)
            alert.addAction(cancelAction)

            if UIDevice.isIpad {
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = view
                    popoverController.sourceRect = CGRect(
                        x: view.bounds.midX,
                        y: view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popoverController.permittedArrowDirections = []
                }
            }

            present(alert, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension OpenFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            let resizedImage = resizeImageIfNeeded(image: selectedImage, maxWidth: 1260, maxHeight: 760)

            if let activeTag = activeImageViewTag {
                switch activeTag {
                case 1:
                    self.selectedImage = resizedImage
                    selectImageView.addImage(image: selectedImage)
                case 2:
                    selectedFirstDoubleImage = resizedImage
                    selectFirstDoubleImageView.addImage(image: selectedImage)
                case 3:
                    selectedSecondDoubleImage = resizedImage
                    selectSecondDoubleImageView.addImage(image: selectedImage)
                default:
                    break
                }
            }

            var imagePath: String?

            if let imageURL = info[.imageURL] as? URL {
                imagePath = imageURL.path
            } else {
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")

                if let imageData = resizedImage.jpegData(compressionQuality: 1.0) {
                    do {
                        try imageData.write(to: tempFileURL)
                        imagePath = tempFileURL.path
                    } catch {
                        print("Failed to save camera photo to temporary directory: \(error)")
                        imagePath = nil
                    }
                }
            }

            if let activeTag = activeImageViewTag {
                switch activeTag {
                case 1:
                    selectedImagePath = imagePath
                case 2:
                    selectedFirstDoubleImagePath = imagePath
                case 3:
                    selectedSecondDoubleImagePath = imagePath
                default:
                    break
                }
            }
        }
        updateCreateButtonState()
        picker.dismiss(animated: true)
    }

    func resizeImageIfNeeded(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height

        let widthRatio = maxWidth / originalWidth
        let heightRatio = maxHeight / originalHeight

        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: originalWidth * scaleFactor, height: originalHeight * scaleFactor)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SelectorDelegate
extension OpenFilterViewController: SelectorDelegate {
    func didSelect(at index: Int) {
        selectedIndex = index
        updateViewVisibility()
        updateCreateButtonState()
    }
}
