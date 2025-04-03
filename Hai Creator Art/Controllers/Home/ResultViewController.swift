import AVFoundation
import AVKit
import SnapKit
import UIKit

protocol ResultViewControllerDelegate: AnyObject {
    func didTapCloseButton()
}

final class ResultViewController: UIViewController {
    // MARK: - Properties

    private let backButton = UIButton(type: .system)
    private let menuButton = UIButton(type: .system)

    private let playButton = UIButton()
    let blurEffect = UIBlurEffect(style: .light)
    private let blurEffectView: UIVisualEffectView

    private var playerViewController: AVPlayerViewController?
    private var player: AVPlayer?
    private var generatedURL: String?
    private var model: GeneratedVideo
    private let generationCount: Int
    private var fromGeneration: Bool
    private var aspectRatio: CGFloat = 15 / 9
    private var isPlaying = false

    private let promptView = TextView(type: .description)
    private let saveButton = HailuoButton()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let underView = UIView()
    private let effectNameLabel = UILabel()

    weak var delegate: ResultViewControllerDelegate?

    // MARK: - Init
    init(model: GeneratedVideo, generationCount: Int, fromGeneration: Bool) {
        self.model = model
        self.generationCount = generationCount
        self.fromGeneration = fromGeneration
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.CustomFont.bodySemibold,
            .foregroundColor: UIColor.labelsPrimary
        ]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        setupBackButton()
        setupMenuButton()
        view.backgroundColor = UIColor.bgPrimary

        drawSelf()
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        addTapGesture(to: saveButton, action: #selector(saveButtonTapped))
        promptView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        promptView.textView.text = model.prompt
        view.bringSubviewToFront(saveButton)
    }

    private func drawSelf() {
        saveButton.setTitle(to: L.save())
        promptView.textView.isScrollEnabled = false
        promptView.alpha = model.source == .api2 ? 0.0 : 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        blurEffectView.do { make in
            make.layer.cornerRadius = 32
            make.layer.masksToBounds = true
        }

        playButton.do { make in
            make.setImage(R.image.main_play_icon(), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        }

        guard let videoURL = StorageManager.shared.getVideo(for: model) else {
            print("Video is not in cache")
            return
        }

        let asset = AVAsset(url: videoURL)
        let track = asset.tracks(withMediaType: .video).first

        if let naturalSize = track?.naturalSize {
            let width = naturalSize.width
            let height = naturalSize.height
            aspectRatio = width / height
        }

        player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        if let playerVC = playerViewController {
            addChild(playerVC)
            contentView.addSubview(playerVC.view)
            playerVC.videoGravity = .resizeAspectFill
            playerVC.view.layer.cornerRadius = 20
            playerVC.view.layer.masksToBounds = true
            playerVC.didMove(toParent: self)
            playerVC.showsPlaybackControls = false
            playerVC.view.isUserInteractionEnabled = true
            addTapGesture(to: playerViewController!.view, action: #selector(didTapPlayButton))

            view.addSubview(saveButton)
            view.bringSubviewToFront(saveButton)
            view.addSubview(scrollView)

            scrollView.addSubview(contentView)
            contentView.addSubview(blurEffectView)
            contentView.addSubview(playButton)
            contentView.addSubviews(promptView)

            playerVC.view.snp.makeConstraints { make in
                make.top.equalTo(contentView.snp.top).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(view.snp.width).multipliedBy(1 / aspectRatio).offset(-66)
            }
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-8)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(promptView.snp.bottom).offset(16)
        }

        promptView.snp.makeConstraints { make in
            make.top.equalTo(playerViewController?.view.snp.bottom ?? view.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(160)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(48)
        }

        playButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(playerViewController?.view.snp.centerY ?? view.snp.centerY)
            make.size.equalTo(64)
        }

        blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(playButton.snp.edges)
        }
    }

    @objc private func didTapPlayButton() {
        if isPlaying {
            player?.pause()
            playButton.isHidden = false
            blurEffectView.isHidden = false
        } else {
            player?.play()
            playButton.isHidden = true
            blurEffectView.isHidden = true
        }
        isPlaying.toggle()
    }

