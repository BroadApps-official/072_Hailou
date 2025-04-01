import ApphudSDK
import AVFoundation
import MobileCoreServices
import SnapKit
import UIKit
import UniformTypeIdentifiers

final class CreateViewController: UIViewController {
    private let purchaseManager = PurchaseManager()
    private var selectedIndex: Int

    private var selectorView: SelectorView
    private let promtView = TextView(type: .promt)

    private var selectedImage: UIImage?
    private var selectedImagePath: String?
    private let createButton = HailuoButton()
    private let selectImageView = SelectImageView()

    private let maxGenerationCount = 2

    init(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        selectorView = SelectorView(selectedIndex: selectedIndex, frame: .zero)
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

        setupTitle()
        setupBackButton()
        if !purchaseManager.hasUnlockedPro {
            setupProButton()
        }

        view.backgroundColor = UIColor.bgMain

        drawSelf()
        updateViewVisibility()
        selectorView.delegate = self

        let textFields = [promtView.textField]
        let textViews = [promtView.textView]
        let textFieldsToMove = [promtView.textField]
        let textViewsToMove = [promtView.textView]

        KeyboardManager.shared.configureKeyboard(
            for: self,
            targetView: view,
            textFields: textFields,
            textViews: textViews,
            moveFor: textFieldsToMove,
            moveFor: textViewsToMove,
            with: .done
        )

        promtView.delegate = self
        selectImageView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGenerateButtonState()
    }

    private func setupTitle() {
        navigationItem.title = "AI Create"
        if let titleLabel = navigationController?.navigationBar.topItem?.titleView as? UILabel {
            titleLabel.font = UIFont.CustomFont.title1Bold
            titleLabel.textColor = .white
        } else {
            let titleLabel = UILabel()
            titleLabel.text = "AI Create"
            titleLabel.font = UIFont.CustomFont.title1Bold
            titleLabel.textColor = .white
            navigationItem.titleView = titleLabel
        }
    }