    @objc private func didFinishPlaying() {
        player?.seek(to: .zero)
        playButton.isHidden = false
        blurEffectView.isHidden = false
        isPlaying = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupBackButton() {
        backButton.do { make in
            make.setImage(R.image.set_back_button()?.withRenderingMode(.alwaysOriginal), for: .normal)
            make.semanticContentAttribute = .forceLeftToRight
            make.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        }

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    private func setupMenuButton() {
        menuButton.do { make in
            make.setImage(R.image.result_menu_button()?.withRenderingMode(.alwaysOriginal), for: .normal)
            make.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        }

        let shareAction = UIAction(title: L.shareButton(), image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.shareVideo()
        }

        let saveToFileAction = UIAction(title: L.saveFiles(), image: UIImage(systemName: "folder.badge.plus")) { _ in
            self.saveToFiles()
        }

        let deleteAction = UIAction(title: L.delete(), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteVideo()
        }

        let menu = UIMenu(title: "", children: [shareAction, saveToFileAction, deleteAction])
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true

        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = menuBarButtonItem
    }

    @objc private func didTapMenuButton() {
        DispatchQueue.main.async {
            self.menuButton.overrideUserInterfaceStyle = .dark
        }
    }

    @objc private func didTapCloseButton() {
        if fromGeneration {
            if shouldOpenForGenerationCount(generationCount) {
                dismiss(animated: true) {
                    self.delegate?.didTapCloseButton()
                }
            } else {
                dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }

    private func shouldOpenForGenerationCount(_ count: Int) -> Bool {
        return count == 1 || count == 3 || count == 5 || count % 10 == 0
    }

    @objc private func saveButtonTapped() {
        guard let videoURL = StorageManager.shared.getVideo(for: model) else {
            videoGalleryErrorAlert()
            return
        }

        StorageManager.shared.saveVideoToGallery(videoURL: videoURL) { success in
            DispatchQueue.main.async {
                if success {
                    self.videoGallerySuccessAlert()
                } else {
                    self.videoGalleryErrorAlert()
                }
            }
        }
    }

    private func shareVideo() {
        guard let videoURL = StorageManager.shared.getVideo(for: model) else {
            print("Video doesn't exist.")
            return
        }

        if FileManager.default.fileExists(atPath: videoURL.path) {
            let activityViewController = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            present(activityViewController, animated: true)
        } else {
            print("Video doesn't exist.")
        }
    }

    private func saveToFiles() {
        guard let videoURL = StorageManager.shared.getVideo(for: model) else {
            videoFilesErrorAlert()
            return
        }

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let copyURL = documentsDirectory.appendingPathComponent(videoURL.lastPathComponent)

        do {
            if fileManager.fileExists(atPath: copyURL.path) {
                try fileManager.removeItem(at: copyURL)
            }
            try fileManager.copyItem(at: videoURL, to: copyURL)

            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(forExporting: [copyURL])
                documentPicker.delegate = self
                documentPicker.overrideUserInterfaceStyle = .dark
                self.present(documentPicker, animated: true)
            }
        } catch {
            videoFilesErrorAlert()
        }
    }

    @objc private func deleteVideo() {
        showAlert(
            title: L.deleteVideo(),
            message: L.deleteVideoMessage(),
            actionTitles: [L.delete(), L.cancel()],
            actions: [
                { StorageManager.shared.deleteVideoModel(self.model); self.dismiss(animated: true, completion: nil) }
            ]
        )
    }
}

// MARK: - UIDocumentPickerDelegate
extension ResultViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        videoFilesSuccessAlert()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        videoFilesErrorAlert()
    }
}

// MARK: - Alerts
extension ResultViewController {
    private func videoGallerySuccessAlert() {
        showAlert(
            title: L.videoSavedGallery(),
            message: nil,
            actionTitles: ["OK"],
            actions: [nil]
        )
    }

    private func videoGalleryErrorAlert() {
        showAlert(
            title: L.errorVideoGallery(),
            message: L.errorVideoGalleryMessage(),
            actionTitles: [L.cancel(), L.tryAgain()],
            actions: [{self.saveButtonTapped()}])
    }

    private func videoFilesSuccessAlert() {
        showAlert(
            title: L.videoSavedFiles(),
            message: nil,
            actionTitles: ["OK"],
            actions: [nil]
        )
    }

    private func videoFilesErrorAlert() {
        showAlert(
            title: L.errorVideoFiles(),
            message: L.errorVideoGalleryMessage(),
            actionTitles: [L.cancel(), L.tryAgain()],
            actions: [{self.saveToFiles()}])
    }
}

// MARK: - TextViewDelegate
extension ResultViewController: TextViewDelegate {
    func didTapTextField(type: TextView.TextType) {
    }

    func didTapCopyButton() {
        showAlert(
            title: L.textCopied(),
            message: nil,
            actionTitles: ["OK"],
            actions: [nil]
        )
    }
}

// MARK: - TapGesture
extension ResultViewController {
    private func addTapGesture(to view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - ShowAlert
extension ResultViewController {
    private func showAlert(title: String, message: String?, actionTitles: [String], actions: [(() -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default) { _ in
                actions[index]?()
            }
            alert.addAction(action)
        }
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}