    private func setupBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(R.image.set_back_button(), for: .normal)
        backButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func setupProButton() {
        let proButton = UIButton(type: .custom)
        proButton.setImage(R.image.set_pro_button(), for: .normal)
        proButton.addTarget(self, action: #selector(customProButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: proButton)
    }

    private func drawSelf() {
        createButton.do { make in
            createButton.createOffMode()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCreateButton))
            make.addGestureRecognizer(tapGesture)
        }
        view.addSubviews(selectorView)
        selectorView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
    }

    private func updateViewVisibility() {
        view.addSubviews(promtView, selectImageView, createButton)
        if selectedIndex == 0 {
            promtView.isHidden = false
            selectImageView.isHidden = false

            selectImageView.snp.remakeConstraints { make in
                make.top.equalTo(selectorView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(160)
            }

            promtView.snp.remakeConstraints { make in
                make.top.equalTo(selectImageView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(160)
            }

            createButton.snp.makeConstraints { make in
                make.top.equalTo(promtView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(48)
            }
        } else {
            promtView.isHidden = false
            selectImageView.isHidden = true

            selectImageView.snp.remakeConstraints { make in
                make.top.equalTo(selectorView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(160)
            }

            promtView.snp.remakeConstraints { make in
                make.top.equalTo(selectorView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(340)
            }

            createButton.snp.makeConstraints { make in
                make.top.equalTo(promtView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(48)
            }
        }

        selectImageView.layoutIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setupTextView() {
        promtView.textView.delegate = self
    }

    private func updateGenerateButtonState() {
        if getActiveGenerationCount() >= maxGenerationCount {
            createButton.createOffMode()
            return
        }

        let promptFilled = !promtView.textView.text.isEmpty
        let imageSelected = selectedImage != nil

        let isGenerationAllowed: Bool
        if selectedIndex == 0 {
            isGenerationAllowed = promptFilled && imageSelected
        } else {
            isGenerationAllowed = promptFilled
        }

        DispatchQueue.main.async {
            if isGenerationAllowed {
                self.createButton.createOnMode()
            } else {
                self.createButton.createOffMode()
            }
        }
    }

    @objc private func customProButtonTapped(_ sender: UIButton) {
        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }

    @objc private func openSubscription() {
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

    @objc private func selectButtonTapped() {
        showImagePickerController(sourceType: .photoLibrary)
    }

    @objc private func photoButtonTapped() {
        showImagePickerController(sourceType: .camera)
    }

    @objc private func didTapCreateButton() {
        if purchaseManager.hasUnlockedPro {
            startGeneration()
        } else {
            openSubscription()
        }
    }

    private func startGeneration() {
        let userId = Apphud.userID()
        let prompt = promtView.textView.text
        let imagePath: String? = selectedImagePath
        let appBundle = Bundle.main.bundleIdentifier ?? "unknown"
        var generatedVideo = GeneratedVideo(id: "", prompt: prompt, isFinished: false, source: .api1)

        if getActiveGenerationCount() >= maxGenerationCount {
            generationCountReached()
            return
        }
        updateGenerateButtonState()

        Task {
            do {
                var videoId: String?
                if selectedIndex == 0 {
                    videoId = try await NetworkService.shared.createVideoTask(
                        imagePath: imagePath,
                        userId: userId,
                        appBundle: appBundle,
                        prompt: prompt ?? ""
                    )
                } else if selectedIndex == 1 {
                    videoId = try await NetworkService.shared.createVideoTask(
                        imagePath: nil,
                        userId: userId,
                        appBundle: appBundle,
                        prompt: prompt ?? ""
                    )
                }

                guard let validVideoId = videoId else { return }
                generatedVideo.id = validVideoId
                let imagePathToSave = imagePath ?? ""
                let videoData: [String: Any] = ["videoId": validVideoId, "prompt": prompt, "imagePath": imagePathToSave]

                saveLastGeneratedVideoData(video: generatedVideo)
                CacheManager.shared.saveGeneratedVideoModel(generatedVideo)
                openGeneration()

                while !(await checkVideoTaskStatus(videoId: validVideoId, generatedVideo: &generatedVideo, prompt: prompt)) { }

            } catch {
                CacheManager.shared.deleteVideoModel(generatedVideo)
                showErrorAlert()
                removeGeneratedVideo(generatedVideo)
            }
        }
    }
    
    private func checkVideoTaskStatus(videoId: String, generatedVideo: inout GeneratedVideo, prompt: String?) async -> Bool {
        do {
            let videoStatus = try await NetworkService.shared.checkVideoTaskStatus(videoId: videoId)

            if let isFinished = videoStatus["is_finished"] as? Bool, isFinished {
                let videoUrl = try await NetworkService.shared.downloadVideoFile(videoId: videoId, prompt: prompt ?? "")
                generatedVideo.isFinished = true
                CacheManager.shared.saveGeneratedVideoModel(generatedVideo)
                removeGeneratedVideo(generatedVideo)
                await navigateToResultViewController(generatedVideo: generatedVideo)
                return true
            }

            if let isInvalid = videoStatus["is_invalid"] as? Bool, isInvalid {
                CacheManager.shared.deleteVideoModel(generatedVideo)
                removeGeneratedVideo(generatedVideo)
                showErrorAlert()
                return true
            }
            try await Task.sleep(nanoseconds: 5000000000)
        } catch {
            CacheManager.shared.deleteVideoModel(generatedVideo)
            removeGeneratedVideo(generatedVideo)
            showErrorAlert()
            return true
        }
        return false
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

    // MARK: - Last Two Generation
    private func getLastGeneratedVideos() -> [GeneratedVideo] {
        guard let data = UserDefaults.standard.data(forKey: "lastGeneratedVideoDataWithPrompt") else { return [] }
        return (try? JSONDecoder().decode([GeneratedVideo].self, from: data)) ?? []
    }

    private func saveLastGeneratedVideoData(video: GeneratedVideo) {
        var lastGeneratedVideos = getLastGeneratedVideos()
        if lastGeneratedVideos.count == 2 {
            lastGeneratedVideos.removeFirst()
        }
        lastGeneratedVideos.append(video)
        if let encodedData = try? JSONEncoder().encode(lastGeneratedVideos) {
            UserDefaults.standard.set(encodedData, forKey: "lastGeneratedVideoDataWithPrompt")
        }
    }

    private func removeGeneratedVideo(_ video: GeneratedVideo) {
        var lastGeneratedVideos = getLastGeneratedVideos()
        lastGeneratedVideos.removeAll { $0.id == video.id }

        if let encodedData = try? JSONEncoder().encode(lastGeneratedVideos) {
            UserDefaults.standard.set(encodedData, forKey: "lastGeneratedVideoDataWithPrompt")
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
}

// MARK: - SelectorDelegate
extension CreateViewController: SelectorDelegate {
    func didSelect(at index: Int) {
        selectedIndex = index
        updateViewVisibility()
        updateGenerateButtonState()
    }
}

// MARK: - AppTextFieldDelegate
extension CreateViewController: TextViewDelegate {
    func didTapTextField(type: TextView.TextType) {
        updateGenerateButtonState()
    }

    func didTapCopyButton() {
    }
}

// MARK: - UITextViewDelegate
extension CreateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateGenerateButtonState()
    }
}

// MARK: - SelectImageViewDelegate
extension CreateViewController: SelectImageViewDelegate {
    func didTapAddPhoto(sender: SelectImageView) {
        if purchaseManager.hasUnlockedPro {
            showImageSelectionAlert()
        } else {
            openSubscription()
        }
    }

    private func showImageSelectionAlert() {
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
            self.selectButtonTapped()
        }

        let takePhotoAction = UIAlertAction(
            title: L.takePhoto(),
            style: .default
        ) { _ in
            self.photoButtonTapped()
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

// MARK: - UIImagePickerControllerDelegate
extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            let resizedImage = resizeImageIfNeeded(image: selectedImage, maxWidth: 1260, maxHeight: 760)
            self.selectedImage = resizedImage
            selectImageView.addImage(image: selectedImage)

            if let imageURL = info[.imageURL] as? URL {
                selectedImagePath = imageURL.path
            } else {
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")

                if let imageData = resizedImage.jpegData(compressionQuality: 1.0) {
                    do {
                        try imageData.write(to: tempFileURL)
                        selectedImagePath = tempFileURL.path
                    } catch {
                        print("Failed to save camera photo to temporary directory: \(error)")
                        selectedImagePath = nil
                    }
                }
            }
        }
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

        if let resizedImage = resizedImage {
            if let jpegData = resizedImage.jpegData(compressionQuality: 1.0) {
                print("JPEG Size: \(jpegData.count / 1024) KB")
            }
            if let pngData = resizedImage.pngData() {
                print("PNG Size: \(pngData.count / 1024) KB")
            }
        } else {
            print("Failed to resize image")
        }

        return resizedImage ?? image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let templatesUpdated = Notification.Name("templatesUpdated")
}

extension CreateViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillShow(notification as Notification)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        KeyboardManager.shared.keyboardWillHide(notification as Notification)
    }
}
